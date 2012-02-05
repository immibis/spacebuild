AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
local RD = CAF.GetAddon("Resource Distribution")

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
	RD.AddResource(self.Entity, "12V Energy", 100)
	RD.AddResource(self.Entity, "energy", 1000)
	RD.AddResource(self.Entity, "Petrol", 800)
	RD.AddResource(self.Entity, "Crude Oil", 1000)
	RD.AddResource(self.Entity, "Oil", 800)
	RD.AddResource(self.Entity, "hydrogen", 600)
	RD.AddResource(self.Entity, "liquid nitrogen", 600)
	RD.AddResource(self.Entity, "oxygen", 600)
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
self.BaseClass.Think(self)
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
