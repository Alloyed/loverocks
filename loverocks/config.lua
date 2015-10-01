-- load configuration
local config = {}

function config.open(fname, env)
	local fn
	if setfenv then -- lua 5.1
		fn, err = loadfile(fname)
		if not fn then return nil, err end
		setfenv(fn, env)
	else -- lua >= 5.2
		fn, err = loadfile(fname, 't', env)
		if not fn then return nil, err end
	end
	fn()
	return env
end

return config
