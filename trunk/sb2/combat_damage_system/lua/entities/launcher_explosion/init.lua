AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self, true, false, true)
	RD_AddResource(self.Entity, "ammo_explosion", 0)
	RD_AddResource(self.Entity, "ammo_fuel", 0)
	
	self.Entity:SetColor(0, 0, 0, 255)
	self.Entity:SetMaterial("models/shiny")
	
	self.Cooldown = 5
	
	self.EnergyUse = 600
	self.CoolantUse = 600
	
	self.FuelUse = 250
	self.ExplosionUse = 500
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateMissile(self, "missile_explosion")
end
