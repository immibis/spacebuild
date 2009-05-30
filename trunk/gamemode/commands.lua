
include( 'prop_tools.lua' )

/*---------------------------------------------------------
   Name: CCSpawn
   Desc: Console Command for a player to spawn different items
---------------------------------------------------------*/
function CCSpawn( player, command, arguments )

	if ( arguments[1] == nil ) then return end
	if ( !gamemode.Call( "PlayerSpawnObject", player ) ) then return end
	if ( !util.IsValidModel( arguments[1] ) ) then return end
	
	local iSkin = arguments[2] or 0

	if ( util.IsValidProp( arguments[1] ) ) then 
	
		GMODSpawnProp( player, arguments[1], iSkin )
		return
	
	end
	
	if ( util.IsValidRagdoll( arguments[1] ) ) then 
	
		GMODSpawnRagdoll( player, arguments[1], iSkin )
		return
	
	end

	// Not a ragdoll or prop.. must be an 'effect' - spawn it as one
	GMODSpawnEffect( player, arguments[1], iSkin )
	
end

/*---------------------------------------------------------

---------------------------------------------------------*/
local function MakeRagdoll( Player, Pos, Ang, Model, PhysicsObjects, Data )

	if not gamemode.Call( "PlayerSpawnRagdoll", Player, Model ) then return end
	local Ent = ents.Create( "prop_ragdoll" )
		duplicator.DoGeneric( Ent, Data )
	Ent:Spawn()
	
	duplicator.DoGenericPhysics( Ent, Player, Data )
	duplicator.DoFlex( Ent, Data.Flex, Data.FlexScale )
	
	Ent:Activate()

	gamemode.Call( "PlayerSpawnedRagdoll", Player, Model, Ent )
	return Ent	
end

// Register the "prop_ragdoll" class with the duplicator, (Args in brackets will be retreived for every bone)
duplicator.RegisterEntityClass( "prop_ragdoll", MakeRagdoll, "Pos", "Ang", "Model", "PhysicsObjects", "Data" )

/*---------------------------------------------------------
   Name: GMODSpawnRagdoll - player spawns a ragdoll
---------------------------------------------------------*/
function GMODSpawnRagdoll( player, model, iSkin )

	if ( !gamemode.Call( "PlayerSpawnRagdoll", player, model ) ) then return end
	local e = DoPlayerEntitySpawn( player, "prop_ragdoll", model, iSkin )
	gamemode.Call( "PlayerSpawnedRagdoll", player, model, e )
	
	undo.Create("Ragdoll")
		undo.SetPlayer(player)
		undo.AddEntity(e)
	undo.Finish( "Ragdoll ("..tostring(model)..")" )
	
	player:AddCleanup( "ragdolls", e )

end


function MakeProp( Player, Pos, Ang, Model, PhysicsObjects, Data )

	// Uck.
	Data.Pos = Pos
	Data.Angle = Ang
	Data.Model = Model

	// Make sure this is allowed
	if ( !gamemode.Call( "PlayerSpawnProp", Player, Model ) ) then return end
	
	local Prop = ents.Create( "prop_physics" )
		duplicator.DoGeneric( Prop, Data )
	Prop:Spawn()
	
	duplicator.DoGenericPhysics( Prop, Player, Data )
	duplicator.DoFlex( Prop, Data.Flex, Data.FlexScale )
	
	// Tell the gamemode we just spawned something
	gamemode.Call( "PlayerSpawnedProp", Player, Model, Prop )
	
	FixInvalidPhysicsObject( Prop )
	
	DoPropSpawnedEffect( Prop )
	
	return Prop
	
end

duplicator.RegisterEntityClass( "prop_physics", MakeProp, "Pos", "Ang", "Model", "PhysicsObjects", "Data" )

