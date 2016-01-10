local mod = ...

local cnames = {
	"new",
	"install",
	"remove",
	"deps",
	"list",
	"search",
	"purge",
	"help",
	"modules",
	"path",
}

local commands = {}

for _, c in ipairs(cnames) do
	commands[c] = require(mod .. "." .. c)
end

return { names = cnames, modules = commands }
