AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local SB_AIR_O2 = 0
local SB_AIR_CO2 = 1
local SB_AIR_N = 2
local SB_AIR_H = 3

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNetworkedInt( "overlaymode", 1 )
	self:SetNetworkedInt( "OOO", 0 )
	self.Active = 0
	self.sbenvironment = {}
	self.sbenvironment.air = {}
	self.sbenvironment.size = 0
	self.sbenvironment.gravity = 0
	self.sbenvironment.atmosphere = 0
	self.sbenvironment.pressure = 0
	self.sbenvironment.temperature = 0
	self.sbenvironment.air.o2 = 0
	self.sbenvironment.air.o2per = 0
	self.sbenvironment.air.co2 = 0
	self.sbenvironment.air.co2per = 0
	self.sbenvironment.air.n = 0
	self.sbenvironment.air.nper = 0
	self.sbenvironment.air.h = 0
	self.sbenvironment.air.hper = 0
	self.sbenvironment.air.max = 0
	GAMEMODE:AddEnvironment(self)
end

function ENT:SetEnvironmentID(id)
	if not id or type(id) != "number" then return false end
	self.sbenvironment.id = id
end

function ENT:GetEnvironmentID()
	return self.sbenvironment.id or 0
end

function ENT:PrintVars()
	/*Msg("Print Environment Data\n")
	PrintTable(self.sbenvironment)
	Msg("End Print Environment Data\n")*/
end

function ENT:GetEnvClass()
	return "SB ENVIRONMENT"
end

function ENT:GetSize()
	return self.sbenvironment.size or 0
end

function ENT:GetPriority()
	return 3
end

function ENT:GetO2Percentage()
	return (self.sbenvironment.air.o2  / self.sbenvironment.air.max) * 100
end

function ENT:GetCO2Percentage()
	return (self.sbenvironment.air.co2  / self.sbenvironment.air.max) * 100
end

function ENT:GetNPercentage()
	return (self.sbenvironment.air.n  / self.sbenvironment.air.max) * 100
end

function ENT:GetHPercentage()
	return (self.sbenvironment.air.h / self.sbenvironment.air.max) * 100
end

function ENT:SetSize(size)
	if size and type(size) == "number" then
		if size < 0 then size = 0 end
		self:UpdateSize(self.sbenvironment.size, size)
	end
end

function ENT:GetGravity()
	return self.sbenvironment.gravity or 0
end

function ENT:UpdatePressure(ent)
	if not ent or GAMEMODE.Override_PressureDamage > 0 then return end
	if ent:IsPlayer() and GAMEMODE.PlayerOverride > 0 then return end
	if self.sbenvironment.pressure and self.sbenvironment.pressure > 1.5 then
		ent:TakeDamage((self.sbenvironment.pressure - 1.5) * 10)
	end
end