/*---------------------------------------------------------
   Name: FixInvalidPhysicsObject
			Attempts to detect and correct the physics object
			on models such as the TF2 Turrets
---------------------------------------------------------*/
function FixInvalidPhysicsObject( Prop )

	local PhysObj = Prop:GetPhysicsObject()
	if ( !PhysObj ) then return end
	
	local min, max = PhysObj:GetAABB()
	if  ( !min || !max ) then return end
	
	local PhysSize = (min - max):Length()
	if ( PhysSize > 5 ) then return end
	
	local min = Prop:OBBMins()	
	local max = Prop:OBBMaxs()
	if  ( !min || !max ) then return end
	
	local ModelSize = (min - max):Length()
	local Difference = math.abs( ModelSize - PhysSize )
	if ( Difference < 10 ) then return end

	// This physics object is definitiely weird.
	// Make a new one.
	
	Prop:PhysicsInitBox( min, max )
	Prop:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	local PhysObj = Prop:GetPhysicsObject()
	if ( !PhysObj ) then return end
	
	PhysObj:SetMass( 100 )
	PhysObj:Wake()

end

/*---------------------------------------------------------
   Name: CCSpawnProp - player spawns a prop
---------------------------------------------------------*/
function GMODSpawnProp( player, model, iSkin )

	if ( !gamemode.Call( "PlayerSpawnProp", player, model ) ) then return end
	local e = DoPlayerEntitySpawn( player, "prop_physics", model, iSkin )
	gamemode.Call( "PlayerSpawnedProp", player, model, e )

	// This didn't work out - todo: Find a better way.
	//timer.Simple( 0.01, CheckPropSolid, e, COLLISION_GROUP_NONE, COLLISION_GROUP_WORLD )
	
	FixInvalidPhysicsObject( e )
	
	DoPropSpawnedEffect( e )

	undo.Create("Prop")
		undo.SetPlayer(player)
		undo.AddEntity(e)
	undo.Finish( "Prop ("..tostring(model)..")" )
	
	player:AddCleanup( "props", e )

end

/*---------------------------------------------------------
   Name: GMODSpawnEffect
---------------------------------------------------------*/
function GMODSpawnEffect( player, model, iSkin )

	if ( !gamemode.Call( "PlayerSpawnEffect", player, model ) ) then return end
	local e = DoPlayerEntitySpawn( player, "prop_effect", model, iSkin )
	gamemode.Call( "PlayerSpawnedEffect", player, model, e )
	
	undo.Create("Effect")
		undo.SetPlayer(player)
		undo.AddEntity(e)
	undo.Finish( "Effect ("..tostring(model)..")" )
	
	player:AddCleanup( "effects", e )

end

/*---------------------------------------------------------
   Name: DoPlayerEntitySpawn
   Desc: Utility function for player entity spawning functions
---------------------------------------------------------*/
function DoPlayerEntitySpawn( player, entity_name, model, iSkin )

	local vStart = player:GetShootPos()
	local vForward = player:GetAimVector()

	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = player
	
	local tr = util.TraceLine( trace )

	// PrintTable( tr )

	// Prevent spawning too close
	//if ( !tr.Hit || tr.Fraction < 0.05 ) then 
	//	return 
	//end
	
	local ent = ents.Create( entity_name )
	if ( !ent:IsValid() ) then return end

	local ang = player:EyeAngles()
	ang.yaw = ang.yaw + 180 // Rotate it 180 degrees in my favour
	ang.roll = 0
	ang.pitch = 0
	
	if (entity_name == "prop_ragdoll") then
		ang.pitch = -90
		tr.HitPos = tr.HitPos
	end
	
	ent:SetModel( model )
	ent:SetSkin( iSkin )
	ent:SetAngles( ang )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent:Activate()

	// Attempt to move the object so it sits flush
	// We could do a TraceEntity instead of doing all 
	// of this - but it feels off after the old way

	local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )	// Find a point that is definitely out of the object in the direction of the floor
		vFlushPoint = ent:NearestPoint( vFlushPoint )			// Find the nearest point inside the object to that point
		vFlushPoint = ent:GetPos() - vFlushPoint				// Get the difference
		vFlushPoint = tr.HitPos + vFlushPoint					// Add it to our target pos
										
	if (entity_name != "prop_ragdoll") then
	
		// Set new position
		ent:SetPos( vFlushPoint )
	
	else
	
		// With ragdolls we need to move each physobject
		local VecOffset = vFlushPoint - ent:GetPos()
		for i=0, ent:GetPhysicsObjectCount()-1 do
			local phys = ent:GetPhysicsObjectNum( i )
			phys:SetPos( phys:GetPos() + VecOffset )
		end
		
	end

	return ent
	
