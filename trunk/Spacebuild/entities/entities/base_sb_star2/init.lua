AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetMoveType(MOVETYPE_NONE)
	self.CDS_IGNORE_ALL = true
	self.sbenvironment.temperature2 = 0
	self.sbenvironment.temperature3 = 0
	self:SetNotSolid(true)
	self:DrawShadow(false)
end

function ENT:GetTemperature(ent)
	if not ent then return end
	local pos = ent:GetPos()
	local entpos = ent:GetPos()
	local SunAngle = (entpos - pos)
	SunAngle:Normalize()
	local startpos = (entpos - (SunAngle * 4096))
	local trace = {}
	trace.start = startpos
	trace.endpos = entpos + Vector(0,0,30)
	local tr = util.TraceLine( trace )
	if (tr.Hit) then
		if (tr == ent) then
			if (ent:IsPlayer()) then
				if (ent:Health() > 0) then
					ent:TakeDamage( 5, 0 )
					ent:EmitSound( "HL2Player.BurnPain" )
				end
			end
		end
	end
	if pos:Distance(self:GetPos()) < self:GetSize()/3 then
		return self.sbenvironment.temperature
	elseif pos:Distance(self:GetPos()) < self:GetSize() * 2/3 then
		return self.sbenvironment.temperature2
	else
		return self.sbenvironment.temperature3
	end
end

function ENT:GetPriority()
	return 2
end

local function SendSunBeam(ent)
	for k, ply in pairs(player.GetAll()) do
		umsg.Start( "AddStar", ply )
			//umsg.Entity( ent ) //planet.num
			umsg.Short( ent:EntIndex())
			umsg.Angle( ent:GetPos() ) //planet.num
			umsg.Float( ent.sbenvironment.size )
		umsg.End()
	end
end

function ENT:CreateEnvironment(ent, radius, temp1, temp2, temp3)
	if not ent then self:Remove() end //needs a parent!
	self:SetParent(ent)
	if radius and type(radius) == "number" then
		if radius < 0 then
			radius = 0
		end
		self.sbenvironment.size = radius
	end
	if temp2 and type(temp2) == "number" then
		if temp2 < 0 then
			temp2 = 0
		end
		self.sbenvironment.temperature2 = temp2
	end
	if temp3 and type(temp3) == "number" then
		if temp3 < 0 then
			temp3 = 0
		end
		self.sbenvironment.temperature3 = temp3
	end
	self.BaseClass.CreateEnvironment(self, ent, 0, 100, temp1,  0, 0, 100, 0)
	SendSunBeam(self)
end

function ENT:UpdateEnvironment(radius, temp1, temp2, temp3)
	if radius and type(radius) == "number" then
		self:UpdateSize(self.sbenvironment.size, radius)
	end
	if temp1 and type(temp1) == "number" then
		self.Entity.sbenvironment.temperature = temp1
	end
	if temp2 and type(temp2) == "number" then
		self.Entity.sbenvironment.temperature2 = temp2
	end
	if temp3 and type(temp3) == "number" then
		self.Entity.sbenvironment.temperature3 = temp3
	end
	SendSunBeam(self)
end

function ENT:IsStar()
	return true
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end

function ENT:Remove()
	if self:UsesRD2() then
		self.BaseClass.Remove(self)
	end
	GAMEMODE:RemoveEnvironment(self)
	table.remove(TrueSun, self:GetPos())
end

function ENT:UsesRD2()
	return false
end