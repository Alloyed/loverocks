local log = {}

log.use = {
	fs = false,
	warning = true,
	info = true
}

function log:fs(...)
	if self.use.fs then
		io.stderr:write("$ " .. string.format(...) .. "\n")
	end
end

function log:error(...)
	error(string.format(...))
end

function log:warning(...)
	if self.use.warning then
		io.stderr:write(string.format(...) .. "\n")
	end
end

function log:info(...)
	if self.use.info then
		io.stderr:write(string.format(...) .. "\n")
	end
end

return log
