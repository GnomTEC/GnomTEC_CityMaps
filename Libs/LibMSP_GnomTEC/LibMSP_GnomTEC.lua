--[[
	Adapted GnomTEC version for passive data collection
]]

--[[
	LibMSP - highly portable implementation of the Mary Sue Protocol for RP addon communication
	Written by Etarna Moonshyne <etarna@moonshyne.org>

	Released into the public domain by the author - free for any use or embedding. Go nuts.
	Public domain (CC0): http://creativecommons.org/publicdomain/zero/1.0/
	It would be nice if changes to this were given away in the same manner, but you don't have to.

	- Easy to embed: it's a singleton which defines a global table: msp
	- It requires (only) ChatThrottleLib

	- Put your character's field data in the table msp.my, e.g. msp.my["NA"] = UnitName("player")
	- When you initialise or update your character's field data, call msp:Update(); no parameters
	- Don't mess with msp.my['TT'], that's used internally
	- Please save the contents of the table msp.myver between sessions, so we always count up

	- To request one or more fields from someone else, call msp:Request( player, fields )
	  fields can be nil (gets you TT i.e. tooltip), or a string (one field) or a table (multiple)

	- To get a call back when we receive data (such as a request for us, or an answer), so you can
	  update your display: tinsert( msp.callback.received, YourCallbackFunctionHere )
	  You get (as sole parameter) the name of the player sending you the data

	- Player names appear EXACTLY as the game sends them (case sensitive!).
	- Players on different realms are referenced like this: "Name-Realm" - yes, that does work!

	- All field names are two capital letters. Best if you agree any extensions.
	
	- For more information, see documentation on the Mary Sue Protocol - http://moonshyne.org/msp/
]]

local libmsp_GnomTEC_version = 8

if msp_GnomTEC then
	if msp_GnomTEC.version >= libmsp_version then
		return
	end
else
	_G.msp_GnomTEC = {}
end
local msp_GnomTEC = _G.msp_GnomTEC
msp_GnomTEC.version = libmsp_GnomTEC_version
local ChatThrottleLib = assert(ChatThrottleLib, "LibMSP_GnomTEC requires ChatThrottleLib")
assert(ChatThrottleLib.version >= 22, "LibMSP_GnomTEC requires ChatThrottleLib v22 or later")

msp_GnomTEC.protocolversion = 1

msp_GnomTEC.callback = {
	received = {}
}

local UNKNOWN = _G.UNKNOWN or "Unknown"

local function emptyindex( table, key )
	table[key] = ""
	return table[key]
end

local function charindex( table, key )
	if key == "field" then
		table[key] = setmetatable( {}, { __index = emptyindex, } )
		return table[key]
	elseif key == "ver" or key == "time" then
		table[key] = {}
		return table[key]
	else 
		return nil
	end
end

local function bufferindex( table, key )
	table[key] = setmetatable( {}, { __index = charindex, } )
	return table[key]
end

msp_GnomTEC.char = setmetatable( {}, { __index = bufferindex } )

msp_GnomTEC.my = {}
msp_GnomTEC.myver = {}
msp_GnomTEC.my.VP = tostring( msp_GnomTEC.protocolversion )

local msp_GnomTEC_my_previous = {}
local msp_GnomTEC_tt_cache = false

local strfind, strmatch, strsub, strgmatch = strfind, strmatch, strsub, string.gmatch
local tinsert, tconcat = tinsert, table.concat
local tostring, tonumber, wipe, next = tostring, tonumber, wipe, next
local GetTime = GetTime

