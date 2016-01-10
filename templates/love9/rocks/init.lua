--- Injects a loverocks-compatible module loader into your game.
--  See http://github.com/Alloyed/loverocks for details
--  (c) Kyle McLamb, 2015 <alloyed@tfwno.gf>, MIT License.
--  NOTE: This file can be overwritten without warning! Don't make changes
--  here, but in the loverocks template itself.
--  |version: <%- loverocks_version %>|

local rocks_tree = (...)

local loverocks_paths = {
	rocks_tree .. "/share/lua/5.1/?.lua",
	rocks_tree .. "/share/lua/5.1/?/init.lua",
}

local loverocks_cpaths = {
	rocks_tree .. "/lib/lua/5.1/?"
}

--- Loads loverocks modules.
local function loader(modname)
	local modpath = modname:gsub('%.', '/')
	for _, elem in ipairs(loverocks_paths) do
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

local function mkdir(dir)
	if love.filesystem.createDirectory then
		love.filesystem.createDirectory(dir)
	else
		love.filesystem.mkdir(dir)
	end
end

--- Loads native lockrocks libraries. These modules can either be stored in a
--  folder in the current working directory, in the user's save folder, or
--  inside the .love file itself. In each case though, the module must follow
--  the loverocks folder structure.
local function c_loader(mod_name)
	local os = get_os()
	if not os then
		return "\n\tCannot load LOVERocks modules, OS not found."
	end

	local ext  = os == 'Windows' and ".dll" or ".so"
	local file = mod_name:gsub("%.", "/") .. ext
	local fn   = mod_name:gsub("%.", "_")

	for _, elem in ipairs(loverocks_cpaths) do
		elem = elem:gsub('%?', file)

		local real_dir = love.filesystem.getRealDirectory(elem)
		local save_dir = love.filesystem.getSaveDirectory()
		local elem_dir = elem:gsub("/[^/]+$", "")
		local path     = save_dir .. "/" .. elem
		if real_dir then
			-- this duplicates binaries needlessly, eg. if a dll is in the same
			-- directory as the exe, it'll get copied to the save dir anyways.
			-- Since I can't find a way to tell a real file from a zipped
			-- file, this'll have to do.
			if real_dir ~= save_dir then
				mkdir(elem_dir)
				love.filesystem.write(elem, (love.filesystem.read(elem)))
			end

			return package.loadlib(path, "loveopen_" .. fn) or
			       package.loadlib(path, "luaopen_" .. fn)
		end
	end

	return"\n\tno library '" .. file .. "' in LOVERocks path."
end

--- Installs the LOVERocks package loader if it's not already installed.
--  @param use_external_deps Set to true if you would like to continue
--                           using system-level dependencies in your project.
local function inject(use_external_deps)
	local installed = false
	local c_installed = false

	-- Done in reverse because the modules are most likely
	-- to be installed at the end
	for i=#package.loaders, 1, -1 do
		local i_loader = package.loaders[i]

		if i_loader == loader then
			installed = true
			if c_installed then
				break
			end
		elseif i_loader == c_loader then
			c_installed = true
			if installed then
				break
			end
		end
	end

	if not installed then
		table.insert(package.loaders, loader)
	end

	if not c_installed then
		table.insert(package.loaders, c_loader)
	end

	if not external_deps then
		package.path = ""
		package.cpath = ""
	end
end

return setmetatable({
	inject = inject,
	path = loverocks_paths,
	cpath = loverocks_cpaths,
	loader = loader,
	cloader = c_loader
}, {__call = inject})
