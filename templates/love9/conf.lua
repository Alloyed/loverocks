require 'rocks' ()

function love.conf(t)
	t.identity = <%- string.format("%q", project_name) %>
	t.window.title = t.identity
	t.version = <%- raw_version(versions.love) %>
end
