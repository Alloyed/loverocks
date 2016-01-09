--- Configuration for test runner
--

return setmetatable({},{__call = function()
	local log = require 'loverocks.log'
	log.use.ask = false
	if os.getenv("LR_VERBOSE") then
		log:verbose()
	elseif os.getenv("LR_QUIET") then
		log:quiet()
	else
		log:quiet()
		log.use.error = true
	end

	local _os = _G.os
	_G.os = setmetatable({
		exit = function(i) error(string.format("os.exit(%d)", i or 1)) end
	}, {__index = _os})
end})
