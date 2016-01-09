--- Injects luarocks modules installed at ./rocks into your love game.
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
	for _, elem in ipairs(luarocks_paths) do
		elem = elem:gsub('%?', modpath)
		if love.filesystem.isFile(elem) then
			return love.filesystem.load(elem)
		end
	end
	return "\n\tno module '" .. modname .. "' in LOVERocks path."
end

--- Loads native lockrocks libraries. These modules can either be stored in a
--  folder in the current working directory, in the user's save folder, or
--  inside the .love file itself. In each case though, the module must follow
--  the loverocks folder structure.
local function c_loader(mod_name)
	if not love.system then return "\n\tCannot load native modules, love.system not initialized." end
	local ext = love.system.getOS() == 'windows' and ".dll" or ".so"
	local file = mod_name:gsub("%.", "/") .. ext
	local fn   = mod_name:gsub("%.", "_")

	for _, elem in ipairs(luarocks_cpaths) do
		elem = elem:gsub('%?', file)

		local real_dir = love.filesystem.getRealDirectory(elem)
		if real_dir then
			-- this duplicates binaries needlessly, eg. if a dll is in the same
			-- directory as the exe, it'll get copied to the save dir anyways.
			-- Since I can't find way to tell a real file from a zipped file,
			-- this'll have to do.
			if real_dir ~= love.filesystem.getSaveDirectory() then
				love.filesystem.write(elem, love.filesystem.read(elem))
			end

			local path = save_dir .. "/" .. elem
			return package.loadlib(path, "loveopen_" .. fn) or
			       package.loadlib(path, "luaopen_" .. fn)
		end
		return"\n\tno library '" .. file .. "' in LOVERocks path."
	end
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
	path = luarocks_paths,
	cpath = luarocks_cpaths,
	loader = loader,
	cloader = c_loader
}, {__call = inject})
