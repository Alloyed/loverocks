require 'spec.test_config'()
describe("loverocks.modules", function()
	it("can load every module in this project", function()
		local modules = require 'loverocks.commands.modules'
		modules.list_modules(function(mod)
			if mod:match("^loverocks%.") then
				require(mod)
			end
		end, ".")
		assert.truthy(package.loaded["loverocks.version"])
		assert.truthy(package.loaded["loverocks.commands.install"])
		assert.truthy(package.loaded["loverocks.luarocks"])
	end)
end)
