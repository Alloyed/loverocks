-- Setup project environments.
local New         = require 'loverocks.commands.new'
local fs          = require 'luarocks.fs'
local loadconf    = require 'loverocks.loadconf'
local before_each = require 'busted'.before_each
local after_each  = require 'busted'.after_each

local env = {}

function env.start()
	New.run(nil, {
		project      = "my-project",
		template     = "love",
		love_version = "0.10.1",
	})
	fs.change_dir("my-project")
	loadconf._config = nil
	_G.conf = assert(loadconf.require(nil))
end

function env.stop()
	assert(_G.cwd)
	fs.change_dir(_G.cwd)
	fs.delete("my-project")
	assert(not fs.is_dir("my-project"))
end

function env.setup()
	_G.cwd = fs.current_dir()
	before_each(env.start)
	after_each(env.stop)
end

return env