local MSP_GNOMTEC_TT_ALONE = { 'TT' }
local MSP_GNOMTEC_FIELDS_IN_TT = { 'VP', 'VA', 'NA', 'NH', 'NI', 'NT', 'RA', 'FR', 'FC', 'CU' }
local MSP_GNOMTEC_TT_FIELD = { VP=true, VA=true, NA=true, NH=true, NI=true, NT=true, RA=true, FR=true, FC=true, CU=true }
local MSP_GNOMTEC_PROBE_FREQUENCY = 300.0 + math.random(0, 60) -- Wait 5-6 minutes for someone to respond before asking again
local MSP_GNOMTEC_FIELD_UPDATE_FREQUENCY = 10.0 + math.random(0, 5) -- Fields newer than 10-15 seconds old are still fresh

local garbage = setmetatable( {}, { __mode = "k" } )
local function newtable()
	local t = next( garbage )
	if t then 
		garbage[t] = nil
		return wipe(t)
	end
	return {}
end

function msp_GnomTEC_onevent( this, event, prefix, body, dist, sender )
	if event == "CHAT_MSG_ADDON" then
		if MSP_GNOMTEC_INCOMING_HANDLER[ prefix ] then
			MSP_GNOMTEC_INCOMING_HANDLER[ prefix ]( sender, body )
		end
	end
end

function msp_GnomTEC_incomingfirst( sender, body )
	msp_GnomTEC.char[ sender ].buffer = body
end

function msp_GnomTEC_incomingnext( sender, body )
	local buf = msp_GnomTEC.char[ sender ].buffer
	if buf then
		if type( buf ) == "table" then
			tinsert( buf, body )
		else
			local temp = newtable()
			temp[ 1 ] = buf
			temp[ 2 ] = body
			msp_GnomTEC.char[ sender ].buffer = temp
		end
	end
end

function msp_GnomTEC_incominglast( sender, body )
	local buf = msp_GnomTEC.char[ sender ].buffer
	if buf then
		if type( buf ) == "table" then
			tinsert( buf, body )
			msp_GnomTEC_incoming( sender, tconcat( buf ) )
			garbage[ buf ] = true
		else
			msp_GnomTEC_incoming( sender, buf .. body )
		end
	end
end

function msp_GnomTEC_incoming( sender, body )
	msp_GnomTEC.char[ sender ].supported = true
	msp_GnomTEC.char[ sender ].scantime = nil
	msp_GnomTEC.reply = newtable()
	if body ~= "" then
		if strfind( body, "\1", 1, true ) then
			for chunk in strgmatch( body, "([^\1]+)\1*" ) do
				msp_GnomTEC_incomingchunk( sender, chunk )
			end
		else
			msp_GnomTEC_incomingchunk( sender, body )
		end
	end
	for k, v in ipairs( msp_GnomTEC.callback.received ) do
		v( sender )
	end
	msp_GnomTEC:Send( sender, msp_GnomTEC.reply )
	garbage[ msp_GnomTEC.reply ] = true
end

function msp_GnomTEC_incomingchunk( sender, chunk )
	local reply = msp_GnomTEC.reply
	local head, field, ver, body = strmatch( chunk, "(%p?)(%a%a)(%d*)=?(.*)" )
	ver = tonumber( ver ) or 0
	if not field then
		return
	end
	if head == "?" then
		if (ver == 0) or (ver < (msp_GnomTEC.myver[ field ] or 0)) or (ver > (msp_GnomTEC.myver[ field ] or 0)) then
			if field == "TT" then
				if not msp_GnomTEC_tt_cache then
					msp_GnomTEC:Update()
				end
				tinsert( reply, msp_GnomTEC_tt_cache )
			else
				if not msp_GnomTEC.my[ field ] or msp_GnomTEC.my[ field ] == "" then
					tinsert( reply, field .. (msp_GnomTEC.myver[ field ] or "") )
				else
					tinsert( reply, field .. (msp_GnomTEC.myver[ field ] or "") .. "=" .. msp_GnomTEC.my[ field ] )
				end
			end
		else
			tinsert( reply, "!"..field..(msp_GnomTEC.myver[ field ] or "") )
		end
	elseif head == "!" then
		msp_GnomTEC.char[ sender ].ver[ field ] = ver
		msp_GnomTEC.char[ sender ].time[ field ] = GetTime()
	elseif head == "" then
		msp_GnomTEC.char[ sender ].ver[ field ] = ver
		msp_GnomTEC.char[ sender ].time[ field ] = GetTime()
		msp_GnomTEC.char[ sender ].field[ field ] = body or ""
	end
