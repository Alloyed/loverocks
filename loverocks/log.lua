local log = {}

log.use = {
	fs = false,         -- print filesystem events
	warning = true,     -- print warnings
	error = true,       -- print errors
	tracebacks = false, -- print tracebacks on expected errors
	info = true,        -- print info text/dialogs
	ask = true,         -- ask for confirmation
}

function log:quiet()
	self.use.fs = false
	self.use.error = false
	self.use.tracebacks = false
	self.use.warning = false
	self.use.info = false
	self.use.ask = false
end

function log:verbose()
	self.use.fs = true
	self.use.error = true
	self.use.tracebacks = true
	self.use.warning = true
	self.use.info = true
end

local function eprintf(pre, ...)
	local indent = pre:gsub(".", " ")
	local body = string.format(...)
	body = body:gsub("\n", "\n" .. indent)
	return io.stderr:write(pre .. body .. "\n")
end

function log:fs(...)
	if self.use.fs then
		eprintf("$ ", ...)
	end
end

function log:error(...)
	if self.use.error then
		eprintf("Error: ", ...)
	end

	if self.use.tracebacks then
		eprintf("", "%s", debug.traceback())
	end
	os.exit(1)
end

function log:assert(ok, ...)
	if not ok then
		self:error("%s", ...)
	end
	return ok, ...
end

function log:warning(...)
	if self.use.warning then
		eprintf("Warning: ", ...)
	end
end

function log:_warning(...)
	if self.use.warning then
		eprintf("",...)
	end
end

function log:info(...)
	if self.use.info then
		eprintf("", ...)
	end
end

function log:ask(...)
	if self.use.info == false then
		return function() return true end
	end
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
