
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Energy Hoverball"
end

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
    self.Entity:DrawShadow(false)
	
	// Don't use the model's physics object, create a perfect sphere
	
	self.Entity:PhysicsInitSphere( 8, "metal_bouncy" )
	
	local phys = self.Entity:GetPhysicsObject()
	RD_AddResource(self.Entity, "energy", 0)
	if ( phys:IsValid() ) then 
		phys:SetMass( 100 )
		phys:EnableGravity( false )
		phys:Wake() 
	end
	
	// Start the motion controller (so PhysicsSimulate gets called)
	self.Entity:StartMotionController()
	
	self.maxhealth = 700
	self.health = self.maxhealth
	self.damaged = 0
	self.Fraction = 0
	self.energycon = 0
	self.strength = 1
	self.resistance = 0
	self.speed = 1
	
	self.ZVelocity = 0
	self:SetTargetZ( self.Entity:GetPos().z )
	self:SetSpeed( 1 )
	self:EnableHover()

	self.Inputs = Wire_CreateInputs(self.Entity, { "ZVelocity", "HoverMode", "SetZTarget", "Speed", "Strength", "Resistance"})
	self.Outputs = Wire_CreateOutputs(self.Entity, { "Zpos", "Xpos", "Ypos", "Speed", "Strength", "Resistance", "EnergyConsumption" })
end


function ENT:TriggerInput(iname, value)
	if (iname == "ZVelocity") then
		self:SetZVelocity( value )
	elseif (iname == "HoverMode") then
		if (value >= 1 && !self:GetHoverMode()) then
			self:EnableHover()
		elseif (self:GetHoverMode()) then
			self:DisableHover()
		end
	elseif (iname == "SetZTarget") then
		self:SetTargetZ(value)
	elseif (iname == "Speed") then
		self:SetSpeed( value )
		self.speed = value
	elseif (iname == "Strength") then
		if ( value < 1 ) then 
			value = 0.1
		end
		self:SetStrength(value)
		self.strength = value
	elseif (iname == "Resistance") then
		if ( value < 0 ) then
			value = 0
		end
		self:SetAirResistance(value)
		self.resistance = value
	end
end


function ENT:EnableHover()
	self:SetHoverMode( true )
	self:SetStrength( self.strength ) //reset weight so it will work
	self:SetTargetZ ( self.Entity:GetPos().z ) //set height to current
	local phys = self.Entity:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:EnableGravity( false )
		phys:Wake()
	end
	self:SetOOO(1)
end

function ENT:DisableHover()
	self:SetHoverMode( false )
	self:SetStrength(0.1) //for less dead weight while off
	local phys = self.Entity:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:EnableGravity( true ) //falls slowly otherwise
	end
	self:SetOOO(0)
end


function ENT:OnRestore()
	self.ZVelocity = 0
	
	self.BaseClass.OnRestore(self)
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	//self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Repair()
	self.health = self.maxhealth
	self.damaged = 0
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()
    self.BaseClass.Think(self)
	self.Entity:NextThink( CurTime() + 1 )
    self.Entity:SetNetworkedInt( "TargetZ", self:GetTargetZ() )
    
    self.energycon = math.abs(math.floor( self.speed + self.strength + (self.ZVelocity/2) ))
    
    if (self:CanRun() && self:GetHoverMode() ) then
        RD_ConsumeResource(self.Entity, "energy", self.energycon)
    else
        self:DisableHover()
	self.energycon = 0
    end
	Wire_TriggerOutput(self.Entity, "Speed", self.speed)
	Wire_TriggerOutput(self.Entity, "Strength", self.strength)
	Wire_TriggerOutput(self.Entity, "Resistance", self.resistance)
    Wire_TriggerOutput(self.Entity, "EnergyConsumption", self.energycon)
	return true
end

 function ENT:CanRun()
 
	local energy = RD_GetResourceAmount(self.Entity, "energy")	
	return (energy >= self.energycon)
	
 end

/*---------------------------------------------------------
   Name: Simulate
---------------------------------------------------------*/
function ENT:PhysicsSimulate( phys, deltatime )
	
	local Pos = phys:GetPos()
	
	Wire_TriggerOutput(self.Entity, "Zpos", Pos.z)
	Wire_TriggerOutput(self.Entity, "Xpos", Pos.x)
	Wire_TriggerOutput(self.Entity, "Ypos", Pos.y)
	
	
	if (self:GetHoverMode()) then
		
		if ( self.ZVelocity != 0 ) then
			
			self:SetTargetZ( self:GetTargetZ() + (self.ZVelocity * deltatime * self:GetSpeed()) )
			self.Entity:GetPhysicsObject():Wake()
			
		end
		
		phys:Wake()
		
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
	else
		return SIM_GLOBAL_FORCE
	end

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
end

/*---------------------------------------------------------
   SetStrength
---------------------------------------------------------*/
function ENT:SetStrength( strength )

	local phys = self.Entity:GetPhysicsObject()
	if ( phys:IsValid() ) then 
		phys:SetMass( 150 * strength )
	end
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
