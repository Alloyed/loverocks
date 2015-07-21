package = "loverocks"
version = "0.0.6-1.rockspec"
source = {
   url = "git://github.com/Alloyed/loverocks",
   tag = "v0.0.6"
}
description = {
   summary = "A luarocks <-> love wrapper",
   detailed = [[
LÖVERocks is a CLI wrapper around Luarocks that teaches your LÖVE projects how
to download and use standard luarocks packages. It stores downloaded rocks in
a project-local rocks tree which includes all the necessary config and loaders,
so your entire LÖVE project is self-contained.
   ]],
   homepage = "https://github.com/Alloyed/loverocks",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "etlua ~> 1.2",
   "luafilesystem ~> 1.6",
   "datafile >= 0.2",
   "argparse >= 0.4"
}
build = {
   type = "builtin",
   modules = {
      ["loverocks.api"] = "loverocks/api.lua",
      ["loverocks.argparse"] = "loverocks/argparse.lua",
      ["loverocks.commands"] = "loverocks/commands.lua",
      ["loverocks.commands.help"] = "loverocks/commands/help.lua",
      ["loverocks.commands.init"] = "loverocks/commands/init.lua",
      ["loverocks.commands.install"] = "loverocks/commands/install.lua",
      ["loverocks.commands.list"] = "loverocks/commands/list.lua",
      ["loverocks.commands.lua"] = "loverocks/commands/lua.lua",
      ["loverocks.commands.new"] = "loverocks/commands/new.lua",
      ["loverocks.commands.purge"] = "loverocks/commands/purge.lua",
      ["loverocks.commands.search"] = "loverocks/commands/search.lua",
      ["loverocks.config"] = "loverocks/config.lua",
      ["loverocks.log"] = "loverocks/log.lua",
      ["loverocks.love-versions"] = "loverocks/love-versions.lua",
      ["loverocks.main"] = "loverocks/main.lua",
      ["loverocks.template"] = "loverocks/template.lua",
      ["loverocks.util"] = "loverocks/util.lua",
      ["loverocks.version"] = "loverocks/version.lua"
   },
   copy_directories = {
      "templates"
   },
   platforms = {
      unix = {
         modules = {
            ["loverocks.os"] = "loverocks/os_unix.lua"
         }
      },
      windows = {
         modules = {
            ["loverocks.os"] = "loverocks/os_win.lua"
         }
      }
   },
   install = {
      bin = {
         "bin/loverocks"
      }
   }
}
