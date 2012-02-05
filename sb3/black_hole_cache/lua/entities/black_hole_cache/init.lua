AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Resources = {"energy", "oxygen", "nitrogen", "water", "steam", "heavy water", "hydrogen", "carbon dioxide", "liquid nitrogen", "hot liquid nitrogen", "methane", "propane", "deuterium", "tritium"}
ENT.MaxAmount = 500000

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	local RD = CAF.GetAddon("Resource Distribution")
	self.Entity:SetColor(0, 0, 0, 255)
	self.Entity:SetMaterial("models/shiny")
	
	for k, res in pairs(self.Resources) do
		RD.AddResource(self.Entity, res, self.MaxAmount)
	end
	
	local Phys = self.Entity:GetPhysicsObject()
	if(Phys:IsValid()) then
		Phys:Wake()
	end
	
	if(WireAddon != nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, {"Resource Amount"})
		Wire_TriggerOutput(self.Entity, "Resource Amount", self.MaxAmount)
	end
end

function ENT:Think()
	local RD = CAF.GetAddon("Resource Distribution")
	for k, res in pairs(self.Resources) do
		if(RD.GetResourceAmount(self.Entity, res) < self.MaxAmount) then
			RD.SupplyResource(self.Entity, res, self.MaxAmount)
		end
	if (self.NextOverlayTextTime) and (CurTime() >= self.NextOverlayTextTime) then
		if (self.NextOverlayText) then
			self.Entity:SetNetworkedString( "GModOverlayText", self.NextOverlayText )
			self.NextOverlayText = nil
		end
	end
	self.NextOverlayTextTime = CurTime() + 0.2 + math.random() * 0.2
	end
	self.Entity:NextThink(CurTime() + 1)
	return true
end


function ENT:OnRemove()
	//self.BaseClass.OnRemove(self) --use this if you have to use OnRemove
	CAF.GetAddon("Resource Distribution").Unlink(self)
	CAF.GetAddon("Resource Distribution").RemoveRDEntity(self)
	if not (WireAddon == nil) then Wire_Remove(self.Entity) end
end