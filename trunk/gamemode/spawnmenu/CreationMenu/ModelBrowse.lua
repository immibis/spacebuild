
local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()
	
	self:SetCookieName( "SpawnmenuModelBrowser" )
	
	self.IconList = vgui.Create( "DPanelList", self )
	self.IconList:EnableVerticalScrollbar( true )
	self.IconList:EnableHorizontal( true )
	self.IconList:SetPadding( 4 )
	
	self.PropList = vgui.Create( "DListView", self )
	self.PropList:SetDataHeight( 16 )
	self.PropList:AddColumn( "#Name" )
	self.PropList.DoDoubleClick = function( PropList, RowNumber, Line ) self:OnRowClick( RowNumber, Line ) end
	self.PropList:SetMultiSelect( false )
	
	self.PropList.OnRowRightClick = function( PropList, RowNumber, Line ) 
	
										local models = { Line.Model }
										self:OpenContextMenu( models ) 
										
									end
	
	self:SetBottom( self.IconList )
	
	self:SetViewMode( "Icon" )
	
	self:SetIconSize( 64 )
	
	self.Folders = vgui.Create( "DTree" )
	self.Folders:SetPadding( 5 )
	
	local pFolder = self.Folders:AddNode( "All" )
	pFolder:MakeFolder( "models", false )
	
	self.Folders.DoClick = function( tree, node ) return self:ModelBrowse( node.FileName ) end
	
	self:SetTop( self.Folders )
	
	self:AddRootFolder( "Garry's Mod", "../garrysmod/models" )
	
	//
	// Add content (css, dod etc)
	//
	local Content = GetMountedContent()
	for NiceName, FolderName in pairs( Content ) do
		
		self:AddRootFolder( NiceName, "../"..FolderName.."/models" )
		
	end
	
	//
	// Add addons (model packs etc)
	//
	local Addons = GetAddonList()
	for index, Name in pairs( Addons ) do
		
		self:AddRootFolder( Name, "addons/"..Name.."/models" )
		
	end
	
end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:AddRootFolder( strName, strPath )

	// For addons, if the addon doesn't have any models
	// then don't clutter us up by adding it.
	if ( !file.Exists( strPath, true ) ) then
		return
	end

	local pFolder = self.Folders:AddNode( strName )
	pFolder:MakeFolder( strPath, false )

end

/*---------------------------------------------------------
   Name: AddModel
---------------------------------------------------------*/
function PANEL:AddModel( strModel )
	
	// Make icon 
	local icon = vgui.Create( "SpawnIcon", self )
	icon:SetModel( strModel )
	icon.DoClick = function( icon ) surface.PlaySound( "ui/buttonclickrelease.wav" ) RunConsoleCommand( "gm_spawn", strModel ) end
	icon.OpenMenu = function( icon ) self:OpenContextMenu( { strModel }, icon )	end
					
	icon:SetIconSize( self.m_iIconSize )
	icon:InvalidateLayout( true )
	
	self.IconList:AddItem( icon )
	
	
	local tab = self.PropList:AddLine( strModel )
	tab.Model = strModel
	
	self.PropList:InvalidateLayout()
	
end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Clear()
	
	// Clear
	self.IconList:Clear()
	self.PropList:Clear()
	