end


concommand.Add( "gm_spawn", CCSpawn )


local function SetAdditionalEquipment( Player, NPC )

	local WeaponName = Player:GetInfo( "gmod_npc_weapon" )
	if ( !WeaponName or WeaponName == "" or WeaponName == "none" ) then return end

	// Make sure the weapon is in the allowed list!
	local WeaponList = list.Get( "NPCWeapons" )
	if ( !WeaponList[ WeaponName ] ) then return end

	NPC:SetKeyValue( "additionalequipment", WeaponName )

end

local function InternalSpawnNPC( Player, Position, Normal, Class )

	local NPCList = list.Get( "NPC" )
	local NPCData = NPCList[ Class ]
	
	// Don't let them spawn this entity if it isn't in our NPC Spawn list.
	// We don't want them spawning any entity they like!
	if ( !NPCData ) then 
		Player:SendLua( "Derma_Message( \"Sorry! You can't spawn that NPC!\" )" );
	return end
	
	local bDropToFloor = false
		
	//
	// This NPC has to be spawned on a ceiling ( Barnacle )
	//
	if ( NPCData.OnCeiling && Vector( 0, 0, -1 ):Dot( Normal ) < 0.95 ) then
		return nil
	end
	
	//
	// This NPC has to be spawned on a floor ( Turrets )
	//
	if ( NPCData.OnFloor && Vector( 0, 0, 1 ):Dot( Normal ) < 0.95 ) then
		return nil
	else
		bDropToFloor = true
	end
	
	
	//
	// Offset the position
	//
	local Offset = NPCData.Offset or 32
	Position = Position + Normal * Offset
	
	
	// Create NPC
	local NPC = ents.Create( NPCData.Class )
	if ( !ValidEntity( NPC ) ) then return end

	NPC:SetPos( Position )
	
	// Rotate to face player (expected behaviour)
	local Angles = Player:GetAngles()
		Angles.pitch = 0
		Angles.roll = 0
		Angles.yaw = Angles.yaw + 180

	if ( NPCData.Rotate ) then Angles = Angles + NPCData.Rotate end
		
	NPC:SetAngles( Angles )
	
	//
	// This NPC has a special model we want to define
	//
	if ( NPCData.Model ) then
		NPC:SetModel( NPCData.Model )
	end
	
	//
	// Spawn Flags
	//
	local SpawnFlags = SF_NPC_FADE_CORPSE | SF_NPC_ALWAYSTHINK
	if ( NPCData.SpawnFlags ) then SpawnFlags = SpawnFlags | NPCData.SpawnFlags end
	if ( NPCData.TotalSpawnFlags ) then SpawnFlags = NPCData.TotalSpawnFlags end
	NPC:SetKeyValue( "spawnflags", SpawnFlags )
	
	//
	// Optional Key Values
	//
	if ( NPCData.KeyValues ) then
		for k, v in pairs( NPCData.KeyValues ) do
			NPC:SetKeyValue( k, v )
		end		
	end
	
	//
	// This NPC has a special skin we want to define
	//
	if ( NPCData.Skin ) then
		NPC:SetSkin( NPCData.Skin )
	end
	
	//
	// What weapon should this mother be carrying
	//
	SetAdditionalEquipment( Player, NPC )
	
	
	NPC:Spawn()
	NPC:Activate()
	
	if ( bDropToFloor && !NPCData.OnCeiling ) then
		NPC:DropToFloor()	
	end
	
	return NPC
	
