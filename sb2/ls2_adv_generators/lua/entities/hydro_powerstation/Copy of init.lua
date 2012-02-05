AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local Energy_Increment = 2500
local Water_Increment = 250

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self.lastused = 0
	self.time = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On" })
		self.Outputs = Wire_CreateOutputs(self.Entity, {"On" })
	end
end

function ENT:TurnOn()
	self.Entity:EmitSound( "apc_engine_start" )
	self.Active = 1
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
end

function ENT:TurnOff()
	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	self.Active = 0
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
	self:SetOOO(0)
end

function ENT:SetActive( value )
	if (value) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
	LS_Destruct( self.Entity, true )
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "apc_engine_start" )
end

function ENT:Extract_Energy()
	local inc = Energy_Increment

	--water check (if there is no water powerstation won't create any energy)
	if (RD_GetResourceAmount(self, "water") <= 0) then

		if (self.critical == 0) then
			if self.time > 3 then 
				self.Entity:EmitSound( "common/warning.wav" )
				self.time = 0
			else
				self.time = self.time + 1
			end
		else
			if self.time > 3 then 
				self.Entity:EmitSound( "coast.siren_citizen" )
				self.time = 0
			else
				self.time = self.time + 1
			end
		end

		--only supply 5-25% of the normal amount
		if (inc > 0) then inc = math.ceil(inc/math.random(0,0)) end
	else
		RD_ConsumeResource(self, "water", Water_Increment)
	end

	--the money shot!
	if (inc > 0) then RD_SupplyResource(self, "energy", inc) end
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Output", inc) end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then 
		self:Extract_Energy()
	end
	self.Entity:NextThink( CurTime() + 2 )
	return true
end

