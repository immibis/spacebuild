
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
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	
	self.Label:SizeToContents()
	
	self.Label:SetFont( "DefaultSmallDropShadow" )
	self.Label:SetTextColor( color_white )
	self.Label:SetContentAlignment( 5 )
	self.Label:SetWide( self:GetWide() )
	self.Label:AlignBottom( 2 )
	
	DImageButton.PerformLayout( self )
	
	if ( self.imgAdmin ) then
	
		self.imgAdmin:SizeToContents()
		self.imgAdmin:AlignTop( 4 )
		self.imgAdmin:AlignRight( 4 )
	
	end
	
end

/*---------------------------------------------------------
   Name: CreateAdminIcon
---------------------------------------------------------*/
function PANEL:CreateAdminIcon()
	
	self.imgAdmin = vgui.Create( "DImage", self )
	self.imgAdmin:SetImage( "gui/silkicons/shield" )
	self.imgAdmin:SetTooltip( "#Admin Only" )

	
end

/*---------------------------------------------------------
   Name: Paint
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
function PANEL:Setup( NiceName, SpawnName, IconMaterial, AdminOnly )
	
	self.Label:SetText( NiceName )
	self.DoClick = function() RunConsoleCommand( "gm_giveswep", SpawnName ) end
	self.DoRightClick = function() RunConsoleCommand( "gm_spawnswep", SpawnName ) end
	
	if ( !IconMaterial ) then
		IconMaterial = "VGUI/entities/"..SpawnName
	end
	
	self:SetOnViewMaterial( IconMaterial, "vgui/swepicon" )
	
	if ( AdminOnly ) then
		self:CreateAdminIcon()
	end
	
	self:InvalidateLayout()
	
end

local WeaponIcon = vgui.RegisterTable( PANEL, "DImageButton" )




local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	
	self.PanelList = vgui.Create( "DPanelList", self )	
		self.PanelList:SetPadding( 4 )
		self.PanelList:SetSpacing( 2 )
		self.PanelList:EnableVerticalScrollbar( true )
		
	self:BuildList()
	
end

/*---------------------------------------------------------
   Name: BuildList
---------------------------------------------------------*/
function PANEL:BuildList()
	
	self.PanelList:Clear()
	
	// Get weapons
	local Weapons = weapons.GetList()
	local Categorised = {}
	
	// Build into categories
	for k, weapon in pairs( Weapons ) do
	
		// We need to get a real copy of the weapon table so that
		// all of the inheritence shit will be taken into consideration
		weapon = weapons.Get( weapon.ClassName )
		Weapons[ k ] = weapon
		weapon.Category = weapon.Category or "Other"
		
		// Only show it if we or an admin can spawn it
		if ( !weapon.Spawnable && !weapon.AdminSpawnable ) then
		
			Weapons[ k ] = nil
		
		else
		
			Categorised[ weapon.Category ] = Categorised[ weapon.Category ] or {}
			table.insert( Categorised[ weapon.Category ], weapon )
			Weapons[ k ] = nil
			
		end
	
	end
	
	Weapons = nil
	
	// Loop through each category
	for CategoryName, v in SortedPairs( Categorised ) do
	
		local Category = vgui.Create( "DCollapsibleCategory", self )
		self.PanelList:AddItem( Category )
		Category:SetLabel( CategoryName )
		Category:SetCookieName( "WeaponSpawn."..CategoryName )
		
		local Content = vgui.Create( "DPanelList" )
		Category:SetContents( Content )
		Content:EnableHorizontal( true )
		Content:SetDrawBackground( false )
		Content:SetSpacing( 2 )
		Content:SetPadding( 2 )
		Content:SetAutoSize( true )
		
		for k, WeaponTable in SortedPairsByMemberValue( v, "PrintName" ) do
				
			local Icon = vgui.CreateFromTable( WeaponIcon, self )
				Icon:Setup( WeaponTable.PrintName or WeaponTable.ClassName, WeaponTable.ClassName, WeaponTable.SpawnMenuIcon, WeaponTable.AdminSpawnable && !WeaponTable.Spawnable )
				
				local Tooltip =  Format( "Name: %s", WeaponTable.PrintName )
				if ( WeaponTable.Author != "" ) then Tooltip = Format( "%s\nAuthor: %s", Tooltip, WeaponTable.Author ) end
				if ( WeaponTable.Contact != "" ) then Tooltip = Format( "%s\nContact: %s", Tooltip, WeaponTable.Contact ) end
				if ( WeaponTable.Instructions != "" ) then Tooltip = Format( "%s\n\n%s", Tooltip, WeaponTable.Instructions ) end
				
				Icon:SetTooltip( Tooltip )
				Content:AddItem( Icon )
		
		end
	
	end
	
	self.PanelList:InvalidateLayout()
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.PanelList:StretchToParent( 0, 0, 0, 0 )

end


local CreationSheet = vgui.RegisterTable( PANEL, "Panel" )

local function CreateContentPanel()

	local ctrl = vgui.CreateFromTable( CreationSheet )
	return ctrl

end

spawnmenu.AddCreationTab( "Weapons", CreateContentPanel, "gui/silkicons/bomb", 30 )
