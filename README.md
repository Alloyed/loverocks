LOVEROCKS
=========
[![Circle CI](https://circleci.com/gh/Alloyed/loverocks.svg?style=svg&circle-token=badf14e71fb7fbecee7120a1fda86fa642be9dd2)](https://circleci.com/gh/Alloyed/loverocks)

LÖVERocks is a CLI wrapper around [Luarocks][L] that teaches your [LÖVE][O]
projects how to download and use standard Luarocks packages.

[L]: https://luarocks.org
[O]: https://love2d.org

Installing
----------

To install LÖVERocks you'll first need a copy of Luarocks to host it.
Luarocks should itself use either Lua 5.1 or Luajit (because that's what
LÖVE itself uses) and it should be relatively up-to-date, which as of
writing means either Luarocks 2.3.0 or 2.4.0.

If you're on Windows, [the official package][W] works. Notably, Lua For
Windows does _not_ work: its Luarocks version is too old.

MacOS users can use brew:
```
# brew install lua51
```

This will install both Lua 5.1 and an appropriate Luarocks version.

Linux users should check their package managers. On Ubuntu/Debian,
`luarocks` will work, on Arch Linux the package is called `luarocks5.1`
instead.

Once you have that, installing LÖVERocks is easy. Just run:

```shell
$ luarocks install loverocks
```

and make sure the directory you installed to is in your ``$PATH`` and
you should be good to go.

Linux is the primary development platform for loverocks. Windows seems
to work, although the test suite still mostly fails, and I've heard that
Mac OS seems to work as well. Any issue reports or patches /w/r/t
porting would be greatly appreciated.

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

This will install the necessary shims and config files into `my-project/`.
This includes:
* A `rocks/` directory to store your modules.
* A `conf.lua`, which is configured to add your rocks modules to the
  search path. You can always comment out

  ```lua
  require 'rocks' ()
  ```

  to disable LOVERocks and only use local files, and uncomment it to bring it
  back.

If you already have a LÖVE project you'd like to manage with Luarocks, just 
add these lines to your conf.lua instead:
```lua
if love.filesystem then
    require 'rocks' ()
end

function love.conf(t)
    t.dependencies = {
    }
end
```

and LÖVErocks will automatically install your rocks folder for you.
If you'd like to customize your install more than that an
[extended example][E] is also available.

Now you can start working on your project. Lets say you decide you need
to use dkjson in your project. To install it, all you need to do is add
dkjson to your dependencies table, like so:

```lua
function love.conf(t)
    t.dependencies = { "dkjson ~> 2" }
end
```

and then run

```shell
$ loverocks deps
```

Now you have the latest possible version of dkjson 2, bugfixes included.
You can use it like any other top-level module, with

```lua
local json = require 'dkjson'
```

This does not complicate sharing your game, either. Since all modules
are stored inside your project folder, and external modules are explicitly
disabled, you can continue packaging your game the way you always have:

```shell
$ loverocks purge
$ loverocks deps
$ zip -r my-project.love *
```

will refresh your package cache and install everything, rocks modules
included, into `my-project.love`.

[E]: https://github.com/Alloyed/loverocks/blob/master/example-conf.lua

Libraries
---------
If you are a library writer, good news! You do not have to do anything
special to support LÖVERocks. Just follow the
[Luarocks documentation][M] and you should be fine. Just remember, if
you depend on LÖVE modules in your code, be sure to make that explicit.
For example, if you support LÖVE 0.10 and 11.0, use the dependency string:

```lua
    "love >= 0.10, < 12.0"
```

and LÖVERocks will automatically check that for you.

[M]: https://github.com/keplerproject/luarocks/wiki/Creating-a-rock

Known Issues
------------

* Even though LÖVERocks can install and load native libraries, like for
  example [luafilesystem][lfs], there isn't a recommended way (yet) to package
  them with your application. They are installed at `rocks/lib/lua/5.1/` if
  you'd like to get your hands dirty.

[lfs]: https://luarocks.org/modules/hisham/luafilesystem

Testing
-------
LÖVERocks uses busted to test. Install it using

```shell
$ luarocks install busted
```

In addition, a mock Luarocks repository is necessary to keep the tests
from touching the network. use

```shell
$ git clone https://github.com/alloyed/loverocks-repo
$ ./loverocks-repo/make-test-repo.sh
```

to generate it. If the script is broken for you (sorry!) or you're on
Windows, a [zipped repository][R] is also available.

[R]: http://alloyed.me/loverocks/loverocks-test-repo.zip

To use it:
```shell
$ wget http://alloyed.me/loverocks/loverocks-test-repo.zip
$ unzip loverocks-test-repo.zip
```

LICENSE
-------

Copyright (c) 2016, Kyle McLamb <alloyed@tfwno.gf> under the MIT License

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
