describe("module listing", function()
	it("can list/load every module in this project", function()
		local modules = require 'loverocks.commands.modules'
		modules.list_modules(function(mod)
			if mod:match("^loverocks%.") then
				require(mod)
			end
		end, ".")
	end)
end)
