package = "hump"
version = "scm-0"
source = {
   url = "git://github.com/vrld/hump"
}
description = {
   summary = "Hump is a small collection of tools for developing games with LöVE.",
   detailed = "Hump is a small collection of tools for developing games with LöVE.",
   homepage = "http://vrld.github.com/hump/",
   license = "MIT/X11"
}
dependencies = {
   "lua ~> 5.1",
   "love ~> 0.9" -- hump.camera uses love.graphics
}
build = {
   type = "builtin",
   modules = {
      ["hump.camera"]       = "camera.lua",
      ["hump.class"]        = "class.lua",
      ["hump.gamestate"]    = "gamestate.lua",
      ["hump.signal"]       = "signal.lua",
      ["hump.timer"]        = "timer.lua",
      ["hump.vector"]       = "vector.lua",
      ["hump.vector-light"] = "vector-light.lua",
   }
}
