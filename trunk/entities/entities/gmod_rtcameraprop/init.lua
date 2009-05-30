
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

local CAMERA_MODEL = "models/dav0r/camera.mdl"


local I_KEY 			= 0

local E_PLAYER 			= 0
local E_TRACK			= 1

local V_TRACK			= 0

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

	self.Entity:SetNetworkedInt( I_KEY, key )

end

function ENT:SetTracking( Ent, LPos )

	if ( Ent:IsValid() ) then
	
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_BBOX )
	
	else
	
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
	
	end

	self.Entity:SetNetworkedVector( V_TRACK, LPos)
	self.Entity:SetNetworkedEntity( E_TRACK, Ent )
	self.Entity:NextThink( CurTime() )
	
	self.TrackEnt = Ent

end


function ENT:Think()

	self.TrackEnt = self.Entity:GetNetworkedEntity( E_TRACK )
	self:TrackEntity( self.TrackEnt, self.Entity:GetNetworkedVector( V_TRACK ) )
	
	self.Entity:NextThink( CurTime() )
	
end

function ENT:SetPlayer( pl )

	self.Entity:SetNetworkedEntity( E_PLAYER, pl )

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

/*---------------------------------------------------------
   Name: OnRemove
---------------------------------------------------------*/
function ENT:OnRemove()

	// Pick a random camera to use if this one gets removed
	if RenderTargetCameraProp != self.Entity then return end

	Cameras = ents.FindByClass( "gmod_rtcameraprop" )
	CameraIdx = math.random( #Cameras )

	if CameraIdx == self.Entity then
		if #Cameras != 0 then return end
		self:OnRemove()
	end

	Camera = Cameras[ CameraIdx ]
	UpdateRenderTarget( Camera )

end

/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function RTCamera_Use( pl, ent )

	if (!ent:IsValid()) then return false end

	UpdateRenderTarget( ent )

	return true
	
end

// register numpad functions
numpad.Register( "RTCamera_Use", RTCamera_Use )

include('shared.lua')