local log = require 'loverocks.log'
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
	log:error("NYI. For now, try making an empty project with `loverocks new` and moving your code into the result.")
end

return search
