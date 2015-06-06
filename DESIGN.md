ROCKS
--------
Most love libraries are small collections of lua modules, which luarocks
is pretty good about supporting. See ``example-rockspecs/`` to see how you
would package some common love libraries.

To make a repo from the example rockspecs, do:
```sh
    $ for f in *.rockspec; do luarocks pack $f; done && mkdir -p rocks && mv *.src.rock rocks/
    $ cd rocks && luarocks-admin make_manifest .
```
then upload rocks/ to a server or use it locally.

LOVEROCKS
-------
Ideally, we would like to bundle our rocks modules with our games, so
any rocks we install should go into our game directory, and we should
ignore anything that is external to that directory.

Also, in order to accurately represent the running environment, we need to
register love and the libraries it comes with (luasocket, etc) as their own
dependencies. We can do that by defining a site-specific luarocks config
and using the rocks_provided field. see loverocks_config.lua for more.

Caveat: This disables user-specific config options.

apply both with
```sh
  $ mkdir -p $GAME/rocks
  $ cp rocks_template/* $GAME/rocks/
  $ cd $GAME
  $ alias loverocks="LUAROCKS_CONFIG=rocks/config.lua luarocks --tree='rocks'"
```

LOVE
----
Write a rockspec for your game, add 
```lua
    require "rocks" ()
```
to the top of your conf.lua, and
```sh
  $ loverocks build *.rockspec --only-deps
  $ love .
```
will install all the dependencies listed into "rocks/", where
they can then be loaded like normal modules.

Loverocks presents no barriers to distributing (yet). Just zip up the
directory, including your rocks/ tree, and you should be good.

OPEN QUESTIONS
--------------

C modules can't be loaded from a zip file the same way lua modules can.
Since this is how you usually package love code, we need to do something
special for them.

How much detritus should loverocks leave around, really? What is safe to
.gitignore and what isn't?

Should we use luarocks for packaging, too? Something tells me that .rock
is the wrong format for games but if it could be extended to make .love
files that would be handy.

rockspec files and conf.lua overlap in scope. They should probably share
at least a the data they have in common like package name, love version
etc
