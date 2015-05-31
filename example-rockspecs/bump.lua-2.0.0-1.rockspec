package = "bump.lua"
version = "2.0.0-1"
source = {
   url = "git://github.com/kikito/bump.lua",
   tag = "v2.0.0"
}
description = {
   summary = "Lua collision-detection library for axis-aligned rectangles.",
   detailed = "Lua collision-detection library for axis-aligned rectangles. Its main features are:",
   homepage = "http://github.com/kikito/bump.lua",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1"
}
build = {
   type = "builtin",
   modules = {
      bump = "bump.lua",
   }
}
