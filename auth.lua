--[[
    SISTEMA DE AUTENTICAÇÃO - COMPATIBILIDADE UNIVERSAL
    
    Detecta automaticamente o melhor método HTTP disponível
    Fallback automático se syn.request for bloqueado
]]

-- ===============================
-- CONFIGURAÇÃO DA KEY
-- ===============================
getgenv().KEY = getgenv().KEY or ""

-- Validações iniciais
assert(getgenv().KEY ~= "", "Chave não definida! Defina getgenv().KEY antes de executar.")
assert(gethwid, "Função gethwid() não encontrada no executor")

local KEY = getgenv().KEY
local HWID = gethwid()
local HttpService = game:GetService("HttpService")

-- ===============================
-- FUNÇÃO COM syn.request
-- ===============================
local function requestWithSyn(url)
    if not (syn and syn.request) then
        return false, "syn.request não disponível"
    end
    
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
        return false, "syn.request bloqueado: " .. tostring(response)
    end
    
    if response.StatusCode ~= 200 then
        return false, "HTTP erro: " .. response.StatusCode
    end
    
    return true, response.Body
end

-- ===============================
-- FUNÇÃO COM HttpService
-- ===============================
local function requestWithHttpService(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    
    if not success then
        return false, "HttpService erro: " .. tostring(response)
    end
    
    return true, response
end

-- ===============================
-- FUNÇÃO UNIVERSAL (DETECTA AUTOMATICAMENTE)
-- ===============================
local function makeRequest(url)
    print("🔄 Detectando método HTTP disponível...")
    
    -- Tentar syn.request primeiro (se disponível)
    local synSuccess, synResponse = requestWithSyn(url)
    if synSuccess then
        print("✅ Usando syn.request")
        return true, synResponse
    else
        print("⚠️ syn.request falhou:", synResponse)
    end
    
    -- Fallback para HttpService
    print("🔄 Tentando HttpService como fallback...")
    local httpSuccess, httpResponse = requestWithHttpService(url)
    if httpSuccess then
        print("✅ Usando HttpService")
        return true, httpResponse
    else
        print("❌ HttpService falhou:", httpResponse)
    end
    
    return false, "Nenhum método HTTP funcionou"
end

-- ===============================
-- FUNÇÃO PRINCIPAL DE VERIFICAÇÃO
-- ===============================
local function verifyKey()
    local url = ("https://server-dun-six.vercel.app/api/HWIDCheck?key=%s&hwid=%s"):format(KEY, HWID)
    
    print("🔐 Verificando autenticação...")
    print("Key:", KEY)
    print("HWID:", HWID)
    
    local success, responseBody = makeRequest(url)
    
    if not success then
        warn("❌ Erro na requisição:", responseBody)
        return false, "Erro de conexão"
    end
    
    local data = nil
    local ok, err = pcall(function()
        data = HttpService:JSONDecode(responseBody)
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
    
    print("✨ Script premium executado com sucesso!")
    
    -- Exemplo de loadstring:
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
