AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

function ENT:Initialize()
	-- Entity properties and crap
	self.Entity:SetModel( "models/props_c17/oildrum001.mdl" )
	self.BaseClass.Initialize(self)
	self.damaged = 0
	
	-- Create a wire output if wire is installed
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Oil" }) end
	
	-- Add resource
	RD_AddResource(self.Entity, "Oil", 4000)
	LS_RegisterEnt(self.Entity, "Storage")
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
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
	
	-- If wire is installed, update the output!
	if not (WireAddon == nil) then
		self.Oil = RD_GetResourceAmount(self.Entity, "Oil")
		Wire_TriggerOutput(self.Entity, "Oil", self.Oil)
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end
