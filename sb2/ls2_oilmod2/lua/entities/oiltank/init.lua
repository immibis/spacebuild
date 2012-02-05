AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')


function ENT:Initialize()
	self.Entity:SetModel( "models/props_wasteland/horizontalcoolingtank04.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetColor( 0, 204, 0, 255 )
	-- If wiremod is installed, create an output partaining to requirments!
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Oil" }) end
	-- Are we valid?
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(2000)
	end
	-- Resource variable
	self.val1 = 0
	RD_AddResource(self.Entity, "Oil", 50000)
end

function ENT:SpawnFunction( ply, tr )
	-- Hit summat??!?!?!?!?!?!?!?
	if ( !tr.Hit ) then return end
	-- Create thy entity
	local ent = ents.Create( "oiltank" )
	ent:SetPos( tr.HitPos + Vector(0, 0, 100))
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()
	-- Update overlay, so player know what the shit is happening >.>
	self.val1 = RD_GetResourceAmount(self.Entity, "Oil")
	self:SetOverlayText( "Oil Tank\nOil: " .. self.val1 )
	-- If wire is installed, Use it...
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
