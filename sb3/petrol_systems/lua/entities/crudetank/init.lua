AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

local RD = CAF.GetAddon("Resource Distribution")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetColor( 0, 204, 0, 255 )
	-- If wiremod is installed, create an output partaining to requirments!
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Crude Oil" }) end
	-- Are we valid?
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(2000)
		phys:Wake()
	end
	
	-- Add resource
	RD.AddResource(self.Entity, "Crude Oil", self.MAXRESOURCE)
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repoxygen()
	self.Entity:SetColor( 255, 255, 255, 255 )
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
	local Effect = EffectData()
		Effect:SetOrigin(self.Entity:GetPos())
		Effect:SetScale(1)
		Effect:SetMagnitude(25)
	util.Effect("Explosion", Effect, true, true)
	self.Entity:Remove()
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	-- If wire is installed, Use it...
	if not (WireAddon == nil) then
		self.CrudeOil = RD.GetResourceAmount(self.Entity, "Crude Oil")
		Wire_TriggerOutput(self.Entity, "Crude Oil", self.CrudeOil)
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end
