
//
// For the client to choose the weapon
//
CreateClientConVar( "gmod_npc_weapon", "", true /*Should Save*/, true /*Accessible by server*/ )

local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	
	self:SetSize( 83, 83 )
	
	self.Label = vgui.Create ( "DLabel", self )
	
	self:SetKeepAspect( true )
	self:SetDrawBorder( true )
	
	self.m_Image:SetPaintedManually( true )
	
end

/*---------------------------------------------------------
   Name: SetNPC
---------------------------------------------------------*/
function PANEL:PerformLayout()
	
	self.Label:SizeToContents()
	
	self.Label:SetFont( "DefaultSmallDropShadow" )
	self.Label:SetTextColor( color_white )
	self.Label:SetContentAlignment( 5 )
	self.Label:SetWide( self:GetWide() )
	self.Label:AlignBottom( 2 )
	
	DImageButton.PerformLayout( self )
	
end


/*---------------------------------------------------------
   Name: PaintOver
---------------------------------------------------------*/
function PANEL:Paint()
	
	local w, h = self:GetSize()
	
	self.m_Image:Paint()
	
	surface.SetDrawColor( 30, 30, 30, 200 )
	surface.DrawRect( 0, h - 16, w, 16 )
	
	DImageButton.Paint( self )
	
	
end


/*---------------------------------------------------------
   Name: SetNPC
---------------------------------------------------------*/
function PANEL:SetNPC( NiceName, SpawnName )
	
	self.Label:SetText( NiceName )
	self.DoClick = function() RunConsoleCommand( "gmod_spawnnpc", SpawnName ) end
	
	self:SetOnViewMaterial( "VGUI/entities/"..SpawnName )
	
	self:InvalidateLayout()
	
end

local NPCIcon = vgui.RegisterTable( PANEL, "DImageButton" )






local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Options = vgui.Create( "DPanel", self )
	
	self.WeaponSelect = vgui.Create( "DMultiChoice", self.Options )
	self.WeaponSelect:SetWide( 130 )
	self.WeaponSelect:SetEditable( false )
	self.WeaponSelect.OnSelect = function( obj, index, value, data ) RunConsoleCommand( "gmod_npc_weapon", data ) end
	self.WeaponSelectlbl = Label( "NPC Weapon:", self.Options )
	self.WeaponSelectlbl:SetTextColor( color_black )
	
	local CurrentChoice = GetConVarString( "gmod_npc_weapon" )
	
	self.WeaponSelect:SetText( "No Weapon" )
	self.WeaponSelect:AddChoice( "No Weapon", "none" )
	
	local WeaponList = list.Get( "NPCWeapons" )
	for ClassName, NiceName in SortedPairs( WeaponList ) do
		local Item = self.WeaponSelect:AddChoice( NiceName, ClassName )
		if ( CurrentChoice == ClassName ) then
			self.WeaponSelect:SetText( NiceName )
		end
	end
	
	self.SinglePlayerOptions = vgui.Create( "DPanel", self )
	self.SinglePlayerOptionslbl = vgui.Create( "DLabel", self.SinglePlayerOptions )
	self.SinglePlayerOptionslbl:SetTextColor( color_black )
	self.SinglePlayerOptionslbl:SetText( "Single Player" )
	
	self.DisableAI = vgui.Create( "DCheckBoxLabel", self.SinglePlayerOptions )
	self.DisableAI:SetText( "Disable AI" )
	self.DisableAI:SetConVar( "ai_disabled" )
	self.DisableAI:SetTextColor( color_black )
	
	self.KeepCorpses = vgui.Create( "DCheckBoxLabel", self.SinglePlayerOptions )
	self.KeepCorpses:SetText( "Keep Corpses" )
	self.KeepCorpses:SetConVar( "ai_keepragdolls" )
	self.KeepCorpses:SetTextColor( color_black )
	
	self.NoTarget = vgui.Create( "DCheckBoxLabel", self.SinglePlayerOptions )
	self.NoTarget:SetText( "Ignore Players" )
	self.NoTarget:SetConVar( "ai_ignoreplayers" )
	self.NoTarget:SetTextColor( color_black )
	
	self.NoSquads = vgui.Create( "DCheckBoxLabel", self.SinglePlayerOptions )
	self.NoSquads:SetText( "Allow join player's squad" )
	self.NoSquads:SetConVar( "npc_citizen_auto_player_squad" )
	self.NoSquads:SetTextColor( color_black )	
	

	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	
	self.SinglePlayerOptions:StretchToParent( 4, 4, 4, 4 )
	self.SinglePlayerOptions:SetWide( self:GetWide() * 0.5 - 8 )
	
		self.SinglePlayerOptionslbl:SizeToContents()
		self.SinglePlayerOptionslbl:SetPos( 8, 4 )
		
			self.DisableAI:SizeToContents()
			self.DisableAI:SetPos( 16, 0 )
			self.DisableAI:MoveBelow( self.SinglePlayerOptionslbl, 4 )
			
			self.KeepCorpses:SizeToContents()
			self.KeepCorpses:SetPos( 16, 0 )
			self.KeepCorpses:MoveBelow( self.DisableAI, 2 )
			
			self.NoTarget:SizeToContents()
			self.NoTarget:SetPos( 16, 0 )
			self.NoTarget:MoveBelow( self.KeepCorpses, 2 )
			
			self.NoSquads:SizeToContents()
			self.NoSquads:SetPos( 16, y )
			self.NoSquads:MoveBelow( self.NoTarget, 2 )
		
	self.Options:MoveRightOf( self.SinglePlayerOptions, 4 )
	self.Options:StretchToParent( nil, 4, 4, 4 )	
	
	self:PositionLabel( 80, 20, 4, self.WeaponSelectlbl, self.WeaponSelect )
	
