
include( 'toolmenu.lua' )
include( 'contextmenu.lua' )
include( 'CreationMenu.lua' )

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	//self:SetDrawOnTop( true )
	
	self.ToolMenu = vgui.Create( "ToolMenu", self )
	
	self.CreateMenu = vgui.Create( "CreationMenu", self )
	
	self.animIn = Derma_Anim( "OpenAnim", self, self.OpenAnim )
	self.animOut = Derma_Anim( "CloseAnim", self, self.CloseAnim )
	
	self.m_bHangOpen = false

end

/*---------------------------------------------------------
   Name: HangOpen
---------------------------------------------------------*/
function PANEL:HangOpen( bHang )
	self.m_bHangOpen = bHang
end

/*---------------------------------------------------------
   Name: HangingOpen
---------------------------------------------------------*/
function PANEL:HangingOpen()
	return self.m_bHangOpen
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Open()

	RestoreCursorPosition()

	self.m_bHangOpen = false
	
	// If the context menu is open, try to close it..
	if ( g_ContextMenu:IsVisible() ) then 
		g_ContextMenu:Close( true )
	end
	
	if ( self:IsVisible() ) then return end
	
	CloseDermaMenus()
	
	self:MakePopup()
	self:SetVisible( true )
	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( true )
	
	self.animOut:Stop()
	self.animIn:Start( 0.05 )

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Close( bSkipAnim )

	if ( self.m_bHangOpen ) then 
		self.m_bHangOpen = false
		return
	end
	
	RememberCursorPosition()
	
	CloseDermaMenus()

	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( false )
	
	self.animIn:Stop()
	
	if ( bSkipAnim ) then
	
		self:SetAlpha( 255 )
		self:SetVisible( false )
	
	else
	
		self.animOut:Start( 0.1 )
		
	end

end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()

	self.animIn:Run()
	self.animOut:Run()

end




/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	local tall = ScrH() - 50
	local wide = ScrW() - 50
	
	// Limit the size of the menu?

	self:SetSize( wide, tall )
	self:SetPos( 25, 25 )
	
	self.ToolMenu:SetSize( 450, self:GetTall() )
	self.ToolMenu:InvalidateLayout( true )
	self.ToolMenu:SetPos( self:GetWide() - self.ToolMenu:GetWide(), 0 )
	
	self.CreateMenu:StretchToParent( 0, 0, 0, 0 )
	self.CreateMenu:StretchRightTo( self.ToolMenu, 5 )

end


/*---------------------------------------------------------
   Name: AnimSlide
---------------------------------------------------------*/
function PANEL:OpenAnim( anim, delta, data )
	
	if ( anim.Started ) then
		self:SetAlpha( 0 )
	end
	
	if ( anim.Finished ) then
		self:SetAlpha( 255 )
	return end
	
	self:SetAlpha( 255 * delta )

end

/*---------------------------------------------------------
   Name: AnimSlide
---------------------------------------------------------*/
function PANEL:CloseAnim( anim, delta, data )
	
	if ( anim.Started ) then
		self:SetAlpha( 255 )
	end
	
	if ( anim.Finished ) then
		self:SetAlpha( 255 )
		self:SetVisible( false )
	return end
	
	self:SetAlpha( 255 - 255 * delta )

end

/*---------------------------------------------------------
   Name: StartKeyFocus
---------------------------------------------------------*/
function PANEL:StartKeyFocus( pPanel )

	self.m_pKeyFocus = pPanel
	self:SetKeyboardInputEnabled( true )
	self:HangOpen( true )
	
	g_ContextMenu:StartKeyFocus( pPanel )
	
	
end

/*---------------------------------------------------------
   Name: EndKeyFocus
---------------------------------------------------------*/
function PANEL:EndKeyFocus( pPanel )

	if ( self.m_pKeyFocus != pPanel ) then return end
	self:SetKeyboardInputEnabled( false )
	
	g_ContextMenu:EndKeyFocus( pPanel )

end

vgui.Register( "SpawnMenu", PANEL, "EditablePanel" )


