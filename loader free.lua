local placeId = game.PlaceId

if placeId == 79546208627805 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BananaCatbeststaff/GatoHubOnTop/refs/heads/main/99-nights.lua"))()
elseif placeId == 109983668079237 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BananaCatbeststaff/GatoHubOnTop/refs/heads/main/obfuscated.lua"))()
else
    warn("Nenhum script definido para este PlaceId:", placeId)
end
