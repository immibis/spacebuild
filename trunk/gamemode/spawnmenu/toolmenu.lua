
include( 'toolpanel.lua' )

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	self.ToolPanels = {}

	self:LoadTools()

end


/*---------------------------------------------------------
	LoadTools
---------------------------------------------------------*/
function PANEL:LoadTools()

	local tools = spawnmenu.GetTools()
	
	for strName, pTable in pairs( tools ) do
	
		self:AddToolPanel( strName, pTable )
	
	end

end


/*---------------------------------------------------------
	LoadTools
---------------------------------------------------------*/
function PANEL:AddToolPanel( Name, ToolTable )

	// I hate relying on a table's internal structure
	// but this isn't really that avoidable.
	
	local Panel = vgui.Create( "ToolPanel" )
	Panel:LoadToolsFromTable( ToolTable.Items )
	
	self:AddSheet( ToolTable.Label, Panel, ToolTable.Icon )
	
	self.ToolPanels[ Name ] = Panel

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	//surface.SetDrawColor( 255, 0, 0, 150 )
	//surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	DPropertySheet.Paint( self )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	DPropertySheet.PerformLayout( self )

	// We want to size to the contents in the base panel
	self:SizeToContentWidth()

end

vgui.Register( "ToolMenu", PANEL, "DPropertySheet" )