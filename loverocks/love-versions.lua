local util = require 'loverocks.util'
local log = require 'loverocks.log'

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

local function parse_conf(body)
	local s = body:match([[version%s*=%s*(%b"")]]) or
	          body:match([[version%s*=%s*(%b'')]])
	if not s then
		return nil, "could not find LOVE version in conf.lua"
	end
	return s:sub(2, -2)
end

local function add_version_info(fname, cfg)
	local version = STABLE
	local f = io.open(fname, 'r')
	if f then
		local fbody = f:read('*a')
		version = log:assert(parse_conf(fbody))
	end

	log:verbose("Providing LOVE v%s", version)
	cfg.rocks_provided = versions[version]
	assert(cfg.rocks_provided)
	return true
end

return setmetatable({
	get = get_versions_for,
	add_version_info = add_version_info,
}, {__call = get_versions_for})
