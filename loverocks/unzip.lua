-- Library for reading .zip files (and by extension, .love files!)


local os = require 'loverocks.os'
local util = require 'loverocks.util'
local unzip_ok, luazip = pcall(require, 'zip')

local unzip = {}

if unzip_ok then
	function unzip.read(archive, fname)
		local zipfile, err = luazip.open(archive)
		if not zipfile then return nil, err end

		local rf
		rf, err = zipfile:open(fname)
		if not rf then zipfile:close() return nil, err end

		local data = rf:read('*a')

		rf:close()
		zipfile:close()

		return data
	end
elseif os == 'unix' then -- use unzip binary
	function unzip.read(archive, fname)
		local s, err = util.stropen(string.format("unzip -p %q %q 2> /dev/null", archive, fname))
		if s == "" then
			return nil, "unzip failed"
		end
		return s
	end
elseif os == 'windows' then -- nope.
	function unzip.read()
		error("FIXME: Not yet implemented")
	end
end

assert(unzip.read)
return unzip
