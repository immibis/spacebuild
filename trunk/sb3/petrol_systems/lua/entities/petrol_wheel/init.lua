AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
local RD = CAF.GetAddon("Resource Distribution")
include('shared.lua')

 CreateConVar( "sv_petrolwheelmult", "1000" ) 

ENT.WireDebugName = "Wheel"
ENT.OverlayDelay = 0

--[[---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------]]
function ENT:Initialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
	
	self:SetToggle( false )
	
	self.ToggleState = false
	self.BaseTorque = 0
	self.TorqueScale = 1
	self.Breaking = 0
	self.SpeedMod = 0
	self.Go = 0
	
	
	RD.AddResource(self.Entity, "Petrol", 0)
	RD.AddResource(self.Entity, "12V Energy", 0)
	if not (WireAddon == nil) then 
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Consume rate" })
		self.Inputs = Wire_CreateInputs(self.Entity, { "A: Go", "B: Break", "C: SpeedMod" })
	end
	
	self.petrolpertick = 12
	
	self.Entity:NextThink( CurTime() ) 
	
end

--[[---------------------------------------------------------
   Sets the base torque
---------------------------------------------------------]]
function ENT:SetBaseTorque( base )

	self.BaseTorque = base
	
	txt = "Torque: " .. math.floor( self.TorqueScale * self.BaseTorque )
	--self.BaseClass.BaseClass.SetOverlayText(self, txt)
	self:SetOverlayText(txt)
end

--[[---------------------------------------------------------
   Sets the axis (world space)
---------------------------------------------------------]]
function ENT:SetAxis( vec )

	self.Axis = self.Entity:GetPos() + vec * 512
	self.Axis = self.Entity:NearestPoint( self.Axis )
	self.Axis = self.Entity:WorldToLocal( self.Axis )

end


--[[---------------------------------------------------------
   Name: PhysicsCollide
   Desc: Called when physics collides. The table contains 
			data on the collision
---------------------------------------------------------]]
function ENT:PhysicsCollide( data, physobj )
end


--[[---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: Called to update the physics .. or something.
---------------------------------------------------------]]
function ENT:PhysicsUpdate( physobj )
end


--[[---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us (usually from the map)
---------------------------------------------------------]]
function ENT:KeyValue( key, value )
end


--[[---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------]]
function ENT:OnTakeDamage( dmginfo )

	self.Entity:TakePhysicsDamage( dmginfo )

end


function ENT:SetMotor( Motor )
	self.Motor = Motor
end

function ENT:GetMotor()
	
	if (not self.Motor) then
		self.Motor = constraint.FindConstraintEntity( self.Entity, "Motor" )
	end
	
	return self.Motor
end


function ENT:SetDirection( dir )
	self.Entity:SetNetworkedInt( 1, dir )
	self.Direction = dir
end

function ENT:SetToggle( bool )
	self.Toggle = bool
end

function ENT:GetToggle()
	return self.Toggle
end


function ENT:SetFwd( fwd )
	self.Fwd = fwd
end

function ENT:SetBck( bck )
	self.Bck = bck
end

function ENT:SetStop( stop )
	self.Stop = stop
end


--[[---------------------------------------------------------
   Forward
---------------------------------------------------------]]
function ENT:Forward( mul )

	-- Is this key invalid now? If so return false to remove it
	if ( not self.Entity:IsValid() ) then return false end
	local Motor = self:GetMotor()
	if ( not Motor:IsValid() ) then
		--Msg("Wheel doesn't have a motor!\n");
		return false
	end

	mul = mul or 1
	local mdir = Motor:GetTable().direction
	local Speed = mdir * mul * self.TorqueScale * (1 + self.SpeedMod)
	
	txt = "Torque: " .. math.floor( self.TorqueScale * self.BaseTorque ) .. "\nSpeed: " .. (mdir * mul * (self.SpeedMod)) .. "\nBreak: " .. self.Breaking .. "\nSpeedMod: " .. math.floor( self.SpeedMod * 100 ) .. "%"
	--self.BaseClass.BaseClass.SetOverlayText(self, txt)
	self:SetOverlayText(txt)
	
	Motor:Fire( "Scale", Speed, 0 )
	Motor:GetTable().forcescale = Speed
	Motor:Fire( "Activate", "" , 0 )
	
	return true
	
end

--[[---------------------------------------------------------
   Reverse
---------------------------------------------------------]]
function ENT:Reverse( )
	return self:Forward( -1 )
end


