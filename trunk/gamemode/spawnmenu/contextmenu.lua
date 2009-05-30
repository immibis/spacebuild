
local PANEL = {}

AccessorFunc( PANEL, "m_bHangOpen", 	"HangOpen" )

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	self.animIn = Derma_Anim( "OpenAnim", self, self.OpenAnim )
	self.animOut = Derma_Anim( "CloseAnim", self, self.CloseAnim )
	
	self.Canvas = vgui.Create( "DPanelList", self )
	
	self.m_bHangOpen = false
	
	self.Canvas:EnableVerticalScrollbar( true )
	self.Canvas:SetSpacing( 0 )
	self.Canvas:SetPadding( 5 )
	self.Canvas:SetDrawBackground( false )
	
	
	
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Open()

	self:SetHangOpen( false )
	
	// If the spawn menu is open, try to close it..
	if ( g_SpawnMenu:IsVisible() ) then 	
		g_SpawnMenu:Close( true )
	end
	
	if ( self:IsVisible() ) then return end
	
	CloseDermaMenus()
	
	self:MakePopup()
	self:SetVisible( true )
	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( true )
	
	RestoreCursorPosition()
	
	// Set up the active panel..
	if ( g_ActiveControlPanel ) then
		self.OldParent = g_ActiveControlPanel:GetParent()
		self.OldPosX, self.OldPosY = g_ActiveControlPanel:GetPos()
		g_ActiveControlPanel:SetParent( self )
		self.Canvas:Clear()
		self.Canvas:AddItem( g_ActiveControlPanel )
		self.Canvas:Rebuild()
	end
	
	self.animOut:Stop()
	self.animIn:Stop()
	
	self:InvalidateLayout( true )
	
	self.animIn:Start( 0.1, { TargetX = self.x } )

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Close( bSkipAnim )

	if ( self:GetHangOpen() ) then 
		self:SetHangOpen( false )
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
		self:RestoreControlPanel()
		
	else
	
		self.animOut:Start( 0.1, { StartX = self.x } )
		
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

	if ( g_ActiveControlPanel ) then
	
		g_ActiveControlPanel:InvalidateLayout( true )
		
		local Tall = g_ActiveControlPanel:GetTall() + 10
		local MaxTall = ScrH() * 0.8
		if ( Tall > MaxTall ) then Tall = MaxTall end
		
		self:SetTall( Tall )
		self.y = ScrH() - 50 - self:GetTall()
	
	end

	self:SetWide( 260 )
	self:SetPos( ScrW() - self:GetWide() - 50, self.y )
	
	self.Canvas:StretchToParent( 0, 0, 0, 0 )
	self.Canvas:InvalidateLayout( true )
	
	self.animIn:Run()
	self.animOut:Run()

end

/*---------------------------------------------------------
   Name: StartKeyFocus
---------------------------------------------------------*/
function PANEL:StartKeyFocus( pPanel )

	self:SetKeyboardInputEnabled( true )
	self:SetHangOpen( true )
	
end

/*---------------------------------------------------------
   Name: EndKeyFocus
---------------------------------------------------------*/
function PANEL:EndKeyFocus( pPanel )

	self:SetKeyboardInputEnabled( false )

end

/*---------------------------------------------------------
   Name: EndKeyFocus
---------------------------------------------------------*/
function PANEL:RestoreControlPanel()

	// Restore the active panel
	if ( !g_ActiveControlPanel ) then return end
	if ( !self.OldParent ) then return end
	
	g_ActiveControlPanel:SetParent( self.OldParent )
	g_ActiveControlPanel:SetPos( self.OldPosX, self.OldPosY )
	
	self.OldParent = nil

end

/*---------------------------------------------------------
   Name: AnimSlide
---------------------------------------------------------*/
function PANEL:OpenAnim( anim, delta, data )
	
	if ( anim.Started ) then
		
	end
	
	if ( anim.Finished ) then
		self.x = data.TargetX
	return end
	
	local Distance = ScrW() - data.TargetX
	
	self.x = data.TargetX + Distance - Distance * ( delta ^ 0.1 )

end

/*---------------------------------------------------------
   Name: AnimSlide
---------------------------------------------------------*/
function PANEL:CloseAnim( anim, delta, data )
	
	if ( anim.Finished ) then
	
		self:SetVisible( false )
		self:RestoreControlPanel()
		
	return end
	
	local Distance = ScrW() - data.StartX
	
	self.x = data.StartX + Distance * ( delta ^ 2 )

end


vgui.Register( "ContextMenu", PANEL, "EditablePanel" )

/*---------------------------------------------------------
   CreateContextMenu
---------------------------------------------------------*/
function CreateContextMenu()

	// If we have an old spawn menu remove it.
	if ( g_ContextMenu ) then
	
		g_ContextMenu:Remove()
		g_ContextMenu = nil
	
	end

	g_ContextMenu = vgui.Create( "ContextMenu" )
	g_ContextMenu:SetVisible( false )

end


/*---------------------------------------------------------
   GAMEMODE:OnContextMenuOpen
---------------------------------------------------------*/
function GM:OnContextMenuOpen()

	// Let the gamemode decide whether we should open or not..
	if ( !hook.Call( "SpawnMenuOpen", GAMEMODE ) ) then return end
	if (g_ContextMenu) then g_ContextMenu:Open() end
	
end

/*---------------------------------------------------------
   GAMEMODE:OnContextMenuClose
---------------------------------------------------------*/
function GM:OnContextMenuClose()

	if (g_ContextMenu) then g_ContextMenu:Close() end 
	
end
