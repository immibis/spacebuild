

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Hover Ball"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false


function ENT:GetTargetZ()

	// The !self.TargetZ is so old save games will work :)
	if ( CLIENT || !self.TargetZ ) then
	
		// This just smooths it out
		self.TargetZ = self.TargetZ or self.Entity:GetPos().z
		self.TargetZ = self.TargetZ * 9 + self.Entity:GetNetworkedInt( "TargetZ", self.Entity:GetPos().z )
		self.TargetZ = self.TargetZ * 0.1
		
		return self.TargetZ
	end

	return self.TargetZ
end

function ENT:SetTargetZ( z )

	self.TargetZ = z
	
end




function ENT:GetSpeed()

	// Sensible limits
	if (!SinglePlayer()) then
		return math.Clamp( self.Entity:GetNetworkedFloat( 0 ), 0, 10 )
	end

	return self.Entity:GetNetworkedFloat( 0 )
end

function ENT:SetSpeed( s )
	
	self.Entity:SetNetworkedFloat( 0, s )
	self:UpdateLabel()
	
end

function ENT:UpdateLabel()

	self:SetOverlayText( string.format( "Speed: %i\nResistance: %.2f", self:GetSpeed(), self:GetAirResistance() ) )

end
