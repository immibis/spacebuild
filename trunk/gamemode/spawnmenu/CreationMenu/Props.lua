
include( "Props/SpawnIcon.lua" )
include( "Props/PropSearch.lua" )
include( "Props/PropPanel.lua" )

local PANEL = {}

AccessorFunc( PANEL, "m_pSelectedPanel", 		"SelectedPanel" )

local COL_NAME = 1
local COL_COUNT = 2

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()
	
	g_PropSpawnController = self
	
	hook.Call( "PopulatePropMenu", GAMEMODE )
	
	self.Panels = {}
	
	self.CategoryTable = {}
	self.PropPanels = {}
	
	self.PropList = vgui.Create( "DListView", self )
	self.PropList:SetDataHeight( 16 )
	self.PropList:AddColumn( "#Name" )
	self.PropList:AddColumn( "#Count" ):SetFixedWidth( 50 )
	self.PropList.OnRowSelected = function( PropList, RowNumber ) self:ChangeRow( RowNumber ) end
	self.PropList.OnRowRightClick = function( PropList, RowNumber ) self:CategoryMenu( RowNumber ) end
	self:SetTop( self.PropList )
	
	self:SetDividerHeight( 26 )
	self:SetTopHeight( 200 )
	
	self.Divide = vgui.Create( "PropsPanelDivide", self )
	self.Divide:SetController( self )
	self:SetMiddle( self.Divide )
	
	self.Search = vgui.Create( "PropSearchResults", self )
	self.Search:SetVisible( false )
	self.Search:SetController( self )
	
	self:PopulateFromStored()
	self:UpdatePropCounts()
	
	self.PropList:SortByColumn( 2, true )
	self.PropList:SelectFirstItem()
	
	self:SetCookieName( "SpawnMenu.Props" )
	
	
	
	
end

/*---------------------------------------------------------
	LoadCookies
---------------------------------------------------------*/
function PANEL:LoadCookies()

	DVerticalDivider.LoadCookies( self )

	self:SetViewMode( self:GetCookie( "ViewMode", "Icon" ) )
	self:SwitchIconSize( self:GetCookieNumber( "IconSize", 64 ) )

end

/*---------------------------------------------------------
   Name: PopulateFromStored
---------------------------------------------------------*/
function PANEL:PopulateFromStored()

	local Props = spawnmenu.GetPropTable()
	
	for k, v in pairs( Props ) do
	
		local Category = self:AddCategory( k )
		
		for i, model in pairs( v ) do
			self:AddCategoryModel( Category, model )
		end
		
	end
	
	self:LoadCookies()
	
end

/*---------------------------------------------------------
   Name: CategoryMenu
---------------------------------------------------------*/
function PANEL:CategoryMenu( RowNumber )

	local Selected = self.PropList:GetSelected()
	local Item = Selected[1]
	local bMultilple = #Selected > 1
	local strOldName = Item:GetValue( 1 )
	
	local menu = DermaMenu()

		if (!bMultilple) then
			menu:AddOption( "Rename", function() 	g_SpawnMenu:HangOpen( true ) 
													Derma_StringRequest( "Rename Category \"" .. strOldName .. "\"", 
																"What should this category be renamed?", 
																strOldName, 
																function( strTextOut ) self:RenameCategory( strOldName, strTextOut ) end )
										end )
		end
		
		/*
		Todo.
		if ( bMultilple ) then
			menu:AddOption( "Merge" )
		end
		*/
		
		menu:AddOption( "Empty", function() self:EmptyCategories( Selected ) end )
		menu:AddOption( "Delete", function() self:DeleteCategories( Selected ) end )
		
	menu:Open()
	

end

/*---------------------------------------------------------
   Name: GetCategory
---------------------------------------------------------*/
function PANEL:GetCategory( strName )

	return self.CategoryTable[ strName ]

end

/*---------------------------------------------------------
   Name: RenameCategory
---------------------------------------------------------*/
function PANEL:RenameCategory( strOldName, strName )

	if ( !strName || strName == "" ) then return end

	spawnmenu.RenamePropCategory( strOldName, strName )
	
	local cat = self:GetCategory( strOldName )
	
	cat:SetValue( 1, strName )
	
	self.CategoryTable[ strName ] = self.CategoryTable[ strOldName ]
	self.CategoryTable[ strOldName ] = nil
	
	SpawnMenuEnableSave()

end

/*---------------------------------------------------------
   Name: EmptyCategories
---------------------------------------------------------*/
function PANEL:EmptyCategories( Selected )

	for k, Line in pairs( Selected ) do
	
		local strName = Line:GetValue( 1 )
		spawnmenu.EmptyPropCategory( strName )
	
		Line.PropPanel:Clear()
	
		self:UpdatePropCounts()
		SpawnMenuEnableSave()

	end

end

