
/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnObject( ply )
   Desc: Called to ask whether player is allowed to spawn any objects
---------------------------------------------------------*/
function GM:PlayerSpawnObject( ply )
	return true
end


/*---------------------------------------------------------
   Name: LimitReachedProcess
---------------------------------------------------------*/
local function LimitReachedProcess( ply, str )

	// Always allow in single player
	if (SinglePlayer()) then return true end

	local c = server_settings.Int( "sbox_max"..str, 0 )
	
	if ( ply:GetCount( str ) < c || c < 0 ) then return true end 
	
	ply:LimitHit( str ) 
	return false

end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnRagdoll( ply, model )
   Desc: Return true if it's allowed 
---------------------------------------------------------*/
function GM:PlayerSpawnRagdoll( ply, model )

	return LimitReachedProcess( ply, "ragdolls" )
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnProp( ply, model )
   Desc: Return true if it's allowed 
---------------------------------------------------------*/
function GM:PlayerSpawnProp( ply, model )

	return LimitReachedProcess( ply, "props" )

end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnEffect( ply, model )
   Desc: Return true if it's allowed 
---------------------------------------------------------*/
function GM:PlayerSpawnEffect( ply, model )

	return LimitReachedProcess( ply, "effects" )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnVehicle( ply, model, vname, vtable )
   Desc: Return true if it's allowed 
---------------------------------------------------------*/
function GM:PlayerSpawnVehicle( ply, model, vname, vtable )

	return LimitReachedProcess( ply, "vehicles" )
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnSWEP( ply, wname, wtable )
   Desc: Return true if it's allowed 
---------------------------------------------------------*/
function GM:PlayerSpawnSWEP( ply, wname, wtable )

	return true
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerGiveSWEP( ply, wname, wtable )
   Desc: Return true if it's allowed 
---------------------------------------------------------*/
function GM:PlayerGiveSWEP( ply, wname, wtable )

	return true
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnSENT( ply, name )
   Desc: Return true if player is allowed to spawn the SENT
---------------------------------------------------------*/
function GM:PlayerSpawnSENT( ply, name )
		
	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnNPC( ply, npc_type )
   Desc: Return true if player is allowed to spawn the NPC
---------------------------------------------------------*/
function GM:PlayerSpawnNPC( ply, npc_type, equipment )

	return LimitReachedProcess( ply, "npcs" )	
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnedRagdoll( ply, model, ent )
   Desc: Called after the player spawned a ragdoll
---------------------------------------------------------*/
function GM:PlayerSpawnedRagdoll( ply, model, ent )

	ply:AddCount( "ragdolls", ent )

end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnedProp( ply, model, ent )
   Desc: Called after the player spawned a prop
---------------------------------------------------------*/
function GM:PlayerSpawnedProp( ply, model, ent )

	ply:AddCount( "props", ent )
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnedEffect( ply, model, ent )
   Desc: Called after the player spawned an effect
---------------------------------------------------------*/
function GM:PlayerSpawnedEffect( ply, model, ent )

	ply:AddCount( "effects", ent )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnedVehicle( ply, ent )
   Desc: Called after the player spawned a vehicle
---------------------------------------------------------*/
function GM:PlayerSpawnedVehicle( ply, ent )

	ply:AddCount( "vehicles", ent )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnedNPC( ply, ent )
   Desc: Called after the player spawned an NPC
---------------------------------------------------------*/
function GM:PlayerSpawnedNPC( ply, ent )

	ply:AddCount( "npcs", ent )

end



/*---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
---------------------------------------------------------*/
function GM:PlayerNoClip( ply, on )
	// Don't allow if player is in vehicle
	if ( ply:InVehicle() ) then return false end
	
	// Always allow in single player
	if ( SinglePlayer() ) then return true end
	
	--Spacebuild
	if SB_InSpace == 1 and server_settings.Bool("SB_NoClip") and not self:AllowAdminNoclip(ply) and server_settings.Bool( "SB_PlanetNoClipOnly" ) and ply.environment and ply.environment:IsSpace() then return false end
	--End Spacebuild
	
	return server_settings.Bool( "sbox_noclip" )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnedSENT( ply, ent )
   Desc: Called after the player has spawned a SENT
---------------------------------------------------------*/
function GM:PlayerSpawnedSENT( ply, ent )

	ply:AddCount( "sents", ent )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnedSENT( ply, ent )
   Desc: Called after the player has spawned a SENT
---------------------------------------------------------*/
function GM:PlayerSpawnedSENT( ply, ent )

	ply:AddCount( "sents", ent )

end

/*---------------------------------------------------------
   Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
---------------------------------------------------------*/
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( 3 )
	 
	 end
	 
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.5 )
	 
	 end

end


/*---------------------------------------------------------
   Name: gamemode:PlayerEnteredVehicle( player, vehicle, role )
   Desc: Player entered the vehicle fine
---------------------------------------------------------*/
function GM:PlayerEnteredVehicle( player, vehicle, role )

	player:SendHint( "VehicleView", 2 )

end
