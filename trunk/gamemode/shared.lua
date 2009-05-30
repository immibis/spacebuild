
/*---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

---------------------------------------------------------*/

include( "player_extension.lua" )

GM.Name 	= "Spacebuild 3: The New Age (Beta)"
GM.Author 	= "Spacebuild Dev Team"
GM.Email 	= ""
GM.Website 	= "http://snakesvx.blogdns.com"

/*
 Note: This is so that in addons you can do stuff like
 
 if ( !GAMEMODE.IsSandboxDerived ) then return end //SandBox Check
 if ( !GAMEMODE.IsSpacebuildDerived ) then return end //Spacebuild 3 Check
 
*/

GM.IsSandboxDerived = true
GM.IsSpacebuildDerived = true
GM.SpacebuildVersion = 3.01

GM.affected = {
	"prop_physics",
	"prop_ragdoll",
	"npc_grenade_frag",
	"npc_grenade_bugbait",
	"npc_satchel",
	"grenade_ar2",
	"crossbow_bolt",
	"phys_magnet",
	"prop_vehicle_airboat",
	"prop_vehicle_jeep",
	"prop_vehicle_prisoner_pod"
}

cleanup.Register( "props" )
cleanup.Register( "ragdolls" )
cleanup.Register( "effects" )
cleanup.Register( "npcs" )
cleanup.Register( "constraints" )
cleanup.Register( "ropeconstraints" )
cleanup.Register( "sents" )
cleanup.Register( "vehicles" )


physgun_limited = CreateConVar( "physgun_limited", "0", FCVAR_REPLICATED )


/*---------------------------------------------------------
   Name: gamemode:CanConstrain( ply, trace, mode )
   Return true if the player is allowed to do this constrain
---------------------------------------------------------*/
function GM:CanConstrain( ply, trace, mode )

	// Not allowed to constrain their fellow players
	if (trace.Entity:IsValid() && trace.Entity:IsPlayer()) then
		return false
	end
	
	// Give the entity a chance to decide
	if ( trace.Entity:GetTable().CanConstrain ) then
		return trace.Entity:GetTable():CanConstrain( ply, trace, mode )
	end
	
	//Msg( "Can Constrain "..mode.."\n" )

	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:CanConstruct( ply, trace, mode )
   Return true if the player is allowed to do this construction
---------------------------------------------------------*/
function GM:CanConstruct( ply, trace, mode )

	if ( mode == "remover" && !trace.Entity:IsValid()) then
		return false
	end
	
	// The jeep spazzes out when applying something
	// todo: Find out what it's reacting badly to and change it in _physprops
	if ( mode == "physprop" && trace.Entity:IsValid() && trace.Entity:GetClass() == "prop_vehicle_jeep" ) then
		return false
	end
	
	// Give the entity a chance to decide
	if ( trace.Entity:GetTable().CanConstruct ) then
		return trace.Entity:GetTable():CanConstruct( ply, trace, mode )
	end

	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:CanPose( ply, trace, mode )
   Return true if the player is allowed to do this constrain
---------------------------------------------------------*/
function GM:CanPose( ply, trace, mode )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:CanRender( ply, trace, mode )
   Return true if the player is allowed to do this constrain
---------------------------------------------------------*/
function GM:CanRender( ply, trace, mode )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:CanTool( ply, trace, mode )
   Return true if the player is allowed to use this tool
---------------------------------------------------------*/
function GM:CanTool( ply, trace, mode )

	// The jeep spazzes out when applying something
	// todo: Find out what it's reacting badly to and change it in _physprops
	if ( mode == "physprop" && trace.Entity:IsValid() && trace.Entity:GetClass() == "prop_vehicle_jeep" ) then
		return false
	end
	
	// If we have a toolsallowed table, check to make sure the toolmode is in it
	if ( trace.Entity.m_tblToolsAllowed ) then
	
		local vFound = false	
		for k, v in pairs( trace.Entity.m_tblToolsAllowed ) do
			if ( mode == v ) then vFound = true end
		end

		if ( !vFound ) then return false end

	end
	
	// Give the entity a chance to decide
	if ( trace.Entity.CanTool ) then
		return trace.Entity:CanTool( ply, trace, mode )
	end

	return true
	
