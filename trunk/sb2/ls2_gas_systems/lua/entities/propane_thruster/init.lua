
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireMod == nil) then
	ENT.WireDebugName = "Propane Thruster"
end

local Thruster_Sound 	= Sound( "PhysicsCannister.ThrusterLoop" )

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.Entity:DrawShadow( false )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	--Resource settings
	self.propanecon = 0
	self.propanediv = 170
	self.thrustmult = 12
	
	RD_AddResource(self.Entity, "propane", 0)
	
	local max = self.Entity:OBBMaxs()
	local min = self.Entity:OBBMins()
	
	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	self:SetForce( 2000 )
	
	self.OWEffect = "fire"
	self.UWEffect = "same"
	
	self:SetOffset( self.ThrustOffset )
	self.Entity:StartMotionController()
	self.outputon = 0
	
	self:Switch( false )

	self.Inputs = Wire_CreateInputs(self.Entity, { "On" })
	self.Outputs = Wire_CreateOutputs(self.Entity, { "On", "Propane Consumption" })
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
    if (self.EnableSound) then
		self.Entity:StopSound(Thruster_Sound)
	end
end

function ENT:SetForce( force, mul )
	if (force) then
		self.force = force
		self:NetSetForce( force )
	end
	mul = mul or 1
	
	local phys = self.Entity:GetPhysicsObject()
	if (!phys:IsValid()) then
		Msg("Warning: [propane_thruster] Physics object isn't valid!\n")
		return
	end

	--Get the data in worldspace
	local ThrusterWorldPos = phys:LocalToWorld( self.ThrustOffset )
	local ThrusterWorldForce = phys:LocalToWorldVector( self.ThrustOffset * -1 )

	-- Calculate the velocity
	ThrusterWorldForce = ThrusterWorldForce * self.force * mul * self.thrustmult
	self.ForceLinear, self.ForceAngle = phys:CalculateVelocityOffset( ThrusterWorldForce, ThrusterWorldPos );
	self.ForceLinear = phys:WorldToLocalVector( self.ForceLinear )
	
	if ( mul > 0 ) then
		self:SetOffset( self.ThrustOffset )
	else
		self:SetOffset( self.ThrustOffsetR )
	end
end

function ENT:Setup(force, force_min, force_max, oweffect, uweffect, owater, uwater, bidir, sound)
	self:SetForce(force)
	
	self.OWEffect = oweffect
	self.UWEffect = uweffect
	self.ForceMin = force_min
	self.ForceMax = force_max
	self.BiDir = bidir
	self.EnableSound = sound
	self.OWater = owater
	self.UWater = uwater
	
	self:SetEffect( self.OWEffect ) 
	
	if (not sound) then
		self.Entity:StopSound(Thruster_Sound)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if ( (self.BiDir) and (math.abs(value) > 0.01) and (math.abs(value) > self.ForceMin) ) or ( (value > 0.01) and (value > self.ForceMin) ) then
			self:Switch(true, math.min(value, self.ForceMax))
		else
			self:Switch(false, 0)
		end
	end
end

function ENT:PhysicsSimulate( phys, deltatime )
	if (!self:IsOn()) then return SIM_NOTHING end
	
	if (!self:CanRun()) then
		self:Switch( false )
	end
	
	if (self.Entity:WaterLevel() > 0) then
	    if (not self.UWater) then
	    	self:SetEffect("none")
			return SIM_NOTHING
		end
		
		if (self.UWEffect == "same") then
	    	self:SetEffect(self.OWEffect)
		else
	    	self:SetEffect(self.UWEffect)
		end
	else
	    if (not self.OWater) then
	    	self:SetEffect("none")
			return SIM_NOTHING
		end
		
	    self:SetEffect(self.OWEffect)
	end
	
	local ForceAngle, ForceLinear = self.ForceAngle, self.ForceLinear
	
	return ForceAngle, ForceLinear, SIM_LOCAL_ACCELERATION
end

function ENT:Switch( on, mul )
	if (!self.Entity:IsValid()) then return false end
	
	local changed = (self:IsOn() ~= on)
	self:SetOn( on )
	
	
	if (on) then 
	    if (changed) and (self.EnableSound) then
			self.Entity:StopSound( Thruster_Sound )
			self.Entity:EmitSound( Thruster_Sound )
		end
		
		self:NetSetMul( mul )
		
		self:SetForce( nil, mul )
	else
	    if (self.EnableSound) then
			self.Entity:StopSound( Thruster_Sound )
		end
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	return true
end

function ENT:CanRun()
	local propane = RD_GetResourceAmount(self.Entity, "propane")	
	
	if (propane >= self.propanecon) then
		return true
	else
		return false
	end
end

 function ENT:Think()
	self.BaseClass.Think(self)
	self.propanecon = math.abs(math.ceil(self.force/self.propanediv))

	if (self:IsOn() && self:CanRun()) then
		RD_ConsumeResource(self.Entity, "propane", self.propanecon)
		self.outputon = 1
	else
		self:Switch( false )
		self.outputon = 0
	end
	
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self.Entity, "Propane Consumption", self.propanecon)
		Wire_TriggerOutput(self.Entity, "On", self.outputon )
	end
	
	self:UpdateTextOutput()

	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateTextOutput()
	local propane = RD_GetResourceAmount(self, "propane")
	
	self.Entity:SetNetworkedInt( 8, propane)
end

function ENT:OnRestore()
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	local max = self.Entity:OBBMaxs()
	local min = self.Entity:OBBMins()
	
	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	self:SetOffset( self.ThrustOffset )
	self.Entity:StartMotionController()
	
	if (self.PrevOutput) then
		self:Switch(true, self.PrevOutput)
	else
		self:Switch(false)
	end
	
    self.BaseClass.OnRestore(self)
end

--Duplicator stuff 
function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