end

function CCSpawnNPC( player, command, arguments )

	local NPCClassName = arguments[1]
	if ( !NPCClassName ) then return end
	
	local WeaponName = player:GetInfo( "gmod_npc_weapon" )

	// Give the gamemode an opportunity to deny spawning
	if ( !gamemode.Call( "PlayerSpawnNPC", player, NPCClassName, WeaponName ) ) then return end
	
	local vStart = player:GetShootPos()
	local vForward = player:GetAimVector()
	
	local trace = {}
		trace.start = vStart
		trace.endpos = vStart + vForward * 2048
		trace.filter = player

	local tr = util.TraceLine( trace )
	
	// Create the NPC is you can.
	local SpawnedNPC = InternalSpawnNPC( player, tr.HitPos, tr.HitNormal, NPCClassName )
	if ( !ValidEntity( SpawnedNPC ) ) then return end

	// Give the gamemode an opportunity to do whatever
	gamemode.Call( "PlayerSpawnedNPC", player, SpawnedNPC )
	
	// See if we can find a nice name for this NPC..
	local NPCList = list.Get( "NPC" )
	local NiceName = nil
	if ( NPCList[ NPCClassName ] ) then 
		NiceName = NPCList[ NPCClassName ].Name
	end

	// Add to undo list
	undo.Create("NPC")
		undo.SetPlayer( player )
		undo.AddEntity( SpawnedNPC )
		if ( NiceName ) then
			undo.SetCustomUndoText( "Undone "..NiceName )
		end
	undo.Finish( "NPC ("..tostring(arguments[1])..")" )
	
	// And cleanup
	player:AddCleanup( "npcs", SpawnedNPC )
		

end

concommand.Add( "gmod_spawnnpc", CCSpawnNPC )


local function GenericNPCDuplicator( Player, Model, Class, Equipment, SpawnFlags, Data )

	if ( !gamemode.Call( "PlayerSpawnNPC", Player, Class, Equipment ) ) then return end

	local Entity = InternalSpawnNPC( Player, Data.Pos, Vector(0,0,1), Class, Equipment, SpawnFlags )
	
	if ( Entity && Entity:IsValid()) then

		Entity:SetModel( Model )
		Entity:SetAngles( Data.Angle )
		gamemode.Call( "PlayerSpawnedNPC", Player, Entity )
		Player:AddCleanup( "npcs", Entity )
		table.Add( Entity:GetTable(), Data )
		
	end
	
	return Entity
	
end

// Huuuuuuuuhhhh
duplicator.RegisterEntityClass( "npc_alyx", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_antlion", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_antlionguard", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_barnacle", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_barney", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_breen", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_combine_s", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_combine_p", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_combine_e", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_crow", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_cscanner", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_dog", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_eli", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_fastzombie", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_gman", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_headcrab", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_headcrab_black", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_headcrab_fast", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_kleiner", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_manhack", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_metropolice", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_monk", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_mossman", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_pigeon", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_rollermine", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_seagull", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_zombie", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_zombie_torso", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_citizen_rebel", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_citizen", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_citizen_dt", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )
duplicator.RegisterEntityClass( "npc_citizen_medic", GenericNPCDuplicator, "Model", "Class", "Equipment", "SpawnFlags", "Data"  )