/*---------------------------------------------------------
   Called to create the spawn menu..
---------------------------------------------------------*/
local function CreateSpawnMenu()

	// If we have an old spawn menu remove it.
	if ( g_SpawnMenu ) then
	
		g_SpawnMenu:Remove()
		g_SpawnMenu = nil
	
	end
	
	// Start Fresh
	spawnmenu.ClearToolMenus()
	
	// Add defaults for the gamemode. In sandbox these defaults
	// are the Main/Postprocessing/Options tabs.
	// They're added first in sandbox so they're always first
	hook.Call( "AddGamemodeToolMenuTabs", GAMEMODE )

	// Use this hook to add your custom tools
	// This ensures that the default tabs are always
	// first.
	hook.Call( "AddToolMenuTabs", GAMEMODE )
	
	// Use this hook to add your custom tools
	// We add the gamemode tool menu categories first
	// to ensure they're always at the top.
	hook.Call( "AddGamemodeToolMenuCategories", GAMEMODE )
	hook.Call( "AddToolMenuCategories", GAMEMODE )
	
	// Add the tabs to the tool menu before trying
	// to populate them with tools.
	hook.Call( "PopulateToolMenu", GAMEMODE )

	g_SpawnMenu = vgui.Create( "SpawnMenu" )
	g_SpawnMenu:SetVisible( false )
	
	CreateContextMenu()

	hook.Call( "PostReloadToolsMenu", GAMEMODE )

end

function GM:OnSpawnMenuOpen()

	// Let the gamemode decide whether we should open or not..
	if ( !hook.Call( "SpawnMenuOpen", GAMEMODE ) ) then return end

	if (g_SpawnMenu) then g_SpawnMenu:Open() end
	
end

function GM:OnSpawnMenuClose()

	if (g_SpawnMenu) then g_SpawnMenu:Close() end 
	
end


// Development command to reload the spawnmenu (usually just use gamemode_reload)
concommand.Add( "spawnmenu_reload", function() if (g_SpawnMenu) then g_SpawnMenu:Remove(); end CreateSpawnMenu() end )

// Hook to create the spawnmenu at the appropriate time (when all sents and sweps are loaded)
hook.Add( "OnGamemodeLoaded", "CreateSpawnMenu", CreateSpawnMenu )


/*---------------------------------------------------------
   Name: HOOK SpawnMenuKeyboardFocusOn
		Called when text entry needs keyboard focus
---------------------------------------------------------*/
local function SpawnMenuKeyboardFocusOn( pnl )

	if ( !ValidPanel( g_SpawnMenu ) && !ValidPanel( g_ContextMenu ) ) then return end
	if ( !pnl:HasParent( g_SpawnMenu ) && !pnl:HasParent( g_ContextMenu ) ) then return end
	
	g_SpawnMenu:StartKeyFocus( pnl )

end

hook.Add( "OnTextEntryGetFocus", "SpawnMenuKeyboardFocusOn", SpawnMenuKeyboardFocusOn )


/*---------------------------------------------------------
   Name: HOOK SpawnMenuKeyboardFocusOff
		Called when text entry stops needing keyboard focus
---------------------------------------------------------*/
local function SpawnMenuKeyboardFocusOff( pnl )

	if ( !ValidPanel( g_SpawnMenu ) && !ValidPanel( g_ContextMenu ) ) then return end
	if ( !pnl:HasParent( g_SpawnMenu ) && !pnl:HasParent( g_ContextMenu ) ) then return end
	
	g_SpawnMenu:EndKeyFocus( pnl )

end

hook.Add( "OnTextEntryLoseFocus", "SpawnMenuKeyboardFocusOff", SpawnMenuKeyboardFocusOff )

/*---------------------------------------------------------
   Name: HOOK SpawnMenuOpenGUIMousePressed
		Don't do context screen clicking if spawnmenu is open
---------------------------------------------------------*/
local function SpawnMenuOpenGUIMousePressed()

	if ( !ValidPanel( g_SpawnMenu ) ) then return end
	if ( !g_SpawnMenu:IsVisible() ) then return end
	
	return true

end

hook.Add( "GUIMousePressed", "SpawnMenuOpenGUIMousePressed", SpawnMenuOpenGUIMousePressed )

/*---------------------------------------------------------
   Name: HOOK SpawnMenuOpenGUIMousePressed
		Close spawnmenu if it's open
---------------------------------------------------------*/
local function SpawnMenuOpenGUIMouseReleased()

	if ( !ValidPanel( g_SpawnMenu ) ) then return end
	if ( !g_SpawnMenu:IsVisible() ) then return end
	
	g_SpawnMenu:Close()
	
	return true

end

hook.Add( "GUIMouseReleased", "SpawnMenuOpenGUIMouseReleased", SpawnMenuOpenGUIMouseReleased )