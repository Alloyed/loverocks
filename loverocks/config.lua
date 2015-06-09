-- load configuration
local datafile = require 'datafile'
local config = {}

local UNIX_PATH = os.getenv("XDG_CONFIG_HOME")
if UNIX_PATH then
	UNIX_PATH = UNIX_PATH .. "/loverocks/"
else
	UNIX_PATH = os.getenv("HOME") .. "/.config/loverocks/"
end
	
local WIN_PATH  = "FIXME"

local function apply_config(self, f, path)
	self.CONFIG = {}
	local fn
	if setfenv then -- lua 5.1
		fn = assert(loadstring(f:read('*a'), "conf.lua"))
		setfenv(fn, self.CONFIG)
	else -- lua >= 5.2
		fn = assert(load(f:read('*a'), "conf.lua", 't', self.CONFIG))
	end
	fn()
	if self.CONFIG.luarocks == nil then
		log:error("Config file %q must have field 'luarocks'", path)
	end
	self.CONFIG.loverocks_config = path
end

local LUAROCKS_BIN = os.getenv("HOME") .. "/.luarocks/bin"

local command_names = {
	LUAROCKS_BIN .. "/luarocks", -- most specific
	"luarocks-5.1",              -- arch linux uses this
	"luarocks5.1",
	"luarocks51",
	"luarocks",                  -- least specific
}

--
-- This definition is identical to the one in util.lua
-- However, since config.lua is intended to sit lower on the dependency chain 
-- it can't use any util functions, so instead we just copy-pasted it here :p
local function stropen(cli)
	local f = io.popen(cli, 'r')
	local s = f:read('*a')
	f:close()
	return s
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
		local help = stropen(name .. " help")
		local v = help:match("Lua version: ([^%s]+)")
		local invalid_config = help:match("User%s*:%s*disabled in this LuaRocks installation.")

		if v == "5.1" and invalid_config then
			bad_luarocks = stropen("which " .. name)
		elseif v == "5.1" then
			local path = UNIX_PATH
			local filename = path .. "conf.lua"
			local ok, err = lfs.mkdir(path)
			if not ok and not err == "file exists" then
				error(err)
			end
			local f = assert(io.open(filename, 'w'))
			f:write(string.format(config_fmt, name))
			f:close()

			self.CONFIG.luarocks = name
			self.CONFIG.loverocks_config = filename
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
	local file, path = datafile.open("loverocks/conf.lua", 'r', "config")
	if file then
		apply_config(self, file, path)
		file:close()
	else
		find_luarocks(self)
	end
end

function config:get(var)
	return self.CONFIG[var]
end

return setmetatable(config, {__call = config.get})