function ENT:Convert(air1, air2, value)
	if not air1 or not air2 or not value then return end
	if type(air1) != "number" or type(air2) != "number" or type(value) != "number" then return end 
	air1 = math.Round(air1)
	air2 = math.Round(air2)
	value = math.Round(value)
	if air1 < 0 or air1 > 3 then return 0 end
	if air2 < 0 or air2 > 3 then return 0 end
	if air1 == air2 then return 0 end
	if value < 1 then return 0 end
	if air1 == SB_AIR_O2 then
		if self.sbenvironment.air.o2 < value then
			value = self.sbenvironment.air.o2
		end
		self.sbenvironment.air.o2 = self.sbenvironment.air.o2 - value
		if air2 == SB_AIR_CO2 then
			self.sbenvironment.air.co2 = self.sbenvironment.air.co2 + value
		elseif air2 == SB_AIR_N then
			self.sbenvironment.air.n = self.sbenvironment.air.n + value
		else
			self.sbenvironment.air.h = self.sbenvironment.air.h + value
		end
	elseif air1 == SB_AIR_CO2 then
		if self.sbenvironment.air.co2 < value then
			value = self.sbenvironment.air.co2
		end
		self.sbenvironment.air.co2 = self.sbenvironment.air.co2 - value
		if air2 == SB_AIR_O2 then
			self.sbenvironment.air.o2 = self.sbenvironment.air.o2 + value
		elseif air2 == SB_AIR_N then
			self.sbenvironment.air.n = self.sbenvironment.air.n + value
		else
			self.sbenvironment.air.h = self.sbenvironment.air.h + value
		end
	elseif air1 == SB_AIR_N then
		if self.sbenvironment.air.n < value then
			value = self.sbenvironment.air.n
		end
		self.sbenvironment.air.n = self.sbenvironment.air.n - value
		if air2 == SB_AIR_O2 then
			self.sbenvironment.air.o2 = self.sbenvironment.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.sbenvironment.air.co2 = self.sbenvironment.air.co2 + value
		else
			self.sbenvironment.air.h = self.sbenvironment.air.h + value
		end
	else
		if self.sbenvironment.air.h < value then
			value = self.sbenvironment.air.h
		end
		self.sbenvironment.air.h = self.sbenvironment.air.h - value
		if air2 == SB_AIR_O2 then
			self.sbenvironment.air.o2 = self.sbenvironment.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.sbenvironment.air.co2 = self.sbenvironment.air.co2 + value
		else
			self.sbenvironment.air.n = self.sbenvironment.air.n + value
		end
	end
	return value
end

function ENT:UpdateGravity(ent)
	if not ent then return end
	if self.sbenvironment.gravity == 0 then
		local trace = {}
		local pos = ent:GetPos()
		trace.start = pos
		trace.endpos = pos - Vector(0,0,512)
		trace.filter = { ent }
		local tr = util.TraceLine( trace )
		if (tr.Hit) then
			if (tr.grav_plate == 1) then
				ent:SetGravity(1)
				ent.gravity = 1
				phys:EnableGravity( true )
				phys:EnableDrag( true )
				return
			end
		end
	elseif ent.gravity and  ent.gravity == self.sbenvironment.gravity then 
		return 
	end
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return end
	if not self.sbenvironment.gravity or self.sbenvironment.gravity  == 0 then
		phys:EnableGravity( false )
		phys:EnableDrag( false )
		ent:SetGravity(0.00001)
		ent.gravity = 0
	else
		ent:SetGravity(self.sbenvironment.gravity)
		ent.gravity = self.sbenvironment.gravity
		phys:EnableGravity( true )
		phys:EnableDrag( true )
	end	
end

function ENT:GetAtmosphere()
	return self.sbenvironment.atmosphere or 0
end

function ENT:GetPressure()
	return self.sbenvironment.pressure or 0
end

function ENT:GetTemperature()
	return self.sbenvironment.temperature or 0
end

function ENT:GetO2()
	return self.sbenvironment.air.o2 or 0
end

function ENT:GetCO2()
	return self.sbenvironment.air.co2 or 0
end

function ENT:GetN()
	return self.sbenvironment.air.n or 0
end

function ENT:GetH()
	return self.sbenvironment.air.h or 0
end

