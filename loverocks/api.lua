----------------------
-- A well defined API for using luarocks.
-- This allows you to query the existing packages (@{show} and @{list}) and
-- packages on a remote repository (@{search}). Like the luarocks command-line
-- tool, you can specify the flags `from` and `only_from` for this function.
--
-- Local information is a table: @{local_info_table}.  Usually you get less
-- information for remote queries (basically, package, version and repo) but
-- setting the  flag `details` for @{search} will fill in more fields by
-- downloading the remote rockspecs - bear in mind that this can be slow for
-- large queries.
--
-- @author Steve Donovan
-- @license MIT/X11

local api = {}

local util = require("luarocks.util")
local _search = require("luarocks.search")
local deps = require("luarocks.deps")
local manif = require("luarocks.manif")
local manif_core = require("luarocks.manif_core")
local fetch = require("luarocks.fetch")
local _install = require("luarocks.install")
local build = require("luarocks.build")
local fs = require("luarocks.fs")
local path = require("luarocks.path")
local dir = require("luarocks.dir")
local _remove = require("luarocks.remove")

local log = require 'loverocks.log'
local lcfg = require 'loverocks.config'

local append = table.insert

local function version_iter (versions)
	return util.sortedpairs(versions, deps.compare_versions)
end

local function _latest(versions, first_repo)
	local version, repos = version_iter(versions)()
	local repo = repos[first_repo and 1 or #repos]
	return version, repo.repo
end

local function copy(t, into)
	for k, v in pairs(t) do
		if type(v) == 'table' then
			if not into[k] then into[k] = {} end
			copy(v, into[k])
		else
			into[k] = v
		end
	end
end

-- cool, let's initialize this baby. This is normally done by command_line.lua
-- Since cfg is a singleton, api has to be one too. So it goes.
local cfg = require("luarocks.cfg")

function api.apply_config(new)
	-- idea: instead of copying-in, we make package.preload["luarocks.cfg"]
	-- a mock table, and then push in and out prototypes to apply the config.
	copy(new, cfg)
end

local function use_tree(tree)
	cfg.root_dir = tree
	cfg.rocks_dir = path.rocks_dir(tree)
	cfg.deploy_bin_dir = path.deploy_bin_dir(tree)
	cfg.deploy_lua_dir = path.deploy_lua_dir(tree)
	cfg.deploy_lib_dir = path.deploy_lib_dir(tree)
end

local old_printout, old_printerr = util.printout, util.printerr
local path_sep = package.config:sub(1, 1)
local log_dir = path_sep=='\\' and os.getenv('TEMP') or '/tmp'
local log_name = log_dir..path_sep..'luarocks-api-log.txt'

function q_printout(...)
	log:info("L: %s", table.concat({...}, "\t"))
end

function q_printerr(...)
	log:_warning("L: %s", table.concat({...}, "\t"))
end

local project_cfg = nil
local cwd = nil
local function check_flags (flags)
	cwd = fs.current_dir()
	use_tree(cwd .. "/rocks")
	if not project_cfg then
		project_cfg = {}
		lcfg:open(cwd .. "/rocks/config.lua", project_cfg)
		api.apply_config(project_cfg)
	end

	manif_core.manifest_cache = {} -- clear cache
	flags._old_servers = cfg.rocks_servers
	if flags.from then
		table.insert(cfg.rocks_servers, 1, flags.from)
	elseif flags.only_from then
		cfg.rocks_servers = { flags.only_from }
	end
	util.printout = q_printout
	util.printerr = q_printerr
end

local function restore_flags (flags)
	assert(lfs.chdir(cwd))
	if flags.from then
		table.remove(cfg.rocks_servers, 1)
	elseif flags.only_from then
		cfg.rocks = flags._old_servers
	end
	util.printout = old_printout
	util.printerr = old_printerr
end

local manifests = {}

--- get the log file.
-- This is used when the `quiet` flag is specified.
-- @return full path to log file
function api.get_log_file ()
	return log_name
end

--- information returned by @{show} and @{list}.
-- @field package canonical name
-- @field repo the tree where found
-- @field version
-- @field rock_dir the full path to the rock
-- @field homepage
-- @field maintainer
-- @field license
-- @field summary
-- @field description
-- @field build_type (this is the rockspec's build.type)
-- @field modules modules provided by this package
-- @field dependencies packages that this package needs
-- @table local_info_table

--- known flag names for the `flags` parameter.
-- @field exact (bool) query pattern is an exact name (default false)
-- @field use_local use local rock tree, not global (default false)
-- @field from include this URL in @{search}
-- @field only_from only use this URL in @{search}
-- @field all get all version info with @{search}
-- Can use @{get_log_file} to find the name of the log.
-- @table flags

--- show information about an installed package.
-- @param name the package name
-- @param version version, may be nil
-- @param field one of the output fields
-- @return @{local_info_table}, or a string if field is specified.
-- @see show.lua
function api.show(name, version, field)
	local res, err = list (name, version, {exact = true})
	if not res then return nil, err end
	res = res[1]
	if field then return res[field]
	else return res
	end
end

--- list information about currently installed packages.
-- @param pattern a string which is partially matched against packages
-- @param version a specific version, may be nil.
-- @param flags @{flags}
-- @return list of @{local_info_table}
function api.list(pattern, version, flags)
	local results = {}
	flags = flags or {}
	if flags.rockspec == nil then flags.rockspec = true end
	if flags.manifest == nil then flags.manifest = true end
	pattern = pattern or ''
	local query = _search.make_query(pattern, version)
	query.exact_name = flags.exact == true

	local tree_map = {}
	for _, tree in ipairs(cfg.rocks_trees) do
		local rocks_dir = path.rocks_dir(tree)
		tree_map[rocks_dir] = tree
		_search.manifest_search(results, rocks_dir, query)
	end

	if not next(results) then
		return nil, "cannot find "..pattern..(version and (' '..version) or '')
	end

	local res = {}
	for name, versions in util.sortedpairs(results) do
		local version, repo_url = _latest(versions, false)
		local repo =  tree_map[repo_url]
		local directory = path.install_dir(name, version, repo)

		local descript, minfo, build_type
		if flags.rockspec then
			local rockspec_file = path.rockspec_file(name, version, repo)
			local rockspec, err = fetch.load_local_rockspec(rockspec_file)
			if rockspec then
				descript = rockspec.description
				build_type = rockspec.build.type
			end
		end
		if flags.manifest then
			local manifest = manifests[repo_url]
			if not manifest then -- cache these
				manifest = manif.load_manifest(repo_url)
				manifests[repo_url] = manifest
			end
			if manifest then
				minfo = manifest.repository[name][version][1]
			end
		end

		local entry =  {
			package = name,
			repo = repo,
			version = version,
			rock_dir = directory,
			homepage = descript and descript.homepage,
			license = descript and descript.license,
			maintainer = descript and descript.maintainer,
			summary = descript and descript.summary,
			description = descript and descript.detailed,
			build_type = build_type,
			modules = minfo and util.keys(minfo.modules),
			dependencies = minfo and util.keys(minfo.dependencies),
		}
		if flags.map then
			res[name] = entry
		else
			append(res, entry)
		end
	end
	return res

end

function api.search_extra (info)
	local url = path.make_url(info.repo,
	                          info.package,
	                          info.version,
	                          'rockspec')
	local rockspec, err = fetch.load_rockspec(url)
	if rockspec then
		local descript = rockspec.description
		info.homepage = descript.homepage
		info.license = descript.license
		info.maintainer = descript.maintainer
		info.summary = descript.summary
		info.description = descript.detailed
		info.build_type = rockspec.build.type
		local rdeps, odeps = rockspec.dependencies, {}
		for i, rdep in ipairs(rdeps) do
			odeps[i] = rdep.name
		end
		info.dependencies = odeps
		-- guessing the modules: this can be hit-and-miss
		-- It will often not work for the 'make' build type
		local build = rockspec.build
		if build.type == 'builtin' then
			local mods = build.modules
			info.modules = #mods > 0 and mods or util.keys(mods)
		elseif build.install and build.install.lua then
			local mods = build.install.lua
			info.modules = #mods > 0 and mods or util.keys(mods)
		end
		return true
	else
		return nil, err
	end
end

--- list information like @{list}, but return as a map.
-- @param pattern a string which is partially matched against packages
-- @param version a specific version, may be nil.
-- @param flags @{flags}
-- @return a map of package names -> @{local_info_table}
function api.list_map(pattern, version, flags)
	flags = flags or {}
	flags.map = true
	return list(pattern, version, flags)
end

--- is this package outdated?.
-- @{check.lua} shows how to compare installed and available packages.
-- @param linfo local info table
-- @param info server info table
-- @return true if the package is out of date.
function api.compare_versions (linfo, info)
	return deps.compare_versions(info.version, linfo.version)
end

--- search LuaRocks repositories for a package.
-- @param pattern a string which is partially matched against packages
-- @param version a specific version, may be nil.
-- @param flags @{flags} a table with keys
--  - 'all' means get all version information,
--  - 'from' to add another repository to the search
--  - 'only_from' to only search one repository
--  - 'details' get more information about each package
-- @return a list of server information.
--  - Without 'all', we get package, version and the remote server (repo)
--  - With 'all', instead of the repo we get versions, which is a list of
--    - version
--    - repos
--  - with 'details', you get pretty much what @{list} returns. Note that
--  this function will then have to download the remote rockspec for this,
--  and may not always be able to deduce the modules provided by a package.
-- @see search.lua
function api.search (pattern, version, flags)
	flags = flags or {}
	check_flags(flags)
	local query = _search.make_query((pattern or ''):lower(), version)
	query.exact_name = flags.exact == true
	local results, err = _search.search_repos(query)
	if not results then
		restore_flags(flags)
		return nil, err
	end
	local res = {}
	for package, versions in util.sortedpairs(results) do
		local rec
		if not flags.all then
			local version, repo = _latest(versions, true)
			rec = {
				package = package,
				version = version,
				repo = repo
			}
		else
			local vss = {}
			for vs, repos in version_iter (versions) do
				append(vss, {version=vs, repos=repos})
			end
			rec = {
				package = package,
				version = vss[1].version,
				versions = vss
			}
		end
		if flags.details then
			search_extra(rec)
		end
		if flags.map then
			res[package] = rec
		else
			append(res, rec)
		end
	end
	restore_flags(flags)
	return res
end

--- search repositories like @{search}, but return a map.
-- @param pattern a string which is partially matched against packages
-- @param version a specific version, may be nil.
-- @param flags @{flags}
-- @return a table of server information indexed by package name.
function api.search_map(pattern, version, flags)
	flags = flags or {}
	flags.map = true
	return search(pattern, version, flags)
end

--- install a rock.
-- @param name
-- @param version can ask for a specific version (default nil means get latest)
-- @param flags @{flags} `use_local` to install to local tree,
-- `from` to add another repository to the search and `only_from` to only use
-- the given repository
-- @return true if successful, nil if not.
-- @return error message if not
function api.install(name, version, flags)
	flags = flags or {}
	check_flags(flags)

	log:fs("luarocks install %s %s", name, version)
	local ok, err = _install.run(name, version)
	restore_flags(flags)
	return ok, err
end

--- remove a rock.
-- @param name
-- @param version a specific version (default nil means remove all)
function api.remove(name, version, flags)
	flags = flags or {}
	check_flags(flags)

	log:fs("luarocks remove %s %s", name, version)
	local ok, err = _remove.run(name, version)
	restore_flags(flags)
	return ok, err
end

--- Build a rock.
-- @param name
-- @param version
-- @param flags @{flags}
-- @return true if successful, nil if not
-- @return error message if not
function api.build(name, version, flags)
	flags = flags or {}
	check_flags(flags)
	local f = {}
	if version then table.insert(f, version) end
	if flags.only_deps then table.insert(f, "--only-deps") end

	log:fs("luarocks build %s %s", name, table.concat(f, " "))
	local ok, err = build.run(name, unpack(f))
	restore_flags(flags)
	return ok, err
end

return api
