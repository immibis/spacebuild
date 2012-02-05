AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Small N2O Tank"
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/PropaneCanister001a.mdl")
    self.BaseClass.Initialize(self)
    self.Entity:SetColor(0, 38, 123, 255)
    
	self.damaged = 0
    self.maxhealth = 200
    self.health = self.maxhealth
    
    LS_RegisterEnt(self.Entity, "Storage")
    RD_AddResource(self.Entity, "nitrous", 3000)

	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Nitrous Oxide", "Max Nitrous Oxide" }) end
	
    local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(40)
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
	self.Entity:SetColor(0, 38, 123, 255)
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
        Wire_TriggerOutput(self.Entity, "Nitrous Oxide", RD_GetResourceAmount( self, "nitrous" ))
        Wire_TriggerOutput(self.Entity, "Max Nitrous Oxide", RD_GetNetworkCapacity( self, "nitrous" ))
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
