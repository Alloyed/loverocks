local log = require 'loverocks.log'
local util = require 'loverocks.util'
local search = {}

function search:build(parser)
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

function search:run(args)
	local all = args.all and "--all " or ""

	local server = ""
	if args.server then
		server = string.format("--only-server=%q ", args.server)
	elseif args.love then
		log:error("--love is broken, see https://github.com/leafo/luarocks-site/issues/59") -- FIXME
		server = '--only-server="http://luarocks.org/m/love" '
	end

	local query = string.format("%q", table.concat(args.search_string, " "))

	util.luarocks("search " .. server .. all .. query)
end

return search
