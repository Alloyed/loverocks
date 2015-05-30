local log = {}

log.use = {
	fs = false,
	warning = true,
	info = true
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

return log