/*---------------------------------------------------------
   Name: DeleteCategories
---------------------------------------------------------*/
function PANEL:DeleteCategories( Selected )

	for k, Item in pairs( Selected ) do
	
		local strName = Item:GetValue( 1 )
		
		self.CategoryTable[ strName ] = nil
		self.PropList:RemoveLine( Item:GetID() )
		spawnmenu.DeletePropCategory( strName )
		
		SpawnMenuEnableSave()

	end

end

/*---------------------------------------------------------
   Name: AddCategory
---------------------------------------------------------*/
function PANEL:AddCategory( strName )

	local Line = self.PropList:AddLine( strName, 0 )
	
	Line.PropPanel = vgui.Create( "PropPanel", self )
	Line.PropPanel:SetVisible( false )
	Line.PropPanel:SetControllerPanel( self )
	Line.PropPanel:SetCategoryName( strName )
	
	table.insert( self.Panels, Line.PropPanel )
	
	self.CategoryTable[ strName ] = Line
	self.PropPanels[ Line:GetID() ] = Line.PropPanel
	
	return Line

end

/*---------------------------------------------------------
   Name: AddCategoryModel
---------------------------------------------------------*/
function PANEL:AddCategoryModel( Category, model )

	Category.PropPanel:AddModel( model )

end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetTopMax( self.PropList:GetInnerTall() + self.PropList:GetHeaderHeight() )

	DVerticalDivider.PerformLayout( self )

end



/*---------------------------------------------------------
   Name: ChangeRow
---------------------------------------------------------*/
function PANEL:ChangeRow( RowNumber )

	local pnl = self:GetSelectedPanel()
	if ( pnl ) then
		pnl:SetVisible( false )
	end
	
	local PropPanel = self.PropPanels[ RowNumber ]

	self:SetBottom( PropPanel )
	self:SetSelectedPanel( PropPanel )
	
	PropPanel:SetVisible( true )
	
	self:InvalidateLayout()
	
end

/*---------------------------------------------------------
   Name: DoSearch
---------------------------------------------------------*/
function PANEL:DoSearch( strString )

	local pnl = self:GetSelectedPanel()
	if ( pnl ) then
		pnl:SetVisible( false )
	end
	
	self:SetBottom( self.Search )
	self:SetSelectedPanel( self.Search )
	
	self.Search:SetVisible( true )
	
	self:InvalidateLayout()
	
	self.Search:Search( strString )
	
	self:SetCookie( "SearchString", strString )
	
end

/*---------------------------------------------------------
   Name: DoSearchDelayed
---------------------------------------------------------*/
function PANEL:DoSearchDelayed( strString )

	self.SearchString = strString
	self.SearchTimer = SysTime() + 0.5
	
end


/*---------------------------------------------------------
   Name: SearchThink
---------------------------------------------------------*/
function PANEL:SearchThink()

	if (!self.SearchTimer) then return end
	if ( self.SearchTimer > SysTime() ) then return end
	
	self:DoSearch( self.SearchString )
	
	self.SearchTimer = nil
	self.SearchString = nil

end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()
	
	self:SearchThink()
	
end

/*---------------------------------------------------------
   Name: SetIconView
---------------------------------------------------------*/
function PANEL:SetViewMode( strView )

	for k, v in pairs( self.Panels ) do
	
		v:SetViewMode( strView )
	
	end
	
	if ( !self.Search ) then
	
		debug.Trace()
	
	end
	
	self.Search:SetViewMode( strView )	
	self:SetCookie( "ViewMode", strView )
	
end

/*---------------------------------------------------------
   Name: SwitchIconSize
---------------------------------------------------------*/
function PANEL:SwitchIconSize( fSize )

	for k, v in pairs( self.Panels ) do
		v:SetIconSize( fSize )
	end
	
	self.Search:SetIconSize( fSize )
	self:SetCookie( "IconSize", fSize )
	
end


