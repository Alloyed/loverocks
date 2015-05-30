local argparse = require 'argparse'

local commands = require 'loverocks.commands'

local function main(...)
	local parser = argparse "loverocks" {
		description = "A wrapper to make luarocks and love play nicely.",
	}
	commands.help:add_command("main", parser)

	for name, c in pairs(commands) do
		local cmd = parser:command(name)
		commands.help:add_command(name, cmd)
		c:build(cmd)
	end

	local a = {...}
	-- hack to make sure luarocks args survive intact
	if a[1] == "lua" then
		table.remove(a, 1)
		commands.lua:run(a)
	else
		local args = parser:parse(a)

		for name, c in pairs(commands) do
			if args[name] then
				return c:run(args)
			end
		end
	end
end

return main
