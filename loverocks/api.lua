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

local lfs = require 'lfs'
local util = require("luarocks.util")
local deps = require("luarocks.deps")
local manif_core = require("luarocks.manif_core")
local build = require("luarocks.build")
local fs = require("luarocks.fs")
local path = require("luarocks.path")
local _remove = require("luarocks.remove")
local purge = require("luarocks.purge")
local list = require("luarocks.list")

local T = require 'schema'
local log = require 'loverocks.log'
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

-- cool, let's initialize this baby. This is normally done by command_line.lua
-- Since cfg is a singleton, api has to be one too. So it goes.
local cfg = require("luarocks.cfg")

function api.apply_config(new)
	T(new, 'table')

	-- idea: instead of copying-in, we make package.preload["luarocks.cfg"]
	-- a mock table, and then push in and out prototypes to apply the config.
	copy(new, cfg)
end

local function use_tree(tree)
	T(tree, 'string')

	cfg.root_dir = tree
	cfg.rocks_dir = path.rocks_dir(tree)
	cfg.rocks_trees = { "rocks" }
	cfg.deploy_bin_dir = path.deploy_bin_dir(tree)
	cfg.deploy_lua_dir = path.deploy_lua_dir(tree)
	cfg.deploy_lib_dir = path.deploy_lib_dir(tree)
end

local old_printout, old_printerr = util.printout, util.printerr
local path_sep = package.config:sub(1, 1)

function q_printout(...)
	log:info("L: %s", table.concat({...}, "\t"))
end

function q_printerr(...)
	log:_warning("L: %s", table.concat({...}, "\t"))
end

local project_cfg = nil
local cwd = nil
local function check_flags(flags)
	T(flags, 'table')

	cwd = fs.current_dir()
	use_tree(cwd .. "/rocks")
	if not project_cfg then
		project_cfg = {}
		versions.add_version_info(cwd .. "/conf.lua", project_cfg)
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

api.check_flags = check_flags

local function restore_flags(flags)
	T(flags, 'table')
	assert(lfs.chdir(cwd))
	if flags.from then
		table.remove(cfg.rocks_servers, 1)
	elseif flags.only_from then
		cfg.rocks = flags._old_servers
	end
	util.printout = old_printout
	util.printerr = old_printerr
end

api.restore_flags = restore_flags

return api
