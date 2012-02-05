-- Author: Solthar
-- Thanks to: Sassafrass
-- Entity: Mass Driver
-- Purpose: transports goods over large distances
-- and provides a nice gcombat weapon :-P
-- Uses: Resource Distribution 3, Life Support 3, GCombat, Wire
--
-- NEW IN RTS:Piracy
-- * if the packets can be slowed they become semi-stable again
-- * It loads, then waits for user input before firing the packet
-- * a MODEL!

-- Includes
AddCSLuaFile ("shared.lua")
include      ("shared.lua")

-- Precaching
util.PrecacheSound( "NPC_Strider.Shoot" )

resource.AddFile("models/rts_massdriver.mdl")
resource.AddFile("models/rts_massdriver.xbox.vtx")
resource.AddFile("models/rts_massdriver.dx80.vtx")
resource.AddFile("models/rts_massdriver.dx90.vtx")
resource.AddFile("models/rts_massdriver.phy")
resource.AddFile("models/rts_massdriver.sw.vtx")
resource.AddFile("models/rts_massdriver.vvd")
util.PrecacheModel("models/rts_massdriver.mdl" )

resource.AddFile("materials/rts_massdriver.vtf")
resource.AddFile("materials/rts_massdriver.vmt")


-- Default Variables
local _ReloadInterval = 15			-- Minimum time between mass driver shots
local _DefaultPacketSize = 1000		-- 
local _DefaultChargeRate = 10		-- How many units per tenth of a second does the Mass Driver load?
local _InternalCheckInterval = 2.5  -- Time, in seconds, between polls for new resources

function ENT:Initialize()										-- Initialization ------------------------------------------------------------------
	--self.Entity:SetModel( "models/props_lab/teleportframe.mdl" )
	self.Entity:SetModel( "models/rts_massdriver.mdl" )
	self.Entity:SetMaterial("rts_massdriver")
	self.BaseClass.Initialize(self)
	
	-- Setup the Mass Driver
	self.TargetPacketSize 	= _DefaultPacketSize
	self.CurrentPacketSize 	= 0
	self.ResourceID			= 1
	self.TimeToReload 		= 0 
	self.ChargingPacket		= false
	self.WaitingForRelease 	= false
	self.Capacitor			= 0
	
	self._count				= 0
	
	self.Multiplier			= 1
	self.ResourceWaste		= 0
	-- Energy use grows exponentially with packet size.
	self.EnergyToLaunch 	= math.Round(((self.CurrentPacketSize+1)/40)^ 2) + 50
		
	local RD = CAF.GetAddon("Resource Distribution")
	RD.RegisterNonStorageDevice(self)
	
	-- Tell the server that it needs to check for new resources
	-- and register them with the entity.
	self.ResTable = {}
	self.NextCheckTime = CurTime() + _InternalCheckInterval
	self:ReadyResources()
	
	-- Set the Clientside info
	self.Entity:SetNetworkedString("Resource",self.ResTable[self.ResourceID] or 0)
	self.Entity:SetNetworkedString("Energy",self.Capacitor.." / "..self.EnergyToLaunch)
	self.Entity:SetNetworkedString("Packet",self.CurrentPacketSize.." / "..self.TargetPacketSize)
	self.Entity:SetNetworkedString("Status","Idle")
	if self.Multiplier == 1 then
		self.Entity:SetNetworkedString("OverDrive", "Disabled")
	else
		self.Entity:SetNetworkedString("OverDrive", math.Round(self.Multiplier*100).."%  -  Waste: ".. math.Round(self.ResourceWaste/10*100).."%")
	end

	
	-- Setup the Entity's Wire Inputs and Outputs
	if not (WireAddon == nil) then 
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, {"Load Packet","Launch","Cancel","Resource ID","Packet Size","Overdrive Multiplier"})
		self.Outputs = Wire_CreateOutputs( self.Entity, {"Packet Ready","Loading Packet","Current Size","Maximum Size","Capacitor Charge", "Energy To Launch" })	
		Wire_TriggerOutput(self.Entity, "Energy To Launch"	, self.EnergyToLaunch					)
	 end

end

