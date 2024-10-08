#!/usr/bin/env luajit
-- TODO remove closing commas so JSON doesn't complain (because JavaScript sucks)
require 'ext'
local htmlparser = require 'htmlparser'
local flattenText = require 'htmlparser.common'.flattenText
local findchilds = require 'htmlparser.common'.findchilds
local findchild = require 'htmlparser.common'.findchild
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
	for _,cardTable in ipairs(findchilds(divEntryContent, 'table')) do
		local cardTBody = findchild(cardTable, 'tbody')
		for _,cardTR in ipairs(findchilds(cardTBody, 'tr')) do
			local cardTDs = findchilds(cardTR, 'td')

			local title = flattenText(cardTDs[1]):gsub([[&#8217;]], "'"):trim()
			local cardtype = flattenText(cardTDs[2]):gsub([[&#8211;]], '-'):trim()
			local cost = flattenText(cardTDs[3]):trim()
			local text = (cardTDs[4]
				and flattenText(cardTDs[4])
					:gsub([[&#8211;]], '-')
					:gsub([[&#8217;]], "'")
					:gsub([[&#8212;]], ' -- ')
					:gsub([[&#8230]], ':')
				or ''):trim()

			--[[
			removing cards that can't be chosen
			--]]

			-- Alchemy:
			if title == 'Potion' then

			-- Prosperity:
			elseif title == 'Platinum' then
			elseif title == 'Colony' then

			-- Cornucopia:
			elseif title == 'Bag of Gold' then
			elseif title == 'Diadem' then
			elseif title == 'Followers' then
			elseif title == 'Princess' then
			elseif title == 'Trusty Steed' then


			-- Dark Ages
			-- 'Shelters' is a separate thing - replace all of them with a single 'Shelters'
			-- replace all 'Knights' with the single Knights
			elseif title == 'Ruins' then
			elseif cardtype:sub(-8) == '- Ruins' then
			elseif title == 'Shelters' then
			elseif cardtype:sub(-10) == '- Shelter' then
			elseif cardtype:sub(-9) == '- Knight' then
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

			-- Empires:
			-- add Castle, but don't add Castle cards: Humble Castle, Crumbling Castle, Small Castle, Haunted Castle, Opulent Castle, Sprawling Castle, Grand Castle, King's Castle
			-- same with Events?
			-- same with Landmarks?
			elseif title == 'Humble Castle' then
			elseif title == 'Crumbling Castle' then
			elseif title == 'Small Castle' then
			elseif title == 'Haunted Castle' then
			elseif title == 'Opulent Castle' then
			elseif title == 'Sprawling Castle' then
			elseif title == 'Grand Castle' then

			-- Nocturne:
			-- cost has a "*" and text has "(This is not in the supply.)"
			-- ex: Imp, Bat, Wish, Will O' Wisp, Imp, Ghost
			elseif title == 'Imp' then
			elseif title == 'Bat' then
			elseif title == 'Wish' then
			elseif title == "Will-O'-Wisp" then
			elseif title == "Ghost" then
			-- all else:
			else
				--[[
				if title ~= ''
				and cardtype ~= ''
				and cost ~= ''
				and text ~= ''
				then
				--]] do
					if cards:find(nil, function(card) return card.name == title end) then
						io.stderr:write('WARNING!!! DUPLICATE CARD: ', title, '\n')
					end
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


-- TODO or get this list from the rhs menu
-- TODO or just 'https://dominionstrategy.com/all-cards/',
local setinfos = {
	{name='dominion', url='https://dominionstrategy.com/card-lists/dominion-card-list/'},
	{name='intrigue', url='https://dominionstrategy.com/card-lists/intrigue-card-list/'},
	{name='seaside', url='https://dominionstrategy.com/card-lists/seaside-card-list/'},
	{name='alchemy', url='https://dominionstrategy.com/card-lists/alchemy-card-list/'},
	{name='prosperity', url='https://dominionstrategy.com/card-lists/prosperity-card-list/'},
	{name='cornucopia', url='https://dominionstrategy.com/card-lists/cornucopia-card-list/'},
	{name='hinterlands', url='https://dominionstrategy.com/card-lists/hinterlands-card-list/'},
	{name='dark-ages', url='https://dominionstrategy.com/card-lists/dark-ages-card-list/'},
	{name='guilds', url='https://dominionstrategy.com/card-lists/guilds-card-list/'},
	{name='adventures', url='https://dominionstrategy.com/card-lists/adventures-card-list/'},
	{name='empires', url='https://dominionstrategy.com/card-lists/empires-card-list/'},
	{name='nocturne', url='https://dominionstrategy.com/card-lists/nocturne-card-list/'},
	{name='renaissance', url='https://dominionstrategy.com/card-lists/renaissance-card-list/'},
	{name='promotional', url='https://dominionstrategy.com/card-lists/promotional-cards/'},
}
local sets = table()
for _,setinfo in ipairs(setinfos) do
	local setname = setinfo.name
	local url = setinfo.url
	local page = assert(http.request(url))

	local cards = processPage(page)
	sets:insert{
		name = setname:sub(1,1):upper()..setname:sub(2),
		cards = cards,
	}
end

print('decks = '..json.encode(sets, {
	indent = true,
	keyorder = {'name', 'type', 'cost', 'text', 'cards'},
}))
