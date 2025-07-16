--[[
    SISTEMA DE AUTENTICAÇÃO COM SYN.REQUEST
    
    Usa syn.request para requisições HTTP GET
    Compatível com executores que suportam syn.request
]]

-- ===============================
-- CONFIGURAÇÃO DA KEY
-- ===============================
getgenv().KEY = getgenv().KEY or ""

-- Validações iniciais
assert(getgenv().KEY ~= "", "Chave não definida! Defina getgenv().KEY antes de executar.")
assert(gethwid, "Função gethwid() não encontrada no executor")
assert(syn and syn.request, "syn.request não encontrado! Este executor não suporta syn.request")

local KEY = getgenv().KEY
local HWID = gethwid()

local function verifyKey()
    local url = ("https://server-dun-six.vercel.app/api/HWIDCheck?key=%s&hwid=%s"):format(KEY, HWID)
    
    print("🔐 Verificando autenticação com syn.request...")
    print("Key:", KEY)
    print("HWID:", HWID)
    
    local success, response = pcall(function()
        return syn.request({
            Url = url,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    if not success then
        warn("❌ Erro na requisição HTTP:", response)
        return false, "Erro de conexão"
    end
    
    -- Verificar se a requisição foi bem-sucedida
    if response.StatusCode ~= 200 then
        warn("❌ Erro HTTP:", response.StatusCode, response.StatusMessage)
        return false, "Erro HTTP: " .. response.StatusCode
    end
    
    local data = nil
    local ok, err = pcall(function()
        data = game:GetService("HttpService"):JSONDecode(response.Body)
    end)
    
    if not ok then
        warn("❌ Erro ao decodificar JSON:", err)
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

-- ===============================
-- EXECUÇÃO PRINCIPAL
-- ===============================
local valid, err = verifyKey()

if valid then
    print("🚀 Autenticação bem-sucedida!")
    print("Executando script principal...")
    
    -- ===============================
    -- SEU SCRIPT PRINCIPAL AQUI
    -- ===============================
    
    -- Exemplo de uso
    print("✨ Script premium executado com sucesso!")
    
    -- Aqui você pode colocar:
    -- loadstring(game:HttpGet("https://raw.githubusercontent.com/seu-repo/script.lua"))()
    
else
    print("⚠️ Falha na autenticação:", err)
    print("Executando script alternativo...")
    
    -- ===============================
    -- SCRIPT ALTERNATIVO (OPCIONAL)
    -- ===============================
    
    print("💡 Executando versão gratuita...")
    print("Para acessar recursos premium, entre em contato para obter uma key válida.")
end
