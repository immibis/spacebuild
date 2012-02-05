include('shared.lua')

function ENT:Initialize()
	local P1 = self.Entity:GetNetworkedEntity( "Pod1" )
	local P2 = self.Entity:GetNetworkedEntity( "Pod2" )
	if P1 && P1:IsValid() && P2 && P2:IsValid() then
		for i = 1, 7 do
			if P2:GetNetworkedEntity( "HPW"..i ) != P1:GetNetworkedEntity( "HPW"..i ) then
				P2:SetNetworkedEntity( "HPW"..i, P1:GetNetworkedEntity( "HPW"..i ))
			end
		end
	end
end

function ENT:Draw()
	
	self.Entity:DrawModel()

end
