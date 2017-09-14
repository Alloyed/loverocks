----------------------
-- A butchering of
-- https://git.io/vuFYa
-- used to call luarocks functions within a contained sandbox.
-- FIXME: this is a total mess
-- @author Steve Donovan
-- @license MIT/X11

local luarocks = {}

local fs = require 'luarocks.fs'

local T = require 'loverocks.schema'
local log = require 'loverocks.log'
local template = require 'loverocks.template'
local util = require 'loverocks.util'
local versions = require 'loverocks.love-versions'

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

local function use_tree(root, tree_name)
	T(root,      'string')
	T(tree_name, 'string')

	local cfg = require 'luarocks.cfg'
	local path = require("luarocks.path")

	cfg.root_dir = root
	cfg.rocks_dir = path.rocks_dir(root)
	cfg.rocks_trees = { tree_name }
	cfg.deploy_bin_dir = path.deploy_bin_dir(root)
	cfg.deploy_lua_dir = path.deploy_lua_dir(root)
	cfg.deploy_lib_dir = path.deploy_lib_dir(root)
end

local function q_printout(...)
	log:info("L: %s", table.concat({...}, "\t"))
end

local function q_printerr(...)
	log:_warning("L: %s", table.concat({...}, "\t"))
end

local function version_gt(a, b)
	T(a, 'string')
	T(b, 'string')
	-- Don't worry about it. 100 versions are enough for anybody :^)
	local a_maj, a_min, a_patch, a_rock = a:match("^(%d+)%.(%d+)%.(%d+)-(%d+)")
	local an = a_maj * 1e8 + a_min * 1e4 + a_patch * 1e2 + a_rock

	local b_maj, b_min, b_patch, b_rock = b:match("^(%d+)%.(%d+)%.(%d+)-(%d+)")
	local bn = b_maj * 1e8 + b_min * 1e4 + b_patch * 1e2 + b_rock

	return an > bn
end

local function old_init_file(rocks_tree)
	local fname = rocks_tree .. "/init.lua"

	if fs.is_file(fname) then
		local body = log:assert(util.slurp(fname))
		for field in body:gmatch("%b||") do
			field = field:sub(2, -2)
			local old_ver = field:match("^version: (%d+%.%d+%.%d+-%d+)")
			if old_ver then
				if version_gt(require'loverocks.version', old_ver) then
					return true -- our version is newer, update
				else
					return false -- our version is same or lower, don't update
				end
			end
		end
	end
	log:error([[
Couldn't recognize rocks tree %q.
This can happen when upgrading from an older version of LOVERocks,
in which case it's safe to delete the old directory.
Please rename or remove and try again.]], rocks_tree)
end

local function reinstall_tree(rocks_tree, provided)
	local env = template.new_env(provided)
	local files = require("loverocks.templates.love").rocks
	files = template.apply(files, env)
	assert(util.spit(files, rocks_tree))
end

local function init_rocks(rocks_tree, provided)
	if not fs.is_dir(rocks_tree) then
		log:info("Rocks tree %q not found, reinstalling.", rocks_tree)
		reinstall_tree(rocks_tree, provided)
		return true
	elseif old_init_file(rocks_tree) then
		log:info("Rocks tree %q is outdated, upgrading.", rocks_tree)
		reinstall_tree(rocks_tree, provided)
		return true
	end

	return false
end

local function assert_rocks(rocks_tree)
	if not fs.is_dir(rocks_tree) then
		log:warning("Rocks tree %q not found", rocks_tree)
		return true
	elseif old_init_file(rocks_tree) then
		log:warning("Rocks tree %q is outdated, run `loverocks deps` to get a new one", rocks_tree)
		return true
	end

end

local function check_flags(flags)
	T(flags, 'table')

	local rocks_tree = flags.tree or "rocks"
	T(rocks_tree, 'string')

	local cfg = require("luarocks.cfg")

	-- local fs = require("luarocks.fs")

	-- FIXME make configurable
	local cwd = fs.current_dir()
	use_tree(cwd .. "/" .. rocks_tree, rocks_tree)

	local project_cfg = {}
	local provided = versions.get(flags.version)
	project_cfg.rocks_provided = provided
	if flags.init_rocks then
		init_rocks(rocks_tree, provided)
	else
		assert_rocks(rocks_tree)
	end
	copy(project_cfg, cfg)

	flags._old_servers = cfg.rocks_servers
	if flags.only_from then
		T(flags.only_from, 'string')
		cfg.rocks_servers = { flags.only_from }
	elseif flags.from then
		T(flags.from, T.all('string'))
		for i=#flags.from, 1, -1 do
			table.insert(cfg.rocks_servers, 1, flags.from[i])
		end
	end

	local lr_util = require("luarocks.util")
	lr_util.printout = q_printout
	lr_util.printerr = q_printerr
end

luarocks.check_flags = check_flags

local function make_env(flags)
	local env = setmetatable({}, {__index = _G})
	env._G = env
	env.package = setmetatable({}, {__index = package})
	env.check_flags = check_flags
	env.flags = flags
	env.T = T -- TODO: remove

	env.package.loaded = {
		string = string,
		debug = debug,
		package = env.package,
		_G = env,
		io = io,
		os = os,
		table = table,
		math = math,
		coroutine = coroutine,
	}
	return env
end

local function pack(...)
	local t = {...}
	t.n = select('#', ...)
	return t
end

--
function luarocks.sandbox(flags, f)
	-- FIXME: required packages are leaking! This is a hack to avoid the
	-- consequences of this...
	for k, _ in pairs(package.loaded) do
		if k:match('^luarocks') then
			package.loaded[k] = nil
		end
	end
	local env = make_env(flags)
	local function lr()
		-- local fs = require('luarocks.fs')
		local cwd = fs.current_dir()
		check_flags(flags)
		local r = pack(f())
		local l_util = require('luarocks.util')
		l_util.run_scheduled_functions()
		assert(fs.change_dir(cwd))
		return unpack(r, 1, r.n)
	end
	setfenv(lr, env)

	return lr()
end

-- attempts to find current version of luarocks as a string. false if failure.
function luarocks.version()
	local ok, cfg = pcall(require, 'luarocks.cfg')

	--local ok, v = pcall(luarocks.sandbox({}, function()
	--	local cfg = require 'luarocks.cfg'
	--	return cfg.program_version
	--end))

	if ok and cfg.program_version then
		return cfg.program_version
	end
	return false
end

function luarocks.make_flags(conf)
	conf = conf or {}
	local t = {
		tree    = conf.rocks_tree,
		version = conf.version,
		from    = {}
	}

	if conf.rocks_servers then
		T(conf.rocks_servers, T.all('string'))
		t.from = conf.rocks_servers
	end

	return t
end

return luarocks
