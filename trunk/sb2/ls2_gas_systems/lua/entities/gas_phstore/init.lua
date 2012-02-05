AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Huge Processed Gas Tank"
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_buildings/watertower_001c.mdl")
    self.BaseClass.Initialize(self)

    local phys = self.Entity:GetPhysicsObject()
    
    RD_AddResource(self.Entity, "nitrogen",55000)
    RD_AddResource(self.Entity, "methane",55000)
    RD_AddResource(self.Entity, "propane",55000)

    self.damaged = 0
    self.maxhealth = 600
    self.health = self.maxhealth
    
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Nitrogen", "Methane", "Propane", "Max Nitrogen", "Max Methane", "Max Propane" }) end
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(500)
	end
end


function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
    LS_Destruct(self.Entity)
end

function ENT:Output()
	return 1
end

function ENT:UpdateWireOutputs()
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self.Entity, "Nitrogen", RD_GetResourceAmount( self, "nitrogen" ))
        Wire_TriggerOutput(self.Entity, "Methane", RD_GetResourceAmount( self, "methane" ))
        Wire_TriggerOutput(self.Entity, "Propane", RD_GetResourceAmount( self, "propane" ))
        Wire_TriggerOutput(self.Entity, "Max Nitrogen",RD_GetNetworkCapacity( self, "nitrogen" ))
        Wire_TriggerOutput(self.Entity, "Max Methane", RD_GetNetworkCapacity( self, "methane" ))
        Wire_TriggerOutput(self.Entity, "Max Propane", RD_GetNetworkCapacity( self, "propane" ))
    end
end

function ENT:Think()
    self.BaseClass.Think(self)
    
    self:UpdateWireOutputs()
    
	self.Entity:NextThink( CurTime() + 1 )
	return true
end


function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
	end
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
