local argparse = require 'argparse'
local commands = require 'loverocks.commands'
local loadconf = require 'loverocks.loadconf'
local log      = require 'loverocks.log'
local luarocks = require 'loverocks.luarocks'

local function main(...)
	local fullname = "Loverocks " .. (require 'loverocks.version')
	local lr_version = luarocks.version()
	assert(lr_version)
	local lr_name = "Luarocks " .. tostring(lr_version)
	local desc = "%s, a wrapper to make %s and LOVE play nicely."

	local parser = argparse "loverocks" {
		description = string.format(desc, fullname, lr_name),
	}
	parser:command_target("cmd")
	local help = commands.modules.help
	help.add_command("main", parser)

	for _, name in pairs(commands.names) do
		local cmd = commands.modules[name]
		local cmd_parser = parser:command(name)

		help.add_command(name, cmd_parser)
		cmd.build(cmd_parser)
	end

	parser:flag "--version"
		:description "Print version info."
		:action(function()
			io.write(fullname .. "\n" .. lr_name .. "\n")
			os.exit(0)
		end)
	parser:flag "-v" "--verbose"
		:description "Use verbose output."
		:action(function()
			log:verbose()
		end)
	parser:flag "-q" "--quiet"
		:description "Suppress output. also enables -c"
		:action(function()
			log:quiet()
		end)
	parser:flag "-c" "--confirm"
		:description "Confirm without prompting. useful for scripts."
		:action(function()
			log.use.ask = false
		end)
	parser:option "--game" "-g"
		:description "Manage the game represented by this file/folder."

	local B = parser:parse{...}
	local conf = log:assert(loadconf.require(B.game))

	return commands.modules[B.cmd].run(conf, B)
end

return main
