AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.Entity:SetColor(0, 0, 255, 255)
	self.Entity:SetMaterial("models/shiny")

	self.Cooldown = 20
	
	self.EnergyUse = 450
	self.CoolantUse = 450
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Shoot()
	if(!self.BaseClass.Shoot(self)) then return end
	self.BaseClass.CreateBomb(self, "bomb_emp")
end
