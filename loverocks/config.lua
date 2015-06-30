-- load configuration
local datafile = require 'datafile'
local log      = require 'loverocks.log'
local util     = require 'loverocks.util'
local config = {}

local home = os.getenv("HOME")
local xdg_config = os.getenv("XDG_CONFIG_HOME")
local win_config = os.getenv("APPDATA")

-- FIXME: home is not a reliable indicator of OS
local PATH
if xdg_config then
	PATH = xdg_config .. "/loverocks"
elseif home then
	PATH = home .. "/.config/loverocks"
elseif win_config then
	PATH = win_config .. "/loverocks"
else
	log:error("No appropriate config file path found.")
end

function config:open(fname, env)
	local fn
	if setfenv then -- lua 5.1
		fn, err = loadfile(fname)
		if not fn then return nil, err end
		setfenv(fn, env)
	else -- lua >= 5.2
		fn, err = loadfile(fname, 't', env)
		if not fn then return nil, err end
	end
	fn()
	return env
end

local function apply_config(self, path)
	self.CONFIG = {}
	self:open(path, self.CONFIG)
	if self.CONFIG.luarocks == nil then
		log:error("Config file %q must have field 'luarocks'", path)
	end
	self.CONFIG.loverocks_config = path
end

local global_rock
if home then
	global_rock = "/usr/local/bin/luarocks"
else
	global_rock = ([["%s/LuaRocks/2.2/luarocks.bat"]]):format(os.getenv "ProgramFiles") -- installed via install.bat
end

local command_names = {
	global_rock,
	"luarocks-5.1",              -- arch linux installed
	"luarocks5.1",
	"luarocks51",
	"luarocks",                  -- least specific
}

if home then
	table.insert(command_names, 1, home .. "/.luarocks/bin/luarocks") -- local rock. not possible on windows
end

local config_fmt = [[
luarocks = %q

]]

local no_luarocks_fmt = [[
We couldn't find a copy of luarocks that uses lua 5.1. If you know you have one
installed, please tell us by creating the file ~/.config/loverocks/conf.lua and
adding:

	luarocks = "/usr/bin/my-luarocks-command"

with the appropriate path to your luarocks command.
]]

local bad_luarocks_fmt = [[
bad luarocks: %s

We found a copy of luarocks configured for lua 5.1, but it happens to disable
user-configs, which is a core part of loverocks. Either recompile or bug your
package maintainer about it. If you'd like to use another luarocks install
instead, you can always create the file ~/.config/loverocks/conf.lua and add:

	luarocks = "/usr/bin/my-luarocks-command"

with the appropriate path to your cusom luarocks.
]]

local function find_luarocks(self)
	self.CONFIG = {}
	local bad_luarocks = false

	for _, name in ipairs(command_names) do
		local help = util.stropen(name .. " help")
		-- FIXME: also check for version number. 2.2.2 and up only.
		local v = help:match("Lua version: ([^%s]+)")
		local invalid_config = help:match("User%s*:%s*disabled in this LuaRocks installation.")

		if v == "5.1" and invalid_config then
			bad_luarocks = util.stropen("which " .. name)
		elseif v == "5.1" then
			local filename = PATH .. "/conf.lua"
			local ok, err = util.mkdir_p(PATH)
			if not ok and not err == "file exists" then
				error(err)
			end
			local f = assert(io.open(filename, 'w'))
			f:write(string.format(config_fmt, name))
			f:close()

			self.CONFIG.luarocks = name
			self.CONFIG.loverocks_config = filename
			log:info("Found a suitable copy of luarocks at %s", self.CONFIG.luarocks)
			return
		end
	end

	if bad_luarocks then
		log:error(bad_luarocks_fmt, bad_luarocks)
	else
		log:error(no_luarocks_fmt)
	end
end

function config:load()
	if not self.CONFIG then
		local file, path = datafile.open("loverocks/conf.lua", 'r', "config")
		if file then
			file:close()
			apply_config(self, path)
		else
			find_luarocks(self)
		end
		local ok, err = pcall(require, "loverocks.os")
		self.CONFIG.os = ok and err or "unix"
	end
end

function config:get(var)
	self:load()
	return self.CONFIG[var]
end

return setmetatable(config, {__call = config.get})
