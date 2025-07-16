--[[
    SISTEMA DE AUTENTICAÇÃO SIMPLES COM JSONBIN.IO
    
    Compatible com Synapse X, ScriptWare, Krnl, etc.
    Suporta syn.request, http.request, request
    Verificação apenas por KEY (sem HWID)
]]

-- ===============================
-- CONFIGURAÇÃO
-- ===============================
getgenv().KEY = getgenv().KEY or ""

if getgenv().KEY == "" then
    warn("❌ Defina getgenv().KEY = 'sua_chave' primeiro!")
    warn("💡 Obtenha sua chave no Discord com /genkey")
    return
end

local KEY = getgenv().KEY

-- Configurações JSONBin.io
local JSONBIN_BIN_ID = "6877254365900461b7a2eb18" -- Substitua pelo seu Bin ID
local JSONBIN_API_KEY = "$2a$10$c3fijGM2Qq0w7OR58Y/RMur8Jtr9MtM/zyEcdJ/HBWVzsD2BqA1mm" -- Substitua pela sua API Key
local JSONBIN_URL = "https://api.jsonbin.io/v3/b/" .. JSONBIN_BIN_ID

-- ===============================
-- DETECÇÃO DE EXECUTOR
-- ===============================
local requestFunction = nil
local executor = "Unknown"

-- Tentar detectar o executor e função de request
if syn and syn.request then
    requestFunction = syn.request
    executor = "Synapse X"
elseif request then
    requestFunction = request
    executor = "Krnl/Delta"
elseif http_request then
    requestFunction = http_request
    executor = "ScriptWare"
elseif game:GetService("HttpService").RequestAsync then
    requestFunction = function(options)
        return game:GetService("HttpService"):RequestAsync(options)
    end
    executor = "Roblox HttpService"
else
    warn("❌ Executor não suportado ou função de request não encontrada!")
    return
end

print("🔧 Executor detectado:", executor)

-- ===============================
-- FUNÇÃO DE REQUEST UNIVERSAL
-- ===============================
local function makeRequest(method, url, headers, body)
    local options = {
        Url = url,
        Method = method,
        Headers = headers or {},
        Body = body
    }
    
    local success, response = pcall(requestFunction, options)
    
    if not success then
        warn("❌ Erro na requisição:", response)
        return nil
    end
    
    return response
end

-- ===============================
-- FUNÇÕES JSONBIN.IO
-- ===============================
local function getWhitelistFromJSONBin()
    print("🔍 Buscando whitelist do JSONBin.io...")
    
    local headers = {
        ["X-Master-Key"] = JSONBIN_API_KEY,
        ["Content-Type"] = "application/json"
    }
    
    local response = makeRequest("GET", JSONBIN_URL, headers)
    
    if not response then
        warn("❌ Falha ao conectar com JSONBin.io")
        return nil
    end
    
    if response.StatusCode ~= 200 then
        warn("❌ Erro JSONBin.io:", response.StatusCode, response.Body)
        return nil
    end
    
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response.Body)
    end)
    
    if not success then
        warn("❌ Erro ao decodificar JSON:", data)
        return nil
    end
    
    return data.record or {}
end

local function updateKeyUsage(whitelist, key)
    print("📤 Atualizando último uso da key...")
    
    -- Atualizar último uso
    if whitelist[key] then
        whitelist[key].lastUsed = os.date("!%Y-%m-%dT%H:%M:%SZ")
    end
    
    local headers = {
        ["X-Master-Key"] = JSONBIN_API_KEY,
        ["Content-Type"] = "application/json"
    }
    
    local body = game:GetService("HttpService"):JSONEncode(whitelist)
    local response = makeRequest("PUT", JSONBIN_URL, headers, body)
    
    if not response then
        warn("❌ Falha ao atualizar JSONBin.io")
        return false
    end
    
    if response.StatusCode ~= 200 then
        warn("❌ Erro ao atualizar JSONBin.io:", response.StatusCode, response.Body)
        return false
    end
    
    print("✅ Último uso atualizado com sucesso!")
    return true
end