/*---------------------------------------------------------
   Name: CanPlayerSpawnSENT
---------------------------------------------------------*/
local function CanPlayerSpawnSENT( player, EntityName )

	// Make sure this is a SWEP
	local sent = scripted_ents.GetStored( EntityName )
	if (sent == nil) then 
	
		// Is this in the SpawnableEntities list?
		local SpawnableEntities = list.Get( "SpawnableEntities" )
		if (!SpawnableEntities) then return false end
		local EntTable = SpawnableEntities[ EntityName ]
		if (!EntTable) then return false end
		if ( EntTable.AdminOnly && !player:IsAdmin() ) then return false end
		
		return true 
	
	end

	local sent = sent.t
	
	// We need a spawn function. The SENT can then spawn itself properly
	if (!sent.SpawnFunction) then return false end
	
	// You're not allowed to spawn this unless you're an admin!
	if ( !sent.Spawnable && !player:IsAdmin() ) then return false end 
	if ( sent.AdminOnly && !player:IsAdmin() ) then return false end
	
	return true
	
end

/*---------------------------------------------------------
   Name: CCSpawnSENT
   Desc: Console Command for a player to spawn different items
---------------------------------------------------------*/

function CCSpawnSENT( player, command, arguments )

	local EntityName = arguments[1]
	if ( EntityName == nil ) then return end
	
	if ( !CanPlayerSpawnSENT( player, EntityName ) ) then return end
	
	// Ask the gamemode if it's ok to spawn this
	if ( !gamemode.Call( "PlayerSpawnSENT", player, EntityName ) ) then return end
	
	local vStart = player:GetShootPos()
	local vForward = player:GetAimVector()
	
	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = player
	
	local tr = util.TraceLine( trace )
	
	local entity = nil
	local PrintName = nil
	local sent = scripted_ents.GetStored( EntityName )
	if ( sent ) then
	
		local sent = sent.t
		entity = sent:SpawnFunction( player, tr )
		PrintName = sent.PrintName
	
	else
	
		// Spawn from list table
		local SpawnableEntities = list.Get( "SpawnableEntities" )
		if (!SpawnableEntities) then return end
		local EntTable = SpawnableEntities[ EntityName ]
		if (!EntTable) then return end
		
		PrintName = EntTable.PrintName
		
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		if ( EntTable.NormalOffset ) then SpawnPos = SpawnPos + tr.HitNormal * EntTable.NormalOffset end
	
		entity = ents.Create( EntTable.ClassName )
			entity:SetPos( SpawnPos )
		entity:Spawn()
		entity:Activate()
		
		if ( EntTable.DropToFloor ) then
			entity:DropToFloor()
		end
	
	end
	

	if ( ValidEntity( entity ) ) then
	
		gamemode.Call( "PlayerSpawnedSENT", player, entity )
		
		undo.Create("SENT")
			undo.SetPlayer(player)
			undo.AddEntity(entity)
			if ( PrintName ) then
				undo.SetCustomUndoText( "Undone "..PrintName )
			end
		undo.Finish( "Scripted Entity ("..tostring( EntityName )..")" )
		
		player:AddCleanup( "sents", entity )		
		entity:SetVar( "Player", player )
	
	end
	
	
end

concommand.Add( "gm_spawnsent", CCSpawnSENT )

/*---------------------------------------------------------
	// Give a swep.. duh.
---------------------------------------------------------*/
function CCGiveSWEP( player, command, arguments )

	if ( arguments[1] == nil ) then return end

	// Make sure this is a SWEP
	local swep = weapons.GetStored( arguments[1] )
	if (swep == nil) then return end
	
	// You're not allowed to spawn this!
	if ( !swep.Spawnable && !player:IsAdmin() ) then
		return
	end
	
	if ( !gamemode.Call( "PlayerGiveSWEP", player, arguments[1], swep ) ) then return end
	
	MsgAll( "Giving "..player:Nick().." a "..swep.Classname.."\n" )
	player:Give( swep.Classname )
	
	// And switch to it
	player:SelectWeapon( swep.Classname )
	
end

concommand.Add( "gm_giveswep", CCGiveSWEP )

