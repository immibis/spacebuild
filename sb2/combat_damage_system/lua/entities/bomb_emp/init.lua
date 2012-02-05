AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.BaseClass.Initialize(self, false, true)
	self.Entity:SetColor(0, 0, 255, 255)
end

function ENT:PhysicsCollide(data, physobj)
	self.BaseClass.BFPhysicsCollide(self, data, physobj)
end

function ENT:DoHit()
	cds_empblast(self.Entity:GetPos(), 8, 500)
	self.Entity:Remove()
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end
