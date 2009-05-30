
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetModel( "models/props_lab/tpplug.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end


/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function On( pl, ent )

	if ( !ent || ent == NULL ) then return false end

	local ptab = pl:GetTable()
	pl:SetViewEntity( ent )
	ptab.UsingCamera = ent
	ent:GetTable().UsingPlayer = pl

end


local function On( pl, ent )

	if ( !ent || ent == NULL ) then return end
	
	local etab = ent:GetTable()

	if ( etab:GetToggle() ) then
		etab:SetOn( !etab:GetOn() )
	return end

	
	etab:SetOn( true )

end

local function Off( pl, ent )

	if ( !ent || ent == NULL ) then return end
	local etab = ent:GetTable()
	
	if ( etab:GetToggle() ) then return end
	
	etab:SetOn( false )

end


numpad.Register( "Emitter_On", 	On )
numpad.Register( "Emitter_Off", Off )