end

MSP_GNOMTEC_INCOMING_HANDLER = {
	["MSP"] = msp_GnomTEC_incoming,
	["MSP\1"] = msp_GnomTEC_incomingfirst,
	["MSP\2"] = msp_GnomTEC_incomingnext,
	["MSP\3"] = msp_GnomTEC_incominglast
}

msp_GnomTEC.dummyframe = msp_GnomTEC.dummyframe or CreateFrame( "Frame", "libmsp_GnomTECDummyFrame" )
msp_GnomTEC.dummyframe:SetScript( "OnEvent", msp_GnomTEC_onevent )
msp_GnomTEC.dummyframe:RegisterEvent( "CHAT_MSG_ADDON" )

for prefix, handler in pairs( MSP_GNOMTEC_INCOMING_HANDLER ) do
	RegisterAddonMessagePrefix( prefix )
end

--[[
	msp_GnomTEC:Update()
	Call this function when you update (or might have updated) one of the fields in the player's own profile (msp_GnomTEC.my).
	It'll deal with any version updates necessary and will rebuild the cached tooltip reply.
]]
function msp_GnomTEC:Update()
	local updated = false
	local tt = newtable()
	for field, value in pairs( msp_GnomTEC_my_previous ) do
		if not msp_GnomTEC.my[ field ] then
			updated = true
			msp_GnomTEC_my_previous[ field ] = ""
			msp_GnomTEC.myver[ field ] = (msp_GnomTEC.myver[ field ] or 0) + 1
			if MSP_GNOMTEC_TT_FIELD[ field ] then
				ttupdated = true
				tinsert( tt, field .. msp_GnomTEC.myver[ field ] )
			end
		end
	end
	for field, value in pairs( msp_GnomTEC.my ) do
		if (msp_GnomTEC_my_previous[ field ] or "") ~= value then
			updated = true
			msp_GnomTEC_my_previous[ field ] = value or ""
			msp_GnomTEC.myver[ field ] = (msp_GnomTEC.myver[ field ] or 0) + 1
		end
	end
	for k, field in ipairs( MSP_GNOMTEC_FIELDS_IN_TT ) do
		local value = msp_GnomTEC.my[ field ]
		if not value or value == "" then
			tinsert( tt, field .. (msp_GnomTEC.myver[ field ] or "") )
		else
			tinsert( tt, field .. (msp_GnomTEC.myver[ field ] or "") .. "=" .. value )
		end
	end
	local newtt = tconcat( tt, "\1" ) or ""
	if msp_GnomTEC_tt_cache ~= newtt.."\1TT"..(msp_GnomTEC.myver.TT or 0) then
		msp_GnomTEC.myver.TT = (msp_GnomTEC.myver.TT or 0) + 1
		msp_GnomTEC_tt_cache = newtt.."\1TT"..msp_GnomTEC.myver.TT
	end
	garbage[ tt ] = true
	return updated
end

