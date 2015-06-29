return setmetatable({},{__call = function()
	local log = require 'loverocks.log'
	log.use.ask = false
	log:quiet()
end})
