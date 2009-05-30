
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
   Name: Setup
---------------------------------------------------------*/
function PANEL:Setup( NiceName, SpawnName, IconMaterial, AdminOnly )
	
	self.Label:SetText( NiceName )
	self.DoClick = function() RunConsoleCommand( "gm_spawnvehicle", SpawnName ) end
	
	if ( !IconMaterial ) then
		IconMaterial = "VGUI/entities/"..SpawnName
	end
	
	self:SetOnViewMaterial( IconMaterial, "vgui/swepicon" )
	
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
	local Vehicles = list.Get( "Vehicles" )
	local Categorised = {}
	
	// Build into categories
	for k, vehicle in pairs( Vehicles ) do
	
		vehicle.Category = vehicle.Category or "Other"
		Categorised[ vehicle.Category ] = Categorised[ vehicle.Category ] or {}
		vehicle.__ClassName = k
		table.insert( Categorised[ vehicle.Category ], vehicle )
		Vehicles[ k ] = nil
	
	end
	
	Vehicles = nil
	
	// Loop through each category
	for CategoryName, v in SortedPairs( Categorised ) do
	
		local Category = vgui.Create( "DCollapsibleCategory", self )
		self.PanelList:AddItem( Category )
		Category:SetLabel( CategoryName )
		Category:SetCookieName( "VehicleSpawn."..CategoryName )
		
		local Content = vgui.Create( "DPanelList" )
		Category:SetContents( Content )
		Content:EnableHorizontal( true )
		Content:SetDrawBackground( false )
		Content:SetSpacing( 2 )
		Content:SetPadding( 2 )
		Content:SetAutoSize( true )
		
		for k, WeaponTable in SortedPairsByMemberValue( v, "Name" ) do
				
			local Icon = vgui.CreateFromTable( WeaponIcon, self )
				Icon:Setup( WeaponTable.Name or WeaponTable.__ClassName, WeaponTable.__ClassName, WeaponTable.Material )
				
				local Tooltip =  Format( "Name: %s", WeaponTable.Name )
				if ( WeaponTable.Author ) then Tooltip = Format( "%s\nAuthor: %s", Tooltip, WeaponTable.Author ) end
				if ( WeaponTable.Information ) then Tooltip = Format( "%s\n\n%s", Tooltip, WeaponTable.Information ) end
				
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

spawnmenu.AddCreationTab( "Vehicles", CreateContentPanel, "gui/silkicons/car", 40 )
