include('shared.lua')

--[[ All Functions:
	Global Functions:
		self.BaseClass.Draw(self)
		self.BaseClass.CheckBeam(self)
		self.BaseClass.MakeBeam(self, End, Color)
		self.BaseClass.GetToolTip(self)
]]

--[[
	GLOBAL FUNCTIONS START
]]

-- self.BaseClass.Draw(self)
function ENT:Draw()
	self.Entity:DrawModel()
	self.BaseClass.CheckBeam(self)
	if(LocalPlayer():GetEyeTrace().Entity == self.Entity and EyePos():Distance(self.Entity:GetPos()) < 512) then
		AddWorldTip(self.Entity:EntIndex(), self:GetToolTip(), 0.5, self.Entity:GetPos(), self.Entity)
	end
end

-- self.BaseClass.CheckBeam(self)
function ENT:CheckBeam()
	if(self.Entity:GetNetworkedBool("DrawBeam") == true) then
		local Trace = self.BaseClass.Trace(self, self.Entity:GetUp())
		self.BaseClass.MakeBeam(self, Trace, Color(255, 255, 255, 255))
	end
end

-- self.BaseClass.MakeBeam(self, End, Color)
function ENT:MakeBeam(End, Color)
	render.SetMaterial(Material("sprites/bluelaser1"))
	render.DrawBeam(self.Entity:GetPos(), End, 5, 0, 0, Color)	
end

-- self.BaseClass.GetToolTip(self)
function ENT:GetToolTip()
	local txt = self.PrintName
	
	if(self.OnOff) then
		txt = txt..": "..tostring(self.Entity:GetNetworkedString("OnOff"))
	end
	
	if not (self.RD2Resources == nil) then
		if (self.RD2Resources == -1) then --print all resouces on the ent
			txt = txt.."\n"..self.Entity:GetAllResourcesAmountsText()
			RD2Resources = 0
		elseif (self.RD2Resources > 0) and not (self.TableString == nil) then --only print the resource names given
			for i=1, self.RD2Resources  do
				txt = txt.."\n"..self.Entity:GetResourceAmountTextPrint(self.TableString[i])
			end
		end
	end
	
	return txt .. (self.ToolTip or "")
end

--[[
	GLOBAL FUNCTIONS END
]]
