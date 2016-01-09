----------------------
-- @author Steve Donovan
-- @license MIT/X11

local api = {}

local lfs = require 'lfs'

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

local Lutil = require 'luarocks.util'
local old_printout, old_printerr = Lutil.printout, Lutil.printerr
local path_sep = package.config:sub(1, 1)

function q_printout(...)
	log:info("L: %s", table.concat({...}, "\t"))
end

function q_printerr(...)
	log:_warning("L: %s", table.concat({...}, "\t"))
end

local function init_rocks(versions)
	if not util.is_dir(ROCKSDIR) then
		local env = template.new_env(versions)
		local path = log:assert(template.path('love9/rocks'))
		local files = assert(util.slurp(path))
		files = template.apply(files, env)
		assert(util.spit(files, ROCKSDIR))

		return true
	end

	return false
end

local project_cfg = nil
local cwd = nil
local function check_flags(flags)
	T(flags, 'table')

	local cfg = require("luarocks.cfg")
	local util = require("luarocks.util")
	local manif_core = require("luarocks.manif_core")

	local fs = require("luarocks.fs")
	local path = require("luarocks.path")

	cwd = fs.current_dir()
	use_tree(cwd .. "/" .. ROCKSDIR , ROCKSDIR)
	if not project_cfg then
		project_cfg = {}
		local versions = versions.add_version_info(cwd .. "/conf.lua", project_cfg)
		init_rocks(versions)
		copy(project_cfg, cfg)
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

api.check_flags = check_flags

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

function api.in_luarocks(flags, f)
	local env = make_env(flags)
	local function lr()
		check_flags(flags)
		return f()
	end
	setfenv(lr, env)

	return lr()
end

return api
