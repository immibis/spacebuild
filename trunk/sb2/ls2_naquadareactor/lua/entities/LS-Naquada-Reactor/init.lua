AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Energy_Increment = 100
local sequence_close = nil
local sequence_open = nil

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	sequence_open = self.Entity:LookupSequence("close")
	sequence_close = self.Entity:LookupSequence("open")
	
	LS_RegisterEnt(self.Entity)

	RD_AddResource(self.Entity, "energy", 0)
	
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self.Entity, { "On" }) end
	if not (WireAddon == nil) then self.Outputs = Wire_CreateOutputs(self.Entity, { "Out" }) end

end

function ENT:SpawnFunction( ply, trace )
	if ( !trace.Hit ) then return end
	local ent = ents.Create( "LS-Naquada-Reactor" )
	ent:SetModel( "models/Naquada-Reactor.mdl" )
	ent:SetPos( trace.HitPos )
	ent:Spawn()
	ent:Activate()
	ent.Active = 1
	return ent
end

function ENT:Setup()
	self:TriggerInput("On", 0)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if (value ~= 0) then
			if ( self.Active == 0 ) then
				self.Entity:SetSequence(sequence_open)
				self.Entity:SetMaterial( "models/Reactor-Skin" )
				self.Active = 1
				Wire_TriggerOutput(self.Entity, "Out", self.Active)
			end
		else
			if ( self.Active == 1 ) then
				local sequence = self.Entity:LookupSequence("open")
				self.Entity:SetSequence(sequence_close)
				self.Entity:SetMaterial( "models/Reactor-Skin-off" )
				self.Active = 0
				Wire_TriggerOutput(self.Entity, "Out", self.Active)
			end
		end
	end
end

function ENT:OnRemove()
	Dev_Unlink_All(self.Entity)
end

function ENT:Output()
	return 1
end


function ENT:Think()
	if ( self.Active == 0 ) then
		if (self.Entity:GetSequence() == sequence_open) then
			self.Entity:SetSequence(sequence_close)
			self.Entity:SetMaterial( "models/Reactor-Skin-off" )
		end
		self:SetOverlayText( "Naquada Reactor\n(OFF)" )
	else
		if (self.Entity:GetSequence() == sequence_close) then
			self.Entity:SetSequence(sequence_open)
			self.Entity:SetMaterial( "models/Reactor-Skin" )
		end
		self:SetOverlayText( "Naquada Reactor\n(ON)" )
	end
	if ( self.Active == 1 ) then
		RD_SupplyResource(self.Entity, "energy", Energy_Increment)
	end
	self:NextThink( CurTime() + 1 )
	return true
end


function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if ( self.Active == 0 ) then
			local sequence = self.Entity:LookupSequence("close")
			self.Entity:SetSequence(sequence)
			self.Entity:SetMaterial( "models/Reactor-Skin" )
			self.Active = 1
		else
			local sequence = self.Entity:LookupSequence("open")
			self.Entity:SetSequence(sequence)
			self.Entity:SetMaterial( "models/Reactor-Skin-off" )
			self.Active = 0
		end
	end
end


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