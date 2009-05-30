include( 'controlpanel.lua' )
include( 'ToolMenuButton.lua' )

g_ActiveControlPanel = nil
g_ToolPanel = nil

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	self.List = vgui.Create( "DPanelList", self )
	self.List:EnableVerticalScrollbar( true )
	self.List:SetSpacing( 1 )
	self.List:SetPadding( 1 )
	
	self.Content = vgui.Create( "DPanelList", self )
	self.Content:EnableVerticalScrollbar( true )
	self.Content:SetSpacing( 0 )
	self.Content:SetPadding( 5 )
	
end


/*---------------------------------------------------------
   Name: LoadToolsFromTable
---------------------------------------------------------*/
function PANEL:LoadToolsFromTable( inTable )

	local inTable = table.Copy( inTable )
	
	for k, v in pairs( inTable ) do
	
		if ( type( v ) == "table" ) then
		
			// Remove these from the table so we can
			// send the rest of the table to the other 
			// function
					
			local Name = v.ItemName
			local Label = v.Text
			v.ItemName = nil
			v.Text = nil
			
			self:AddCategory( Name, Label, v )
			
		end
	
	end

end

/*---------------------------------------------------------
   Name: AddCategory
---------------------------------------------------------*/
function PANEL:AddCategory( Name, Label, tItems )

	local Category = vgui.Create( "DCollapsibleCategory", self )
	self.List:AddItem( Category )
	Category:SetLabel( Label )
	Category:SetCookieName( "ToolMenu."..tostring(Name) )
	
	local CategoryContent = vgui.Create( "DPanelList" )
		CategoryContent:SetAutoSize( true )
		CategoryContent:SetDrawBackground( false )
		CategoryContent:SetSpacing( 0 )
		CategoryContent:SetPadding( 0 )
	
	Category:SetContents( CategoryContent )
	
	local bAlt = true
	
	for k, v in pairs( tItems ) do
	
		local item = vgui.Create( "ToolMenuButton", self )
		item:SetText( v.Text )
		item.OnSelect = function( button ) self:EnableControlPanel( button ) end
		
		concommand.Add( Format( "tool_%s", v.ItemName ), function() item:OnSelect() end )
		
		if ( v.SwitchConVar ) then
			item:AddCheckBox( v.SwitchConVar )
		end
		
		item.ControlPanelBuildFunction = v.CPanelFunction
		item.Command = v.Command
		item.Name = v.ItemName
		item.Controls = v.Controls
		item.Text = v.Text
		
		item:SetAlt( bAlt )
		bAlt = !bAlt
		
		
	
		CategoryContent:AddItem( item )
	
	end
	
	self:InvalidateLayout()
	
end

/*---------------------------------------------------------
   Name: EnableControlPanel
---------------------------------------------------------*/
function PANEL:EnableControlPanel( button )

	if ( self.LastSelected ) then
		self.LastSelected:SetSelected( false )
	end
	
	button:SetSelected( true )
	self.LastSelected = button

	local cp = controlpanel.Get( button.Name )
	if ( !cp:GetInitialized() ) then
		cp:FillViaTable( button )
	end
	
	self.Content:Clear()
	self.Content:AddItem( cp )
	self.Content:Rebuild()

	g_ActiveControlPanel = cp
	
	if ( button.Command ) then
		LocalPlayer():ConCommand( button.Command )
	end
		
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.List:SetPos( 0, 0 )
	self.List:SetSize( 140, self:GetTall() )
	
	self.Content:SetPos( self.List:GetWide() + 5, 0 )
	self.Content:SetSize( 260, self:GetTall() )
	
	self:SetWide( self.Content.x + self.Content:GetWide() )

end

vgui.Register( "ToolPanel", PANEL, "Panel" )