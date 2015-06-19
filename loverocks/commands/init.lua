local lfs      = require 'lfs'

local template = require 'loverocks.template'
local log      = require 'loverocks.log'
local config   = require 'loverocks.config'
local util     = require 'loverocks.util'

local init = {}

function init:build(parser)
	parser:description "Loverocks-ify or update an existing project."
	parser:argument "path"
		:args("?")
		:description "The path of the project to init.\nIf unspecified uses current working directory."
	parser:option "-t" "--template"
		:description "The template to follow."
		:default "love9"
	parser:option "--love-version"
		:description "The lua version.\nIf unspecified, we guess by running `love --version`."
	parser:option "-p" "--project"
		:description "the name of the project.\nIf unspecified, uses the name of the directory specified in <path>."
end

init.aliases = {}

local INSTALL_MSG = [[
WARNING: This command will modify the following files:

         %s

         Make sure you have a backup in case you don't like the results.

         Continue (y/N)?]]

function install_fmt(o)
	local mod = ""
	local sep = ""
	for k, _ in pairs(o) do
		mod = mod .. sep .. k
		sep = " "
	end
	return string.format(INSTALL_MSG, mod)
end

local injections = {
	[[require_(_'rocks'_)_(_)]],
	[[require_(_"rocks"_)_(_)]],
	[[require_'rocks'_(_)]],
	[[require_"rocks"_(_)]],
}
for i=1, #injections do
	injections[i] = injections[i]
		:gsub("%(", "%%(")
		:gsub("%)", "%%)")
		:gsub("_", "%%s*")
end
local function has_injection(s)
	for _, pat in ipairs(injections) do
		if s:match(pat) then
			return true
		end
	end
	return false
end

local function merge_gitignore(old, new)
	local old_lines = {}
	for line in string.gmatch(old,  "[^\n]+") do
		old_lines[line] = true
	end

	local add = old:match("\n$") and "" or "\n"
	local edited = false
	for line in string.gmatch(new, "[^\n]+") do
		if not old_lines[line] then
			edited = true
			add = add .. line .. "\n"
		end
	end
	return old .. add, edited
end

local function newer(a, b)
	-- Don't worry about it. 100 versions are enough for anybody :^)
	local a_maj, a_min, a_patch, a_rock = a:match("^(%d+)%.(%d+)%.(%d+)-(%d+)")
	local an = a_maj * 1e8 + a_min * 1e4 + a_patch * 1e2 + a_rock

	local b_maj, b_min, b_patch, b_rock = b:match("^(%d+)%.(%d+)%.(%d+)-(%d+)")
	local bn = b_maj * 1e8 + b_min * 1e4 + b_patch * 1e2 + b_rock

	return an > bn
end

local function is_empty(t)
	local gen, param, state = pairs(t)
	return gen(param, state) == nil
end

function init:run(args)
	local path    = args.path or lfs.current_dir()
	local project = args.project or path:match("/([^/]+)$") or path
	local env = template.new_env(project, args.love_version)

	local tpath = log:assert(template.path(args.template))
	local t = assert(util.slurp(tpath))
	t = template.apply(t, env)
	local a = {}
	local o = {}

	if util.is_dir(path .. "/rocks") then
		local cfg = {}
		if util.exists(path .. "/rocks/init.lua") and config:open(path .. "/rocks/config.lua", cfg) then
			local old_ver = cfg.loverocks and cfg.loverocks.version
			local new_ver = require 'loverocks.version'
			if not old_ver or newer(new_ver, old_ver) then
				log:info("Updating loverocks tree to %s", new_ver)
				a.rocks = t.rocks
				o.rocks = true
			end
		else
			log:error("%s is not recognized as a valid loverocks tree. " ..
			          "Please remove or rename, then try again.", path .. "/rocks")
		end
	else
		a.rocks = t.rocks
	end

	if not util.get_first(path, "%.rockspec$") then
		local rockspec_path = project .. "-scm-1.rockspec"
		a[rockspec_path] = assert(t[rockspec_path])
	end

	if util.exists(path.."/conf.lua") then
		-- TODO check love version number, if included
		local body = log:assert(util.slurp(path.."/conf.lua"))
		if not has_injection(body) then
			body = "require 'rocks' ()\n" .. body
			a["conf.lua"] = body
			o["conf.lua"] = true
		end
	else
		a["conf.lua"] = t["conf.lua"]
	end

	if util.exists(path.."/.gitignore") then
		local old = assert(util.slurp(path.."/.gitignore"))
		local new, edited = merge_gitignore(old, t[".gitignore"])
		if edited then
			a[".gitignore"] = new
			o[".gitignore"] = true
		end
	else
		a[".gitignore"] = t[".gitignore"]
	end

	if not is_empty(o) then
		local should_overwrite = log:ask("%s", install_fmt(o)) ('n')

		if not should_overwrite then
			log:info("Aborting.")
			os.exit(0)
		end
	end
	assert(util.spit(a, path))
	log:info("LOVErocks installed into %q. You can test this by running `loverocks install`.", path)
end

return init
