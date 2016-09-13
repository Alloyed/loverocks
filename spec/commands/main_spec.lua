require 'spec.test_config'()

describe("loverocks", function()
	local main  = require 'loverocks.main' 
	local match = require 'luassert.match'
	local luarocks = require 'loverocks.luarocks'
	it("can dispatch to commands", function()
		local new = require 'loverocks.commands.new'
		stub(new, 'run')
		main("new", "mygame")
		assert.stub(new.run).was.called_with(match._, match._)
	end)

	it("returns help", function()
		stub(io, "write")
		main("help")
		assert.stub(io.write).was.called()
	end)

	it("returns version", function()
		stub(io, "write")
		assert.has_errors(function() main("--version") end, "os.exit(0)")
		local version = "Loverocks " .. (require 'loverocks.version') .. "\nLuarocks " .. (luarocks.version()) .. "\n"
		assert.stub(io.write).was.called_with(version)
	end)
end)