function ENT:TriggerInput(inputName, value)					-- Wire Mod Inputs ---------------------------------------------------------------------
	self:ReadyResources()
	if 		((inputName == "Load Packet"	) and (math.Round(value) == 1)) then
		self.ChargingPacket = true
		self.Entity:SetNetworkedString("Status","Charging")
	elseif 	((inputName == "Launch"		) and (math.Round(value) == 1)) then
		if self.WaitingForRelease then 
			self:LaunchMassDriverPacket() 
		end
	elseif 	((inputName == "Cancel"		) and (math.Round(value) == 1)) then
		self:CancelPacket()
	elseif 	(inputName == "Resource ID"	) then
		self:CancelPacket()
		self.ResourceID = math.Round(math.Max(1,value))
		self.Entity:SetNetworkedString("Resource",self.ResTable[self.ResourceID] or 0)
	elseif 	(inputName == "Packet Size"	) then
		self:CancelPacket()
		self.TargetPacketSize = math.Max(value,100)
		self.Entity:SetNetworkedString("Packet",self.CurrentPacketSize.." / "..self.TargetPacketSize)
	elseif 	(inputName == "Overdrive Multiplier"	) then
		self.Multiplier = math.Max(1,value)
		if (self.Multiplier > 1) then
			self.ResourceWaste = ((self.Multiplier - 1)/4) * _DefaultChargeRate
		else
			self.ResourceWaste = 0
		end
		if self.Multiplier == 1 then
			self.Entity:SetNetworkedString("OverDrive", "Disabled")
		else
			self.Entity:SetNetworkedString("OverDrive", math.Round(self.Multiplier*100).."%  -  Waste: ".. math.Round(self.ResourceWaste/10*100).."%")
		end

	end
	
end

function ENT:CancelPacket()									-- Cancel (Refund) Loaded Packet -------------------------------------------------------
	self.CurrentPacketSize	= 0
	self.ChargingPacket 	= false
	self.WaitingForRelease 	= false
	self.EnergyToLaunch 	= math.Round(((self.CurrentPacketSize+1)/40)^ 2) + 50
	--RD_SupplyResource(self, self.ResTable[self.ResourceID], self.CurrentPacketSize)
	local RD = CAF.GetAddon("Resource Distribution")
	RD.SupplyResource(self, self.ResTable[self.ResourceID], self.CurrentPacketSize)
	self.Entity:SetNetworkedString("Status","Idle")
end

function ENT:ReadyResources()
	local RD = CAF.GetAddon("Resource Distribution")
	self.ResTable = RD.GetRegisteredResources();
end  

function ENT:Use()
	if self.WaitingForRelease then 
		self:LaunchMassDriverPacket() 
	end
end

function ENT:LaunchMassDriverPacket()									-- Launch the prepared packet if required energy is present ----------------------------
	
	--local _Energy = RD_GetResourceAmount(self, "energy")
	
	--if ((_Energy >= self.EnergyToLaunch ) and (self.TimeToReload < CurTime())) then
	if ((self.Capacitor >= self.EnergyToLaunch ) and (self.TimeToReload < CurTime())) then
		self.Capacitor = math.Min(0,self.Capacitor - self.EnergyToLaunch)
		--RD_ConsumeResource(self, "energy", self.EnergyToLaunch)
		local MDPacket = ents.Create( "rts_massdriverpacket" 							)
		MDPacket:SetPos				( self.Entity:GetPos() +  self.Entity:GetUp() * 40	)
		MDPacket:SetAngles			( self.Entity:GetAngles() 							)
		MDPacket:TransferResources	(self.ResourceID,self.CurrentPacketSize,self.ResTable[self.ResourceID])
		MDPacket:Spawn				()
		MDPacket:GetPhysicsObject	():EnableGravity( false ) 
		
		-- make sure the packet doesn't collide with the launcher.
		local constraint = constraint.NoCollide(self.Entity, MDPacket, 0, 0)
		
		MDPacket:Activate			()
	
		self.TimeToReload 		= CurTime() + _ReloadInterval
		self.Entity:EmitSound("NPC_Strider.Shoot", 100, 100)
		-- Reset the mass driver
		self:CancelPacket()
	end
end

