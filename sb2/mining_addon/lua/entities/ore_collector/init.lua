AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "Canals.d1_canals_01_chargeloop" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	RD_AddResource(self.Entity, "energy", 0)
	for _, res in pairs( AsteroidResources ) do
		RD_AddResource(self.Entity, res.name, 0)
	end
	
	self.Active = 0
	self.range = 500
	self.Entity:SetNetworkedInt( 1, self.range )
	
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self.Entity, { "On", "Range" })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Active" })
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(80)
		phys:Wake()
	end
end

function ENT:TurnOn()
	if ( self.Active == 0 ) then
		self.Active = 1
		self:SetOOO(1)
		self.Entity:EmitSound( "Canals.d1_canals_01_chargeloop" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Active", 1) end
	end
end

function ENT:TurnOff()
	if ( self.Active == 1 ) then
		self.Active = 0
		self:SetOOO(0)
		self.Entity:StopSound( "Canals.d1_canals_01_chargeloop" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Active", 0) end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "Canals.d1_canals_01_chargeloop" )
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Range") then
		if (value ~= 0) then
			self.range = math.abs(math.floor(value))
		else
			self.range = 0
		end
		self.Entity:SetNetworkedInt( 1, self.range )
	end
end

function ENT:PhysicsCollide( data, physobj )
	local hitent = data.HitEntity
	if (hitent:GetClass() == "raw_resource") then
		if ((RD_GetNetworkCapacity(self.Entity, hitent.resource.name) - RD_GetResourceAmount(self.Entity, hitent.resource.name)) > hitent.resource.yield) then
			self.Entity:EmitSound( "Rubber.BulletImpact" )
			RD_SupplyResource(self.Entity, hitent.resource.name, hitent.resource.yield)
			hitent:Remove()
		end
	end
end

function ENT:Vacuum()
	if ( RD_GetResourceAmount(self.Entity, "energy") >= math.floor(self.range/10) + 5 ) then
		RD_ConsumeResource(self.Entity, "energy", 5) --stand by power
		local ore_units = ents.FindByClass( "raw_resource" )
		local pos = self.Entity:GetPos()
		
		for _, check in pairs( ore_units ) do
			local dist = check:GetPos():Distance(pos)
			if (dist < self.range) then
				
				local energyneeded = math.max(math.floor(dist/10) , 2)
				if ( RD_GetResourceAmount(self.Entity, "energy") >= energyneeded ) then
					RD_ConsumeResource(self.Entity, "energy", energyneeded) -- use more energy when when doing something
					
					local phys = check:GetPhysicsObject()
					local mass = phys:GetMass()
					local vec = (pos - check:GetPos()):Normalize()
					local force = (vec * (self.range - dist)) * mass
					phys:ApplyForceCenter(force)
				end
				
			end
		end
		
	else
		self.Entity:EmitSound( "common/warning.wav" )
	end
end

function ENT:Think()
	self.BaseClass.Think(self)

	if ( self.Active == 1 ) then self:Vacuum() end
	
	self:NextThink( CurTime() + 1 )
	return true
end
