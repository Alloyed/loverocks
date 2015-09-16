local util = require 'loverocks.util'
local log = require 'loverocks.log'
local api = require 'loverocks.api'

local install = {}

function install:build(parser)
	parser:description
		"Installs a package manually."
	parser:argument "packages"
		:args("+")
		:description
			"The packages to install."
	-- FIXME: merge -a and -r
	parser:flag  "-a" "--add-to-rockspec"
		:description
			"Add packages to rockspec during install."
	parser:option "-r" "--rockspec"
		:description
			"The path to the rockspec file."
	parser:flag "--only-deps"
		:description(
			"Only install the packages dependencies. "..
			"Analogous to apt-get build-dep.")
	parser:option "-s" "--server"
		:description
			"Fetch rocks/rockspecs from this server as a priority."
	parser:option "--only-server"
		:description
			"Fetch rocks/rockspecs from this server, ignoring other servers."
end

local function fmt_table(t)
	local s = "{"
	local sep = "\n   " -- FIXME: configurable indents

	for _, v in ipairs(t) do
		s = s .. sep .. string.format("%q", v)
		sep = ",\n   "
	end

	return s .. "\n}"
end

local function to_set(o)
	local t = {}
	for _, k in ipairs(o) do
		t[k] = true
	end
	return t
end

local function add_to_depstring(spec, new_deps)
	local added_deps = {}
	return spec:gsub("(dependencies%s*=%s*)(%b{})", function(pre, s)
		local old_deps = assert(loadstring("return " .. s))()
		local depset = to_set(new_deps)
		for _, v in ipairs(old_deps) do
			for _, dep in ipairs(new_deps) do
				if v:match("^" .. util.escape_str(dep)) then
					local S = "%s is already present in the rockspec, ignoring"
					log:warning(S, dep)
					depset[dep] = nil
				end
			end
		end

		for dep, _ in pairs(depset) do
			table.insert(old_deps, dep) -- FIXME: constrain version
			table.insert(added_deps, dep)
		end
		return pre .. fmt_table(old_deps)
	end), added_deps
end

local INSTALL_MSG = [[
INSTALLING: %s

WARNING: This command will modify your rockspec, %q. Make sure you have a
         backup in case you don't like the results.

         Continue (y/N)?]]

local function add_deps(args)
	local rspec = false
	if args.rockspec then
		rspec = ("%q"):format(args.rockspec)
	else
		rspec = assert(util.get_first(".", "%.rockspec$"))
	end

	local data = assert(util.slurp(rspec))
	local new_data, to_install = add_to_depstring(data, args.new_packages)
	if #to_install == 0 then
		log:warning("No packages to install")
		os.exit(0)
	end

	local package_str = table.concat(args.new_packages, " ")

	-- TODO: ask luarocks search if this is a valid package
	local goahead = log:ask(
		INSTALL_MSG,
		table.concat(to_install, " "),
		rspec) ('n')

	if not goahead then
		log:info("Aborting.")
		os.exit(0)
	end

	assert(util.spit(new_data, rspec))
	log:info(
		"\n%s added to rockspec, now installing.",
		table.concat(to_install, ", "))
end

function install:run(args)
	for _, pkg in ipairs(args.packages) do
		log:info("Installing %s", pkg)
		local ok, err = api.install(pkg, nil, {
			quiet      = false,
			from      = args.server,
			only_from = args.only_server,
		})
		if not ok then
			log:error(err)
		end
	end
	if args.add_to_rockspec then
		add_deps(args)
	end
end

return install
