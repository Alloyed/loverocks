local luarocks  = require 'loverocks.luarocks'
local log  = require 'loverocks.log'

local list = {}

function list.build(parser)
	parser:description "List installed dependencies."
	parser:argument "filter"
		:args("*")
		:description "Only return dependencies matching this substring."
	parser:flag "--outdated"
		:description "Only return dependencies that have newer versions available."
end

function list.run(conf, args)
	local flags = luarocks.make_flags(conf)
	if args.outdated then
		flags.outdated = true
	end

	local lr_args = { filter = table.concat(args.filter, " ") }
	lr_args.outdated = args.outdated
	lr_args.porcelain = args.porcelain

	log:assert(luarocks.sandbox(flags, function()
		local lr_list = require 'luarocks.cmd.list'

		return lr_list.run(lr_args)
	end))
end

return list
