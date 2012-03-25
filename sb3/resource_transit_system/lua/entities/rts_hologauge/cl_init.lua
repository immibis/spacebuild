 include('shared.lua')     

-- function ENT:Draw()      
-- self.BaseClass.Draw(self)  
-- We want to override rendering, so don't call baseclass.                                   
-- Use this when you need to add to the rendering.        
--self.Entity:DrawModel()       -- Draw the model.
-- end  
 
surface.CreateFont( "arial", 60, 600, true, false, "PackageText" )
-- 	self.Entity:SetNetworkedString("Resource", self.ResourceType)
-- 	self.Entity:SetNetworkedInt("ResAmount", RD_GetResourceAmount(self.Entity, self.ResourceType))
-- 	self.Entity:SetNetworkedInt("ResMaxAmount", RD_GetNetworkCapacity(self.Entity, self.ResourceType))

function ENT:Draw()
	self.Entity:DrawModel()
		
	self.LastValue = 0
	local n=0
	local ang=self.Entity:GetAngles()
	local rot = Vector(-90,90,0)
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * -1) + (self.Entity:GetUp() * 12) + (self.Entity:GetRight() * -0.5)
	cam.Start3D2D(pos,ang,0.05)
	
-- Resource bar
		-- Semitransparent graph background
		surface.SetDrawColor(0,0,0,125)
		surface.DrawRect( 30, 185, 600, 70 )
		
		local lTemp =0
		if (self.Entity:GetNetworkedInt("ResMaxAmount")) > 0 then
			lTemp = self.Entity:GetNetworkedInt("ResAmount") / self.Entity:GetNetworkedInt("ResMaxAmount")
			-- Main bargraph
			surface.SetDrawColor((1-lTemp) * 255,lTemp * 255,0,255)
			surface.DrawRect( 30, 185, lTemp * 600, 70 )

			--Internal gauge text
			surface.SetFont("PackageText")
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(30,190)
			surface.DrawText(self.Entity:GetNetworkedInt("ResAmount").."/"..self.Entity:GetNetworkedInt("ResMaxAmount"))

			-- Outline
			surface.SetDrawColor(0,0,0,255)
			surface.DrawOutlinedRect( 30, 185, 600, 70 )
			

		else
			surface.SetFont("PackageText")
			surface.SetTextColor(255,255,255,255)
			surface.SetTextPos(30,190)
			surface.DrawText("No Resource")
		end


		surface.SetFont("PackageText")
		surface.SetTextColor(255,255,255,255)
		surface.SetTextPos(0,120)
		surface.DrawText(string.upper(self.Entity:GetNetworkedString("Resource")))

		
			--Stop rendering
	cam.End3D2D()

end