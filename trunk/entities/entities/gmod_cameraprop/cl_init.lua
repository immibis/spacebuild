
CreateConVar( "cl_drawcameras", "1" )

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.RenderGroup 		= RENDERGROUP_BOTH

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.ShouldDrawInfo 	= false
	self.KeyTextures 		= {}
	self.ShouldDraw 		= 1

end


/*---------------------------------------------------------
   Name: Draw
---------------------------------------------------------*/
function ENT:Draw()	

	if (self.ShouldDraw == 0) then return end

	// Don't draw the camera if we're taking pics
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if ( wep:IsValid() ) then 
		local weapon_name = wep:GetClass()
		if ( weapon_name == "gmod_camera" ) then return end
	end

	self.Entity:DrawModel()
	
end
	
/*---------------------------------------------------------
   Name: DrawTranslucent
   Desc: Draw translucent
---------------------------------------------------------*/
function ENT:DrawTranslucent()
	
	if ( !self.ShouldDrawInfo || !self.Texture ) then return end
	
	// Don't draw the camera if we're taking pics
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if ( wep:IsValid() ) then 
		local weapon_name = wep:GetClass()
		if ( weapon_name == "gmod_camera" ) then return end
	end
	
	render.SetMaterial( self.Texture )
	render.DrawSprite( self.Entity:GetPos() + Vector( 0, 0, 32), 16, 16, color_white )

end


/*---------------------------------------------------------
   Name: Think
   Desc: Client Think - called every frame
---------------------------------------------------------*/
function ENT:Think()

	self.TrackEnt = self.Entity:GetNetworkedEntity( "trackent" )	
	self:TrackEntity( self.TrackEnt, self.Entity:GetNetworkedVector( "trackvec" ) )

	self.ShouldDraw = GetConVarNumber( "cl_drawcameras" )
	if (self.ShouldDraw == 0) then return end

	// Are we the owner of this camera?
	// If we are then draw the overhead text info
	local Player = self.Entity:GetNetworkedEntity( "player" )
	if ( Player == LocalPlayer() ) then
	
		self.ShouldDrawInfo = true
		local iKey = self.Entity:GetNetworkedInt( "key", 0 )
		
		if ( self.KeyTextures[ iKey ] == nil ) then
			self.KeyTextures[ iKey ] = Material( "sprites/key_"..iKey )
		end
		
		self.Texture = self.KeyTextures[ iKey ]
		
	else
	
		self.ShouldDrawInfo = false
	
	end


	
end

function ENT:SetPlayer( pl )

	

end

include('shared.lua')