----------------------
-- A butchering of
-- https://git.io/vuFYa
-- used to call luarocks functions within a contained sandbox.
-- FIXME: this is a total mess
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

	if util.is_file(fname) then
		local body = log:assert(util.slurp(fname))
		for field in body:gmatch("%b||") do
			field = field:sub(2, -2)
			old_ver = field:match("^version: (%d+%.%d+%.%d+-%d+)") 
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
	local path = log:assert(template.path('love/rocks'))
	local files = assert(util.slurp(path))
	files = template.apply(files, env)
	assert(util.spit(files, rocks_tree))
end

local function init_rocks(rocks_tree, provided)
	if not util.is_dir(rocks_tree) then
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

local project_cfg = nil
local cwd = nil
local function check_flags(flags)
	T(flags, 'table')

	local rocks_tree = flags.tree or "rocks"
	T(rocks_tree, 'string')

	local cfg = require("luarocks.cfg")
	local util = require("luarocks.util")
	local manif_core = require("luarocks.manif_core")

	local fs = require("luarocks.fs")
	local path = require("luarocks.path")

	cwd = fs.current_dir()
	use_tree(cwd .. "/" .. rocks_tree, rocks_tree)
	if not project_cfg then
		project_cfg = {}
		local provided = versions.get(flags.version)
		project_cfg.rocks_provided = provided
		init_rocks(rocks_tree, provided)
		copy(project_cfg, cfg)
	end

	manif_core.manifest_cache = {} -- clear cache
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

-- 
function api.make_flags(conf)
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

return api
