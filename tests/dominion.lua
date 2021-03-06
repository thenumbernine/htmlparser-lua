-- TODO remove closing commas so JSON doesn't complain (because JavaScript sucks)
require 'ext'
local htmlparser = require 'htmlparser'
local socket = require 'socket'
local common = require 'htmlparser.common'
local xpath = require 'htmlparser.xpath'
local http = require 'socket.http'
local json = require 'dkjson'

local function processPage(page)
	local cards = table()

	page = page:gsub(string.char(0xe2, 0x97, 0x89), 'P')
	page = page:gsub(string.char(0xc2, 0xa0, 0x20), ' ')

	local tree = htmlparser.parse(page)
	local divEntryContent = xpath(tree, '//@class=entry-content'):unpack()
	assert(divEntryContent)
	for _,cardTable in ipairs(common.findchilds(divEntryContent, 'table')) do
		local cardTBody = common.findchild(cardTable, 'tbody')
		for _,cardTR in ipairs(common.findchilds(cardTBody, 'tr')) do
			local cardTDs = common.findchilds(cardTR, 'td')
			
			local title = flattenText(cardTDs[1]):gsub([[&#8217;]], "'")
			local cardtype = flattenText(cardTDs[2]):gsub([[&#8211;]], '-')
			local cost = flattenText(cardTDs[3])
			local text = flattenText(cardTDs[4]):gsub([[&#8211;]], '-'):gsub([[&#8217;]], "'"):gsub([[&#8212;]], ' -- '):gsub([[&#8230]], ':')

			--[[
			removing cards that can't be chosen
			--]]
			
			-- Dark Ages
			if title == 'Ruins' then
			elseif cardtype:sub(-8) == ' - Ruins' then
			elseif title == 'Shelters' then
			elseif cardtype:sub(-10) == ' - Shelter' then
			elseif cardtype:sub(-9) == ' - Knight' then
			elseif title == 'Knights' then
				cards:insert{
					name=title, 
					type='Action - Attack - Knight', 
					cost='$5',
					text=text,
				}
			elseif title == 'Spoils' then
			elseif title == 'Madman' then
			elseif title == 'Mercenary' then
			-- Prosperity
			elseif title == 'Platinum' then
			elseif title == 'Colony' then
			-- Alchemy
			elseif title == 'Potion' then
			-- Cornucopia:
			elseif title == 'Bag of Gold' then
			elseif title == 'Diadem' then
			elseif title == 'Followers' then
			elseif title == 'Princess' then
			elseif title == 'Trusty Steed' then
			-- all else:
			else
				if title ~= '' 
				and cardtype ~= '' 
				and cost ~= '' 
				and text ~= '' 
				then
					cards:insert{
						name=title, 
						type=cardtype, 
						cost=cost, 
						text=text,
					}
				end
			end
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
	{name='guilds', url='http://dominionstrategy.com/card-lists/guilds-card-list/'},
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

print('decks = '..json.encode(sets, {indent=true}))
