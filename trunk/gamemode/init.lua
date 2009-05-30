/*---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

---------------------------------------------------------*/

// These files get sent to the client

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "cl_notice.lua" )
AddCSLuaFile( "cl_hints.lua" )
AddCSLuaFile( "cl_worldtips.lua" )
AddCSLuaFile( "player_extension.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_quicktool.lua" )
AddCSLuaFile( "cl_sun.lua" )
AddCSLuaFile( 'cl_spacebuild.lua' )

AddCSLuaFile( "scoreboard/admin_buttons.lua" )
AddCSLuaFile( "scoreboard/player_frame.lua" )
AddCSLuaFile( "scoreboard/player_infocard.lua" )
AddCSLuaFile( "scoreboard/player_row.lua" )
AddCSLuaFile( "scoreboard/scoreboard.lua" )
AddCSLuaFile( "scoreboard/vote_button.lua" )

include( 'shared.lua' )
include( 'commands.lua' )
include( 'player.lua' )
include( 'rating.lua' )
include( 'sv_spacebuild.lua' )

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )

	self.BaseClass.PlayerSpawn( self, pl )
	
	// Set the player's speed
	GAMEMODE:SetPlayerSpeed( pl, 250, 500 )
	
end

/*---------------------------------------------------------
   Name: PlayerDataUpdate
---------------------------------------------------------*/
function PlayerDataUpdate( pl )

	if ( !pl ) then return end
	if ( !pl:IsValid() ) then return end
	
	
	pl:SetNetworkedString( "Website", 	pl:GetInfo( "cl_website" ) )
	pl:SetNetworkedString( "Location", 	pl:GetInfo( "cl_location" ) )
	pl:SetNetworkedString( "Email", 	pl:GetInfo( "cl_email" ) )
	pl:SetNetworkedString( "MSN", 		pl:GetInfo( "cl_msn" ) )
	pl:SetNetworkedString( "AIM", 		pl:GetInfo( "cl_aim" ) )
	pl:SetNetworkedString( "GTalk", 	pl:GetInfo( "cl_gtalk" ) )
	pl:SetNetworkedString( "XFire", 	pl:GetInfo( "cl_xfire" ) )
	
	timer.Simple( 1, PlayerDataUpdate, pl )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout()
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )

	// Remove any old ammo
	pl:RemoveAllAmmo()

	if ( server_settings.Bool( "sbox_weapons", true ) ) then
	
		pl:GiveAmmo( 256,	"Pistol", 		true )
		pl:GiveAmmo( 256,	"SMG1", 		true )
		pl:GiveAmmo( 5,		"grenade", 		true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 32,	"357", 			true )
		pl:GiveAmmo( 32,	"XBowBolt", 	true )
		pl:GiveAmmo( 6,		"AR2AltFire", 	true )
		pl:GiveAmmo( 100,	"AR2", 			true )
		
		
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_pistol" )
		pl:Give( "weapon_smg1" )
		pl:Give( "weapon_frag" )
		pl:Give( "weapon_physcannon" )
		pl:Give( "weapon_crossbow" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_357" )
		pl:Give( "weapon_rpg" )
		pl:Give( "weapon_ar2" )
		
		// The only reason I'm leaving this out is because
		// I don't want to add too many weapons to the first
		// row because that's where the gravgun is.
		//pl:Give( "weapon_stunstick" )
	
	end
	
	pl:Give( "gmod_tool" )
	pl:Give( "gmod_camera" )
	pl:Give( "weapon_physgun" )

	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )

	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end

	
end

/*---------------------------------------------------------
   Name: gamemode:OnPhysgunFreeze( weapon, phys, ent, player )
   Desc: The physgun wants to freeze a prop
---------------------------------------------------------*/
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	
	self.BaseClass:OnPhysgunFreeze( weapon, phys, ent, ply )

	ply:SendHint( "PhysgunUnfreeze", 0.3 )
	ply:SuppressHint( "PhysgunFreeze" )
	
end


/*---------------------------------------------------------
   Name: gamemode:OnPhysgunReload( weapon, player )
   Desc: The physgun wants to freeze a prop
---------------------------------------------------------*/
function GM:OnPhysgunReload( weapon, ply )

	local num = ply:PhysgunUnfreeze()
	
	if ( num > 0 ) then
		ply:SendLua( "GAMEMODE:UnfrozeObjects("..num..")" )
	end

	ply:SuppressHint( "PhysgunReload" )

end


/*---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
   Note: This is a shared function - the client will think they can 
	 damage the players even though they can't. This just means the 
	 prediction will show blood.
---------------------------------------------------------*/
function GM:PlayerShouldTakeDamage( ply, attacker )

	// The player should always take damage in single player..
	if ( SinglePlayer() ) then return true end

	// Global godmode, players can't be damaged in any way
	if ( server_settings.Bool( "sbox_godmode", false ) ) then return false end

	// No player vs player damage
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		return !server_settings.Bool( "sbox_plpldamage", false )
	end
	
	// Default, let the player be hurt
	return true

end


/*---------------------------------------------------------
   Show the school window when F1 is pressed..
---------------------------------------------------------*/
function GM:ShowHelp( ply )

	ply:ConCommand( "SchoolMe" )
	
end


/*---------------------------------------------------------
   Called once on the player's first spawn
   See sv_spacebuild.lua
---------------------------------------------------------*/
--[[function GM:PlayerInitialSpawn( ply )
	
	self.BaseClass:PlayerInitialSpawn( ply )
	
	PlayerDataUpdate( ply )
	
end]]


/*---------------------------------------------------------
   Desc: A ragdoll of an entity has been created
---------------------------------------------------------*/
function GM:CreateEntityRagdoll( entity, ragdoll )

	// Replace the entity with the ragdoll in cleanups etc
	undo.ReplaceEntity( entity, ragdoll )
	cleanup.ReplaceEntity( entity, ragdoll )
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerUnfrozeObject( )
---------------------------------------------------------*/
function GM:PlayerUnfrozeObject( ply, entity, physobject )

	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
	util.Effect( "phys_unfreeze", effectdata, true, true )	
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerFrozeObject( )
---------------------------------------------------------*/
function GM:PlayerFrozeObject( ply, entity, physobject )

	local effectdata = EffectData()
		effectdata:SetOrigin( physobject:GetPos() )
	util.Effect( "phys_freeze", effectdata, true, true )	
	
end
