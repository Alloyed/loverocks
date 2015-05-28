package = "hardoncollider"
version = "scm-0"
source = {
   url = "git://github.com/vrld/HardonCollider"
}
description = {
   summary = "A pure lua collision detection library",
   detailed = [[
	Documentation and examples here:
	http://vrld.github.com/HardonCollider
	]],
   homepage = "http://vrld.github.io/HardonCollider",
   license = "MIT/X11"
}
dependencies = {
   "lua ~> 5.1",
   -- Optional
   -- "class-commons"
}
build = {
   type = "builtin",
   modules = {
      ["hardoncollider.class"]        = "class.lua",
      ["hardoncollider.gjk"]          = "gjk.lua",
      ["hardoncollider.init"]         = "init.lua",
      ["hardoncollider.polygon"]      = "polygon.lua",
      ["hardoncollider.shapes"]       = "shapes.lua",
      ["hardoncollider.spatialhash"]  = "spatialhash.lua",
      ["hardoncollider.vector-light"] = "vector-light.lua"
   }
}
