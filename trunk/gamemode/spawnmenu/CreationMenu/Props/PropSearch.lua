include ( 'SearchGuts.lua' )


local PANEL = {}

AccessorFunc( PANEL, "m_pController", 		"Controller" )
AccessorFunc( PANEL, "m_iIconSize", 		"IconSize" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	
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
	
	
	
	self:SetViewMode( "Icon" )
	
	self:SetIconSize( 64 ) // cookie!
	
end


/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:AddModel( strModel, iSkin )
	
	iSkin = iSkin or 0
	
	// Make icon 
	local icon = vgui.Create( "SpawnIcon", self )
	icon:SetModel( strModel, iSkin )
	icon.DoClick = function( icon ) surface.PlaySound( "ui/buttonclickrelease.wav") RunConsoleCommand( "gm_spawn", strModel, iSkin ) end
	icon.OpenMenu = function( icon ) self:OpenContextMenu( { strModel }, icon, iSkin )	end
					
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
function PANEL:OpenContextMenu( ModelTable, Icon, iSkin )
	
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
										
										self:GetController():RebuildPropList( strCategory ) 
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
										
												self:GetController():RebuildPropList( strTextOut ) 
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
   Name: Init
---------------------------------------------------------*/
function PANEL:Search( strSearch )
	
	self:Clear()
	
	if ( strSearch == "" ) then return end
	if ( strSearch:len() < 2 ) then return end
	
	local Models = ModelSearch( strSearch ) // (defined in SearchGuts.lua)
	
	for k, v in pairs( Models ) do
	
		self:AddModel( v )
		
		// Find/Add additional skins
		/*
		
		TODO: Add in an update!
		
		iSkins = NumModelSkins( v )
		
		if ( iSkins > 1 ) then
			
			for i=2, iSkins do
				self:AddModel( v, i-1 )
			end
		
		end
		*/
	
	end
	
	self.IconList:Rebuild()
	self.IconList:InvalidateLayout()
	
	self.PropList:InvalidateLayout()
	
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
	end
	
	if ( strName == "List" ) then
		self.PropList:SetVisible( true )
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	
	self.IconList:StretchToParent( 0, 0, 0, 0 )
	self.IconList:InvalidateLayout()
	
	self.PropList:StretchToParent( 0, 0, 0, 0 )
	self.PropList:InvalidateLayout()
	
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
	
	self:GetController():RebuildPropList( category )
	SpawnMenuEnableSave()
	
end


vgui.Register( "PropSearchResults", PANEL, "DPanel" )
