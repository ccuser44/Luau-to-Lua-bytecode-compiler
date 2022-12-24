--[[
	Title: Luau to Lua bytecode compiler
	Author: ccuser44
	Date: 24.12.2022
	License: MIT
]]
--[[
	MIT License

	Copyright (c) 2022 ccuser44

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local luaZ = require("./LuaZ")
local luaX = require("./LuaX")
local luaY = require("./LuaY")
local luaU = require("./LuaU")
local LuaState = {}

luaX:init()

return function(sourcecode, options)
	assert(type(sourcecode) == "string", string.format("bad argument #1 (string expected, got %s)", type(sourcecode)))
	assert(options == nil or type(options) == "table", string.format("bad argument #2 (table expected, got %s)", type(options)))

	local writer, buff
	local scriptname = options and options.scriptname

	local success, error = pcall(function()
		local stream = assert(luaZ:init(luaZ:make_getS(sourcecode), nil), "LuaZ did not generate a buffered stream")
		local proto = luaY:parser(LuaState, stream, nil, scriptname or "@input")
		writer, buff = luaU:make_setS()
		luaU:dump(LuaState, proto, writer, buff)
	end)
	
	if success then
		return success, buff.data, buff
	else
		return success, error, nil
	end
end
