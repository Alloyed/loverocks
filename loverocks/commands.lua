local mod = ...

local cnames = {
	"help",
	"install",
	"init",
	"new",
	"lua",
}

local commands = {}

for _, c in ipairs(cnames) do
	commands[c] = require(mod .. "." .. c)
end

return commands
