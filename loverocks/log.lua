local log = {}

log.use = {
	fs = false,
	warning = true,
	info = true,
	ask = true
}

local function eprintf(pre, ...)
	return io.stderr:write(pre .. string.format(...) .. "\n")
end

function log:fs(...)
	if self.use.fs then
		eprintf("$ ", ...)
	end
end

function log:error(...)
	eprintf("ERROR: ", ...)
	os.exit(1)
end

function log:warning(...)
	if self.use.warning then
		eprintf("Warning: ", ...)
	end
end

function log:info(...)
	if self.use.info then
		eprintf("", ...)
	end
end

function log:ask(...)
	local outstr = string.format(...) .. " "
	io.write(outstr)
	return function(default)
		if self.use.ask then
			local s = io.read('*l') or default
			return s:lower():sub(1, 1) == 'y' and true or false
		end

		io.write('y\n')
		return true
	end
end

return log
