
local PANEL = {}

AccessorFunc( PANEL, "m_pControllerPanel", 		"ControllerPanel" )
AccessorFunc( PANEL, "m_iIconSize", 			"IconSize" )
AccessorFunc( PANEL, "m_strCategoryName", 		"CategoryName" )



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
	
	// Icon by default: todo: Cookie
	self:SetViewMode( "Icon" )
	
	self:SetIconSize( 64 ) // todo: Cookie!
	
	self.Models = {}
	
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
	icon.OpenMenu = function( icon ) 

						local menu = DermaMenu()
							menu:AddOption( "Copy to Clipboard", function() SetClipboardText( strModel ) end )
							local submenu = menu:AddSubMenu( "Re-Render", function() icon:RebuildSpawnIcon() end )
								submenu:AddOption( "This Icon", function() icon:RebuildSpawnIcon() end )
								submenu:AddOption( "All Icons", function() self:RebuildAll() end )
							menu:AddSpacer()
							menu:AddOption( "Delete", function() self:DeleteIcon( self.m_strCategoryName, icon, strModel ) end )
						menu:Open()
						
					end
					
	icon:SetIconSize( self.m_iIconSize )
	icon:InvalidateLayout( true )
	
	self.IconList:AddItem( icon )
	
	local Line = self.PropList:AddLine( strModel )
	Line.Model = strModel
	
	icon.LineID = Line:GetID()
	
	self.PropList:InvalidateLayout()
	
	if ( iSkin != 0 ) then return end
	
	local iSkinCount = NumModelSkins( strModel )
	if ( iSkinCount <= 1 ) then return end
	
	for i=1, iSkinCount-1, 1 do
	
		self:AddModel( strModel, i )
	
	end
	
	
end

/*---------------------------------------------------------
   Name: DeleteIcon
---------------------------------------------------------*/
function PANEL:DeleteIcon( category, icon, model )

	self.PropList:RemoveLine( icon.LineID )
		
	self.IconList:RemoveItem( icon )
	self.IconList:InvalidateLayout()
	
	spawnmenu.RemoveProp( category, model )
	
	SpawnMenuEnableSave()
	
end


/*---------------------------------------------------------
   Name: OnRowClick
---------------------------------------------------------*/
function PANEL:OnRowClick( LineNumber, Line )

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
   Name: RebuildAll
---------------------------------------------------------*/
function PANEL:RebuildAll( proppanel )

	local items = self.IconList:GetItems()
	
	for k, v in pairs( items ) do
	
		v:RebuildSpawnIcon()
	
	end
	
end

/*---------------------------------------------------------
   Name: GetCount
---------------------------------------------------------*/
function PANEL:GetCount()

	local items = self.IconList:GetItems()
	return #items
	
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
   Name: SetIconSize
---------------------------------------------------------*/
function PANEL:Clear()

	self.IconList:Clear()
	self.PropList:Clear()

end


vgui.Register( "PropPanel", PANEL, "DPanel" )
