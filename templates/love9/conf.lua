if love.filesystem then
	require 'rocks' ()
end

function love.conf(t)
	t.identity = <%- string.format("%q", project_name) %>
	t.version = <%- raw_version(versions.love) %>
	t.dependencies = {
	}
end
