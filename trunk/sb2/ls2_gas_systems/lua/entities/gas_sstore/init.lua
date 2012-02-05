AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Small Ngas Tank"
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/oildrum001.mdl")
    self.BaseClass.Initialize(self)
	self.Entity:SetColor(127,127,127, 255)

    local phys = self.Entity:GetPhysicsObject()
	self.damaged = 0
    self.maxhealth = 210
    self.health = self.maxhealth
    
    LS_RegisterEnt(self.Entity, "Storage")
    RD_AddResource(self.Entity, "naturalgas", 3000)

	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Natural Gas", "Max Natural Gas" }) end
	
	//self.timer = CurTime() +  1
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(120)
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
	self.Entity:SetColor(127,127,127, 255)
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
        Wire_TriggerOutput(self.Entity, "Natural Gas", RD_GetResourceAmount( self, "naturalgas" ))
        Wire_TriggerOutput(self.Entity, "Max Natural Gas", RD_GetNetworkCapacity( self, "naturalgas" ))
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
