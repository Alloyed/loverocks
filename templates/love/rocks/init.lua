--- Injects a loverocks-compatible module loader into your game.
--  See http://github.com/Alloyed/loverocks for details
--  (c) Kyle McLamb, 2016 <alloyed@tfwno.gf>, MIT License.
<%- rocks_warning %>
--  |version: <%- loverocks_version %>|

local rocks_tree = (...)

local rocks = {}

rocks.paths = {
	rocks_tree .. "/share/lua/5.1/?.lua",
	rocks_tree .. "/share/lua/5.1/?/init.lua",
}

rocks.cpaths = {
	rocks_tree .. "/lib/lua/5.1/?"
}

---
-- Loads loverocks modules.
function rocks.loader(modname)
	local modpath = modname:gsub('%.', '/')
	for _, elem in ipairs(rocks.paths) do
		elem = elem:gsub('%?', modpath)
		if love.filesystem.isFile(elem) then
			return love.filesystem.load(elem)
		end
	end

	return "\n\tno module '" .. modname .. "' in LOVERocks path."
end

local function get_os()
	if love.system and love.system.getOS then -- >= 0.9.0
		return love.system.getOS()
	elseif love._os then -- < 0.9.0
		return love._os
	else
		-- either love.system wasn't loaded or something else happened
		return nil
	end
end

local function can_open(fname)
	local f, err = io.open(fname, 'r')
	if f == nil then
		return false
	end
	f:close()
	return true
end

local function c_loader(modname, fn_name)
	local os = get_os()
	if not os then
		return "\n\tCannot load native LOVERocks modules, OS not found."
	end

	local ext  = os == 'Windows' and ".dll" or ".so"
	local file = modname:gsub("%.", "/") .. ext

	for _, elem in ipairs(rocks.cpaths) do
		elem = elem:gsub('%?', file)

		local base = nil
		if love.filesystem.isFused() then
			base = love.filesystem.getSourceBaseDirectory()
			if can_open(base .. "/" ..elem) == false then
				base = nil -- actually, file not found
			end
		elseif love.filesystem.exists(elem) then
			base = love.filesystem.getRealDirectory(elem)
		end

		if base then
			local path = base .. "/" .. elem
			local lib, err1 = package.loadlib(path, "loveopen_"..fn_name)
			if lib then return lib end

			local err2
			lib, err2 = package.loadlib(path, "luaopen_"..fn_name)
			if lib then return lib end

			if err1 == err2 then
				return "\n\t"..err1
			else
				return "\n\t"..err1.."\n\t"..err2
			end
		end
	end

	return "\n\tno library '" .. file .. "' in LOVERocks path."
end

--- 
--  Loads native loverocks libraries. In fused mode, these should be placed in
--  the same directory as the game binary. In non-fused(source) mode these can
--  either be placed in the game's saveDirectory or within the game's source if
--  it is run from a folder. Notably, there is no way to load a library that
--  is packed into a love file.
function rocks.c_1_loader(modname)
	return c_loader(modname, modname:gsub("%.", "_"))
end

---
-- Loads native libraries using the "all-in-one" technique supported by vanilla
-- lua and used by libraries luasec to compile several modules into a
-- single library. It shares the same path rules as `rocks.c_1_loader`.
function rocks.c_all_loader(modname)
	local base_mod = modname:match("^.+%.")
	if base_mod then
		return c_loader(base_mod, modname:gsub("%.", "_"))
	end
end

---
-- Installs the LOVERocks package loader if it's not already installed.
-- @param use_external_deps Set to a truthy value if you would like to continue
--                          using system-level dependencies in your project.
function rocks.inject(use_external_deps)
	if package._loverocks then return rocks end

	table.insert(package.loaders, rocks.loader)
	table.insert(package.loaders, rocks.c_1_loader)
	table.insert(package.loaders, rocks.c_all_loader)
	package._loverocks = true

	if not external_deps then
		-- It would be nice to just yoink the native loaders out entirely
		package.path = ""
		package.cpath = ""
	end

	return rocks
end

---
-- Attempts to `require` the given module, but will suggest that the user try
-- manually installing dependencies if they aren't found. This can be useful
-- for source distribution. Behaves like `require` when in fused mode.
function rocks.require(modname)
	if love.filesystem.isFused() then return require(modname) end

	local ok, err_or_mod = pcall(require, modname)
	if not ok then
		error(string.format([[

Dependency not found: %s
If you downloaded a source package (a.k.a a ".love" file),
you can try installing the dependencies using LOVERocks:

	$ loverocks --game <my_game.love> deps

More info at <https://github.com/Alloyed/loverocks>

%s
]], modname, err_or_mod))
	end

	return err_or_mod
end

return setmetatable(rocks, {__call = rocks.inject})
