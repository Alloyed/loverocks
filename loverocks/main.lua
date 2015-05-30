local argparse = require 'argparse'

local commands = require 'commands'

local function main(...)
	local parser = argparse "loverocks" {
		description = "Description.",
	}

	for name, c in pairs(commands) do
		local cmd = parser:command(name)
		c:build(cmd)
	end

	local args = parser:parse{...}

	for name, c in pairs(commands) do
		if args[name] then
			return c:run(args)
		end
	end
	error("commands exhausted")
end

main(...)
