
local meta = FindMetaTable( "Player" )

// Return if there's nothing to add on to
if (!meta) then return end

g_SBoxObjects = {}

/*---------------------------------------------------------
    Name: GetWebsite
---------------------------------------------------------*/
function meta:GetWebsite()
	return self:GetNetworkedString( "Website", "N/A" )
end

/*---------------------------------------------------------
    Name: GetLocation
---------------------------------------------------------*/
function meta:GetLocation()
	return self:GetNetworkedString( "Location", "N/A" )
end

/*---------------------------------------------------------
    Name: GetEmail
---------------------------------------------------------*/
function meta:GetEmail()
	return self:GetNetworkedString( "Email", "N/A" )
end

/*---------------------------------------------------------
    Name: GetMSN
---------------------------------------------------------*/
function meta:GetMSN()
	return self:GetNetworkedString( "MSN", "N/A" )
end

/*---------------------------------------------------------
    Name: GetAIM
---------------------------------------------------------*/
function meta:GetAIM()
	return self:GetNetworkedString( "AIM", "N/A" )
end

/*---------------------------------------------------------
    Name: GetGTalk
---------------------------------------------------------*/
function meta:GetGTalk()
	return self:GetNetworkedString( "GTalk", "N/A" )
end

/*---------------------------------------------------------
    Name: GetXFire
---------------------------------------------------------*/
function meta:GetXFire()
	return self:GetNetworkedString( "XFire", "N/A" )
end



function meta:CheckLimit( str )

	// No limits in single player
	if (SinglePlayer()) then return true end

	local c = server_settings.Int( "sbox_max"..str, 0 )
	
	if ( c < 0 ) then return true end
	if ( self:GetCount( str ) > c-1 ) then self:LimitHit( str ) return false end

	return true

end

function meta:GetCount( str, minus )

	if ( CLIENT ) then
		return self:GetNetworkedInt( "Count."..str, 0 )
	end
	
	minus = minus or 0
	
	if ( !self:IsValid() ) then return end

	local key = self:UniqueID()
	local tab = g_SBoxObjects[ key ]
	
	if ( !tab || !tab[ str ] ) then 
	
		self:SetNetworkedInt( "Count."..str, 0 )
		return 0 
		
	end
	
	local c = 0
	
	for k, v in pairs ( tab[ str ] ) do
	
		if ( v:IsValid() ) then 
			c = c + 1
		else
			tab[ str ][ k ] = nil
		end
	
	end
	
	self:SetNetworkedInt( "Count."..str, c - minus )

	return c

end

function meta:AddCount( str, ent )

	if ( SERVER ) then

		local key = self:UniqueID()
		g_SBoxObjects[ key ] = g_SBoxObjects[ key ] or {}
		g_SBoxObjects[ key ][ str ] = g_SBoxObjects[ key ][ str ] or {}
		
		local tab = g_SBoxObjects[ key ][ str ]
		
		table.insert( tab, ent )
		
		// Update count (for client)
		self:GetCount( str )
		
		ent:CallOnRemove( "GetCountUpdate", function( ent, ply, str ) ply:GetCount(str, 1) end, self, str )
	
	end

end

function meta:LimitHit( str )

	self:SendLua( "GAMEMODE:LimitHit( '".. str .."' )" )

end

function meta:AddCleanup( type, ent )

	cleanup.Add( self, type, ent )
	
end

function meta:GetTool( mode )

	local wep = self:GetWeapon( "gmod_tool" )
	if (!wep || !wep:IsValid()) then return nil end
	
	local tool = wep:GetToolObject( mode )
	if (!tool) then return nil end
	
	return tool

end

if (SERVER) then

	function meta:SendHint( str, delay )

		self:GetTable().Hints = self:GetTable().Hints or {}
		if (self:GetTable().Hints[ str ]) then return end
		
		self:SendLua( "GAMEMODE:AddHint( '"..str.."', "..delay.." )" )
		self:GetTable().Hints[ str ] = true

	end
	
	function meta:SuppressHint( str )

		self:GetTable().Hints = self:GetTable().Hints or {}
		if (self:GetTable().Hints[ str ]) then return end
		
		self:SendLua( "GAMEMODE:SuppressHint( '"..str.."' )" )
		self:GetTable().Hints[ str ] = true

	end

end
