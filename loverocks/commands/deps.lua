local util = require 'loverocks.util'
local log = require 'loverocks.log'
local api = require 'loverocks.api'

local deps = {}

function deps:build(parser)
	parser:description
		"Installs all packages listed as dependencies."
	parser:option "-r" "--rockspec"
		:description
			"The path to the rockspec file."
	parser:option "-s" "--server"
		:description
			"Fetch rocks/rockspecs from this server as a priority."
	parser:option "--only-server"
		:description
			"Fetch rocks/rockspecs from this server, ignoring other servers."
end


local function deps_all(args)
	local rspec
	if args.rockspec then
		rspec = ("%q"):format(args.rockspec)
	else
		rspec = log:assert(util.get_first(".", "%.rockspec$"))
	end
	
	log:assert(api.build(rspec, nil, {
		quiet = false,
		only_deps = true,
		from = args.server,
		only_from = args.only_server
	}))
end

function deps:run(args)
	deps_all(args)
end

return deps
