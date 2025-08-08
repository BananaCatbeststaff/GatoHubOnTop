local obfuscatedIDs = {
    [109983668079237] = true,
    [96342491571673] = true
}

if placeId == 79546208627805 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BananaCatbeststaff/GatoHubOnTop/refs/heads/main/99-nights.lua"))()
elseif obfuscatedIDs[placeId] then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BananaCatbeststaff/GatoHubOnTop/refs/heads/main/obfuscated.lua"))()
else
    warn("Nenhum script definido para este PlaceId:", placeId)
end
