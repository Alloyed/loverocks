local util = require 'loverocks.util'
local log = require 'loverocks.log'
local loadconf = require 'loadconf'
local T = require 'schema'

-- FIXME: non-love version numbers are pretty much made up
-- FIXME: Add the luajit rocks-provided modules too
local STABLE = "0.9.2"
local versions = {
	["0.9.0"] = {
		lua        = "5.1-1",
		love       = "0.9.0-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	},
	["0.9.1"] = {
		lua        = "5.1-1",
		love       = "0.9.1-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	},
	["0.9.2"] = {
		lua        = "5.1-1",
		love       = "0.9.2-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	},
	["0.10.0"] = {
		lua        = "5.1-1",
		love       = "0.10.0-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	}
}

local STORED -- FIXME: should this be stored in a config file somewhere?
local function get_versions_for(v)
	if not v then
		if STORED then
			v = STORED
		elseif io.popen then
			v = util.stropen("love --version"):match("%d+%.%d+%.%d+")
			if v then
				log:info("Found LOVE version %s", v)
				STORED = v
			end
		end
	end
	return versions[v] or versions[STABLE]
end

local function add_version_info(fname, cfg)
	T(fname, 'string')
	T(cfg, 'table')

	local conf = log:assert(loadconf.parse_file(fname))
	log:assert(type(conf.version) == 'string', "t.version not found")
	local version = conf.version

	cfg.rocks_provided = versions[version]
	assert(cfg.rocks_provided)
	return true
end

return setmetatable({
	get = get_versions_for,
	add_version_info = add_version_info,
}, {__call = get_versions_for})
