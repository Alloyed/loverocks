local util = require 'loverocks.util'
local install = {}

function install:build(parser)
	parser:description "Install packages, or add a new one"
	parser:argument "new_package"
		:args("?")
		:description("The package to install. If left out all dependencies are installed.")
	parser:option "-r" "--rockspec"
		:description "The path to the rockspec file."
	parser:option "-s" "--server"
		:description "Fetch rocks/rockspecs from this server as a priority"
	parser:option "--server-only"
		:description "Fetch rocks/rockspecs from this server, ignoring other servers"
end

local function install_all(args)
	local rspec = "*.rockspec"
	if args.rockspec then
		rspec = ("%q"):format(args.rockspec)
	end

	local s = ("build %s --only-deps"):format(rspec)
	if args.server then 
		s = ("%s --server=%q"):format(s, args.server)
	end
	if args.server_only then
		s = ("%s --server-only=%q"):format(s, args.server_only)
	end

	util.luarocks(s)
end

function install:run(args)
	if args.new_package then error("TODO")
	else
		install_all(args)
	end
end

return install
