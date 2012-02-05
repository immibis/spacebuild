include('shared.lua')

local ToolTip = ENT.PrintName
local EntIndex = false

function ENT:Draw()
	self.Entity:DrawModel()
	if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance(self.Entity:GetPos()) < 512) then
		local ToolTip = tostring(self:GetNetworkedString("ToolTip1"))..tostring(self:GetNetworkedString("ToolTip2"))..tostring(self:GetNetworkedString("ToolTip3"))	
		AddWorldTip(EntIndex, ToolTip, 0.5, self.Entity:GetPos(), self.Entity)
	end
end
