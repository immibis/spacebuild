-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Packaging System
-- Purpose: Packages goods for transport. 
-- Uses: Resource Distribution 2, Life Support 2, Wire

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient/energy/electric_loop.wav" )
util.PrecacheSound( "AlyxEMP.Discharge" )
util.PrecacheSound( "common/warning.wav")
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel( "models/props_lab/teleplatform.mdl" )
	self.BaseClass.Initialize(self)
	
	-- use stuff
	self.packetsize = 5000 			-- Default size of packets to launch
	self.currentpacketsize = 0		-- Current load size
	self.resourcetype = 1			-- resource type
	self.reloadtime = 0				-- How long until the packager can fire again
	self.charging = 0				-- 0 = inactive, 1 = packaging
	--self.Cycle = 0
	self.energyuse = math.Round(self.packetsize/10)	-- A simple linear growth for this one
	self.NextCheckTime = 0
	
	
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then 
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Compress", "Resource Type", "Package Size" })
		self.Outputs = Wire_CreateOutputs( self.Entity, { "Ready" ,"Package Size", "Energy Use", "Compressing Package" })	
	 end

	local RD = CAF.GetAddon("Resource Distribution")
	RD.RegisterNonStorageDevice(self)
	
	self.ResTable = {}
	self:ReadyResources()

	self.Entity:SetNetworkedInt("Max",self.packetsize)
	self.Entity:SetNetworkedInt("PercentDone",0)
	self.Entity:SetNetworkedInt("ReqEnergy",self.energyuse)
	self.Entity:SetNetworkedString("Resource",self.ResTable[1])
	self.Entity:SetNetworkedBool("Recharging",false)
	

end


function ENT:ReadyResources()
	local RD = CAF.GetAddon("Resource Distribution")
	self.ResTable = RD.GetRegisteredResources();
end  

-- Wiremod function!
function ENT:TriggerInput(iname, value)
	self:ReadyResources()
	local RD = CAF.GetAddon("Resource Distribution")
	if(iname == "Compress") then
		if((value == 1) and (self.reloadtime < CurTime())) then
			if (RD.GetResourceAmount(self.Entity, "energy") >  self.energyuse) then
				self.charging = 1
				self.counter = 0
				self.Entity:SetNetworkedBool("Recharging",true)

				--self.Entity:EmitSound( "ambient/energy/electric_loop.wav")
			end
		end	
	end
	if(iname == "Resource Type") then
		if ((value >= 0) and (value <= (table.getn(self.ResTable))) and (value != self.resourcetype) and (self.charging == 0)) then
			--Chage resource type if value is within range, and it isn't the same resource type
			--and it isn't charging a packet
			if (value == 0) then value = 1 end
			self.resourcetype = math.Round(value)			--Lurk-moar found this one, forgot to round the input :-P
			self.currentpacketsize=0
			self.reloadtime = CurTime() + 5
			self.Entity:SetNetworkedString("Resource",self.ResTable[self.resourcetype])
			-- if you change the resource
			-- be nice and show it on the tooltip
			--self.Cycle = 2
		end	
	end
	if((iname == "Package Size") and (self.charging == 0)) then
		--minimum packet size is 100
		if (value < 100) then
			self.packetsize = 100
		--no max, if you can afford the energy, you can package it
		else 
			--Change Packet Size
			self.packetsize = math.Round(value)
		end	
		if (self.currentpacketsize > self.packetsize) then
			self.currentpacketsize = self.packetsize
		end
		self.energyuse = math.Round(self.packetsize/10)
		self.Entity:SetNetworkedInt("ReqEnergy",self.energyuse)
		self.Entity:SetNetworkedInt("Max",self.packetsize)
	end
end

