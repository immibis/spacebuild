AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/canister01a.mdl")
	self.BaseClass.Initialize(self, false, true)
	self.Entity:SetColor(0, 190, 255, 255)
	self.BaseClass.Trail(self, Vector(0, 190, 255))
end

function ENT:PhysicsUpdate(PhysObj)
	self.BaseClass.MissilePhysicsUpdate(self, PhysObj)
end
	
function ENT:PhysicsCollide(data, physobj)
	self.BaseClass.BFPhysicsCollide(self, data, physobj)
end

function ENT:DoHit()
	cds_freezepos(self.Entity:GetPos(), 3.5, 600)
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
