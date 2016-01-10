local loadconf = require 'loadconf'
local api  = require 'loverocks.api'
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

function list.run(args)
	local conf = loadconf.parse_file("./conf.lua")

	local flags = api.make_flags(conf)
	if args.outdated then
		flags.outdated = true
	end

	local f = {table.concat(args.filter, " ")}
	if flags.outdated then
		table.insert(f, "--outdated")
	end
	if flags.porcelain then
		table.insert(f, "--porcelain")
	end

	log:fs("luarocks list %s", table.concat(f, " "))
	log:assert(api.in_luarocks(flags, function()
		local lr_list = require 'luarocks.list'

		return lr_list.run(unpack(f))
	end))
end

return list
