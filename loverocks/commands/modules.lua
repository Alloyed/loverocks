local fs     = require 'luarocks.fs'

local modules = {}

function modules.build(parser)
	parser:description(
		"Enumerates lua modules available in a project. " ..
		"In the case of no options, all modules are enumerated.\n" ..
		"NOTE: No guarantees are made about order, and duplicates may occur.")
	parser:flag "-r" "--rocks"
		:description
			"Enumerate modules installed using LOVErocks."
	parser:flag "-s" "--system"
		:description
			"Enumerate modules shipped with Lua/LOVE."
	parser:flag "-l" "--local"
		:description
			"Enumerate project-local modules."
end

function modules.file_to_module(path)
	local sep = "/"

	local no_ext = path
		:gsub(".init%.lua$",""):gsub("%.lua$","")
		:gsub("%.dll$", ""):gsub("%.so$","")

	if no_ext:match("%.") then
		return nil, "path has invalid character"
	end
	return (no_ext:gsub(sep, "."))
end

local function p(...)
	local t = {}
	for i=1, select('#', ...) do
		local v = select(i, ...)
		if v then table.insert(t, v) end
	end
	return table.concat(t, "/")
end

function modules.list_modules(fn, prefix, inner)
	local dir = p(prefix, inner)
	for f in fs.dir(dir) do
		local path = p(prefix, inner, f)
		if fs.is_dir(path) then
			modules.list_modules(fn, prefix, p(inner, f))
		else
			if f:match("%.lua$") or f:match("%.dll$") or f:match("%.so$") then
				local mod = modules.file_to_module(p(inner, f))
				if mod then
					fn(mod)
				end
			end
		end
	end
end

function modules.run(conf, args)
	local provided = require 'loverocks.module_data'
	if not args.love and not args['local'] and not args.rocks then
		args.love     = true
		args['local'] = true
		args.rocks    = true
	end

	if args.love then
		for _, v in ipairs(provided.lua["5.1"])    do print(v) end
		for _, v in ipairs(provided.luajit["2.1"]) do print(v) end
		for _, v in ipairs(provided.love["0.9.2"]) do print(v) end
	end

	if args['local'] then
		modules.list_modules(print, ".")
	end

	if args.rocks then
		local rocks_tree = "rocks"
		if conf and conf.rocks_tree then
			rocks_tree = conf.rocks_tree
		end

		if fs.exists(rocks_tree .. "/share/lua/5.1") then
			modules.list_modules(print, rocks_tree .. "/share/lua/5.1")
		end

		if fs.exists(rocks_tree .. "/lib/lua/5.1") then
			modules.list_modules(print, rocks_tree .. "/lib/lua/5.1")
		end
	end
end

return modules