end

local NPCControls = vgui.RegisterTable( PANEL, "DPanel" )



local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	
	self.PanelList = vgui.Create( "DPanelList", self )
	
	self:BuildNPCList()
	
	self.PanelList:SetPadding( 4 )
	self.PanelList:SetSpacing( 2 )
	self.PanelList:EnableVerticalScrollbar( true )
	
	self.Controls = vgui.CreateFromTable( NPCControls, self )
	
end

/*---------------------------------------------------------
   Name: BuildNPCList
---------------------------------------------------------*/
function PANEL:BuildNPCList()
	
	self:Clear()
	
	local NPCList = list.Get( "NPC" )
	
	local Categories = {}
	
	// Categorize the NPCs
	for k, v in pairs( NPCList ) do
	
		local Category = v.Category or "Other"
		local Tab = Categories[ Category ] or {}
		
		Tab[ k ] = v
		
		Categories[ Category ] = Tab
	
	end
	
	for CategoryName, v in SortedPairs( Categories ) do
	
		local Category = vgui.Create( "DCollapsibleCategory", self )
		self.PanelList:AddItem( Category )
		Category:SetLabel( CategoryName )
		Category:SetCookieName( "NPCSpawn."..CategoryName )
		
		local Content = vgui.Create( "DPanelList" )
		Category:SetContents( Content )
		Content:EnableHorizontal( true )
		Content:SetDrawBackground( false )
		Content:SetSpacing( 2 )
		Content:SetPadding( 2 )
		Content:SetAutoSize( true )
		
		for NPCName, NPC in SortedPairsByMemberValue( v, "Name" ) do
		
			local Icon = vgui.CreateFromTable( NPCIcon, self )
				Icon:SetNPC( NPC.Name, NPCName )				
				Content:AddItem( Icon )
		
		end
		
	end
	
	self.PanelList:InvalidateLayout()
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.Controls:SetTall( 100 )
	self.Controls:SetWide( self:GetWide() )
	self.Controls:AlignBottom()

	self.PanelList:StretchToParent( 0, 0, 0, 0 )
	self.PanelList:StretchBottomTo( self.Controls, 4 )

end


local CreationSheet = vgui.RegisterTable( PANEL, "Panel" )

local function CreateContentPanel()

	local ctrl = vgui.CreateFromTable( CreationSheet )
	return ctrl

end

spawnmenu.AddCreationTab( "NPCs", CreateContentPanel, "gui/silkicons/group", 20, "Non Player Characters" )
