if love.filesystem then
   -- if you use a custom rocks tree, be sure to change this too
   require "my-rocks-folder" () 
   -- this flag will enable external modules. Useful for testing, but it's a
   -- bad idea to ship a game with this.
   require "my-rocks-folder" (true)
end

function love.conf(t)
   -- Loverocks reads t.version to populate the dependency tree, so you can
   -- use version-specific modules. If unspecified, Loverocks will use the
   -- latest release version.
   t.version = "0.10.0"

   -- Change this to change which folder loverocks installs its modules to.
   t.rocks_tree = "my-rocks-folder"

   -- Use this to specify alternate project-specific rocks servers, so you
   -- don't need to specify them on the command line all the time.
   -- The server priorities go:
   -- CLI -> conf.lua servers -> luarocks servers
   -- earlier servers take precedence.
   t.rocks_servers = { "http://alloyed.me/shared/rocks" }

   -- The format of t.dependencies is the same as the dependencies field in a
   -- rockspec. additional documentation here:
   --   https://git.io/vuF6U
   t.dependencies = {
      "bump ~> 3",   -- install bump.lua version 3
      "dkjson >= 2", -- install a version of dkjson greater than 2.0
      "repler",      -- install any version of repler, including SCM versions
   }

   -- Loverocks ignores all other fields. That means if you misspell a
   -- field, Loverocks won't notice, so be careful.
end
