AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.CDSIgnore = true

ENT.Radius = 1337

ENT.Strength = 0
ENT.MaxStrength = 3000

ENT.TimeStrengthFix = 3

ENT.DestoryEnts1 = {"missile_", "bomb_", "staff_pulse", "drone"}
ENT.DestoryEnts2 = {100, 100, 200, 100}

ENT.DeflectEnts1 = {"npc_grenade_frag", "prop_combine_ball", "rpg_missile"}
ENT.DeflectEnts2 = {50, 300, 100}

ENT.BouceOff = true
ENT.BouceEnergyMulti = .1

function ENT:Initialize()
end

function ENT:Setup(parent)
	if not ValidEntity(parent) then return end
	self.Radius = parent:GetNWInt("Radius")
	
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:PhysicsInitSphere(self.Radius)
	
	self.Entity:DrawShadow(false)
	
	self.Entity:SetTrigger(true)
	self.Entity:SetNotSolid(true)
	
	local offset = Vector() * self.Radius
	
	self.Entity:SetCollisionBounds(-1*offset,offset)
	
	local fx = EffectData()
	fx:SetEntity(self.Entity)
	util.Effect("cds_shield_emit",fx)
	
end

function ENT:ShieldDamage(Amount)
	self.Parent:EventShieldDamage(Amount)
end

function ENT:StartTouch(ent)
	self:ShieldCheck(ent)
	
end

function ENT:EndTouch(ent)
	self:ShieldCheck(ent)
	
end

function ENT:ShieldCheck(ent)
	local classname = ent:GetClass()
	local Energy = RD_GetResourceAmount(self.Entity, "energy")
	local Coolant = RD_GetResourceAmount(self.Entity, "coolant")
	
	for k,v in pairs(self.DestoryEnts1) do
		self:UseStrength(
	end
end

function ENT:OnRemove()
	self.Parent:RequestShieldRegeneration()
end
