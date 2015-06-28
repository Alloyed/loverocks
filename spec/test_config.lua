return setmetatable({},{__call = function()
	local log = require 'loverocks.log'
	log:quiet()
end})
