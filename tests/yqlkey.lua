require 'ext'
require 'htmlparser'
require 'socket'
local http = require 'socket.http'
require 'common'
local json = require 'dkjson'

local function flattenText(n)
	if type(n) == 'string' then return n end
	if n.tag == 'br' then return '.  ' end
	if not n.child then return '' end
	return table.map(n.child, function(ch) return flattenText(ch) end):concat()
end

local function processPage(page)
	local tree = htmlparser.new(page):parse()
	local html = findtag(tree, 'html')
	local body = findchild(html, 'body')
	local divMainCol = findchild(body, 'div', {id='maincol'})
	local divWikipage = findchild(divMainCol, 'div', {id='wikipage'})
	local tbl = findchild(divWikipage, 'table')
	local tbody = findchild(tbl, 'tbody')
	local tr = findchild(tbody, 'tr')
	local td = findchild(tr, 'td')
	local divWikicontent = findchild(td, 'div', {id='wikicontent'})
	local divWikimaincol = findchild(divWikicontent, 'div', {id='wikimaincol'})
	local tblWikitable = findchild(divWikimaincol, 'table', {class='wikitable'})
	local tbodyWikitable = findchild(tblWikitable, 'tbody')
	local trs = findchilds(tbodyWikitable, 'tr')
	for i=2,#trs do
		local tr = trs[i]
		local tds = findchilds(trs, 'td')
		local varname = flattenText(tds[1])
		local varflag = flattenText(tds[2])	
		print(varname, varflag)
	end
end

local url = 'http://code.google.com/p/yahoo-finance-managed/wiki/enumQuoteProperty'
local page = assert(http.request(url))
processPage(page)
