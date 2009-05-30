
/*---------------------------------------------------------

  Sandbox Gamemode

  This is GMod's default gamemode

---------------------------------------------------------*/

include( 'shared.lua' )
include( 'cl_spawnmenu.lua' )
include( 'cl_notice.lua' )
include( 'cl_hints.lua' )
include( 'cl_worldtips.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_quicktool.lua' )
include( "cl_sun.lua" )
include( 'cl_spacebuild.lua' )


function GM:Initialize()

	self.BaseClass:Initialize()
	
end

function GM:LimitHit( name )

	Msg("You have hit the ".. name .." limit!\n")
	self:AddNotify( "#SBoxLimit_"..name, NOTIFY_ERROR, 6 )
	surface.PlaySound( "buttons/button10.wav" )

end

function GM:OnUndo( name, strCustomString )
	
	Msg( name .." undone\n" )

	if ( !strCustomString ) then
		self:AddNotify( "#Undone_"..name, NOTIFY_UNDO, 2 )
	else	
		self:AddNotify( strCustomString, NOTIFY_UNDO, 2 )
	end
	
	// Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end

function GM:OnCleanup( name )

	Msg( name .." cleaned\n" )
	self:AddNotify( "#Cleaned_"..name, NOTIFY_CLEANUP, 5 )
	
	// Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end

function GM:UnfrozeObjects( num )

	Msg( "Unfroze "..num.." Objects\n" )
	self:AddNotify( "Unfroze "..num.." Objects", NOTIFY_GENERIC, 3 )
	
	// Find a better sound :X
	surface.PlaySound( "npc/roller/mine/rmine_chirp_answer1.wav" )

end

function GM:HUDPaint()

	self:PaintWorldTips()

	// Draw all of the default stuff
	self.BaseClass:HUDPaint()
	
	self:PaintNotes()
	
end

/*---------------------------------------------------------
	Draws on top of VGUI..
---------------------------------------------------------*/
function GM:PostRenderVGUI()

	self.BaseClass:PostRenderVGUI()

end
