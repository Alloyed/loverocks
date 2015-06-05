package = "sti"
version = "scm-1"
source = {
   url = "git://github.com/karai17/Simple-Tiled-Implementation"
}
description = {
   summary = "Simple Tiled Implementation is a [**Tiled Map Editor**][Tiled] library designed for the *awesome* [**LÖVE**][LOVE] framework.",
   detailed = "Simple Tiled Implementation is a [**Tiled Map Editor**][Tiled] library designed for the *awesome* [**LÖVE**][LOVE] framework. Please read the library [**documentation**][dox] to learn how it all works!",
   homepage = "http://github.com/karai17/Simple-Tiled-Implementation",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "love ~> 0.9"
}
build = {
   type = "builtin",
   modules = {
      ["sti.framework.love"] = "framework/love.lua",
      ["sti"] = "init.lua",
      ["sti.map"] = "map.lua"
   }
}