/*---------------------------------------------------------
   Name: RebuildPropLists
---------------------------------------------------------*/
function PANEL:RebuildPropList( strCategory )

	//
	// If the category already exists, rebuild it
	//
	local Category = self:GetCategory( strCategory )
	if ( Category ) then
	
		Category.PropPanel:Clear()
		
		local models = spawnmenu.GetPropCategoryTable( strCategory )
		for k, model in pairs( models ) do
			self:AddCategoryModel( Category, model )
		end
		
		self:UpdatePropCounts()
		
		return
	
	end
	
	//
	// New Category, create it.
	//
	
	local models = spawnmenu.GetPropCategoryTable( strCategory )
	if ( !models || #models == 0 ) then return end
	
	local Category = self:AddCategory( strCategory )
	
	for i, model in pairs( models ) do
	
		self:AddCategoryModel( Category, model )
		
	end
	
	table.insert( self.Panels, Category.PropPanel )
	
	self.PropList:InvalidateLayout()
	
	self:UpdatePropCounts()

end

/*---------------------------------------------------------
   Name: UpdatePropCounts
---------------------------------------------------------*/
function PANEL:UpdatePropCounts()

	for k, Category in pairs( self.CategoryTable ) do
	
		local count = Category.PropPanel:GetCount()
		
		Category:SetColumnText( COL_COUNT, count )
	
	end

end

vgui.Register( "CreatePropsPanel", PANEL, "DVerticalDivider" )



local function CreateContentPanel()

	local ctrl = vgui.Create( "CreatePropsPanel" )
	return ctrl

end

spawnmenu.AddCreationTab( "#Props", CreateContentPanel, "gui/silkicons/application_view_tile", -10 )




local PANEL = {}

AccessorFunc( PANEL, "m_pController", 		"Controller" )

local g_SpawnMenuDivide = nil

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	
	//self:SetMouseInputEnabled( false )
	g_SpawnMenuDivide = self
	
	self.btnSave = vgui.Create( "DImageButton", self )
		self.btnSave:SetImage( "vgui/spawnmenu/save" )
		self.btnSave:SetTooltip( "Save changes to spawn icons" )
		self.btnSave.DoClick = function( self ) self:SetDisabled( true ) spawnmenu.SaveProps() end
		self.btnSave:SetDisabled( true )
		
	self.btnViewMode = vgui.Create( "DImageButton", self )
		self.btnViewMode:SetImage( "gui/silkicons/application_view_detail" )
		self.btnViewMode:SetTooltip( "Change View Mode" )
		self.btnViewMode.DoClick = function( btn ) 	
		
										local menu = DermaMenu()
	
											menu:AddOption( "Icons", function() self:GetController():SetViewMode( "Icon" ) end )
											menu:AddOption( "List", function() self:GetController():SetViewMode( "List" ) end )
										
										menu:Open()
										
									end
		
	self.btnIconSize = vgui.Create( "DImageButton", self )
		self.btnIconSize:SetImage( "gui/silkicons/application_form_magnify" )
		self.btnIconSize:SetTooltip( "Change Icon Size" )
		self.btnIconSize.DoClick = function( btn ) 	
		
										local menu = DermaMenu()
	
											menu:AddOption( "Tiny", function() self:GetController():SwitchIconSize( 32 ) end )
											menu:AddOption( "Small", function() self:GetController():SwitchIconSize( 48 ) end )
											menu:AddOption( "Normal", function() self:GetController():SwitchIconSize( 64 ) end )
											menu:AddOption( "Large", function() self:GetController():SwitchIconSize( 96 ) end )
											menu:AddOption( "Too Big", function() self:GetController():SwitchIconSize( 128 ) end )
										
										menu:Open()
										
									end
	
	self.txtSearch = vgui.Create( "DTextEntry", self )
	self.txtSearch.OnTextChanged = function( txtentry ) self:GetController():DoSearchDelayed( txtentry:GetValue() or "" ) end 
	
	self.btnSearch = vgui.Create( "DImageButton", self )
	self.btnSearch:SetImage( "gui/silkicons/page_white_magnify" )
	self.btnSearch:SetTooltip( "Search Props.." )
	self.btnSearch.DoClick = function( btn ) self:GetController():DoSearch( self.txtSearch:GetValue() or "" ) end
	
	self.btnSearchRebuild = vgui.Create( "DImageButton", self )
	self.btnSearchRebuild:SetImage( "gui/silkicons/arrow_refresh" )
	self.btnSearchRebuild:SetTooltip( "Refresh Search Cache" )
	self.btnSearchRebuild.DoClick = function( btn ) g_SpawnMenu:HangOpen( true ) 	
													Derma_Query( "Are you sure you want to rebuild the search cache?\n\nThe search cache can take up to a minute to rebuild. You only need to rebuild if you have added new models.", 
													"Rebuild Search Cache",
													"Rebuild", 	function() RebuildSearchCache() end, 
													"Cancel" ) end
	
	
	
	self:SetCursor( "sizens" )
	
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:EnableSave()
	
	self.btnSave:SetDisabled( false )
	
end

function SpawnMenuEnableSave()

	g_SpawnMenuDivide:EnableSave()

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	
	self.btnSave:SetPos( 4, 4 )
	self.btnSave:SetSize( 16, 16 )
	
	self.btnViewMode:CopyBounds( self.btnSave )
	self.btnViewMode:MoveRightOf( self.btnSave, 16 )
	
		self.btnIconSize:CopyBounds( self.btnSave )
		self.btnIconSize:MoveRightOf( self.btnViewMode, 4 )
			
		
	
	self.btnSearchRebuild:CopyBounds( self.btnSave )
	self.btnSearchRebuild:AlignRight( 4 )
	
	self.btnSearch:CopyBounds( self.btnSave )
	self.btnSearch:MoveLeftOf( self.btnSearchRebuild, 4 )
	
	self.txtSearch:CopyBounds( self.btnSave )
	self.txtSearch:SetSize( self:GetWide() * 0.3, 16 )
	self.txtSearch:MoveLeftOf( self.btnSearch, 4 )
	
end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )
	
	// Reel back to parent, so user can still drag
	self:GetParent():OnMousePressed( mcode )	
	
end

vgui.Register( "PropsPanelDivide", PANEL, "Panel" )
