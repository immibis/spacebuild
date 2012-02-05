AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.AmmoType = "ammo_pierce"
	
function ENT:Initialize()
	self.Entity:SetColor(0, 255, 0, 255)
	self.BaseClass.Initialize(self, false)
	self.BaseClass.SetUpCrate(self)
end

function ENT:Think()
	self.BaseClass.CrateThink(self)
	self.Entity:NextThink(CurTime() + 1)
	return true
end
