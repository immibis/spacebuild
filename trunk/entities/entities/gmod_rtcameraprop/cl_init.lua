
local cl_drawcameras = CreateConVar( "cl_drawcameras", "1" )

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

local I_KEY 			= 0

local E_PLAYER 			= 0
local E_TRACK			= 1

local V_TRACK			= 0

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
	
	if ( !self.ShouldDrawInfo || !self.Texture ) then return end
	
	
	render.SetMaterial( self.Texture )
	render.DrawSprite( self.Entity:GetPos() + Vector( 0, 0, 32), 16, 16, color_white )
	

end


/*---------------------------------------------------------
   Name: Think
   Desc: Client Think - called every frame
---------------------------------------------------------*/
function ENT:Think()

	self.TrackEnt = self.Entity:GetNetworkedEntity( E_TRACK )
	self:TrackEntity( self.TrackEnt, self.Entity:GetNetworkedVector( V_TRACK ) )

	self.ShouldDraw = cl_drawcameras:GetBool()
	if (self.ShouldDraw == 0) then return end

	// Are we the owner of this camera?
	// If we are then draw the overhead text info
	local Player = self.Entity:GetNetworkedEntity( E_PLAYER )
	if ( Player == LocalPlayer() ) then
	
		self.ShouldDrawInfo = true
		local iKey = self.Entity:GetNetworkedInt( I_KEY )
		
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