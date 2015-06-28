local log = require 'loverocks.log'
local versions = require 'loverocks.love-versions'
local etlua = require 'etlua'
local config = require 'loverocks.config'
local util = require 'loverocks.util'

local template = {}

local function raw_version(s)
	return string.format("%q", s:gsub("-1$", ""))
end

local function depstring(s)
	return ("\"love ~> %s\""):format(s:match("%d+.%d+"))
end

function template.new_env(name, v)
	return {
		project_name = name,
		versions = versions.get(v),
		raw_version = raw_version,
		loverocks_version = require 'loverocks.version',
		depstring = depstring,
	}
end

function template.apply(files, env)
	local done = {}
	for name, file in pairs(files) do
		if type(file) == 'table' then
			done[name] = template.apply(file, env)
		elseif not name:match("%.swp$") then
			local new_name = name:gsub("PROJECT", env.project_name)

			local d, err = etlua.render(file, env)
			if not d then
				log:error("%s", name .. ": " .. err)
			end

			done[new_name] = d
		end
	end

	return done
end

function template.path(name)
	local override = config("loverocks_templates")
	if override then
		override = override .. "/" .. name
		local f, err = io.open(override)
		if f then
			return override
		end
	end

	if config('os') == "unix" then
		return util.dpath("templates/" .. name)
	else
		-- hack to avoid datafile's inability to resolve directories on windows
		local path, err = util.dpath("templates/" .. name .. "/.gitignore")
		if path then return path:gsub("%/%.gitignore", "") end
		return nil, err
	end

end

return template
