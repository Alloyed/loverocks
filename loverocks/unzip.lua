-- Library for reading .zip files (and by extension, .love files!)

local os = require 'loverocks.os'
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
	local fs   = require 'luarocks.fs'
	local vars = require 'luarocks.cfg'.variables
	function unzip.read(archive, fname)
		assert(archive)
		assert(fname)
		local tmpdir = fs.make_temp_dir("read")
		-- unzip -d tmpdir archive fname
		local ok = fs.execute_quiet(vars.UNZIP.." -d", tmpdir, archive, fname)
		if not ok then return nil, "unzip failed" end

		local f, err
		f, err = io.open(tmpdir.."/"..fname)
		if not f then return nil, err end

		local s = f:read('*a')
		f:close()

		fs.delete(tmpdir)

		return s
	end
elseif os == 'windows' then -- use builtin 7z
	local fs   = require 'luarocks.fs'
	local vars = require 'luarocks.cfg'.variables
	function unzip.read(archive, fname)
		local tmpdir, err
		tmpdir, err = fs.tmpdir("read")
		if not tmpdir then return nil, err end
		-- 7z e archive fname -otmpdir
		local ok = fs.execute_quiet(vars.SEVENZ .. " x", archive, fname, "-o"..tmpdir)
		if not ok then return nil, "unzip failed" end

		local f
		f, err = io.open(tmpdir.."/"..fname)
		if not f then return nil, err end

		local s = f:read('*a')
		f:close()

		fs.delete(tmpdir)

		return s
	end
end

assert(unzip.read)
return unzip
