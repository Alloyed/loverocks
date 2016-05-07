-- Monkeypatched loadconf.

local _loadconf = require 'loadconf'
local loadconf = {}
for k, v in pairs(_loadconf) do
	loadconf[k] = v
end

local util = require 'loverocks.util'

-- Simple shallow merge.
-- New values replace old, so base[k] == new[k] for every k in new
local function merge(base, new)
	for k, v in pairs(new) do
		base[k] = v
	end

	return true -- Mutates!
end

-- builds and returns a loadconf table.
function loadconf.require()
	if not loadconf._config then
		local conf = {}
		local base_conf, err = loadconf.parse_file("./conf.lua")
		if not base_conf then return base_conf, err end

		merge(conf, base_conf)
		if not conf.dependencies then -- check for a makefile
			spec_name = util.get_first("./", "scm-%d%.rockspec$")
			if spec_name then

				local chunk
				chunk, err = loadfile(spec_name)
				if not chunk then return chunk, err end

				local rock = {}
				setfenv(chunk, rock)
				chunk()

				conf.dependencies = rock.dependencies
			end
		end
		loadconf._config = conf
	end

	return loadconf._config
end

return loadconf
