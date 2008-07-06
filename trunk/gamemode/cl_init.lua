/*------------------------------------------------
	SPACEBUILD 3 GAMEMODE
	
		Based on Spacebuild 2
		Made by the Spacebuild Dev Team

------------------------------------------------*/


include("shared.lua")

local planets = {} //Clients hasn't been updated yet
local pScoreBoard = nil
// enabled?
local Color_Enabled = false;
local Bloom_Enabled = false;
local timer = CurTime() + 0.2
// Color Variables.
local ColorModify = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 0,
	[ "$pp_colour_colour" ] = 0,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0,
};

// Bloom Variables
local Bloom = {
	darken = 0,
	multiply = 0,
	sizex = 0,
	sizey = 0,
	passes = 0,
	color = 0,
	col = {
		r = 0,
		g = 0,
		b = 0,
	},
};
// Color receive message
local function SetColor(planet)
	// don't support colormod?
	if( !render.SupportsPixelShaders_2_0() ) then return; end
	// enabled?
	Color_Enabled = planet.color
	if( !Color_Enabled ) then return; end
	// read attributes
	ColorModify[ "$pp_colour_addr" ] 	= planet.AddColor_r
	ColorModify[ "$pp_colour_addg" ] 	= planet.AddColor_g
	ColorModify[ "$pp_colour_addb" ] 	= planet.AddColor_b
	ColorModify[ "$pp_colour_brightness" ] 	= planet.Brightness
	ColorModify[ "$pp_colour_contrast" ] 	= planet.Contrast
	ColorModify[ "$pp_colour_colour" ] 	= planet.CColor
	ColorModify[ "$pp_colour_mulr" ] 	= planet.AddColor_r
	ColorModify[ "$pp_colour_mulg" ] 	= planet.AddColor_g
	ColorModify[ "$pp_colour_mulb" ] 	= planet.AddColor_b
end

// Bloom receive message
local function SetBloom(planet)
	// don't support bloom?
	if( !render.SupportsPixelShaders_2_0() ) then return; end
	// enabled?
	Bloom_Enabled = planet.bloom
	if( !Bloom_Enabled ) then return; end
	// read attributes
	Bloom.darken 	= planet.Darken
	Bloom.multiply 	= planet.Multiply
	Bloom.sizex 	= planet.SizeX
	Bloom.sizey 	= planet.SizeY
	Bloom.passes 	= planet.Passes
	Bloom.color 	= planet.BColor
	Bloom.col.r 	= planet.Col_r
	Bloom.col.g 	= planet.Col_g
	Bloom.col.b 	= planet.Col_b
end

// render.
local function Render( )
	if( Color_Enabled ) then
		// draw colormod.
		DrawColorModify( ColorModify );
	end
	if( Bloom_Enabled ) then
		// draw bloom.
		//DrawBloom( darken, multiply, sizex, sizey, passes, color, colr, colg, colb )
		DrawBloom(
			Bloom.darken, 
			Bloom.multiply, 
			Bloom.sizex, 
			Bloom.sizey, 
			Bloom.passes, 
			Bloom.color, 
			Bloom.col.r, 
			Bloom.col.g, 
			Bloom.col.b 
		);
	end
end
hook.Add( "RenderScreenspaceEffects", "VFX_Render", Render );

local function recPlanet( msg )
	Msg("Adding Planet\n")
	local ent = msg:ReadShort()
	local hash  = {}
	hash.Position = msg:ReadAngle()
	hash.radius = msg:ReadFloat()
	if msg:ReadBool() then
		hash.color = true
		hash.AddColor_r = msg:ReadShort()
		hash.AddColor_g = msg:ReadShort()
		hash.AddColor_b = msg:ReadShort()
		hash.MulColor_r = msg:ReadShort()		
		hash.MulColor_g = msg:ReadShort()
		hash.MulColor_b = msg:ReadShort()
		hash.Brightness = msg:ReadFloat()
		hash.Contrast = msg:ReadFloat()
		hash.CColor = msg:ReadFloat()
	else
		hash.color = false
	end
	if msg:ReadBool() then
		hash.bloom = true
		hash.Col_r = msg:ReadShort()
		hash.Col_g = msg:ReadShort()
		hash.Col_b = msg:ReadShort()
		hash.SizeX = msg:ReadFloat()
		hash.SizeY = msg:ReadFloat()
		hash.Passes = msg:ReadFloat()
		hash.Darken = msg:ReadFloat()
		hash.Multiply = msg:ReadFloat()
		hash.BColor = msg:ReadFloat()
	else
		hash.bloom = false
	end
	planets[ent] = hash
end
usermessage.Hook( "AddPlanet", recPlanet );

function GM:Space_Affect_Cl ()
	local ply = LocalPlayer()
	if not (ply and ply:IsValid() and ply:Alive()) then return end
	local ppos = ply:GetPos()
	for ent, p in pairs( planets ) do
		if ppos:Distance(p.Position) < p.radius then
			if not ply.planet or ply.planet != ent then
				SetBloom(p)
				SetColor(p)
				ply.planet = ent
		  	end
			return
		end
	end
	if (ply.planet != nil) then
		Color_Enabled = false
		Bloom_Enabled = false
		ply.planet = nil
	end
end

function GM:Think()
	if (GetGlobalInt("InSpace") == 0) then return end
	if timer > CurTime() then return end
	self:Space_Affect_Cl()
	timer = CurTime() + 0.5
end

/*---------------------------------------------------------
   Name: gamemode:CreateScoreboard( )
   Desc: Creates/Recreates the scoreboard
---------------------------------------------------------*/
function GM:CreateScoreboard()

	if ( pScoreBoard ) then
	
		pScoreBoard:Remove()
		pScoreBoard = nil
	
	end

	pScoreBoard = vgui.Create( "SB_ScoreBoard" )

end

/*---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
---------------------------------------------------------*/
function GM:ScoreboardShow()

	GAMEMODE.ShowScoreboard = true
	gui.EnableScreenClicker( true )
	
	if ( !pScoreBoard ) then
		self:CreateScoreboard()
	end
	
	pScoreBoard:SetVisible( true )
	pScoreBoard:UpdateScoreboard( true )
	
end

/*---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
---------------------------------------------------------*/
function GM:ScoreboardHide()

	

	GAMEMODE.ShowScoreboard = false
	gui.EnableScreenClicker( false )
	
	if ( pScoreBoard ) then pScoreBoard:SetVisible( false ) end
	
end

function GM:HUDDrawScoreBoard()

	// Do nothing (We're vgui'd up)
	
end
