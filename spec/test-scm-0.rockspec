package = "test"
version = "scm-0"
source = {
   url = "file://"
}
description = {
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "luasocket",
   "luasec",
   "busted",
   "luacheck",
   "luacov",
   "luacov-coveralls",
   "ser-alloyed ~> 1.0"
}
build = {
   type = "none"
}
