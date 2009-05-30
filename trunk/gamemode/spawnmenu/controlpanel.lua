//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ / 
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2007
//										 
//
//	Note: This is only really here as a layer between the spawnmenu
//			and the DForm Derma control. You shouldn't ever really be
//			calling AddControl. If you're writing new code - don't call
//			AddControl!! Add stuff directly using the DForm member functions!
//

include( "controls/manifest.lua" )

local PANEL = {}


AccessorFunc( PANEL, "m_bInitialized", "Initialized" )

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()
	self:SetInitialized( false )
end


/*---------------------------------------------------------
   Name: ClearControls
---------------------------------------------------------*/
function PANEL:ClearControls()
	self:Clear()
end


/*---------------------------------------------------------
   Name: GetEmbeddedPanel
---------------------------------------------------------*/
function PANEL:GetEmbeddedPanel()

	return self

end

/*---------------------------------------------------------
   Name: AddPanel
---------------------------------------------------------*/
function PANEL:AddPanel( pnl )

	self:AddItem( pnl, nil )
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: MatSelect   
---------------------------------------------------------*/
function PANEL:MatSelect( strConVar, tblOptions, bAutoStretch, iWidth, iHeight )

	local MatSelect = vgui.Create( "MatSelect", self )
	
		MatSelect:SetConVar( strConVar )
		
		if ( bAutoStretch != nil ) then MatSelect:SetAutoHeight( bAutoStretch ) end
		if ( iWidth != nil ) then MatSelect:SetItemWidth( iWidth ) end
		if ( iHeight != nil ) then MatSelect:SetItemHeight( iHeight ) end
		
		if ( tblOptions != nil ) then
			for k, v in pairs( tblOptions ) do
				MatSelect:AddMaterial( v, v )
			end
		end
	
	self:AddPanel( MatSelect )
	return MatSelect

end

/*---------------------------------------------------------
   Name: FillViaTable
---------------------------------------------------------*/
function PANEL:FillViaTable( Table )

	self:SetInitialized( true )
	
	self:SetName( Table.Text )
	
	//self:Help( "ControlPanelBuildFunction " .. tostring( Table.ControlPanelBuildFunction ).."\nCommand " .. tostring( Table.Command ).."\nName " .. tostring( Table.Name ).."\nText " .. tostring( Table.Text ) )
	//self:Help( "Controls ".. Table.Controls )
	
	//
	// If we have a function to create the control panel, use that
	//
	if ( Table.ControlPanelBuildFunction ) then
	
		local b, e = pcall( Table.ControlPanelBuildFunction, self )
		if ( !b ) then
			Error( "ControlPanelBuildFunction Error: ", e )
		end
		
	//
	// If not, use the txt file
	//
	elseif ( Table.Controls ) then
	
		self:LoadControlsFromTextFile( Table.Controls )
	
	end

end

/*---------------------------------------------------------
   Name: LoadControlsFromTextFile
   
	Please don't use this. Ever. 
	This is just here for backwards compatibility. 
	Don't rely on it staying around. 
   
---------------------------------------------------------*/
function PANEL:LoadControlsFromTextFile( strName )

	local file = file.Read( "../settings/controls/"..strName..".txt" )
	if (!file) then return end

	local Tab = KeyValuesToTablePreserveOrder( file )
	if (!Tab) then return end

	for k, data in pairs( Tab ) do

		if ( type( data.Value ) == "table" ) then
			local kv = table.CollapseKeyValue( data.Value )
			local ctrl = self:AddControl( data.Key, kv )
			if ( ctrl && kv.description ) then
				ctrl:SetTooltip( kv.description );
			end
		end
		
	end

end