end


/*---------------------------------------------------------
   Name: gamemode:GravGunPunt( )
   Desc: We're about to punt an entity (primary fire).
		 Return true if we're allowed to.
---------------------------------------------------------*/
function GM:GravGunPunt( ply, ent )

	if ( ent:IsValid() && ent:GetTable().GravGunPunt ) then
		return ent:GetTable():GravGunPunt( ply )
	end

	return self.BaseClass:GravGunPunt( ply, ent )
	
end

/*---------------------------------------------------------
   Name: gamemode:GravGunPickupAllowed( )
   Desc: Return true if we're allowed to pickup entity
---------------------------------------------------------*/
function GM:GravGunPickupAllowed( ply, ent )

	if ( ent:IsValid() && ent:GetTable().GravGunPickupAllowed ) then
		return ent:GetTable():GravGunPickupAllowed( ply )
	end

	return self.BaseClass:GravGunPickupAllowed( ply, ent )
	
end


/*---------------------------------------------------------
   Name: gamemode:PhysgunPickup( )
   Desc: Return true if player can pickup entity
---------------------------------------------------------*/
function GM:PhysgunPickup( ply, ent )
	--Spacebuild
	local notallowed =  { "base_sb_planet1", "base_sb_planet2", "base_sb_star1", "base_sb_star2", "nature_dev_tree", "sb_environment", "base_cube_environment"}
	if table.HasValue(notallowed, ent:GetClass()) then
		return false
	end
	--Sandbox
	if ( ent:IsValid() && ent.PhysgunPickup ) then
		return ent:PhysgunPickup( ply )
	end
	
	// Some entities specifically forbid physgun interaction
	if ( ent.PhysgunDisabled ) then return false end
	
	local EntClass = ent:GetClass()

	// Never pick up players
	if ( EntClass == "player" ) then return false end
	
	if ( physgun_limited:GetBool() ) then
	
		if ( string.find( EntClass, "prop_dynamic" ) ) then return false end
		if ( string.find( EntClass, "prop_door" ) ) then return false end
		
		// Don't move physboxes if the mapper logic says no
		if ( EntClass == "func_physbox" && ent:HasSpawnFlags( SF_PHYSBOX_MOTIONDISABLED ) ) then return false  end
		
		// If the physics object is frozen by the mapper, don't allow us to move it.
		if ( string.find( EntClass, "prop_" ) && ( ent:HasSpawnFlags( SF_PHYSPROP_MOTIONDISABLED ) || ent:HasSpawnFlags( SF_PHYSPROP_PREVENT_PICKUP ) ) ) then return false end
		
		// Allow physboxes, but get rid of all other func_'s (ladder etc)
		if ( EntClass != "func_physbox" && string.find( EntClass, "func_" ) ) then return false end

	
	end
	
	if ( SERVER ) then 
	
		ply:SendHint( "PhysgunFreeze", 2 )
		ply:SendHint( "PhysgunUse", 8 )
		
	end
	
	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:EntityKeyValue( ent, key, value )
   Desc: Called when an entity has a keyvalue set
	      Returning a string it will override the value
---------------------------------------------------------*/
function GM:EntityKeyValue( ent, key, value )


	// Physgun not allowed on this prop..
	if ( key == "gmod_allowphysgun" && value == '0' ) then
		ent.PhysgunDisabled = true
	end

	// Prop has a list of tools that are allowed on it.
	if ( key == "gmod_allowtools" ) then
		ent.m_tblToolsAllowed = string.Explode( " ", value )
	end
	
end
