AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')


function ENT:Initialize()
	-- Set entity settings
	self.Entity:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	-- If wire is installed, create an output
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Petrol" }) end
	
	-- Check our physics model plox
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	-- Resource Variable
	self.val1 = 0
	RD_AddResource(self.Entity, "Petrol", 4000)
end

ENT.aHealth = 50
function ENT:OnTakeDamage(dmg)  	
if(self.val1 > 1000) then
self.aHealth = self.aHealth - dmg:GetDamage()  	
end


	if self.aHealth <= 0 && self.val1 > 1000  then 
		
	
		local Effect = EffectData()
		Effect:SetOrigin(self.Entity:GetPos())
		Effect:SetScale(self.val1 / 1000)
		Effect:SetMagnitude(self.val1 / 100)
		util.Effect("Explosion", Effect, true, true)

		
		-- Destroy our intity.. mwahahaha
		self.Entity:Remove()  	
	end  
end 

function ENT:SpawnFunction( ply, tr )
	-- Have we got a valid spot to spawn?
	if ( !tr.Hit ) then return end

	-- Create thy entity
	local ent = ents.Create( "petrolbarrel" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()
	-- Update the overlay, allowing player to see what the hell is going on!
	self.val1 = RD_GetResourceAmount(self.Entity, "Petrol")
	self:SetOverlayText( "Petrol Drum\nPetrol: " .. self.val1 )
	-- If wire is installed, update it's ouput!
	if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Petrol", self.val1) end
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
