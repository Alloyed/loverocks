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
	local fn = assert(loadstring(f:read('*a'), "conf.lua"))
	setfenv(fn, self.CONFIG)
	fn()
	if self.CONFIG.luarocks == nil then
		log:error("Config file %q must have field 'luarocks'", path)
	end
	self.CONFIG.loverocks_config = path
end

local command_names = {
	"luarocks-5.1", -- arch
	"luarocks5.1",   
	"luarocks51", 
	"luarocks",     -- last attempt
}

local config_fmt = [[
luarocks = %q

]]
local function stropen(cli)
	local f = io.popen(cli, 'r')
	local s = f:read('*a')
	f:close()
	return s
end

local no_luarocks_fmt = [[
We couldn't find a copy of luarocks that uses lua 5.1. If you know you have one
installed, please tell us by creating the file ~/.config/loverocks/conf.lua and
adding:

	luarocks = "/usr/bin/my-luarocks-command"

with the appropriate path to your luarocks command.
]]

local function find_luarocks(self)
	for _, name in ipairs(command_names) do
		local v = stropen(name .. " help"):match("Lua version: ([^%s]+)")
		local path = UNIX_PATH
		if v == "5.1" then
			assert(lfs.mkdir(path))
			local f = assert(io.open(path .. "conf.lua", 'w'))
			f:write(string.format(config_fmt, name))
			f:close()

			self.CONFIG.luarocks = name
			self.CONFIG.loverocks_config = path .. "conf.lua"
			return
		end
	end

	log:error(no_luarocks_fmt)
end

function config:load()
	local f, path = datafile.open("loverocks/conf.lua", 'r', "config")
	if f then
		apply_config(self, f, path)
	else
		find_luarocks(self)
	end
end

function config:get(var)
	return self.CONFIG[var]
end

return config
