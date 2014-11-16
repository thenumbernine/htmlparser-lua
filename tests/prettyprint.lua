--[[
	Copyright (c) 2009-2013 Christopher E. Moore ( christopher.e.moore@gmail.com / http://christopheremoore.net )

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
--]]

args = {...}

local page
if #args > 0 then
	local filename = args[1]
	local file = assert(io.open(filename, 'r'))
	page = file:read('*a')
	file:close()
else
	require 'socket'
	local http = require 'socket.http'

	local mainpage = 'http://christopheremoore.net/home.lua'
	do
		local filename = 'cachedpage.html'
		local file = io.open(filename, 'r')
		if file then
			page = assert(file:read('*a'))
			file:close()
		else
			page = assert(http.request(mainpage))
			file = assert(io.open(filename, 'w'))
			file:write(page)
			file:close()
		end
	end
end

-- [[
local htmlparser = require 'htmlparser'
local tree = htmlparser.parse(page)
htmlparser.prettyprint(tree, {tabchar='', newlinechar=''})
--Parser.debugprint(tree)
--]]

--[[
filename = 'cachedpage.html'
require 'old.autoformat'
--]]
