package = "anim8"
version = "2.1.0-1"
source = {
   url = "git://github.com/kikito/anim8",
   tag = "v2.1.0"
}
description = {
   summary = "Animation library for [LÖVE](http://love2d.org).",
   detailed = "Animation library for [LÖVE](http://love2d.org).",
   homepage = "http://github.com/kikito/anim8",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "love ~> 0.9"
}
build = {
   type = "builtin",
   modules = {
      anim8 = "anim8.lua",
   }
}
