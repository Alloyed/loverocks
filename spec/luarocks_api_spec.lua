local api = require 'loverocks.api'

describe("search", function()
	local pkg = api.search("inspect", "2.0-1")[1]
	assert.same(pkg, {
		package = "inspect",
		repo = "https://luarocks.org",
		version = "2.0-1"
	})
end)

describe("install/remove", function()
	assert(api.install("inspect", "2.0-1", { quiet = true, use_local = true }))
	assert(api.remove("inspect", "2.0-1", { quiet = true, use_local = true }))
end)
