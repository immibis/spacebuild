
/*---------------------------------------------------------

  SB3 Dummy Gamemode

---------------------------------------------------------*/

// These files get sent to the client

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

/*---------------------------------------------------------
Name: gamemode:PlayerSpawn( )
Desc: Called when a player spawns
GmodFixerupper
Remove once Sandbox/derive system is fixed!
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )
	// If the player doesn't have a team in a TeamBased game
	// then spawn him as a spectator
	if ( self.TeamBased && ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then
	self:PlayerSpawnAsSpectator( pl )
	return
	end
	// Stop observer mode
	pl:UnSpectate()
	// Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	// Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	// Set the player's speed
	GAMEMODE:SetPlayerSpeed( pl, 250, 500 )
end