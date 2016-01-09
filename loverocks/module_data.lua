-- All modules shipped with love2d: changes depending on version and
-- compile-time flag.
--
-- to get the list of modules make a project with this main.lua:
--
--   for k, _ in pairs(package.loaded) do print(k) end
--   for k, _ in pairs(package.preload) do print(k) end
--   love.event.quit()
--
-- and then:
--
--   $ love . | sort | uniq > modules
--
-- then remove conf, main, and then format to table.


local modules = {}

modules.lua = {}
modules.lua["5.1"] = {
"coroutine",
"debug",
"_G",
"io",
"math",
"os",
"package",
"string",
"table",
}

modules.luajit = {}
modules.luajit["2.1"] = {
"bit",
"ffi",
"jit",
"jit.opt",
"jit.profile",
"jit.util",
"table.clear",
"table.new",
}

modules.love = {}
modules.love["0.9.2"] = { -- {{{
"enet",
"love",
"love.audio",
"love.boot",
"love.event",
"love.filesystem",
"love.font",
"love.graphics",
"love.image",
"love.joystick",
"love.keyboard",
"love.math",
"love.mouse",
"love.physics",
"love.sound",
"love.system",
"love.thread",
"love.timer",
"love.window",
"ltn12",
"mime",
"mime.core",
"socket",
"socket.core",
"socket.ftp",
"socket.http",
"socket.smtp",
"socket.tp",
"socket.url",
"utf8",
} -- }}}

modules.love["0.10.0"] = { -- {{{
"enet",
"love",
"love.audio",
"love.boot",
"love.event",
"love.filesystem",
"love.font",
"love.graphics",
"love.image",
"love.joystick",
"love.keyboard",
"love.math",
"love.mouse",
"love.nogame",
"love.physics",
"love.sound",
"love.system",
"love.thread",
"love.timer",
"love.touch",
"love.video",
"love.window",
"ltn12",
"mime",
"mime.core",
"socket",
"socket.core",
"socket.ftp",
"socket.http",
"socket.smtp",
"socket.tp",
"socket.url",
"utf8",
} -- }}}

return modules
