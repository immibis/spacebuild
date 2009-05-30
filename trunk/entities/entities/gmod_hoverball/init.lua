
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local MODEL = Model( "models/dav0r/hoverball.mdl" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	// Use the helibomb model just for the shadow (because it's about the same size)
	self.Entity:SetModel( MODEL )
	
	// Don't use the model's physics object, create a perfect sphere
	self.Entity:PhysicsInitSphere( 8, "metal_bouncy" )
	
	// Wake up our physics object so we don't start asleep
	local phys = self.Entity:GetPhysicsObject()
	if ( phys:IsValid() ) then 
		phys:SetMass( 100 )
		phys:EnableGravity( false )
		phys:Wake() 
	end
	
	// Start the motion controller (so PhysicsSimulate gets called)
	self.Entity:StartMotionController()
	
	self.Fraction = 0
	
	self.ZVelocity = 0
	self:SetTargetZ( self.Entity:GetPos().z )
	self:SetSpeed( 1 )
	
end

function ENT:OnRestore()

	self.ZVelocity = 0

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	//self.Entity:TakePhysicsDamage( dmginfo )
	
end


/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

	self.Entity:NextThink( CurTime() + 0.25 )

	self.Entity:SetNetworkedInt( "TargetZ", self:GetTargetZ() )
	
	return true
	
end



/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use( activator, caller )

end

/*---------------------------------------------------------
   Name: Simulate
---------------------------------------------------------*/
function ENT:PhysicsSimulate( phys, deltatime )

	if ( self.ZVelocity != 0 ) then
	
		self:SetTargetZ( self:GetTargetZ() + (self.ZVelocity * deltatime * self:GetSpeed()) )
		self.Entity:GetPhysicsObject():Wake()
	
	end
	
	phys:Wake()
	
	local Pos = phys:GetPos()
	local Vel = phys:GetVelocity()
	local Distance = self:GetTargetZ() - Pos.z
	local AirResistance = self:GetAirResistance()
	
	if ( Distance == 0 ) then return end
	
	local Exponent = Distance^2
	
	if ( Distance < 0 ) then
		Exponent = Exponent * -1
	end
	
	Exponent = Exponent * deltatime * 300
	
	local physVel = phys:GetVelocity()
	local zVel = physVel.z
	
	Exponent = Exponent - (zVel * deltatime * 600 * ( AirResistance + 1 ) )
	// The higher you make this 300 the less it will flop about
	// I'm thinking it should actually be relative to any objects we're connected to
	// Since it seems to flop more and more the heavier the object
	
	Exponent = math.Clamp( Exponent, -5000, 5000 )
	
	local Linear = Vector(0,0,0)
	local Angular = Vector(0,0,0)
	
	Linear.z = Exponent
	
	if ( AirResistance > 0 ) then
	
		Linear.y = physVel.y * -1 * AirResistance
		Linear.x = physVel.x * -1 * AirResistance
	
	end

	return Angular, Linear, SIM_GLOBAL_ACCELERATION
	
end


function ENT:SetZVelocity( z )

	if ( z != 0 ) then
		self.Entity:GetPhysicsObject():Wake()
	end

	self.ZVelocity = z * FrameTime() * 5000
end

/*---------------------------------------------------------
   GetAirFriction
---------------------------------------------------------*/
function ENT:GetAirResistance( )
	return self.Entity:GetVar( "AirResistance", 0 )
end


/*---------------------------------------------------------
   SetAirFriction
---------------------------------------------------------*/
function ENT:SetAirResistance( num )
	self.Entity:SetVar( "AirResistance", num )
	self:UpdateLabel()
end

/*---------------------------------------------------------
   SetStrength
---------------------------------------------------------*/
function ENT:SetStrength( strength )

	local phys = self.Entity:GetPhysicsObject()
	if ( phys:IsValid() ) then 
		phys:SetMass( 150 * strength )
	end

	self:UpdateLabel()
	
end


/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function Up( pl, ent, keydown, idx )

	if (!ent:IsValid()) then return false end
	
	if (keydown) then
		ent:GetTable():SetZVelocity( 1 )
	else
		ent:GetTable():SetZVelocity( 0 )
	end
	
	return true
	
end

local function Down( pl, ent, keydown )

	if (!ent:IsValid()) then return false end
	
	if (keydown) then
		ent:GetTable():SetZVelocity( -1 )
	else
		ent:GetTable():SetZVelocity( 0 )
	end
	
	return true
	
end

// register numpad functions
numpad.Register( "Hoverball_Up", 	Up )
numpad.Register( "Hoverball_Down", 	Down )

