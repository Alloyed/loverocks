package = "gamera"
version = "1.0.1-1"
source = {
   url = "git://github.com/kikito/gamera",
   tag = "v1.0.1"
}
description = {
   summary = "A camera for [LÖVE](http://love2d.org).",
   detailed = "A camera for [LÖVE](http://love2d.org).",
   homepage = "http://github.com/kikito/gamera",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "love ~> 0.9"
}
build = {
   type = "builtin",
   modules = {
      gamera = "gamera.lua"
   }
}
