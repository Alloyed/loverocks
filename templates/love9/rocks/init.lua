--- Injects luarocks modules installed at ./rocks_modules into your love game.
--  See http://github.com/Alloyed/loverocks for details
--  (c) Kyle McLamb, 2015 <alloyed@tfwno.gf>, MIT License.
--  TODO: Configurable prefixes, binary modules

local function inject()
	local luarocks_paths = {
		"rocks/share/lua/5.1/?.lua",
		"rocks/share/lua/5.1/?/init.lua",
	}
	if love.filesystem.getRequirePath then -- 0.10
		local all_paths = {unpack(luarocks_paths)}
		table.insert(all_paths, love.filesystem.getRequirePath())
		local path = table.concat(all_paths, ';')
		love.filesystem.setRequirePath(path)
		package.path = "" -- Don't let outside files seep in
	else
		local function loader(modname)
			local modpath = modname:gsub('%.', '/')
			for _, elem in ipairs(luarocks_paths) do
				elem = elem:gsub('%?', modpath)
				if love.filesystem.exists(elem) then
					return love.filesystem.load(elem)
				end
			end
			return "\n no module '" .. modname .. "'  in LOVERocks path."
		end
		table.insert(package.loaders, loader)
	end
end

return setmetatable({inject = inject}, {__call = inject})
