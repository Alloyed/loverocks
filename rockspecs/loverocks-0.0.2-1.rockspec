package = "loverocks"
version = "0.0.2-1"
source = {
   url = "git://github.com/Alloyed/loverocks",
   tag = "v0.0.2"
}
description = {
   summary = "A luarocks <-> love wrapper",
   -- detailed = [[]],
   homepage = "https://github.com/Alloyed/loverocks",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.4",
   "argparse ~> 0.3",
   "etlua ~> 1.2",
   "luafilesystem ~> 1.6",
   "datafile ~> 0.1"
}
build = {
   type = "builtin",
   modules = {
      ["loverocks.main"]             = "loverocks/main.lua",
      ["loverocks.util"]             = "loverocks/util.lua",
	  ["loverocks.log"]              = "loverocks/log.lua",
	  ["loverocks.versions"]         = "loverocks/versions.lua",
      ["loverocks.commands"]         = "loverocks/commands.lua",
      ["loverocks.commands.init"]    = "loverocks/commands/init.lua",
      ["loverocks.commands.new"]     = "loverocks/commands/new.lua",
      ["loverocks.commands.lua"]     = "loverocks/commands/lua.lua",
      ["loverocks.commands.install"] = "loverocks/commands/install.lua",
      ["loverocks.commands.help"]    = "loverocks/commands/help.lua",
   },
   install = {
	   bin = {"bin/loverocks"}
   },
   copy_directories = {
	   "templates",
   }
}
