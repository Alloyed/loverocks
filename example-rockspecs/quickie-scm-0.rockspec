package = "quickie"
version = "scm-0"
source = {
   url = "git://github.com/vrld/Quickie"
}
description = {
   summary = "Quickie is an immediate mode gui library for.",
   detailed = [[
   Quickie is an [immediate mode gui][IMGUI] library for [L&Ouml;VE][LOVE].
   Initial inspiration came from the article
   [Sol on Immediate Mode GUIs (IMGUI)][Sol]. You should check it out to
   understand how Quickie works.]],
   homepage = "http://github.com/vrld/Quickie",
   license = "MIT/X11"
}
dependencies = {
   "lua ~> 5.1",
   "love ~> 0.9"
}
build = {
   type = "builtin",
   modules = {
      ["quickie.button"] = "button.lua",
      ["quickie.checkbox"] = "checkbox.lua",
      ["quickie.core"] = "core.lua",
      ["quickie.group"] = "group.lua",
      ["quickie.init"] = "init.lua",
      ["quickie.input"] = "input.lua",
      ["quickie.keyboard"] = "keyboard.lua",
      ["quickie.label"] = "label.lua",
      ["quickie.mouse"] = "mouse.lua",
      ["quickie.slider"] = "slider.lua",
      ["quickie.slider2d"] = "slider2d.lua",
      ["quickie.style-default"] = "style-default.lua",
      ["quickie.utf8"] = "utf8.lua"
   }
}
