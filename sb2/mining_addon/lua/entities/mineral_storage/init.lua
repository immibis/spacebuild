AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

ENT.ResTable = {}

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	for _, res in pairs( AsteroidResources ) do
		RD_AddResource(self.Entity, res.name, 5000)
		table.insert(self.ResTable, res.name)
	end

	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, self.ResTable)
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()	
		phys:SetMass(3000)
	end
end

function ENT:Think()
	if not (WireAddon == nil) then 
		self:UpdateWireOutput()
	end	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	for k, v in pairs(self.ResTable) do
		Wire_TriggerOutput(self.Entity, v, RD_GetResourceAmount(self, v))
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
