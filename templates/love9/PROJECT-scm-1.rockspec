package = <%- string.format("%q", project_name) %>
version = "scm-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua ~> 5.1",
   <%- depstring(versions.love) %>
}
build = { type = 'builtin' }