/*---------------------------------------------------------
	// Give a swep.. duh.
---------------------------------------------------------*/
function CCSpawnSWEP( player, command, arguments )

	if ( arguments[1] == nil ) then return end

	// Make sure this is a SWEP
	local swep = weapons.GetStored( arguments[1] )
	if (swep == nil) then return end
	
	// You're not allowed to spawn this!
	if ( !swep.Spawnable && !player:IsAdmin() ) then
		return
	end
	
	if ( !gamemode.Call( "PlayerSpawnSWEP", player, arguments[1], swep ) ) then return end
	
	local tr = player:GetEyeTraceNoCursor()

	if ( !tr.Hit ) then return end
	
	local entity = ents.Create( swep.Classname )
	
	if ( ValidEntity( entity ) ) then
	
		entity:SetPos( tr.HitPos + tr.HitNormal * 32 )
		entity:Spawn()
	
	end
	
end

concommand.Add( "gm_spawnswep", CCSpawnSWEP )


local function MakeVehicle( Player, Pos, Ang, Model, Class, VName, VTable )

	if (!gamemode.Call( "PlayerSpawnVehicle", Player, Model, VName, VTable )) then return end
	
	local Ent = ents.Create( Class )
	if (!Ent) then return NULL end
	
	Ent:SetModel( Model )
	
	// Fill in the keyvalues if we have them
	if ( VTable && VTable.KeyValues ) then
		for k, v in pairs( VTable.KeyValues ) do
			Ent:SetKeyValue( k, v )
		end		
	end
		
	Ent:SetAngles( Ang )
	Ent:SetPos( Pos )
		
	Ent:Spawn()
	Ent:Activate()
	
	Ent.VehicleName 	= VName
	Ent.VehicleTable 	= VTable
	
	// We need to override the class in the case of the Jeep, because it 
	// actually uses a different class than is reported by GetClass
	Ent.ClassOverride 	= Class

	gamemode.Call( "PlayerSpawnedVehicle", Player, Ent )
	return Ent	
	
end

duplicator.RegisterEntityClass( "prop_vehicle_jeep_old",   		MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable" )
duplicator.RegisterEntityClass( "prop_vehicle_jeep",    		MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable" )
duplicator.RegisterEntityClass( "prop_vehicle_airboat", 		MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable" )
duplicator.RegisterEntityClass( "prop_vehicle_prisoner_pod", 	MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable" )


/*---------------------------------------------------------
   Name: CCSpawnVehicle
   Desc: Player attempts to spawn vehicle
---------------------------------------------------------*/
function CCSpawnVehicle( Player, command, arguments )

	if ( arguments[1] == nil ) then return end
		
	local vname = arguments[1]
	local VehicleList = list.Get( "Vehicles" )
	local vehicle = VehicleList[ vname ]
	
	// Not a valid vehicle to be spawning..
	if ( !vehicle ) then return end
	
	local tr = Player:GetEyeTraceNoCursor()
	
	local Angles = Player:GetAngles()
		Angles.pitch = 0
		Angles.roll = 0
		Angles.yaw = Angles.yaw + 180
	
	local Ent = MakeVehicle( Player, tr.HitPos, Angles, vehicle.Model, vehicle.Class, vname, vehicle ) 
	if ( !ValidEntity( Ent ) ) then return end
	
	if ( vehicle.Members ) then
		table.Merge( Ent, vehicle.Members )
		duplicator.StoreEntityModifier( Ent, "VehicleMemDupe", vehicle.Members );
	end
	
	undo.Create( "Vehicle" )
		undo.SetPlayer( Player )
		undo.AddEntity( Ent )
		undo.SetCustomUndoText( "Undone "..vehicle.Name )
	undo.Finish( "Vehicle ("..tostring( vehicle.Name )..")" )
	
	Player:AddCleanup( "vehicles", Ent )
	
end

concommand.Add( "gm_spawnvehicle", CCSpawnVehicle )


local function VehicleMemDupe( Player, Entity, Data )

    table.Merge( Entity, Data );
	
end
duplicator.RegisterEntityModifier( "VehicleMemDupe", VehicleMemDupe );
