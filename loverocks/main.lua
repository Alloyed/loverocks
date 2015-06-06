local argparse = require 'argparse'
local commands = require 'loverocks.commands'
local config   = require 'loverocks.config'
local log      = require 'loverocks.log'

local config_msg = [[
Configuration:

   luarocks: %s
   loverocks config: %s
]]

local function main(...)
	config:load()
	local parser = argparse "loverocks" {
		description = "A wrapper to make luarocks and love play nicely.",
		epilog = string.format(config_msg,
		                       config('luarocks'),
		                       config('loverocks_config'))
	}
	commands.help:add_command("main", parser)

	for name, cmd in pairs(commands) do
		local cmd_parser = parser:command(name)
		commands.help:add_command(name, cmd_parser)
		cmd:build(cmd_parser)
	end

	parser:flag "-v" "--verbose"
		:description "Use verbose output."
		:action(function()
			log.use.fs = true
		end)
	parser:flag "-q" "--quiet"
		:description "Silence info messages."
		:action(function()
			log.use.info = false
		end)
	parser:flag "-c" "--confirm"
		:description "Confirm without prompting. useful for scripts."
		:action(function()
			log.use.ask = false
		end)

	local args = {...}
	local B = parser:parse(args)

	if B.lua then
		return commands.lua:run(args) -- pass raw args instead of parsed args
	else
		for name, cmd in pairs(commands) do
			if B[name] then
				return cmd:run(B)
			end
		end
	end
end

return main
