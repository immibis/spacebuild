
local g_iModelCount  = 0
local LastOutput = 0

/*---------------------------------------------------------
   Name: Make the table if it doesn't exist
   Note: This should never happen, since I'll be shipping a database with it.. but just in case..
---------------------------------------------------------*/
if ( !sql.TableExists( "searchcache" ) ) then

	sql.Query( "CREATE TABLE IF NOT EXISTS searchcache ( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, modelname TEXT );" )
	
end

/*---------------------------------------------------------
   Name: Builds the search index for this specific folder
---------------------------------------------------------*/
local function BuildSearchIndex( strSearchFolder, tFolders, tFiles )

	strSearchFolder = string.Trim( strSearchFolder, "*" )
	
	sql.Begin()
	for k, filename in pairs( tFiles ) do
	
		local ext = string.GetExtensionFromFilename( filename )
	
		// Filter out unusable crap
		if ( ext == "mdl" && !UTIL_IsUselessModel( filename ) ) then
		
			local ModelName = SQLStr( strSearchFolder .. filename )
			sql.Query( "INSERT INTO searchcache ( modelname ) VALUES ( "..ModelName.." )" )
			g_iModelCount = g_iModelCount + 1
			
		end
		
	end	
	sql.Commit()
	
	//
	// Todo! VGUI!
	//
	if ( LastOutput < CurTime() - 1 ) then
		LocalPlayer():PrintMessage( HUD_PRINTTALK, "Building the search cache.. ("..g_iModelCount.." models found)" );
		LastOutput = CurTime()
	end
	
	for k, dir in pairs( tFolders ) do
		file.TFind( strSearchFolder .. dir .."/*", BuildSearchIndex )
	end

end

/*---------------------------------------------------------
   RebuildSearchCache 
	Wipes the old data and completely replaces it
---------------------------------------------------------*/
function RebuildSearchCache()

	// Remove all from the searchcache table
	sql.Query( "DELETE FROM searchcache" )
	
	g_iModelCount = 0
	file.TFind( "models/*", BuildSearchIndex )
	
end

/*---------------------------------------------------------
   ModelSearch 
---------------------------------------------------------*/
function ModelSearch( SearchString, iLimit )

	iLimit = iLimit or 128

	SearchString = SQLStr( SearchString, true )
	
	local result = sql.Query( "SELECT modelname FROM searchcache WHERE modelname LIKE '%"..SearchString.."%' LIMIT "..iLimit )
	if (!result) then return {} end
	
	local ret = {}
	
	for k, v in pairs( result ) do
	
		table.insert( ret, v.modelname )
	
	end
	
	table.sort( ret )
	
	return ret
	
end