--[[
	msp_GnomTEC:Request( player, fields )
		player = Player name to query; if from a different realm, format should be "Name-Realm"
		fields = One (string) or more (table) fields to request from the player in question

	Returns true if we sent them a request, and false if we didn't (because we either have it
	recently cached already, or they didn't respond to our last request so might not support MSP).

	Notes: 
	- This function does not spam: feel free to use frequently.
	- To avoid problems with network congestion, doesn't work on a player called "Unknown".
	- Player names are CASE SENSITIVE; pass them as you got them.
	- Replies aren't instant: to be notified if/when we get a reply, register a callback function.
	- For a quick shortcut, request field TT to get basic data you'll probably use in the tooltip.
	- Defaults to a TT (tooltip) request, if there is only one parameter.
]]
function msp_GnomTEC:Request( player, fields )
	if player == UNKNOWN then
		return false
	else
		local now = GetTime()
		if msp_GnomTEC.char[ player ].supported == false and ( now < msp_GnomTEC.char[ player ].scantime + MSP_GNOMTEC_PROBE_FREQUENCY ) then
			return false
		elseif not msp_GnomTEC.char[ player ].supported then
			msp_GnomTEC.char[ player ].supported = false
			msp_GnomTEC.char[ player ].scantime = now
		end
		if type( fields ) == "string" then
			fields = { fields }
		elseif type( fields ) ~= "table" then
			fields = MSP_GNOMTEC_TT_ALONE
		end
		local updateneeded = false
		local tosend = newtable()
		for k, field in ipairs(fields) do
			if not msp_GnomTEC.char[ player ].supported or not msp_GnomTEC.char[ player ].time[ field ] or (now > msp_GnomTEC.char[ player ].time[ field ] + MSP_GNOMTEC_FIELD_UPDATE_FREQUENCY) then
				updateneeded = true
				if not msp_GnomTEC.char[ player ].supported or not msp_GnomTEC.char[ player ].ver[ field ] or msp_GnomTEC.char[ player ].ver[ field ] == 0 then
					tinsert( tosend, "?" .. field )
				else
					tinsert( tosend, "?" .. field .. tostring( msp_GnomTEC.char[ player ].ver[ field ] ) )
				end
			end
		end
		if updateneeded then
			msp_GnomTEC:Send( player, tosend )
		end
		garbage[ tosend ] = true
		return updateneeded
	end
end

--[[
	msp_GnomTEC:Send( player, chunks )
		player = Player name to send to; if from a different realm, format should be "Name-Realm"
		chunks = One (string) or more (table) MSP chunks to send

	Normally internally used, but published just in case you want to 'push' a field onto someone.
	Returns the number of messages used to send the data.
]]
function msp_GnomTEC:Send( player, chunks )
	local payload = ""

-- Passive Mode: so we will send nothing

--	if type( chunks ) == "string" then
--		payload = chunks
--	elseif type( chunks ) == "table" then
--		payload = tconcat( chunks, "\1" )
--	end
	if payload ~= "" then
		local len = #payload
		local queue = "MSPWHISPER" .. player
		if len < 256 then
			ChatThrottleLib:SendAddonMessage( "BULK", "MSP", payload, "WHISPER", player, queue )
			return 1
		else
			local chunk = strsub( payload, 1, 255 )
			ChatThrottleLib:SendAddonMessage( "BULK", "MSP\1", chunk, "WHISPER", player, queue )
			local pos = 256
			local parts = 2
			while pos + 255 <= len do
				chunk = strsub( payload, pos, pos + 254 )
				ChatThrottleLib:SendAddonMessage( "BULK", "MSP\2", chunk, "WHISPER", player, queue )
				pos = pos + 255
				parts = parts + 1
			end
			chunk = strsub( payload, pos )
			ChatThrottleLib:SendAddonMessage( "BULK", "MSP\3", chunk, "WHISPER", player, queue )
			return parts
		end
	end
	return 0
end

--[[
	WoW 4.0.3.13329: Bug Workaround
	(Invisible SendAddonMessage() returning visible ERR_CHAT_PLAYER_NOT_FOUND_S system message on failure)
]]
ChatFrame_AddMessageEventFilter( "CHAT_MSG_SYSTEM", function( self, event, msg ) 
	return msp_GnomTEC:PlayerKnownAbout( msg:match( ERR_CHAT_PLAYER_NOT_FOUND_S:format( "(.+)" ) ) )
end )
function msp_GnomTEC:PlayerKnownAbout( player )
	if player == nil or player == "" then
		return false
	end
	return msp_GnomTEC.char[ player ].supported ~= nil
end