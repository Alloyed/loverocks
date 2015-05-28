Loverocks
=========
A project that will (eventually) provide a full compatibility layer
between LÖVE[1] and luarocks[2]. At the moment this doc should be
considered a design doc for an eventual CLI tool automating the process.

1. https://love2d.org
2. https://luarocks.org

Libraries
--------
most love libraries are small collections of lua modules, which luarocks
is pretty good about supporting. See <example-rocks> to see how you
would package some common love libraries.

To make a repo from the example rocks, do:
```sh
	$ for f in *.rockspec; do luarocks pack $f; done && mkdir -p rocks && mv *.src.rock rocks/
    $ luarocks-admin make_manifest rocks
```
then upload rocks/ to a server or use it locally.

LOVE
----
Write a rockspec for your game, copy in rocks.lua, add 
```lua
    require "rocks" ()
```
to the top of your conf.lua, and
```sh
  $ alias loverocks="luarocks --tree='rocks_modules'
  $ loverocks build *.rockspec --only-deps
  $ love .
```
will install all the dependencies listed into "rocks_modules", where
they can be required like normal.

OPEN QUESTIONS
--------------

C modules can't be loaded from a zip file the same way lua modules can.
Since this is how you usually package love code, we need to do something
special. 
