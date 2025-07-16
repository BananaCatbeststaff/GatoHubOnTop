local HttpService = game:GetService("HttpService")
local KEY = getgenv().KEY or ""

-- Validações iniciais
assert(KEY ~= "", "Chave não definida! Defina getgenv().KEY antes de executar.")
assert(gethwid, "Função gethwid() não encontrada no executor")

local HWID = gethwid()

local function verifyKey()
    local url = ("https://server-dun-six.vercel.app/api/HWIDCheck?key=%s&hwid=%s"):format(KEY, HWID)
    
    print("Verificando key:", KEY)
    print("HWID:", HWID)
    
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
            print("✅ HWID vinculado com sucesso!")
        else
            print("✅ Chave e HWID validados com sucesso!")
        end
        return true
    else
        warn("❌ Falha na verificação:", data.error or "Erro desconhecido")
        return false, data.error
    end
end

-- Executar verificação
local valid, err = verifyKey()

if valid then
    print("🚀 Autenticação bem-sucedida!")
    print("Executando script principal...")
    
    -- Coloque aqui sua loadstring principal:
    print("Script principal executado!")
    
else
    print("⚠️ Falha na autenticação:", err)
    print("Executando script alternativo...")
    
    -- Coloque aqui sua loadstring alternativa:
    print("Script alternativo executado!")
end
