AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

function ENT:Initialize()
	-- Create the physical of this entity
	self.Entity:SetModel( "models/props_wasteland/kitchen_fridge001a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetColor( 120, 96, 96, 255 )
	
	-- Wake the ohysics model if it is valid
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	RD_AddResource(self.Entity, "12V Energy", 100)
	RD_AddResource(self.Entity, "energy", 1000)
	RD_AddResource(self.Entity, "Petrol", 800)
	RD_AddResource(self.Entity, "Crude Oil", 1000)
	RD_AddResource(self.Entity, "Oil", 800)
	RD_AddResource(self.Entity, "hydrogen", 600)
	RD_AddResource(self.Entity, "coolant", 600)
	RD_AddResource(self.Entity, "air", 600)
	RD_AddResource(self.Entity, "TiberiumChemicals", 1000)
	RD_AddResource(self.Entity, "RawTiberium", 1000)
	RD_AddResource(self.Entity, "ProcessedTiberium", 1000)
	RD_AddResource(self.Entity, "Munitions", 750)
end

function ENT:SpawnFunction( ply, tr )
	-- Check the trace is OK
	if ( !tr.Hit ) then return end

	-- Create our entity
	local ent = ents.Create( "thecache" )
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	-- Set the overlay text
	self:SetOverlayText( "Everything cache:\n Holds Tiberium, Munitions, Hydrogen\nstandard life supporting and petrol")
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
