-- Setup project environments.
local New         = require 'loverocks.commands.new'
local s_util      = require 'spec.util'
local loadconf    = require 'loverocks.loadconf'
local lfs         = require 'lfs'
local before_each = require 'busted'.before_each
local after_each  = require 'busted'.after_each

local env = {}

function env.start()
	New.run(nil, {
		project      = "my-project",
		template     = "love",
		love_version = "0.10.1",
	})
	lfs.chdir("my-project")
	loadconf._config = nil
	_G.conf = assert(loadconf.require(nil))
end

function env.stop()
	assert(_G.cwd)
	lfs.chdir(_G.cwd)
	assert(s_util.rm("my-project"))
end

function env.setup()
	_G.cwd = lfs.currentdir()
	before_each(env.start)
	after_each(env.stop)
end

return env
