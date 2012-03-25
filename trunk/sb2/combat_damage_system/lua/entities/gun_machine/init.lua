AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self, false, false, false, false)
	RD_AddResource(self.Entity, "coolant", 0)
	RD_AddResource(self.Entity, "ammo_basic", 0)
	
	self.Entity:SetColor(45, 140, 90, 255)
	self.Entity:SetMaterial("models/shiny")
	
	self.Cooldown = 0.16 --old: 0.08
	
	self.EnergyUse = 0
	self.CoolantUse = 25
	self.RequireCoolant = 1
	self.BasicUse = 25
	
	self.Firing = false
	
	self.BaseClass.SetUpWireSupport(self)
end

function ENT:Use(activator, caller)
	if(!self.BaseClass.CanUse(self, activator)) then return end
	self:Shoot()
end

function ENT:Think()
	self.BaseClass.Think(self)
	if(self.Firing == false) then return end
	self:Shoot(true)
	self.Entity:NextThink(CurTime() + 0.16)
	--old rate 0.08
	return true
end

function ENT:Shoot(NoCoolDown)
	if(NoCoolDown == true and self.Cooldown ~= -1) then
		self.Cooldown = -1
	elseif(self.Cooldown ~= 0.16) then --old: 0.08
		self.Cooldown = 0.16 --old: 0.08
	end
	if(!self.BaseClass.Shoot(self)) then return end
	
	local Bullet = {}
	Bullet.Num = 1
	Bullet.Src = self.Entity:GetPos()
	Bullet.Dir = self.Entity:GetUp()
	Bullet.Spread = Vector(0.01, 0.01, 0.01)
	Bullet.Tracer = 1
	Bullet.TracerName = "AR2Tracer" --AirboatGunHeavyTracer
	Bullet.Force = 500
	Bullet.Damage = 10
	Bullet.Attacker = self.Activator
	self.Entity:FireBullets(Bullet)
	self.Entity:EmitSound("Weapon_AR2.Single") 
	
 	-- local Effect = EffectData()
 	-- Effect:SetOrigin(self.Entity:GetPos())
 	-- Effect:SetAngle(self.Entity:GetAngles())
 	-- Effect:SetScale(1)
 	-- util.Effect("MuzzleEffect", Effect)
end

function ENT:TriggerInput(iname, value)
	if(iname == "Fire") then
		if(value == 1) then
			self.Firing = true
		else
			self.Firing = false
		end
	end
	if(iname == "Disable Use") then
		if(value == 1) then
			self.DisableUse = true
			Wire_TriggerOutput(self.Entity, "Disable Use", 1)
		else
			self.DisableUse = false
			Wire_TriggerOutput(self.Entity, "Disable Use", 0)
		end
	end
end
