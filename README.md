LOVEROCKS
=========
LÖVERocks is a CLI wrapper around [luarocks][L] that teaches your [LÖVE][O]
projects how to download and use standard luarocks packages.

[L]: https://luarocks.org
[O]: https://love2d.org

Installing
----------
LÖVERocks can itself be installed using luarocks. Just run

```shell
$ luarocks install loverocks
```

and make sure the directory you installed to is in your ``$PATH`` and
you should be good to go. If you don't have luarocks installed already,
here are installation instructions for [Unix][U] and [Windows][W].

As of 2015.5.30 It has only been tested on a Unix system, using Lua 5.1
and luarocks 2.2.2. If you've gotten it working someplace else, tell me
either with a github issue or by emailing <alloyed@tfwno.gf>.

[U]: https://github.com/keplerproject/luarocks/wiki/Installation-instructions-for-Unix
[W]: https://github.com/keplerproject/luarocks/wiki/Installation-instructions-for-Windows

Using
-----
The LÖVErocks CLI tool is named `loverocks`. You can learn more about
the options and commands it supports by running:

```shell
$ loverocks help
```

To create a new LÖVERocks-managed project, use:

```shell
$ loverocks new my-project
```

If you already have a LÖVE project you'd like to manage with luarocks, do:

```shell
$ loverocks init my-project
```

instead.

This will install the necessary shims and config files into `my-project/`.
This includes:
* A `rocks/` directory to store your modules.
* A `my-project-scm-1.rockspec` file, which you can use to declare your
  dependencies.
* A `conf.lua`, which is configured to add your rocks modules to the
  search path. You can always comment out

  ```lua
  require 'rocks' ()
  ```

  to disable LOVERocks and only use local files, and uncomment it to bring it
  back.
* A `.gitignore` tuned to the needs of LÖVERocks. **If you do not use Git,
  please remember to look over .gitignore and adapt it to your SCM!**

Now you can start working on your project. Lets say you decide you need
to use dkjson in your project. To install it, all you need to do is add

```lua
    "dkjson ~> 2"
```

to your dependencies list in `my-project-scm-1.rockspec`, and run

```shell
$ loverocks install
```

Now you have the latest possible version of dkjson 2, bugfixes included.
You can use it like any other top-level module, with

```lua
local json = require 'dkjson'
```

This does not complicate sharing your game, either. Since all modules
are stored locally, and external modules are explicitly disabled, you
can continue packaging your game the way you always have:

```shell
$ loverocks lua purge
$ loverocks install
$ zip -r my-project.love *
```

will refresh your package cache and install everything, rocks modules
included, into `my-project.love`.

Libraries
---------
If you are a library writer, good news! You do not have to do anything
special to support LÖVERocks. Just follow the
[Luarocks documentation][M] and you should be fine. Just remember, if
you depend on LÖVE modules in your code, be sure to make that explicit.
For example, if you support LÖVE 0.8 and 0.9, use the dependency string:

```lua
    "love >= 0.8, < 0.10"
```

and LÖVERocks will automatically check that for you.

[M]: https://github.com/keplerproject/luarocks/wiki/Creating-a-rock

Known Issues
------------

* **LÖVERocks completely ignores C modules!** LÖVERocks is built on a
  mantra of disabling anything you can't ship as-is. Since C modules
  can't be loaded from a .love file, that means they need their own
  packaging mechanism, which ATM is out of scope for LÖVERocks. If you
  are okay with this state of affairs, you can work around the
  restriction by manually including them in conf.lua:

  ```lua
  local os  = love._os or love.system.getOS()
  local ext = os == "Windows" and ".dll" or ".so"
  package.cpath = "rocks/lib/5.1/?.".. ext ..";" .. package.cpath
  ```
* LÖVERocks can only function with a luarocks that runs on lua
  5.1/luajit. We will try to find a suitable install of luarocks but if we
  can't find one, it's suggested you provide the name via the
  `$HOME/.config/loverocks/conf.lua` file:

 ```lua
 luarocks = "/usr/bin/my-luarocks-command"
 ```

* Luarocks always expects a build configuration table, even if you don't
  plan on building with it. Use the null build type:

  ```lua
      build = { type = 'none' }
  ```
  and it should stay happy.

LICENSE
-------

Copyright (c) 2015, Kyle McLamb <alloyed@tfwno.gf> under the MIT License

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