function ENT:CreateEnvironment(gravity, atmosphere, pressure, temperature, o2, co2, n, h)
	//Msg("CreateEnvironment: "..tostring(gravity).."\n")
	//set Gravity if one is given
	if gravity and type(gravity) == "number" then
		if gravity < 0 then
			gravity = 0
		end
		self.sbenvironment.gravity = gravity
	end
	//set atmosphere if given
	if atmosphere and type(atmosphere) == "number" then
		if atmosphere < 0 then
			atmosphere = 0
		elseif atmosphere > 1 then
			atmosphere = 1
		end
		self.sbenvironment.atmosphere = atmosphere
	end
	//set pressure if given
	if pressure and type(pressure) == "number" and pressure >= 0 then
		self.sbenvironment.pressure = pressure
	else 
		self.sbenvironment.pressure = math.Round(self.sbenvironment.atmosphere * self.sbenvironment.gravity)
	end
	//set temperature if given
	if temperature and type(temperature) == "number" then
		self.sbenvironment.temperature = temperature
	end
	//set o2 if given
	if o2 and type(o2) == "number" then
		if o2 < 0 then o2 = 0 end
		if o2 > 100 then o2 = 100 end
		self.sbenvironment.air.o2per = o2
		self.sbenvironment.air.o2 = math.Round(o2 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		o2 = 0
	end
	//set co2 if given
	if co2 and type(co2) == "number" then
		if co2 < 0 then co2 = 0 end
		if (100 - o2) < co2 then co2 = 100-o2 end
		self.sbenvironment.air.co2per = co2
		self.sbenvironment.air.co2 = math.Round(co2 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		co2 = 0
	end
	//set n if given
	if n and type(n) == "number" then
		if n < 0 then n = 0 end
		if ((100 - o2)-co2) < n then n = (100-o2)-co2 end
		self.sbenvironment.air.nper = n
		self.sbenvironment.air.n = math.Round(n * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		n = 0
	end
	//set h if given
	if h and type(n) == "number" then
		if h < 0 then h = 0 end
		if (((100 - o2)-co2)-n) < h then h = ((100-o2)-co2)-n end
		self.sbenvironment.air.hper = h
		self.sbenvironment.air.h = math.Round(h * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		h = 0
	end
	if o2 + co2 + n + h < 100 then
		local tmp = 100 - (o2 + co2 + n + h)
		self.sbenvironment.air.o2 = math.Round((o2+ tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
		self.sbenvironment.air.o2per = o2 + tmp
	elseif o2 + co2 + n + h > 100 then
		local tmp = (o2 + co2 + n + h) - 100
		if o2 > tmp then
			self.sbenvironment.air.o2 = math.Round((o2 - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.o2per = o2 - tmp
		elseif co2 > tmp then
			self.sbenvironment.air.co2 = math.Round((co2 - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.co2per = co2 + tmp
		elseif n > tmp then
			self.sbenvironment.air.n = math.Round((n - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.nper = n + tmp
		elseif h > tmp then
			self.sbenvironment.air.h = math.Round((h - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.hper = h + tmp
		end
	end
	self.sbenvironment.air.max = math.Round(100 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	self:PrintVars()
end

function ENT:UpdateSize(oldsize, newsize)
	if oldsize == newsize then return end
	if oldsize and newsize and type(oldsize) == "number" and type(newsize) == "number" and oldsize >= 0 and newsize >= 0 then
		if oldsize == 0 then
			self.sbenvironment.size = newsize
			self:UpdateEnvironment(nil, nil, nil, nil, self.sbenvironment.air.o2per, self.sbenvironment.air.co2per, self.sbenvironment.air.nper) 
		elseif newsize == 0 then
			self.sbenvironment.air.o2 = 0
			self.sbenvironment.air.co2 = 0
			self.sbenvironment.air.n = 0
			self.sbenvironment.air.h = 0
			self.sbenvironment.size = 0
		else
			self.sbenvironment.air.o2 = (newsize/oldsize) * self.sbenvironment.air.o2
			self.sbenvironment.air.co2 = (newsize/oldsize) * self.sbenvironment.air.co2
			self.sbenvironment.air.n = (newsize/oldsize) * self.sbenvironment.air.n
			self.sbenvironment.air.h = (newsize/oldsize) * self.sbenvironment.air.h
			self.sbenvironment.size = newsize
		end
		self.sbenvironment.air.max = math.Round(100 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	end
end

function ENT:UpdateEnvironment(gravity, atmosphere, pressure, temperature, o2, co2, n, h)
	//set Gravity if one is given
	if gravity and type(gravity) == "number" then
		if gravity < 0 then
			gravity = 0
		end
		self.sbenvironment.gravity = gravity
	end
	//set atmosphere if given
	if atmosphere and type(atmosphere) == "number" then
		if atmosphere < 0 then
			atmosphere = 0
		elseif atmosphere > 1 then
			atmosphere = 1
		end
		self.sbenvironment.atmosphere = atmosphere
	end
	//set pressure if given
	if pressure and type(pressure) == "number" then
		if pressure < 0 then
			pressure = 0
		end
		self.sbenvironment.pressure = pressure
	end
	//set temperature if given
	if temperature and type(temperature) == "number" then
		self.sbenvironment.temperature = temperature
	end
	//set o2 if given
	if o2 and type(o2) == "number" then
		if o2 < 0 then o2 = 0 end
		if o2 > 100 then o2 = 100 end
		self.sbenvironment.air.o2 = math.Round(o2 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		o2 = math.Round(self.sbenvironment.air.o2 / (self.sbenvironment.atmosphere * (self:GetVolume()/1000) * 5))
	end
	//set co2 if given
	if co2 and type(co2) == "number" then
		if co2 < 0 then co2 = 0 end
		if (100 - o2) < co2 then co2 = 100-o2 end
		self.sbenvironment.air.co2 = math.Round(co2 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		co2 = math.Round(self.sbenvironment.air.co2 / (self.sbenvironment.atmosphere * (self:GetVolume()/1000) * 5))
	end
	//set n if given
	if n and type(n) == "number" then
		if n < 0 then n = 0 end
		if ((100 - o2)-co2) < n then n = (100-o2)-co2 end
		self.sbenvironment.air.n = math.Round(n * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		n = math.Round(self.sbenvironment.air.n / (self.sbenvironment.atmosphere * (self:GetVolume()/1000) * 5))
	end
	if h and type(h) == "number" then
		if h < 0 then h = 0 end
		if (((100 - o2)-co2)-n) < h then h = (((100-o2)-co2)-n) end
		self.sbenvironment.air.h = math.Round(h * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	else 
		h = math.Round(self.sbenvironment.air.h / (self.sbenvironment.atmosphere * (self:GetVolume()/1000) * 5))
	end
	if o2 + co2 + n + h < 100 then
		local tmp = 100 - (o2 + co2 + n + h)
		self.sbenvironment.air.o2 = math.Round((o2+ tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
		self.sbenvironment.air.o2per = o2 + tmp
	elseif o2 + co2 + n + h > 100 then
		local tmp = (o2 + co2 + n + h) - 100
		if o2 > tmp then
			self.sbenvironment.air.o2 = math.Round((o2 - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.o2per = o2 - tmp
		elseif co2 > tmp then
			self.sbenvironment.air.co2 = math.Round((co2 - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.co2per = co2 + tmp
		elseif n > tmp then
			self.sbenvironment.air.n = math.Round((n - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.nper = n + tmp
		elseif h > tmp then
			self.sbenvironment.air.h = math.Round((h - tmp) * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
			self.sbenvironment.air.hper = h + tmp
		end
	end
	self.sbenvironment.air.max = math.Round(100 * 5 * (self:GetVolume()/1000) * self.sbenvironment.atmosphere)
	self:PrintVars()
end

function ENT:GetVolume()
	return (4/3) * math.pi * self.sbenvironment.size * self.sbenvironment.size
end

function ENT:IsEnvironment()
	return true
end

function ENT:IsPlanet()
	return false
end

function ENT:IsStar()
	return false
end

function ENT:IsSpace()
	return false
end
 
function ENT:OnEnvironment(ent)
	if not ent then return end
	if ent == self then return end
	local pos = ent:GetPos()
	if pos:Distance(self:GetPos()) < self:GetSize() then
		if not ent.environment then
			ent.environment = self
			//self:UpdateGravity(ent)
		else
			if ent.environment:GetPriority() < self:GetPriority() then
				ent.environment = self
				//self:UpdateGravity(ent)
			elseif ent.environment:GetPriority() == self:GetPriority() then
				if ent.environment:GetSize() != 0 then
					if self:GetSize() <= ent.environment:GetSize() then
						ent.environment = self
						//self:UpdateGravity(ent)
					end
				else
					ent.environment = self
					//self:UpdateGravity(ent)
				end
			end
		end
	end			
end

function ENT:Remove()
		self.BaseClass.Remove(self)
	GAMEMODE:RemoveEnvironment(self)
end
