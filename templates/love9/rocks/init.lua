--- Injects luarocks modules installed at ./rocks into your love game.
--  See http://github.com/Alloyed/loverocks for details
--  (c) Kyle McLamb, 2015 <alloyed@tfwno.gf>, MIT License.
--  TODO: Configurable prefixes

local luarocks_paths = {
	"rocks/share/lua/5.1/?.lua",
	"rocks/share/lua/5.1/?/init.lua",
}
local luarocks_cpaths = {
	"rocks/lib/lua/5.1/?"
}

local function loader(modname)
	local modpath = modname:gsub('%.', '/')
	for _, elem in ipairs(luarocks_paths) do
		elem = elem:gsub('%?', modpath)
		if love.filesystem.exists(elem) then
			return love.filesystem.load(elem)
		end
	end
	return "\n\tno module '" .. modname .. "' in LOVERocks path."
end

local function c_loader(mod_name)
	local ext = love.system.getOS() == 'windows' and ".dll" or ".so"
	local file = mod_name:gsub("%.", "/") .. ext
	local fn   = mod_name:gsub("%.", "_")

	for _, elem in ipairs(luarocks_cpaths) do
		elem = elem:gsub('%?', file)
		local real_dir = love.filesystem.getRealDirectory(elem)
		if real_dir then
			local path = real_dir .. "/" .. elem
			return package.loadlib(path, "loveopen_" .. fn) or
			       package.loadlib(path, "luaopen_" .. fn)
		end
		return"\n\tno library '" .. file .. "' in LOVERocks path."
	end
end

local function inject()
	table.insert(package.loaders, loader)
	table.insert(package.loaders, c_loader)

	package.path = ""
	package.cpath = ""
end

return setmetatable({
	inject = inject,
	path = luarocks_paths,
	cpath = luarocks_cpaths,
	loader = loader,
	c_loader = c_loader
}, {__call = inject})
