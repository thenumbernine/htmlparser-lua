--[[
	Copyright (c) 2015 Christopher E. Moore ( christopher.e.moore@gmail.com / http://christopheremoore.net )

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

-- TODO -move to htmlparser and make instances of the tree nodes

local function findnode(list, callback)
	local res = {}
	assert(type(list) == 'table')
	for _,v in ipairs(list) do
		if callback(v) then
			table.insert(res, v)
		end
	end
	return res
end

local function findtags(list, tagname, attrs)
	return findnode(list, function(n)
		if type(n) ~= 'table' then return false end
		if n.tag ~= tagname then return false end
		if attrs then
			for k,v in pairs(attrs) do
				local found = false
				if n.attrs then
					for _,kv in ipairs(n.attrs) do
						if kv.name == k then
							if kv.value ~= v then return false end
							found = true
						end
					end
				end
				if not found then return false end
			end
		end
		return true
	end)
end

local function findtag(...)
	return (findtags(...))[1]
end

local function findchild(node, ...)
	return findtag(node.child, ...)
end

local function findchilds(node, ...)
	return findtags(node.child, ...)
end

local function findattr(node, name)
	if node.attrs then
		for _,kv in ipairs(node.attrs) do
			if kv.name == name then return kv.value end
		end
	end
end

local function flattenText(n)
	if type(n) == 'string' then return n end
	if n.tag == 'br' then return '.  ' end
	if not n.child then return '' end
	return table.map(n.child, function(ch) return flattenText(ch) end):concat()
end

return {
	findnode = findnode,
	findtags = findtags,
	findtag = findtag,
	findchild = findchild,
	findchilds = findchilds,
	findattr = findattr,
	flattenText = flattenText,
}
