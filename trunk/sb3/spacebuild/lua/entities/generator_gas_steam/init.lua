AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
include('shared.lua')

local Energy_Increment = 100
local Water_Increment = 10
local Steam_Increment = 10
local HeatUpTime = 5;

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.overdrive = 0
	self.damaged = 0
	self.lastused = 0
	self.time = 0
	self.Mute = 0
	self.Multiplier = 1
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On", "Overdrive", "Mute", "Multiplier" })
		self.Outputs = Wire_CreateOutputs(self.Entity, {"On", "Overdrive", "EnergyUsage", "WaterUsage", "SteamProduction" })
	else
		self.Inputs = {{Name="On"},{Name="Overdrive"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		if (self.Mute == 0) then
			self.Entity:EmitSound( "Airboat_engine_idle" )
		end
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
		self:SetOOO(1)
	elseif ( self.overdrive == 0 ) then
		self:TurnOnOverdrive()
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		if (self.Mute == 0) then
			self.Entity:StopSound( "Airboat_engine_idle" )
			self.Entity:EmitSound( "Airboat_engine_stop" )
			self.Entity:StopSound( "apc_engine_start" )
		end
		self.Active = 0
		self.overdrive = 0
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
		self:SetOOO(0)
	end
end

function ENT:TurnOnOverdrive()
	if ( self.Active == 1 ) then
		if (self.Mute == 0) then
			self.Entity:StopSound( "Airboat_engine_idle" )
			self.Entity:EmitSound( "Airboat_engine_idle" )
			self.Entity:EmitSound( "apc_engine_start" )
		end
		self:SetOOO(2)
		self.overdrive = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Overdrive", self.overdrive) end
	end
end

function ENT:TurnOffOverdrive()
	if ( self.Active == 1 and self.overdrive == 1) then
		if (self.Mute == 0) then
			self.Entity:StopSound( "Airboat_engine_idle" )
			self.Entity:EmitSound( "Airboat_engine_idle" )
			self.Entity:StopSound( "apc_engine_start" )
		end
		self:SetOOO(1)
		self.overdrive = 0
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Overdrive", self.overdrive) end
	end	
end

function ENT:SetActive( value )
	if (value) then
		if (value ~= 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		else
			if ((( CurTime() - self.lastused) < 2 ) and ( self.overdrive == 0 )) then
				self:TurnOnOverdrive()
			else
				self.overdrive = 0
				self:TurnOff()
			end
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Overdrive") then
		if (value ~= 0) then
			self:TurnOnOverdrive()
		else
			self:TurnOffOverdrive()
		end
	end
	if (iname == "Mute") then
		if (value > 0) then
			self.Mute = 1
		else
			self.Mute = 0
		end
	end
	if (iname == "Multiplier") then
		if (value > 0) then
			self.Multiplier = value
		else
			self.Multiplier = 1

		end	
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
	self.BaseClass.Repair(self)
	self.Entity:SetColor(255, 255, 255, 255)
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "apc_engine_start" )
end

function ENT:Proc_Water()
	local energy = self:GetResourceAmount("energy")
	local water = self:GetResourceAmount("water")
	local einc = Energy_Increment + (self.overdrive*Energy_Increment)
	einc = (math.ceil(einc * self:GetMultiplier())) * self.Multiplier
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "EnergyUsage", einc) end
	local winc = Water_Increment + (self.overdrive*Water_Increment)
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "WaterUsage", winc) end
	winc = (math.ceil(winc * self:GetMultiplier())) * self.Multiplier
	if self.time > HeatUpTime - (self.overdrive * 2) then
		if (energy >= einc and water >= winc) then
			if CAF and CAF.GetAddon("Life Support") then
				if (self.overdrive == 1) then
					CAF.GetAddon("Life Support").DamageLS(self, math.random(2, 3))
				end
			else
				self:SetHealth( self:Health( ) - math.Random(2, 3))
				if self:Health() <= 0 then
					self:Remove()
				end
			end
			self:ConsumeResource("energy", einc)
			self:ConsumeResource("water", winc)
			local left = self:SupplyResource("steam", math.ceil((Steam_Increment + (self.overdrive * Steam_Increment )) * self:GetMultiplier() * self.Multiplier))
			if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "SteamProduction",  math.ceil((Steam_Increment + (self.overdrive * Steam_Increment )) * self:GetMultiplier() * self.Multiplier)) end
			if left > 0 then
				local h = left * 2
				local o2 = math.Round(left/2)
				if self.environment then
					self.environment:Convert(-1, 3, h)
					self.environment:Convert(-1, 0, o2)
				end
			end
		else
			self:TurnOff()
		end
	else
		if ( self.overdrive == 1 ) then
			if CAF and CAF.GetAddon("Life Support") then
				CAF.GetAddon("Life Support").DamageLS(self, math.random(2, 3))
			else
				self.health = self.health - math.Random(2, 3)
				if self.health <= 0 then
					self:Remove()
				end
			end
		end
		self.time = self.time + 1
		self:ConsumeResource("energy", einc)
		self:ConsumeResource("water", winc)	
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then 
		self:Proc_Water()
	end
	self.Entity:NextThink( CurTime() + 1 )
	return true
end

