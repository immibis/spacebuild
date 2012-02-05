AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self, true, false, true)
	RD_AddResource(self.Entity, "ammo_fuel", 0)
	
	self.Entity:SetColor(0, 190, 255, 255)
	self.Entity:SetMaterial("models/shiny")

	self.Cooldown = 15
	
	self.EnergyUse = 1500
	self.CoolantUse = 1500
	
	self.FuelUse = 250
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateMissile(self, "missile_freeze")
end
