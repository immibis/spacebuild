
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
	
	if ( self.imgAdmin ) then
	
		self.imgAdmin:SizeToContents()
		self.imgAdmin:AlignTop( 4 )
		self.imgAdmin:AlignRight( 4 )
	
	end
	
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
   Name: CreateAdminIcon
---------------------------------------------------------*/
function PANEL:CreateAdminIcon()
	
	self.imgAdmin = vgui.Create( "DImage", self )
	self.imgAdmin:SetImage( "gui/silkicons/shield" )
	self.imgAdmin:SetTooltip( "#Admin Only" )
	
end

/*---------------------------------------------------------
   Name: Setup
---------------------------------------------------------*/
function PANEL:Setup( NiceName, SpawnName, IconMaterial, AdminOnly )
	
	self.Label:SetText( NiceName or "No Name" )
	self.DoClick = function() RunConsoleCommand( "gm_spawnsent", SpawnName ) end
	
	if ( !IconMaterial ) then
		IconMaterial = "VGUI/entities/"..SpawnName
	end
	
	self:SetOnViewMaterial( IconMaterial, "vgui/swepicon" )
	
	if ( AdminOnly ) then self:CreateAdminIcon() end
	
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
	
	local Entities = scripted_ents.GetSpawnable()
	local Categorised = {}
	
	// Build into categories
	for k, v in pairs( Entities ) do
	
		v.Category = v.Category or "Other"
		Categorised[ v.Category ] = Categorised[ v.Category ] or {}
		table.insert( Categorised[ v.Category ], v )
	
	end
	
	local SpawnableEntities = list.Get( "SpawnableEntities" )
	if ( SpawnableEntities ) then
		for k, v in pairs( SpawnableEntities ) do
		
			v.Category = v.Category or "Other"
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			table.insert( Categorised[ v.Category ], v )
		
		end
	end
	
	// Loop through each category
	for CategoryName, v in SortedPairs( Categorised ) do
	
		local Category = vgui.Create( "DCollapsibleCategory", self )
		self.PanelList:AddItem( Category )
		Category:SetLabel( CategoryName )
		Category:SetCookieName( "EntitySpawn."..CategoryName )
		
		local Content = vgui.Create( "DPanelList" )
		Category:SetContents( Content )
		Content:EnableHorizontal( true )
		Content:SetDrawBackground( false )
		Content:SetSpacing( 2 )
		Content:SetPadding( 2 )
		Content:SetAutoSize( true )
		
		for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
								
			local Icon = vgui.CreateFromTable( WeaponIcon, self )
				Icon:Setup( ent.PrintName or ent.ClassName, ent.ClassName, ent.Material, ent.AdminOnly || ( !ent.Spawnable && ent.AdminSpawnable) )
				
				local Tooltip =  Format( "Name: %s", ent.PrintName )
				if ( ent.Author ) then Tooltip = Format( "%s\nAuthor: %s", Tooltip, ent.Author ) end
				if ( ent.Information ) then Tooltip = Format( "%s\n\n%s", Tooltip, ent.Information ) end
				
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

spawnmenu.AddCreationTab( "Entities", CreateContentPanel, "gui/silkicons/plugin", 50 )
