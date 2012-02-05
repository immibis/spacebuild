AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD_AddResource(self.Entity, "ammo_explosion", 0)
	
	self.Entity:SetColor(0, 0, 0, 255)
	self.Entity:SetMaterial("models/shiny")

	self.Cooldown = 15
	
	self.EnergyUse = 450
	self.CoolantUse = 450
	self.ExplosionUse = 500
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateBomb(self, "bomb_explosion")
end