end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:OpenContextMenu( ModelTable, Icon )
	
	local SingleModel = ModelTable[1]
	
	local menu = DermaMenu()
	
		if ( SingleModel) then
			menu:AddOption( "Copy to Clipboard", function() SetClipboardText( SingleModel ) end )
		end
	
		local categorymenu = menu:AddSubMenu( "Add To Category" )
		
			local props = spawnmenu.GetPropTable()
			for strCategory, v in pairs( props ) do
			
				//
				// Add To Category
				//
				local fnAddIconToCategory = function() 
				
										for _, strModel in pairs( ModelTable ) do
											spawnmenu.AddProp( strCategory, strModel ) 
										end
										
										g_PropSpawnController:RebuildPropList( strCategory )
										
										SpawnMenuEnableSave()
										
										end
			
				local sub = categorymenu:AddSubMenu( strCategory, fnAddIconToCategory )
				sub:AddOption( "This Icon", fnAddIconToCategory )
				sub:AddOption( "All Of These Icons", function() self:AddPropsToCategory( strCategory ) end )
				
			end
			
			categorymenu:AddSpacer()
			
			//
			// Add To NEW Category
			//
			local fnAddIconToCategory = function()
			
										g_SpawnMenu:HangOpen( true ) 
										
										Derma_StringRequest( "New Category", 
											"What should we name the new category?", 
											"", 
											function( strTextOut ) 
											
												for _, strModel in pairs( ModelTable ) do
													spawnmenu.AddProp( strTextOut, strModel ) 
												end
										
												g_PropSpawnController:RebuildPropList( strTextOut )
												SpawnMenuEnableSave()
											end )
											
										end
										
			local fnAddAllIconsToCategory = function()
			
										g_SpawnMenu:HangOpen( true ) 
			
										Derma_StringRequest( "New Category", 
											"What should we name the new category?", 
											"", 
											function( strTextOut ) self:AddPropsToCategory( strTextOut ) end )
										end
			
			local sub = categorymenu:AddSubMenu( "New Category..", fnAddIconToCategory )
			sub:AddOption( "This Icon..", fnAddIconToCategory )
			sub:AddOption( "All Of These Icons..", fnAddAllIconsToCategory )
			
		if ( Icon ) then
			menu:AddSpacer()
			menu:AddOption( "Rebuild Icon", function() Icon:RebuildSpawnIcon() end )
		end
		
	menu:Open()
	
end

/*---------------------------------------------------------
   Name: ModelBrowse
---------------------------------------------------------*/
function PANEL:ModelBrowse( strPath )
	
	// Return false if we're already viewing this path.
	// This causes the tree to be openable via name click.
	if ( self.ViewingPath == strPath ) then return false end
	self.ViewingPath = strPath
	
	self:Clear()
	
	local SearchString = strPath .. "/*.mdl"
	local CleanPath = strPath
	
	// Find the first location of "models"
	local findpos = CleanPath:find( "models" )
	if ( !findpos ) then	return end
	
	// Remove everything before models
	CleanPath = CleanPath:sub( findpos )
	
	local Models = file.Find( SearchString, true )
	
	for k, v in pairs( Models ) do
	
		if ( !UTIL_IsUselessModel( v ) ) then
			self:AddModel( CleanPath .. "/" .. v )
		end
	
	end
	
	self.IconList:Rebuild()
	self.IconList:InvalidateLayout()
	
	self.PropList:InvalidateLayout()
	
	return true
	
end

/*---------------------------------------------------------
   Name: OnRowClick
---------------------------------------------------------*/
function PANEL:OnRowClick( LineID, Line )

	surface.PlaySound( "ui/buttonclickrelease.wav")
	RunConsoleCommand( "gm_spawn", Line.Model )
	
end



/*---------------------------------------------------------
   Name: SetViewMode
---------------------------------------------------------*/
function PANEL:SetViewMode( strName )

	self.IconList:SetVisible( false )
	self.PropList:SetVisible( false )

	if ( strName == "Icon" ) then
		self.IconList:SetVisible( true )
		self:SetBottom( self.IconList )
	end
	
	if ( strName == "List" ) then
		self.PropList:SetVisible( true )
		self:SetBottom( self.PropList )
	end
	
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: SetIconSize
---------------------------------------------------------*/
function PANEL:SetIconSize( iconSize )

	self.m_iIconSize = iconSize
	
	local items = self.IconList:GetItems()
	
	for k, v in pairs( items ) do
	
		v:SetIconSize( self.m_iIconSize )
		v:InvalidateLayout( true )
	
	end
	
	self.IconList:InvalidateLayout()
	
end


/*---------------------------------------------------------
   Name: AddPropsToCategory
---------------------------------------------------------*/
function PANEL:AddPropsToCategory( category )

	local data = self.PropList:GetLines()

	for k, v in pairs( data ) do
		spawnmenu.AddProp( category, v.Model )
	end
	
	g_PropSpawnController:RebuildPropList( category )
	
	SpawnMenuEnableSave()
	
end

vgui.Register( "SpawnmenuModelBrowser", PANEL, "DVerticalDivider" )

local function CreateContentPanel()

	local ctrl = vgui.Create( "SpawnmenuModelBrowser" )
	return ctrl

end

spawnmenu.AddCreationTab( "Browse", CreateContentPanel, "gui/silkicons/folder_go", 10 )
