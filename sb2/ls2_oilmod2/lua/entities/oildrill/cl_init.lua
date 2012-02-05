include('shared.lua')

function ENT:DrawTranslucent()
	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 512 ) then
		AddWorldTip( self.Entity:EntIndex(), self:GetOverlayText(), 0.5, self.Entity:GetPos(), self.Entity  )
	end
end
