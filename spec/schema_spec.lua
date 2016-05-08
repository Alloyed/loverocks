require 'spec.test_config'()
describe("schema", function()
	local T = require 'loverocks.schema'
	it("checks primitive types", function()
		assert.truthy(T.check('foo', 'string'))
		assert.falsy (T.check('foo', 'number'))
		assert.falsy (T.check('foo', 'nil'))

		assert.falsy (T.check(nil,   'string'))
		assert.falsy (T.check(nil,   'number'))
		assert.truthy(T.check(nil,   'nil'))

		assert.falsy (T.check(100,  'string'))
		assert.truthy(T.check(100,  'number'))
		assert.falsy (T.check(100,  'nil'))
	end)

	it("checks sum types", function()
		assert.truthy(T.check("foo", T.sum('string', 'nil')))
		assert.truthy(T.check(nil,   T.sum('string', 'nil')))
		assert.falsy (T.check(100,   T.sum('string', 'nil')))

		assert.truthy(T.check("foo", T.sum('string', 'number')))
		assert.falsy (T.check(nil,   T.sum('string', 'number')))
		assert.truthy(T.check(100,   T.sum('string', 'number')))
	end)

	it("checks enums", function()
		assert.truthy(T.check("foo",    T.enum('foo', 'bar', 'baz')))
		assert.truthy(T.check('bar',    T.enum('foo', 'bar', 'baz')))
		assert.falsy (T.check('needle', T.enum('foo', 'bar', 'baz')))
		assert.falsy (T.check(100,      T.enum('foo', 'bar', 'baz')))
	end)

	it("checks compound types", function()
		assert.truthy(T.check({
			foo = 'bar',
			n   = 20,
			secret = 'ssh'
		}, {
			foo  = 'string',
			n    = 'number',
			nope = 'nil'
		}))

		assert.falsy(T.check({
			foo = 'bar',
			n   = 20,
			secret = 'ssh'
		}, {
			foo  = 'string',
			n    = 'nil',
			nope = 'nil'
		}))

		assert.truthy(T.check({
			foo = 'bar',
			n   = 20,
			secret = 'ssh'
		}, {}))
	end)
end)
