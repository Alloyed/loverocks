local log = require 'loverocks.log'
local etlua = require 'etlua'
local util = require 'loverocks.util'

local template = {}

local function raw_version(s)
	return string.format("%q", s:gsub("-1$", ""))
end

function template.new_env(vs, name)
	return {
		project_name = name,
		versions = vs,
		raw_version = raw_version,
		loverocks_version = require 'loverocks.version',
	}
end

function template.apply(files, env)
	local done = {}
	for name, file in pairs(files) do
		if type(file) == 'table' then
			done[name] = template.apply(file, env)
		elseif not name:match("%.swp$") then
			local new_name = name
			if new_name:match("PROJECT") then
				new_name = new_name:gsub("PROJECT", env.project_name)
			end

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
	if require 'loverocks.os' == "unix" then
		return util.dpath("templates/" .. name)
	else
		-- hack to avoid datafile's inability to resolve directories on windows
		local path, err = util.dpath("templates/" .. name .. "/.gitignore")
		if path then return path:gsub("%/%.gitignore", "") end
		return nil, err
	end
end

return template