--[[---------------------------------------------------------
   Name: TriggerInput
   Desc: the inputs
---------------------------------------------------------]]
function ENT:TriggerInput(iname, value)
	if (iname == "A: Go") then
		if ( value == self.Fwd ) then self.Go = 1
		elseif ( value == self.Bck ) then self.Go = -1
		elseif ( math.abs(value) == self.Stop ) then self.Go =0 end
	elseif (iname == "B: Break") then
		self.Breaking = value
	elseif (iname == "C: SpeedMod") then
		self.SpeedMod = (value / 100)
	end
	if not self:CanRun() then self.Go = 0 end
	return self:Forward( self.Go )
end



--[[---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: happy fun time breaking function
---------------------------------------------------------]]
function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()
	
	if (self.Breaking > 0) then -- to prevent badness
		if (self.Breaking >= 100) then --100% breaking!!!
			vel.x = 0 --full stop!
			vel.y = 0
		else		
			vel.x = vel.x * ((100.0 - self.Breaking)/100.0)
			vel.y = vel.y * ((100.0 - self.Breaking)/100.0)
		end
	end
	
	physobj:SetVelocity(vel)
end



--[[---------------------------------------------------------
   Todo? Scale Motor:GetTable().direction?
---------------------------------------------------------]]
function ENT:SetTorque( torque )
	
	self.TorqueScale = torque / self.BaseTorque
	
	local Motor = self:GetMotor()
	if (not Motor or not Motor:IsValid()) then return end
	Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * self.TorqueScale , 0 )
	
	txt = "Torque: " .. math.floor( self.TorqueScale * self.BaseTorque )
	--self.BaseClass.BaseClass.SetOverlayText(self, txt)
	self:SetOverlayText(txt)
end

--[[---------------------------------------------------------
   Creates the direction arrows on the wheel
---------------------------------------------------------]]
function ENT:DoDirectionEffect()

	local Motor = self:GetMotor()
	if (not Motor or not Motor:IsValid()) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Axis )
		effectdata:SetEntity( self.Entity )
		effectdata:SetScale( Motor.direction )
	util.Effect( "wheel_indicator", effectdata, true, true )	
	
end

--[[---------------------------------------------------------
   Reverse the wheel direction when a player uses the wheel
---------------------------------------------------------]]
function ENT:Use( activator, caller, type, value )
		
	local Motor = self:GetMotor()
	local Owner = self:GetPlayer()
	
	if (Motor and (Owner == nil or Owner == activator)) then

		if (Motor:GetTable().direction == 1) then
			Motor:GetTable().direction = -1
		else
			Motor:GetTable().direction = 1
		end

		Motor:Fire( "Scale", Motor:GetTable().direction * Motor:GetTable().forcescale * self.TorqueScale, 0 )
		self:SetDirection( Motor:GetTable().direction )
	
		self:DoDirectionEffect()
		
	end
	
end


function ENT:Think()
 
	--Msg("Petrol Wheel Thinking...\n")
	-- TEMPRARILY DISABLED AS WAS CAUSING NILLING
	
	--local Torquething = math.ceil( self.TorqueScale * self.BaseTorque *(self.SpeedMod) )
	--self.petrolpertick = math.ceil(Torquething/GetConVarNumber( "sv_petrolwheelmult" ))
	--Msg("Requiring " .. self.petrolpertick .. " petrol per tick\n")
	--Msg(torquething)

	if self.Go ~= 0 or self:CanRun() then
		RD.ConsumeResource(self.Entity, "Petrol", self.petrolpertick)
		RD.SupplyResource(self.Entity, "12V Energy", 1)
		--Msg("a'ight\n")
	else
		self.Go = 0
		self:Forward( self.Go )
		--Msg("not enough stuff or standing still\n")
	end
	
	if not self:CanRun() then
		self.Go = 0
		self:Forward( self.Go )
		--Msg("not enough stuff or standing still\n")
	end
	
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self.Entity, "Consume rate", self.petrolpertick)
	end
	
	self.Entity:NextThink( CurTime() + 1 ) 
end

 function ENT:CanRun()
 
	local petrol = RD.GetResourceAmount(self.Entity, "Petrol")	
	return (petrol >= self.petrolpertick)
	
 end

  --[[---------------------------------------------------------
    Name: OnRemove 
 ---------------------------------------------------------]]
 function ENT:OnRemove() 
   
   self.BaseClass.OnRemove(self)
   
 end 
 
--Duplicator support (TAD2020)
function ENT:PreEntityCopy()
	RD.BuildDupeInfo(self.Entity)
	if (WireAddon == 1) then
		local DupeInfo = Wire_BuildDupeInfo(self.Entity)
		if DupeInfo then
			duplicator.StoreEntityModifier( self.Entity, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	RD.ApplyDupeInfo(Ent, CreatedEntities)
	if (WireAddon == 1) then
		if (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
			Wire_ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
		end
	end
end

 
