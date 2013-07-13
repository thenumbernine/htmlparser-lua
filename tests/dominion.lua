-- TODO remove closing commas so JSON doesn't complain (because JavaScript sucks)
require 'ext'
require 'htmlparser.htmlparser'
require 'socket'
local http = require 'socket.http'
require 'htmlparser.common'
local json = require 'dkjson'

local function flattenText(n)
	if type(n) == 'string' then return n end
	if n.tag == 'br' then return '.  ' end
	if not n.child then return '' end
	return table.map(n.child, function(ch) return flattenText(ch) end):concat()
end

local function processPage(page)
	local cards = table()
	
	local tree = htmlparser.new(page):parse()
	local html = findtag(tree, 'html')
	local body = findchild(html, 'body')
	local divWrapper = findchild(body, 'div', {id='wrapper'})
	local divMain = findchild(divWrapper, 'div', {id='main'})
	local divContainer = findchild(divMain, 'div', {id='container'})
	local divContent = findchild(divContainer, 'div', {id='content'})
	local divPost111 = findchild(divContent, 'div')	--, {id='post-111'})
	local divEntryContent = findchild(divPost111, 'div', {class='entry-content'})
	for _,cardTable in ipairs(findchilds(divEntryContent, 'table')) do
		local cardTBody = findchild(cardTable, 'tbody')
		for _,cardTR in ipairs(findchilds(cardTBody, 'tr')) do
			local cardTDs = findchilds(cardTR, 'td')
			
			local title = flattenText(cardTDs[1]):gsub([[&#8217;]], "'")
			local cardtype = flattenText(cardTDs[2]):gsub([[&#8211;]], '-')
			local cost = flattenText(cardTDs[3])
			local text = flattenText(cardTDs[4]):gsub([[&#8211;]], '-'):gsub([[&#8217;]], "'"):gsub([[&#8212;]], ' -- '):gsub([[&#8230]], ':')

			cards:insert{name=title, type=cardtype, cost=cost, text=text}
		end
	end
	return cards
end


-- 'http://dominionstrategy.com/all-cards/',
local setinfos = {
	{name='dominion', url='http://dominionstrategy.com/card-lists/dominion-card-list/'},
	{name='intrigue', url='http://dominionstrategy.com/card-lists/intrigue-card-list/'},
	{name='seaside', url='http://dominionstrategy.com/card-lists/seaside-card-list/'},
	{name='alchemy', url='http://dominionstrategy.com/card-lists/alchemy-card-list/'},
	{name='prosperity', url='http://dominionstrategy.com/card-lists/prosperity-card-list/'},
	{name='cornucopia', url='http://dominionstrategy.com/card-lists/cornucopia-card-list/'},
	{name='hinterlands', url='http://dominionstrategy.com/card-lists/hinterlands-card-list/'},
	{name='dark-ages', url='http://dominionstrategy.com/card-lists/dark-ages-card-list/'},
	{name='promotional', url='http://dominionstrategy.com/card-lists/promotional-cards/'},
}
local sets = table()
for _,setinfo in ipairs(setinfos) do
	local setname = setinfo.name
	local url = setinfo.url
	local page = assert(http.request(url))

	local cards = processPage(page)
	sets:insert{
		name=setname:sub(1,1):upper()..setname:sub(2),
		cards=cards,
	}
end

print(json.encode(sets, {indent=true}))