/*---------------------------------------------------------
   Name: AddControl
---------------------------------------------------------*/
function PANEL:AddControl( control, data )

	local data = table.LowerKeyNames( data )

	// Retired
	if ( string.lower(control) == "header" ) then return end
	
	if ( string.lower(control) == "textbox" ) then

		local ctrl = self:TextEntry( data.label or "Untitled", data.command )
		return ctrl
		
	end
	
	if ( string.lower(control) == "label" ) then

		local ctrl = self:Help( data.text )
		return ctrl
		
	end
	
	if ( string.lower(control) == "checkbox" || string.lower(control) == "toggle" ) then

		local ctrl = self:CheckBox( data.label or "Untitled", data.command )
		return ctrl
		
	end
	
	if ( string.lower(control) == "slider" ) then

		local Decimals = 0
		if ( data.type && string.lower(data.type) == "float" ) then Decimals = 2 end
		
		local ctrl = self:NumSlider( data.label or "Untitled", data.command, data.min or 0, data.max or 100, Decimals )
		
		return ctrl
		
	end
	
	if ( string.lower(control) == "propselect" ) then

		local ctrl = vgui.Create( control, self )
		ctrl:ControlValues( data ) // Yack.
		self:AddPanel( ctrl )
		return ctrl
		
	end
	
	if ( string.lower(control) == "matselect" ) then

		local ctrl = vgui.Create( "MatSelect", self )
		ctrl:ControlValues( data ) // Yack.
		self:AddPanel( ctrl )
		return ctrl
		
	end
	
	if ( string.lower(control) == "ropematerial" ) then

		local ctrl = vgui.Create( "RopeMaterial", self )
		ctrl:SetConVar( data.convar )
		self:AddPanel( ctrl )
		
		return ctrl
		
	end
	
	if ( string.lower(control) == "button" ) then

		local ctrl = vgui.Create( "DButton", self )
		
		// Note: Buttons created this way use the old method of calling commands,
		// via LocalPlayer:ConCommand. This way is flawed. This way is legacy.
		// The new way is to make buttons via controlpanel:Button( name, command, commandarg1, commandarg2 ) etc
		if ( data.command ) then
			function ctrl:DoClick() LocalPlayer():ConCommand( data.command ) end
		end
		
		ctrl:SetText( data.label or data.text or "No Label" )
		self:AddPanel( ctrl )
		
		return ctrl
		
	end
	
	if ( string.lower(control) == "numpad" ) then

		local ctrl = vgui.Create( "CtrlNumPad", self )
			ctrl:SetConVar1( data.command )
			ctrl:SetConVar2( data.command2 )
			ctrl:SetLabel1( data.label )
			ctrl:SetLabel2( data.label2 )
		self:AddPanel( ctrl )
		return ctrl
		
	end
	
	if ( string.lower(control) == "color" ) then

		local ctrl = vgui.Create( "CtrlColor", self )

			ctrl:SetConVarR( data.red )
			ctrl:SetConVarG( data.green )
			ctrl:SetConVarB( data.blue )
			ctrl:SetConVarA( data.alpha )
			
		self:AddPanel( ctrl )
		return ctrl
		
	end
	
	
	if ( string.lower(control) == "combobox" ) then
		
		if ( tostring(data.menubutton) == "1" ) then
		
			local ctrl = vgui.Create( "ControlPresets", self )
			ctrl:SetPreset( data.folder )
			if ( data.options ) then
				for k, v in pairs( data.options ) do
					if ( k != "id" ) then // Some txt file configs still have an `ID'. But these are redundant now.
						ctrl:AddOption( k, v )
					end
				end
			end
			
			if ( data.cvars ) then
				for k, v in pairs( data.cvars ) do
					ctrl:AddConVar( v )
				end
			end
			
			
			
			self:AddPanel( ctrl )
			return ctrl
		
		end
		
		control = "listbox"
		
	end
	
	if ( string.lower(control) == "listbox" ) then
	
		if ( data.height ) then
		
			local ctrl = vgui.Create( "DListView" )
			ctrl:SetMultiSelect( false )
			self:AddPanel( ctrl )
			
			ctrl:AddColumn( data.label or "unknown" )
			
			if ( data.options ) then
			
				for k, v in pairs( data.options ) do
				
					v.id = nil // Some txt file configs still have an `ID'. But these are redundant now.
				
					local line = ctrl:AddLine( k )
					line.data = v
					
					// This is kind of broken because it only checks one convar
					// instead of all of them. But this is legacy. It will do for now.
					for k, v in pairs( line.data ) do
						if ( GetConVarString( k ) == v ) then
							line:SetSelected( true )
						end
					end
				
				end
			
			end
			
			ctrl:SetTall( data.height )
			
			ctrl:SortByColumn( 1, false )
			
			function ctrl:OnRowSelected( LineID, Line )
				for k, v in pairs( Line.data ) do
					RunConsoleCommand( k, v )
				end
			end
			
		else
			
			local ctrl = vgui.Create( "CtrlListBox", self )
			
			if ( data.options ) then
				for k, v in pairs( data.options ) do
					v.id = nil // Some txt file configs still have an `ID'. But these are redundant now.
					ctrl:AddOption( k, v )
				end
			end
			
			self:AddPanel( ctrl )
		
		end
		
		return ctrl
	
	end 
	
	if ( string.lower(control) == "materialgallery" ) then

		local ctrl = vgui.Create( "MatSelect", self )
		//ctrl:ControlValues( data ) // Yack.
		
		ctrl:SetItemWidth( data.width or 32 )
		ctrl:SetItemHeight( data.height or 32 )
		ctrl:SetNumRows( data.rows or 4 )
		ctrl:SetConVar( data.convar or nil )
		
		for name, tab in pairs( data.options ) do
		
			local mat = tab.material
			local value = tab.value
			
			tab.material = nil
			tab.value = nil
		
			ctrl:AddMaterialEx( name, mat, value, tab )
		
		end
		
		self:AddPanel( ctrl )
		return ctrl
		
	end
	
	local control = vgui.Create( control, self )
	if ( control ) then
		
		if ( control.ControlValues ) then
			control:ControlValues( data ) 
		end
		
		self:AddPanel( control )
		
		return control
		
	end
	
	
	
	MsgN( "UNHANDLED CONTROL: ", control )
	PrintTable( data )
	MsgN( "\n\n" )

end


// These are retired. If you're using them - you shouldn't be.

function PANEL:AddDefaultControls()
end

function PANEL:AddHeader()
end

function PANEL:GetPanel()
end



vgui.Register( "ControlPanel", PANEL, "DForm" )


