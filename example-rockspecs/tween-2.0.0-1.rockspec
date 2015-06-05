package = "tween"
version = "2.0.0-1"
source = {
   url = "git://github.com/kikito/tween.lua",
   tag = "v2.0.0"
}
description = {
   summary = "Tweening in Lua.",
   detailed = [[
tween.lua is a small library to perform [tweening](http://en.wikipedia.org/wiki/Tweening) in Lua. It has a minimal
interface, and it comes with several easing functions.]],
   homepage = "http://github.com/kikito/tween.lua",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      tween = "tween.lua"
   }
}
