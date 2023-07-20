property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt") --~/Library/Scripts/Libraries/Library Loader.scpt
property hellosLib : LibLoader's loadScript("Libraries:FunctionSource.applescript") --~/Library/Scripts/Libraries/FunctionSource.applescript

tell hellosLib to hellos()


-- function in other file "FunctionSource.applescript in ~/Library/Scripts/Libraries/FunctionSource.applescript"
-- to hellos()
--     log "hola"
-- end hellos

