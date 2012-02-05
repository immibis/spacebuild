AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
local RD = CAF.GetAddon("Resource Distribution")
include('shared.lua')




-- Init func ;o
function ENT:Initialize()
	-- Model we will be using
	self.Entity:SetModel( "models/props_c17/furnitureboiler001a.mdl" )
	-- Physics settings
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	-- Timer crap
	self.timer = 0
	self.timera = 5
	-- Toggling Variables
	self.toggle = false -- On or off
	self.togglestring = "Off" -- string for the self.toggle
	self.togglebouncekil = 3 -- You can only self.toggle when this is zero!

	
	-- *************************************
	-- Are we a valid Physics Model?
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self.Entity, { "On" }) end
	-- For Wiremod
	self.active = 0
	-- Our entities Values
	self.val2 = 0
	self.val3 = 0
	self.val4 = 0
	
	-- Resource distribution stuff, Here we define what we are using, creating and destroying
	RD.AddResource(self.Entity, "Petrol", 0)
	RD.AddResource(self.Entity, "Oil", 0)
	RD.AddResource(self.Entity, "energy", 0)
	-- **************************************
end

function ENT:TriggerInput(iname, value)
	if(iname == "On") then

		if(value == 1) then
			self.active = 1
			self.togglestring = "On"
		else
			self.active = 0
			self.togglestring = "Off"
		end	
	end
end


function ENT:Use()
    -- This stops "Bouncing" Where it self.toggles off and on really fast
	-- Every think self.togglebouncekil is decremented till it is 0
	-- at wich point you can self.toggle
	-- Each time you self.toggle it's set back to 5, Therefore disallowing control
	-- For a period of time!
	if(self.togglebouncekil == 0) then
		if(self.toggle == false) then
			self.toggle = true
			self.togglestring = "On"
			self.togglebouncekil = 3
			return
		end
	
		if(self.toggle == true) then
			self.toggle = false
			self.togglestring = "Off"
			self.togglebouncekil = 3
			return
		end
	end
	
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "oildistil" )
	ent:SetPos(tr.HitPos + Vector(0,0,100))
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	-- This is used to stop the use-button bouncing
	-- You can only self.toggle when its 0, this brings it back to zero after a self.toggle
	if(self.togglebouncekil > 0) then
		self.togglebouncekil = self.togglebouncekil -1
	end


	-- Asign the variables
	self.val2 =	RD.GetResourceAmount(self.Entity, "Petrol")
	self.val3 = RD.GetResourceAmount(self.Entity, "Oil")
	self.val4 = RD.GetResourceAmount(self.Entity, "energy")
	-- Overlay, Showing the player some usefull stuffs ;o
	self:SetOverlayText( "Small Distiller\n(" .. self.togglestring .. ")\nOil: " .. self.val3 .. "\nEnergy: " .. self.val4)

	-- Are we ready for a think?, if not, end this function.. NOW
	self.timer = self.timer + 1
	if(self.timer < self.timera) then return end


	-- We can only Crack if we are actually turned on right? lol
	if (self.toggle == true || self.active == 1) then
		-- If we have more than 70 energy, We can heat up the coils to atmosphericly distil the oil
		if (self.val4 > 70) then
			-- But this can only be acheived if we actualy HAVE  oil :/
			if (self.val3 > 300) then
				-- So now we have the required ameneties, let's start cracking our oil eh? :)
				-- HEating the coils uses 100 energy!
				RD.ConsumeResource(self, "energy", 70)
				-- We use 300 oil to to make our products
				RD.ConsumeResource(self, "Oil", 300)
				-- WE have consumed, so now lets make our products
				-- Oil is for lubricant you know ;O
				--  waste ALOT during atmospheric distilations, fact of nature...
				RD.SupplyResource(self.Entity, "Petrol", 100)
				-- We have sucesfully cracked :D (And after looking at this code, i aint surprised...)
				-- When using wire, this helps it respond correctly
				self.togglestring = "On"
			else -- Turn off if we cant run!
				self.toggle = false
				self.togglestring = "Off"
				self.togglebouncekil = 3
			end -- Crude oil check
		else  -- Turn off if we cant run
			self.toggle = false
			self.togglestring = "Off"
			self.togglebouncekil = 3	
		end -- Energy check
	end -- self.toggle
	
	-- Reset the Think self.timer
	self.timer = 0
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

//Duplicator support (TAD2020)
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
