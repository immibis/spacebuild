AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Small Nitrogen Store"
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/canister01a.mdl")
    self.BaseClass.Initialize(self)
    self.Entity:SetColor(0, 123, 38, 255)
    
	self.damaged = 0
    self.maxhealth = 200
    self.health = self.maxhealth
    
    LS_RegisterEnt(self.Entity, "Storage")
    RD_AddResource(self.Entity, "nitrogen", 3000)

	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Nitrogen", "Max Nitrogen" }) end
	
    local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(100)
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
	self.Entity:SetColor(0, 123, 38, 255)
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
        Wire_TriggerOutput(self.Entity, "Max Nitrogen", RD_GetNetworkCapacity( self, "nitrogen" ))
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
