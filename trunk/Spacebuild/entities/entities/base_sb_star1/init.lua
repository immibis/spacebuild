AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetMoveType(MOVETYPE_NONE);
	self.CDS_IGNORE_ALL = true
	self:SetNotSolid(true)
	self:DrawShadow(false)
	if CAF and CAF.GetAddon("Custom Damage System") then
		self:SetReceiveDamage(false)
		self:SetReceiveTemperatureDamage(false)
	end
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
		return self.sbenvironment.temperature * 2/3
	else
		return self.sbenvironment.temperature/3
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

function ENT:CreateEnvironment(ent, radius)
	if not ent then self:Remove() end //needs a parent!
	self:SetParent(ent)
	if radius and type(radius) == "number" then
		if radius < 0 then
			radius = 0
		end
		self.sbenvironment.size = radius
	end
	self.BaseClass.CreateEnvironment(self, ent, 0, 100, 100000,  0, 0, 100, 0)
	SendSunBeam(self)
end

function ENT:UpdateEnvironment(radius)
	if radius and type(radius) == "number" then
		self:UpdateSize(self.sbenvironment.size, radius)
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
	self.BaseClass.Remove(self)
	table.remove(TrueSun, self:GetPos())
end
