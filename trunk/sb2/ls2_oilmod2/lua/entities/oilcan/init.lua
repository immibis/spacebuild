AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')


function ENT:Initialize()
	-- Entitity settings
	self.Entity:SetModel( "models/props_junk/gascan001a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	-- If wire is installed we can create an output for it ;o
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Oil" }) end
	-- Valid physics EGG
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	-- Resource Variable
	self.val1 = 0
	RD_AddResource(self.Entity, "Oil", 750)
end

function ENT:SpawnFunction( ply, tr )
	-- Have we hit something?
	if ( !tr.Hit ) then return end
	-- Create thy entity
	local ent = ents.Create( "oilcan" )
	ent:SetPos( tr.HitPos + Vector(0, 0, 100) )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	-- Set overlay, so player knows what is going on
	self.val1 = RD_GetResourceAmount(self.Entity, "Oil")
	self:SetOverlayText( "Oil Can\nOil: " .. self.val1 )
	-- If wire is installed, update the circuit with EGGS LOL HAXLKJGJG (Yes, it is 4AM, Me = insane LOLOLOLOL)
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Oil", self.val1) end
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
end

//Duplicator support (TAD2020)
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
