local util = require 'loverocks.util'
local log = require 'loverocks.log'

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
	parser:option "--only-server"
		:description "Fetch rocks/rockspecs from this server, ignoring other servers"
end

local function parse_rockspec(rspec)
	local s = util.slurp(rspec)

	local s, e, tbl_s = s:find()

	assert(s, "dependency table not found")
	local tbl =	print (require 'inspect' (tbl))
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

local function update_deps(spec, new_dep)
	return spec:gsub("(dependencies%s*=%s*)(%b{})", function(pre, s)
		local tbl = assert(loadstring("return " .. s))()
		for _, v in ipairs(tbl) do
			if v:match("^" .. util.escape_str(new_dep)) then
				log:error("%s is already present in the rockspec, aborting", new_dep)
				os.exit(1)
			end
		end

		table.insert(tbl, new_dep) -- FIXME: constrain new_dep's version
		return pre .. fmt_table(tbl)
	end)
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

local function install_one(args)
	local rspec = false
	if args.rockspec then
		rspec = ("%q"):format(args.rockspec)
	else
		rspec = assert(util.get_first(".", "%.rockspec$"))
	end

	local data = assert(util.slurp(rspec))
	local new_data = update_deps(data, args.new_package)

	-- TODO: ask luarocks search if this is a valid package
	local a = log:ask([[
INSTALLING: %s

WARNING: This command will modify your rockspec, %q. Make sure you have a
         backup in case you don't like the results.

         Continue(y/N)?]], args.new_package, rspec) ('n')
	if not a then
		log:info("Aborting.")
		os.exit(0)
	end

	assert(util.spit(new_data, rspec))
	log:info("%s added to rockspec, now installing.", args.new_package)
	install_all(args)
end

function install:run(args)
	if args.new_package then
		install_one(args)
	else
		install_all(args)
	end
end

return install
