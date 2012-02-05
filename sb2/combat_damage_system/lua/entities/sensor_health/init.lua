AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
if not (WireAddon == nil) then
	ENT.WireDebugName = "sensor_health"
end
util.PrecacheSound( "Buttons.snd17" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local Energy_Increment = 4
local BeepCount = 3
local running = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.entHealth = 0
	RD_AddResource(self.Entity, "energy", 0)
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self.Entity, { "On" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Health",  "On" })
	end
	self.CDSIgnoreHeatDamage = true
end

function ENT:TurnOn()
	self.Entity:EmitSound( "Buttons.snd17" )
	self.Active = 1
	self:SetOOO(1)
	self:Sense()
	self:ShowOutput()
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", 1) end
end

function ENT:TurnOff(warn)
	if (!warn) then self.Entity:EmitSound( "Buttons.snd17" ) end
	self.Active = 0
	self:SetOOO(0)
	self:ShowOutput()
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self.Entity, "On", 0)
		Wire_TriggerOutput(self.Entity, "Health", 0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive( value )
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Sense()
	if (RD_GetResourceAmount(self, "energy") <= 0) then
		self.Entity:EmitSound( "common/warning.wav" )
		self:TurnOff(true)
		return
	else
		if (BeepCount > 0) then
			BeepCount = BeepCount - 1
		else
			self.Entity:EmitSound( "Buttons.snd17" )
			BeepCount = 20 --30 was a little long, 3 times a minute is ok
		end
	end
	local trace = {}
	local pos = self.Entity:GetPos()
	trace.start = pos
	trace.endpos = pos + (self.Entity:GetUp() * -20)
	trace.filter = self.Entity
	local tr = util.TraceLine( trace ) 
	local CAVec = tr.HitPos
	local TAng = pos - CAVec
	if tr.Entity and tr.Entity:IsValid() and tr.Entity.health then
		self.entHealth = tr.Entity.health
	else
		if not CDS_LastCheck(tr.Entity)then
			self.entHealth = tr.Entity.health
		else
			self.entHealth = -1
		end
	end	
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self.Entity, "Health", self.entHealth)
	end
	RD_ConsumeResource(self, "energy", Energy_Increment)
end

function ENT:ShowOutput()
	self.Entity:SetNetworkedInt( 1, self.entHealth )
end

function ENT:Think()
	self.BaseClass.Think(self)
	if (self.Active == 1) then
		self:Sense()
		self:ShowOutput()
	end
	self.Entity:NextThink(CurTime() + 0.5)
	return true
end

