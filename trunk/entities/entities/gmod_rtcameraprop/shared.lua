

ENT.Type = "anim"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:TrackEntity( ent, lpos )

	if ( !ent || !ent:IsValid() ) then return end

	local WPos = self.TrackEnt:LocalToWorld( lpos )
	
	if ( ent:IsPlayer() ) then
		WPos = WPos + Vector( 0, 0, 54 )
	end
	
	local CamPos = self.Entity:GetPos()
	local Ang = WPos - CamPos
	
	Ang = Ang:Angle()
	self.Entity:SetAngles(Ang)

end

function ENT:CanTool( ply, trace, mode )

	if (self.Entity:GetMoveType() == MOVETYPE_NONE) then return false end
	
	return true

end
