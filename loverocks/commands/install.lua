local util = require 'loverocks.util'
local log = require 'loverocks.log'

local install = {}

function install:build(parser)
	parser:description
		"Installs all packages listed as dependencies."
	parser:argument "new_packages"
		:args("*")
		:description
			"If included, adds new_packages to rockspec as well."
	parser:option "-r" "--rockspec"
		:description
			"The path to the rockspec file."
	parser:option "-s" "--server"
		:description
			"Fetch rocks/rockspecs from this server as a priority"
	parser:option "--only-server"
		:description
			"Fetch rocks/rockspecs from this server, ignoring other servers"
end

local function fmt_table(t)
	local s = "{"
	local sep = "\n   " -- FIXME: configurable indents

	for _, v in ipairs(t) do
		s = s .. sep .. string.format("%q", v)
		sep = ",\n   "
	end

	return s .. "\n}"
end

local function add_to_depstring(spec, new_deps)
	return spec:gsub("(dependencies%s*=%s*)(%b{})", function(pre, s)
		local tbl = assert(loadstring("return " .. s))()
		for _, v in ipairs(tbl) do
			for _, dep in ipairs(new_deps) do
				if v:match("^" .. util.escape_str(dep)) then
					local S = "%s is already present in the rockspec, aborting"
					log:error(S, dep)
					os.exit(1)
				end
			end
		end

		for _, dep in ipairs(new_deps) do
			table.insert(tbl, dep) -- FIXME: constrain dep's version
		end
		return pre .. fmt_table(tbl)
	end)
end

local INSTALL_MSG = [[
INSTALLING: %s

WARNING: This command will modify your rockspec, %q. Make sure you have a
         backup in case you don't like the results.

         Continue (y/N)?
]]

local function add_deps(args)
	local rspec = false
	if args.rockspec then
		rspec = ("%q"):format(args.rockspec)
	else
		rspec = assert(util.get_first(".", "%.rockspec$"))
	end

	local data = assert(util.slurp(rspec))
	local new_data = add_to_depstring(data, args.new_packages)

	local package_str = table.concat(args.new_packages, " ")

	-- TODO: ask luarocks search if this is a valid package
	local goahead = log:ask(
		INSTALL_MSG,
		table.concat(args.new_packages, " "),
		rspec) ('n')

	if not goahead then
		log:info("Aborting.")
		os.exit(0)
	end

	assert(util.spit(new_data, rspec))
	log:info(
		"%s added to rockspec, now installing.",
		table.concat(args.new_packages, ", "))
end

local function install_all(args)
	local rspec = "*.rockspec"
	if args.rockspec then
		rspec = ("%q"):format(args.rockspec)
	end

	local s = ("build --only-deps %s"):format(rspec)
	if args.server then
		s = ("%s --server=%q"):format(s, args.server)
	end
	if args.only_server then
		s = ("%s --only-server=%q"):format(s, args.only_server)
	end

	util.luarocks(s)
end

function install:run(args)
	if #args.new_packages > 0 then
		add_deps(args)
	end
	install_all(args)
end

return install
