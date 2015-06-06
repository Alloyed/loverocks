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
		                       config:get('luarocks'),
		                       config:get('loverocks_config'))
	}
	commands.help:add_command("main", parser)

	for name, c in pairs(commands) do
		local cmd = parser:command(name)
		commands.help:add_command(name, cmd)
		c:build(cmd)
	end

	parser:flag "-v" "--verbose"
		:description "Use verbose output"
	parser:flag "-q" "--quiet"
		:description "Silence info messages"

	local a = {...}
	local args = parser:parse(a)
	if args.verbose then
		log.use.fs = true
	end
	if args.quiet then
		log.use.info = false
	end

	if args.lua then
		return commands.lua:run(a)
	else
		for name, c in pairs(commands) do
			if args[name] then
				return c:run(args)
			end
		end
	end
end

return main
