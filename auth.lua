
local HttpService = game:GetService("HttpService")

-- A key deve ser definida antes de rodar o script
local KEY = getgenv().KEY or ""
assert(KEY ~= "", "Chave não definida! Defina getgenv().KEY antes de executar.")

-- Função para obter HWID (supondo que o executor forneça essa função)
assert(gethwid, "Função gethwid() não encontrada no executor")
local HWID = gethwid()

local function verifyKey()
    local url = ("https://server-dun-six.vercel.app/api/HWIDCheck?key=%s&hwid=%s%22):format(KEY, HWID)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if not success then
        warn("Erro na requisição HTTP:", response)
        return false, "Erro de conexão"
    end

    local data = nil
    local ok, err = pcall(function()
        data = HttpService:JSONDecode(response)
    end)

    if not ok then
        warn("Erro ao decodificar JSON:", err)
        return false, "Resposta inválida"
    end

    if data.success then
        if data.action == "HWID vinculado" then
            print("HWID vinculado com sucesso!")
        else
            print("Chave e HWID validados com sucesso!")
        end
        return true
    else
        warn("Falha na verificação:", data.error or "Erro desconhecido")
        return false, data.error
    end
end

local valid, err = verifyKey()

if valid then
    print("Executando script principal...")
    -- Coloque aqui sua loadstring principal:
    print("foi")
else
    print("Executando script alternativo por causa de erro:", err)
    -- Coloque aqui sua loadstring alternativa:
   print("foi")
end 