function ENT:Think()										-- Entity Think Function ----------------------------------------------------------------
	self.BaseClass.Think(self)
	local RD = CAF.GetAddon("Resource Distribution")
	local _Time 		= CurTime()
	local _ResName 		= self.ResTable[self.ResourceID]
	local _ResAmount 	= RD.GetResourceAmount(self, _ResName)

	self._count = self._count + 1
	if (self._count >= 10) then
		self._count = 0
		self.Entity:SetNetworkedString("Energy",self.Capacitor.." / "..self.EnergyToLaunch)
		self.Entity:SetNetworkedString("Packet",self.CurrentPacketSize.." / "..self.TargetPacketSize)
	end
		
	-- Check for resource updates
	if (self.NextCheckTime > _Time) then
		self.NextCheckTime = CurTime() + _InternalCheckInterval
		self:ReadyResources()
	end
	
	-- The capacitor charges faster than the packet
	if (self.Capacitor < self.EnergyToLaunch) then
		local _ConsumeCapAmount 	= math.Clamp( RD.GetResourceAmount(self, "energy"), 0, math.Min(_DefaultChargeRate*5,self.EnergyToLaunch - self.Capacitor) )
		self.Capacitor 	= self.Capacitor + _ConsumeCapAmount
		RD.ConsumeResource(self, "energy", _ConsumeCapAmount)
	end
	
	-- If we are compressing a packet
	if self.ChargingPacket then 
		--self.Capacitor

		-- RESOURCE TYPE: Consume whatever we can, up to the max. DON'T consume negative resources
		local _ConsumeAmount 	= math.Clamp( _ResAmount, 0, math.Min(_DefaultChargeRate * self.Multiplier + self.ResourceWaste , self.TargetPacketSize - self.CurrentPacketSize) )
		self.CurrentPacketSize 	= self.CurrentPacketSize + _ConsumeAmount * self.Multiplier
		
		self.EnergyToLaunch 	= math.Round(((self.CurrentPacketSize+1)/40)^ 2) + 50
		
		
		RD.ConsumeResource(self, self.ResTable[self.ResourceID], _ConsumeAmount)
		
		--RD_ConsumeResource(self, _ResName, _ConsumeAmount)
		--RD_ConsumeResource(self, self.ResTable[self.ResourceID], _ConsumeAmount)
		--Error("["..self.ResTable[self.ResourceID].."] :: ".._ConsumeAmount.."\n")
	
		-- Tesla FX
		local effectdata = EffectData()
			effectdata:SetStart	(self.Entity:GetPos()+  self.Entity:GetUp() * math.Rand(10, 200) +  self.Entity:GetRight() * 50 + self.Entity:GetForward() * math.Rand(-30,30))
			effectdata:SetOrigin(self.Entity:GetPos()+  self.Entity:GetUp() * 30)
			effectdata:SetEntity(self.Entity)
			effectdata:SetAttachment( 1 )
		util.Effect( "rts_zap", effectdata ) 
			effectdata:SetStart	(self.Entity:GetPos()+  self.Entity:GetUp() * math.Rand(10, 200) +  self.Entity:GetRight() * -50 + self.Entity:GetForward() * math.Rand(-30,30))
		util.Effect( "rts_zap", effectdata ) 
	
		-- Check to see if it's ready
		if (self.CurrentPacketSize >= self.TargetPacketSize) then
			self.Entity:SetNetworkedString("Status","Ready for launch")
			self.ChargingPacket 	= false
			self.WaitingForRelease 	= true
		end
	end
	
	local RTS = CAF.GetAddon("Resource Transit System")
	-- Wiremod Outputs
	if not (WireAddon == nil) then 
		Wire_TriggerOutput(self.Entity, "Packet Ready"		, RTS._BoolToInt(self.WaitingForRelease)	)
		Wire_TriggerOutput(self.Entity, "Loading Packet"	, RTS._BoolToInt(self.ChargingPacket)		)
		Wire_TriggerOutput(self.Entity, "Current Size"		, self.CurrentPacketSize				)
		Wire_TriggerOutput(self.Entity, "Maximum Size"		, self.TargetPacketSize					)
		Wire_TriggerOutput(self.Entity, "Energy To Launch"	, self.EnergyToLaunch					)
		Wire_TriggerOutput(self.Entity, "Capacitor Charge"	, self.Capacitor						)
		
	end	
	
	self.Entity:NextThink( CurTime() + 0.1 )
end

--_BoolToInt(X)