-- ===============================
-- VERIFICAÇÃO DE CHAVE
-- ===============================
local function verifyKey()
    print("🔐 Verificando chave:", KEY)
    
    -- Buscar whitelist
    local whitelist = getWhitelistFromJSONBin()
    if not whitelist then
        warn("❌ Não foi possível acessar a whitelist")
        return false
    end
    
    -- Verificar se a chave existe
    if not whitelist[KEY] then
        warn("❌ Chave inválida ou não encontrada")
        return false
    end
    
    local keyData = whitelist[KEY]
    
    -- Verificar se a chave está ativa
    if keyData.active == false then
        warn("❌ Chave desativada")
        return false
    end
    
    print("✅ Chave válida e ativa!")
    print("📅 Criada em:", keyData.createdAt or "Desconhecido")
    print("🕒 Último uso:", keyData.lastUsed or "Nunca")
    
    -- Atualizar último uso
    updateKeyUsage(whitelist, KEY)
    
    return true
end

-- ===============================
-- SISTEMA DE FALLBACK
-- ===============================
local function fallbackVerification()
    print("🔄 Tentando verificação de fallback...")
    
    -- Lista de chaves de teste (remover em produção)
    local testKeys = {
        "test123",
        "demo456",
        "free789"
    }
    
    for _, testKey in ipairs(testKeys) do
        if KEY == testKey then
            print("✅ Chave de teste válida (modo fallback)")
            return true
        end
    end
    
    return false
end

-- ===============================
-- VERIFICAÇÃO OFFLINE
-- ===============================
local function offlineVerification()
    print("🔄 Verificação offline...")
    
    -- Lista de chaves offline válidas
    local offlineKeys = {
        "offline123",
        "local456",
        "backup789"
    }
    
    for _, offlineKey in ipairs(offlineKeys) do
        if KEY == offlineKey then
            print("✅ Chave offline válida")
            return true
        end
    end
    
    return false
end

-- ===============================
-- EXECUÇÃO PRINCIPAL
-- ===============================
print("🚀 Sistema de Autenticação JSONBin.io")
print("🔧 Executor:", executor)
print("🔑 Chave:", KEY)
print()

local isAuthenticated = verifyKey()

-- Tentar fallback se a verificação principal falhar
if not isAuthenticated then
    print("⚠️ Verificação principal falhou, tentando fallback...")
    isAuthenticated = fallbackVerification()
end

-- Tentar verificação offline se ainda não conseguiu
if not isAuthenticated then
    print("⚠️ Tentando verificação offline...")
    isAuthenticated = offlineVerification()
end

if isAuthenticated then
    print()
    print("🎉 ===============================")
    print("🎉 ACESSO AUTORIZADO!")
    print("🎉 ===============================")
    print()
    
    -- SEU SCRIPT PRINCIPAL AQUI
    print("✨ Carregando script principal...")
    
    -- Exemplo de script
    local player = game:GetService("Players").LocalPlayer
    if player then
        print("👋 Bem-vindo,", player.Name)
        print("🎮 Jogo:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    end
    
    -- Aqui você pode carregar seu script principal
    
    
    print("🚀 Script executado com sucesso!")
    
else
    print()
    print("❌ ===============================")
    print("❌ ACESSO NEGADO!")
    print("❌ ===============================")
    print()
    print("💡 Soluções possíveis:")
    print("1. Verifique se a chave está correta")
    print("2. Obtenha uma nova chave com /genkey no Discord")
    print("3. Verifique se sua chave não foi desativada")
    print("4. Verifique sua conexão com internet")
    print()
    print("🔗 Entre no Discord para obter suporte")
    print()
    print("⚠️ Executando versão limitada...")
    
    -- Script gratuito/limitado
    print("Use o loader free ou delete sua key e gere outra. Se mesmo assim não funcionar, reporte ao @sirgato._ no servidor do discord.")
    
end

-- ===============================
-- INFORMAÇÕES ADICIONAIS
-- ===============================
print()
print("📊 Informações do sistema:")
print("• Executor:", executor)
print("• Jogo:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("• Jogador:", game:GetService("Players").LocalPlayer.Name)
print("• Data:", os.date("%d/%m/%Y %H:%M:%S"))
print("• Status:", isAuthenticated and "✅ Autenticado" or "❌ Não autenticado")
