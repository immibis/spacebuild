
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local CAMERA_MODEL = Model( "models/dav0r/camera.mdl" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetModel( CAMERA_MODEL )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	
	// Don't collide with the player
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Sleep()
	end
	
end

function ENT:SetKey( key )

	self.Entity:SetNetworkedInt( "key", key )

end

function ENT:SetTracking( Ent, LPos )

	if ( Ent:IsValid() ) then
	
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_BBOX )
	
	else
	
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
	
	end
	
	self.Entity:SetNetworkedVector( "trackvec", LPos )
	self.Entity:SetNetworkedEntity( "trackent", Ent )
	self.Entity:NextThink( CurTime() )
	
	self.TrackEnt = Ent

end


function ENT:Think()

	self.TrackEnt = self.Entity:GetNetworkedEntity( "trackent" )	
	self:TrackEntity( self.TrackEnt, self.Entity:GetNetworkedVector( "trackvec" ) )
	
	self.Entity:NextThink( CurTime() )
	
end

function ENT:SetPlayer( pl )

	self.Entity:SetNetworkedEntity( "player", pl )

end

function ENT:SetLocked( locked )

	if (locked == 1) then
	
		self.PhysgunDisabled = true
		
		local phys = self.Entity:GetPhysicsObject()
		if ( phys:IsValid() ) then
			phys:EnableMotion( false )
		end
	
	else
	
		self.PhysgunDisabled = false
	
	end
	
	self.locked = locked

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end

local function Toggle( player )

	local toggle = self:GetToggle()
	local ptab = player:GetTable()
	
	if ( ptab.UsingCamera && ptab.UsingCamera == self.Entity ) then
	
		player:SetViewEntity( player )
		player:GetTable().UsingCamera = nil
		self.UsingPlayer = nil
		
	else
	
		player:SetViewEntity( self.Entity )
		ptab.UsingCamera = self.Entity
		self.UsingPlayer = player
		
	end
	
end

function ENT:OnRemove()

	if (self.UsingPlayer && self.UsingPlayer != NULL) then
	
		self.UsingPlayer:SetViewEntity( self.UsingPlayer )
	
	end

end


/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function On( pl, ent )

	if (!ent || ent == NULL ) then return false end

	local ptab = pl:GetTable()
	pl:SetViewEntity( ent )
	ptab.UsingCamera = ent
	ent:GetTable().UsingPlayer = pl

end

local function Off( pl, ent )

	if (!ent || ent == NULL ) then return false end

	local ptab = pl:GetTable()
	if ( ptab.UsingCamera && ptab.UsingCamera == ent ) then
		pl:SetViewEntity( pl )
		pl:GetTable().UsingCamera = nil
		ent:GetTable().UsingPlayer = nil
	end

end

local function Toggle( pl, ent, idx, buttoned )

	// The camera was deleted or something - return false to remove this entry
	if (!ent || ent == NULL ) then return false end
	
	local ptab = pl:GetTable()
	if ( ptab.UsingCamera && ptab.UsingCamera == ent ) then
		Off( pl, ent )
	else
		On( pl, ent )		
	end
	
end

// register numpad functions
numpad.Register( "Camera_On", On )
numpad.Register( "Camera_Toggle", Toggle )
numpad.Register( "Camera_Off", Off )
