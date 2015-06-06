local log = require 'loverocks.log'
local init = {}

function init:build(parser)
	parser:description "Loverocks-ify an existing project"
end

init.aliases = {}

function init:run(args)
	log:error("NYI. For now, try making an empty project with `loverocks new` and moving your code into the result.")
end

return init
