--[[
Created by lifecell
Credits to:
Lifecell
LS,RD,GS Team


--]]
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:Initialize()
	self.BaseClass.Initialize(self)

    
	self.damaged = 0
  --LS_RegisterEnt(self.Entity, "Storage")
    --wire
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Energy","Air","Coolant","Heavy Water","Water","Steam","ZPE", "methane", "nitrous" , "nitrogen" ,"naturalgas" ,"propane" ,"Max of All" })
	end
    self.Entity:SetColor( 0, 255, 0, 255 )
end

function ENT:Damage()

end

function ENT:Repair()
	--self.Entity:SetColor(255, 255, 255, 255)
	--self.health = self.maxhealth
end

function ENT:Destruct()
	LS_Destruct( self.Entity, true )
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

function ENT:Leak()

end

function ENT:Think()
	self.BaseClass.Think(self)
	
--	if ((self.damaged == 1) and (self.energy > 0)) then
--		self:Leak()
--	end
	
	if not (WireAddon == nil) then
		self:UpdateWireOutput()
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local tenergy = RD_GetResourceAmount(self, "energy")
    local tair = RD_GetResourceAmount(self, "air")
    local tcoolant = RD_GetResourceAmount(self, "coolant")
    local thwater = RD_GetResourceAmount(self, "heavy water")
    local twater = RD_GetResourceAmount(self, "water")
    local tsteam = RD_GetResourceAmount(self, "steam")
    local tzpe = RD_GetResourceAmount(self, "ZPE")
	local maxall = RD_GetUnitCapacity(self, "energy")
    --Gas part
    local tmethane = RD_GetUnitCapacity(self, "methane")
    local tnitrous = RD_GetUnitCapacity(self, "nitrous")
    local tnitrogen = RD_GetUnitCapacity(self, "nitrogen")
    local tnaturalgas = RD_GetUnitCapacity(self, "naturalgas")
    local tpropane = RD_GetUnitCapacity(self, "propane")

	Wire_TriggerOutput(self.Entity, "Energy", tenergy)
    Wire_TriggerOutput(self.Entity, "Air", tair)
    Wire_TriggerOutput(self.Entity, "Coolant", tcoolant)
    Wire_TriggerOutput(self.Entity, "Heavy Water", thwater)
    Wire_TriggerOutput(self.Entity, "Water", twater)
    Wire_TriggerOutput(self.Entity, "Steam", tsteam)
    Wire_TriggerOutput(self.Entity, "ZPE", tzpe)
	Wire_TriggerOutput(self.Entity, "Max of All", maxall)
    --gas part
    Wire_TriggerOutput(self.Entity, "methane", tmethane)
    Wire_TriggerOutput(self.Entity, "nitrous", tnitrous)
    Wire_TriggerOutput(self.Entity, "nitrogen", tnitrogen)
    Wire_TriggerOutput(self.Entity, "naturalgas", tnaturalgas)
	Wire_TriggerOutput(self.Entity, "propane", tpropane)
end
