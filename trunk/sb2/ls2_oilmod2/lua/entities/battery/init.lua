AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

function ENT:Initialize()
	-- Create the physical of this entity
	self.Entity:SetModel( "models/items/car_battery01.mdl" )
	self.BaseClass.Initialize(self)
	self.Entity:SetColor( 120, 96, 96, 255 )
	self.damaged = 0
	
	-- Create the Wire output if wire is installed
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "12V Energy" }) end
	
	-- Add resource, in this case we can hold 100 12V energy
	RD_AddResource(self.Entity, "12V Energy", 100)
	LS_RegisterEnt(self.Entity, "Storage")
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.Entity:SetColor( 120, 96, 96, 255 )
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
	
	-- If wire is installed, we update the wire side of things!
	if not (WireAddon == nil) then
		-- Get the amount of 12V energy in this resource network
		self.energy = RD_GetResourceAmount(self.Entity, "12V Energy")
		Wire_TriggerOutput(self.Entity, "12V Energy", self.energy)
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end
