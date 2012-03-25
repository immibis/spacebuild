AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')



function ENT:Initialize()
	-- Set our entity properties
	self.Entity:SetModel( "models/props_c17/oildrum001.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	-- Check if wire is installed, and if so create an output for the crude oil count
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Crude Oil" }) end
	-- Check physics model is OK
	local phys = self.Entity:GetPhysicsObject()
	self.NextThink = CurTime() +  1
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	-- Add the resource and create a variable for it
	self.val1 = 0
	RD_AddResource(self.Entity, "Crude Oil", 4000)
end

function ENT:SpawnFunction( ply, tr )
	-- Have we hit a valid surface to spawn to?
	if ( !tr.Hit ) then return end

	-- Create thy devine entity
	local ent = ents.Create( "crudebarrel" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()
	-- Update the overlay so player knows what we contain within our bounderies or aranoth!
	self.val1 = RD_GetResourceAmount(self.Entity, "Crude Oil")
	self:SetOverlayText( "Crude Oil Drum\nCrude Oil: " .. self.val1 )
	
	-- Update wired stuff
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Crude Oil", self.val1) end	
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
end

--Duplicator support (TAD2020)
function ENT:PreEntityCopy()
	RD_BuildDupeInfo(self.Entity)
	if (WireAddon == 1) then
		local DupeInfo = Wire_BuildDupeInfo(self.Entity)
		if DupeInfo then
			duplicator.StoreEntityModifier( self.Entity, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	RD_ApplyDupeInfo(Ent, CreatedEntities)
	if (WireAddon == 1) then
		if (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
			Wire_ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
		end
	end
end
