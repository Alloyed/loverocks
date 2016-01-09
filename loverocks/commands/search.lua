local log = require 'loverocks.log'
local api  = require 'loverocks.api'
local search = {}

function search.build(parser)
	parser:description "Query the Luarocks servers."
	parser:argument "search_string"
		:args("*")
		:description "The string to query by."
	parser:flag "--all"
		:description "Return all packages instead of those macthing the search string."

	parser:mutex(
		parser:option "-s" "--server"
			:description "Search this server.",
		parser:flag "--love"
			:description "Search the LOVE manifest."
	)
end

function search.run(args)
	local flags = {}
	local a = {}
	if args.all then
		table.insert(a, "--all")
	end

	if args.server then
		flags.only_from = args.server
	elseif args.love then
		flags.only_from = "http://luarocks.org/m/love"
	end

	for _, s in ipairs(args.search_string) do
		table.insert(a, s)
	end

	log:fs("luarocks search %s", table.concat(a, " "))
	log:assert(api.in_luarocks(flags, function()
		local lr_search = require 'luarocks.search'
		return lr_search.run(unpack(a))
	end))
end

return search
