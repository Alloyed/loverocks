local log = require 'loverocks.log'

-- FIXME: non-love version numbers are pretty much made up
local STABLE = "0.9.2"
local versions = {
	["0.9.0"] = {
		love       = "0.9.0-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	},
	["0.9.1"] = {
		love       = "0.9.1-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	},
	["0.9.2"] = {
		love       = "0.9.2-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	},
	["0.10.0"] = {
		love       = "0.10.0-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	}
}

local function get_versions_for(v)
	if not v then
		if STORED then
			v = STORED
		elseif io.popen then
			local f = io.popen("love --version", 'r')
			v = f:read('*a'):match("%d+%.%d+%.%d+")
			log:info("Found LOVE version %s", v)
			STORED = v
			f:close()
		end
	end
	return versions[v] or versions[STABLE]
end

return setmetatable({get = get_versions_for}, {__call = get_versions_for})