function ENT:Use()
	self:ReadyResources()
	local RD = CAF.GetAddon("Resource Distribution")
	if(self.reloadtime < CurTime()) then
		if (RD.GetResourceAmount(self.Entity, "energy") >  self.energyuse) then
			self.charging = 1
			self.counter = 0
			self.Entity:SetNetworkedBool("Recharging",true)
			--self.Entity:EmitSound( "ambient/energy/electric_loop.wav")

		end
	end	
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "ambient/energy/electric_loop.wav" )
	self.Entity:StopSound( "AlyxEMP.Discharge" )
end

function ENT:Think()
	self.BaseClass.Think(self)
	local RD = CAF.GetAddon("Resource Distribution")
	-- check for updates from the global functions every 5 seconds
	self.NextCheckTime = (self.NextCheckTime + 1) % 50
	if (self.NextCheckTime == 0) then self:ReadyResources() end

	
	self.energy 	= RD.GetResourceAmount(self.Entity, "energy")
	self.varmod		= 0
	
	
	local tempvarname = self.ResTable[self.resourcetype]
	local tempvalue = RD.GetResourceAmount(self.Entity, tempvarname)

	if (self.charging == 1) then
		--Setting networked vars is expensive, so lets do it every five seconds
		self.counter = (self.counter + 1) % 50
		if (self.counter == 0) then
			self.Entity:SetNetworkedInt("PercentDone",math.Round(self.currentpacketsize/self.packetsize*100))
		end
		
		
		self.reloadtime = CurTime() + 5
		--self.Cycle = 3.5
		if ((self.currentpacketsize + 10) > self.packetsize) then
			self.varmod = (self.currentpacketsize + 10) - self. packetsize
			self.charging = 2
		else
			self.varmod = 0
		end
		
		if (tempvalue >= 10) then
			RD.ConsumeResource(self, tempvarname, 10 - self.varmod)
			self.currentpacketsize = self.currentpacketsize + 10 - self.varmod
		else
			RD.ConsumeResource(self, tempvarname, tempvalue - self.varmod)
			self.currentpacketsize = self.currentpacketsize + tempvalue - self.varmod
		end
		local effectdata = EffectData()
			effectdata:SetStart	(self.Entity:GetPos()+ Vector(math.Rand(-30,30),math.Rand(-30,30),0))
			effectdata:SetOrigin(self.Entity:GetPos()+  self.Entity:GetUp() * 50 + Vector(math.Rand(-20,20),math.Rand(-20,20),0))
			effectdata:SetEntity(self.Entity)
			effectdata:SetAttachment( 1 )
		util.Effect	( "rts_zap", effectdata ) 


		--self.energyuse 	= math.Round(self.packetsize/10)
			
		if (self.charging == 2) then
			self.Entity:StopSound( "ambient/energy/electric_loop.wav" )

			local ent = ents.Create( "rts_package" )
			ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 10)
			ent:SetAngles( self.Entity:GetAngles() )
			ent:Spawn()
			ent:SetWeight(tempvarname,self.packetsize)
			ent:Activate()

			self.currentpacketsize = 0
			self.reloadtime = CurTime() + 5
			self.Entity:EmitSound( "AlyxEMP.Discharge", 100, 100)
			
			ent.resourcename = tempvarname

			self.counter = 0
			self.charging = 0
			self.currentpacketsize = 0
			self.Entity:SetNetworkedInt("PercentDone",0)
			self.Entity:SetNetworkedBool("Recharging",false)

		end
	end	
---------------------WIRE MOD OUTPUTS------------------------------------------------- 
	if not (WireAddon == nil) then 
			Wire_TriggerOutput(self.Entity, "Ready", tonumber((self.reloadtime < CurTime())))
			Wire_TriggerOutput(self.Entity, "Energy Use", self.energyuse)
			Wire_TriggerOutput(self.Entity, "Compressing Package", self.charging)
			Wire_TriggerOutput(self.Entity, "Packet Size", self.currentpacketsize)
			Wire_TriggerOutput(self.Entity, "Max Load", self.packetsize)
	end	

	self.Entity:NextThink( CurTime() + 0.1 )
	return true
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end