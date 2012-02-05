AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

if not (WireAddon == nil) then
    ENT.WireDebugName = "Oil Gas Extractor"
end

function ENT:Initialize()
	self.Entity:SetModel("models//props_wasteland/gaspump001a.mdl")
    self.BaseClass.Initialize(self)

    local phys = self.Entity:GetPhysicsObject()
	self.damaged = 0
	self.overdrive = 0
	self.overdrivefactor = 0
	self.Active = 0
    self.maxhealth = 240
    self.health = self.maxhealth
	self.disuse = 0
	self.energy = 0
	self.oil = 0
	self.ngas = 0
    
    -- resource attributes
    self.energycon = 10 --Energy consumption
    self.oilcon = 450 -- "Crude Oil" consumption
    self.ngasprod = 110 -- Coolant production
    self.maxoverdrive = 4 -- maximum overdrive value allowed via wire input. Anything over this value may severely damage or destroy the device.
    
    LS_RegisterEnt(self.Entity, "Generator")
    RD_AddResource(self.Entity, "Crude Oil", 0)
    RD_AddResource(self.Entity, "energy",0)
    RD_AddResource(self.Entity, "naturalgas",0)

	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self.Entity, { "On", "Overdrive", "Disable Use" }) end
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "On", "Overdrive", "Energy Consumption", "Crude Oil Consumption", "NGas Production"}) end
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(200)
	end
end

function ENT:Setup()
	self:TriggerInput("On", 0)
	self:TriggerInput("Overdrive", 0)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if (value ~= 0) then
			if ( self.Active == 0 ) then
                self:TurnOn()
                if (self.overdrive == 1) then
                    self:OverdriveOn()
                end
			end
		else
			if ( self.Active == 1 ) then
                self:TurnOff()
			end
		end
	elseif (iname == "Overdrive") then
        if (self.Active == 1) then
            if (value > 0) then
                self:OverdriveOn()
                self.overdrivefactor = value
            else
                self:OverdriveOff()
            end
            if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Overdrive", self.overdrive) end
        end
	elseif (iname == "Disable Use") then
		if (value >= 1) then
			self.disuse = 1
		else
			self.disuse = 0
		end
	end
end


function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
    self.Entity:StopSound( "Airboat_engine_idle" )
    self.Entity:StopSound( "common/warning.wav" )
    self.Entity:StopSound( "apc_engine_start" )
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
	if ((self.Active == 1) and (math.random(1, 10) <= self.maxoverdrive)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.Entity:SetColor(255,255,255,255)
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:TurnOn()
    self.Active = 1
    self:SetOOO(1)
    if not (WireAddon == nil) then 
        Wire_TriggerOutput(self.Entity, "On", 1)
    end
    self.Entity:EmitSound( "Airboat_engine_idle")
end

function ENT:TurnOff()
    self.Active = 0
    self:SetOOO(0)
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self.Entity, "On", 0)
    end
    self.Entity:StopSound( "Airboat_engine_idle" )
    self.Entity:EmitSound( "Airboat_engine_stop" )
end

function ENT:OverdriveOn()
    self.overdrive = 1
    self:SetOOO(2)
    
    self.Entity:StopSound( "Airboat_engine_idle" )
    self.Entity:EmitSound( "apc_engine_stop" )
    self.Entity:EmitSound( "Airboat_engine_idle" )
    self.Entity:EmitSound( "apc_engine_start" )
end

function ENT:OverdriveOff()
    self.overdrive = 0
    self:SetOOO(1)
    
    self.Entity:StopSound( "Airboat_engine_idle" )
    self.Entity:EmitSound( "Airboat_engine_stop" )
    self.Entity:StopSound( "apc_engine_start" )
end

function ENT:Destruct()
    LS_Destruct(self.Entity)
end

function ENT:Output()
	return 1
end

function ENT:OilGas()
	if ( self.overdrive == 1 ) then
        self.energy = math.ceil(self.energycon  * self.overdrivefactor)
        self.oil = math.ceil(self.oilcon * self.overdrivefactor)
        self.ngas = math.ceil(self.ngasprod * self.overdrivefactor)
        
        if self.overdrivefactor > self.maxoverdrive then
            self:Destruct()
        else
            DamageLS(self.Entity, math.ceil(self.overdrivefactor*5))
        end
        
    else
        self.energy = self.energycon
        self.oil = self.oilcon
        self.ngas = self.ngasprod
    end
    
    if not (WireAddon == nil) then
        Wire_TriggerOutput(self.Entity, "Energy Consumption", self.energy)
        Wire_TriggerOutput(self.Entity, "Crude Oil Consumption", self.oil)
        Wire_TriggerOutput(self.Entity, "NGas Production", self.ngas)
    end
    
	if ( self:CanRun() ) then
        RD_ConsumeResource(self, "Crude Oil", self.oil)
        RD_ConsumeResource(self, "energy", self.energy)
        
        RD_SupplyResource(self.Entity, "naturalgas",self.ngas)

        if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", 1) end
	else
		self.Entity:EmitSound( "common/warning.wav" )
		if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", 0) end
	end
		
	return
end

function ENT:CanRun()
    local energy = RD_GetResourceAmount(self, "energy")
    local oil = RD_GetResourceAmount(self, "Crude Oil")
    if (energy >= self.energycon && oil >= self.oilcon) then
        return true
    else
        return false
    end
end

function ENT:Think()
    self.BaseClass.Think(self)
    
	if ( self.Active == 1 ) then
		self:OilGas()
	end
    
	self.Entity:NextThink( CurTime() + 1 )
	return true
end


function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false and self.disuse == 0 then
		if ( self.Active == 0 ) then
			self:TurnOn()
		else
            self:TurnOff()
		end
	end
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities )
end
