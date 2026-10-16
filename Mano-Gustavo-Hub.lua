-- Mano Gustavo Hub | RetroBox API 2 com atualizações estáveis automáticas
-- Edite CONFIG. A interface e o carregador ficam prontos abaixo.
-- A RetroBox carrega por HTTP; nenhum arquivo local dela é necessário.

-- INICIO DA CONFIGURACAO
local CONFIG = {
    Name = "Mano Gustavo Hub",
    Author = "Mano Gustavo",
    Version = "1.0.0",
    Subtitle = "Teus jogos, teus scripts, teu hub.",
    Theme = "Hacker",
    -- Outros temas: Retro98, Terminal, GameBoy, Paper, Midnight, Monokai,
    -- Dracula, Nord, Sakura, Ocean e Amber.
    ShowDemo = false, -- Troque para false quando terminar teu catálogo.
    Preferences = {
        Profile = "preferencias",
        Folder = "ManoGustavoHub",
        AutoLoad = true,
        AutoSave = true,
    },

    Games = {
        {
            Id = "jogo-1", -- ID interno único. Mantenha estável nos updates.
            Name = "Mushyo",
            Description = "Esse jogo possui alguns script gulosos",
            PlaceId = 17274762379,
            UniverseId = 5909935640, -- ID da experiência; diferente de PlaceId.
            Image = nil, -- Opcional: "rbxassetid://123". Sem isso, usa os IDs.
            Scripts = {
                {
                    Id = "mushyoscript1",
                    Title = "Mushyo Hub",
                    Description = "Auto fish e muito mais!",
                    Version = "1.5.0",
                    Enabled = true,
                    CurrentGameOnly = false, -- true exige um ID que corresponda à sessão.
                    URL = "https://raw.githubusercontent.com/ManoGustavo0/muchyohub/refs/heads/main/mushyohub.lua", -- Ex.: https://raw.githubusercontent.com/USUARIO/REPO/main/script.lua
                    Callback = nil, -- Ou: function(ctx, hub) ...teu código... end
                    -- Use URL OU Callback. Deixe o outro vazio.
                    -- Confirm = "Executar este script?", -- Opcional.
                },
            },
        },
        {
            Id = "jogo-2",
            Name = "Guerra Naval",
            Description = "Esse jogo possui alguns scripts de automação",
            PlaceId = 113987393426315,
            UniverseId = nil,
            Image = nil,
            Scripts = {
                {
                    Id = "GuerraNavalScript1",
                    Title = "Guerra Naval Hub",
                    Description = "Auto collect e Auto venda.",
                    URL = "https://raw.githubusercontent.com/ManoGustavo0/GuerraNavalRetro/refs/heads/main/GuerraNavalRetro.lua",
                    Callback = nil,
                },
            },
        },
        {
            Id = "jogo-3",
            Name = "Cães",
            Description = "Esses jogo possui alguns scripts de silent aim e muito mais.",
            PlaceId = 94009908234110,
            UniverseId = nil,
            Image = nil,
            Scripts = {
                {
                    Id = "CaesScript1", -- ID interno sem acento; Title mantém o nome Cães.
                    Title = "Cães Hub",
                    Description = "Esse script tem silent aim, stamina infinita e muito mais!",
                    URL = "https://raw.githubusercontent.com/ManoGustavo0/C-es/refs/heads/main/c%C3%A3es.lua",
                    Callback = nil,
                },
            },
        },
        {
            Id = "jogo-4",
            Name = "Defesa de Gatos",
            Description = "Esse jogo possui alguns scripts de auto fire, auto mira e muito mais.",
            PlaceId = 118535152903705,
            UniverseId = nil,
            Image = nil,
            Scripts = {
                {
                    Id = "DefesadeGatos1",
                    Title = "Defesa de Gatos Hub",
                    Description = "Esse script tem auto mira, auto fire, auto re-load e muito mais!",
                    URL = "https://raw.githubusercontent.com/ManoGustavo0/Defesa-de-Gatos/refs/heads/main/DefesadeGatos.lua",
                    Callback = nil,
                },
            },
        },
        {
            Id = "jogo-5",
            Name = "Dandy's World",
            Description = "Esse jogo possui alguns scripts de auto minigame, infinita stamina e muito mais.",
            PlaceId = 16116270224,
            UniverseId = nil,
            Image = nil,
            Scripts = {
                {
                    Id = "DandysWorld1",
                    Title = "Dandy's World Hub",
                    Description = "Esse script tem esp para players, monstros e itens, auto minigame e muito mais",
                    URL = "https://raw.githubusercontent.com/ManoGustavo0/Dandy-s-World/refs/heads/main/DandyRetro.lua",
                    Callback = nil,
                },
            },
        },
        {
            Id = "jogo-6",
            Name = "Commander Tycoon",
            Description = "Esse jogo possui alguns scripts de auto bandeira, auto bump e auto upgrade",
            PlaceId = 119263815547952,
            UniverseId = nil,
            Image = nil,
            Scripts = {
                {
                    Id = "CommanderTycoon1",
                    Title = "Commander Tycoon Hub",
                    Description = "Esse script tem auto bandeira, auto óleo, auto upgrade e auto promoção",
                    URL = "https://raw.githubusercontent.com/ManoGustavo0/ComandanteTycoon/refs/heads/main/ComandanteTycoonRetro.lua",
                    Callback = nil,
                },
            },
        },
    },
}
-- FIM DA CONFIGURACAO

-- MOTOR DO HUB: nao precisa editar para cadastrar jogos e scripts.
local RETROBOX_LOADER_URL = "https://raw.githubusercontent.com/ManoGustavo0/RetroBox/main/dist/bootstrap/v2.lua"

local function fail(message)
    error("[Mano Gustavo Hub] " .. tostring(message), 0)
end

local function loadRetroBox()
    if type(loadstring) ~= "function" then
        fail("O ambiente precisa disponibilizar loadstring para carregar a RetroBox.")
    end
    local ok, source = pcall(function() return game:HttpGet(RETROBOX_LOADER_URL) end)
    if not ok then fail("Não foi possível baixar a RetroBox: " .. tostring(source)) end
    if type(source) ~= "string" or source == "" then fail("O raw da RetroBox retornou vazio.") end
    local chunk, reason = loadstring(source, "@RetroBox-bootstrap-v2")
    if not chunk then fail("Não foi possível compilar a RetroBox: " .. tostring(reason)) end
    local loaded, library = pcall(chunk, {Channel = "stable"})
    if not loaded then fail("Não foi possível iniciar a RetroBox: " .. tostring(library)) end
    if type(library) ~= "table" or library.APIVersion ~= 2
        or type(library.CreateScriptHub) ~= "function" then
        fail("O carregador esperava uma RetroBox compatível com a API 2 e Script Hub.")
    end
    return library
end

local issues = {}
local configuredScripts = 0
local function makeScript(entry, gameId)
    local where = tostring(gameId) .. " / " .. tostring(entry.Id)
    local callback, url, problem = entry.Callback, entry.URL, nil
    if url == nil then url = "" end
    if type(url) ~= "string" then
        problem = "URL precisa ser um texto."
    else
        url = url:match("^%s*(.-)%s*$")
        if url ~= "" and not url:match("^https://[^%s]+$") then
            problem = "Use um link raw completo começando com https://."
        end
    end
    if callback ~= nil and type(callback) ~= "function" then
        problem = "Callback precisa ser uma função."
    elseif callback ~= nil and url ~= "" then
        problem = "Preencha apenas URL ou Callback."
    end
    if not problem and callback == nil and url == "" then
        problem = "Preencha URL ou Callback para liberar o Play."
    end

    local requires = {}
    for _, capability in ipairs(entry.Requires or {}) do requires[#requires + 1] = capability end
    if problem then
        issues[#issues + 1] = where .. ": " .. problem
        callback = nil
    elseif url ~= "" then
        requires[#requires + 1] = "HttpGet"
        requires[#requires + 1] = "loadstring"
        -- O link é definido pelo dono do hub. Só é baixado ao pressionar Play.
        callback = function(ctx)
            ctx:ThrowIfCancelled()
            ctx:SetProgress(0, 2, "Baixando o script...")
            local ok, source = pcall(function() return game:HttpGet(url) end)
            ctx:ThrowIfCancelled()
            if not ok then return false, "Falha ao baixar " .. entry.Title .. ": " .. tostring(source) end
            if type(source) ~= "string" or source == "" then return false, "O link retornou um script vazio." end
            local chunk, reason = loadstring(source, "@" .. gameId .. "/" .. entry.Id)
            if not chunk then return false, "Erro de sintaxe no script: " .. tostring(reason) end
            ctx:SetProgress(1, 2, "Executando o script...")
            ctx:ThrowIfCancelled()
            local result, detail = chunk()
            ctx:ThrowIfCancelled()
            if result == false then return false, detail or "O script informou uma falha." end
            ctx:SetProgress(2, 2, "Execução concluída.")
            return result, detail
        end
    end
    if callback then configuredScripts = configuredScripts + 1 end
    return {
        Id = entry.Id,
        Title = entry.Title,
        Description = entry.Description or "",
        Icon = entry.Icon or "code",
        Author = entry.Author or CONFIG.Author,
        Version = entry.Version or "1.0.0",
        Status = problem or entry.Status or "Pronto",
        Enabled = entry.Enabled,
        CurrentGameOnly = entry.CurrentGameOnly,
        Confirm = entry.Confirm,
        Requires = requires,
        Callback = callback,
    }
end

local catalog = {}
for index, entry in ipairs(CONFIG.Games) do
    local scripts = {}
    for _, script in ipairs(entry.Scripts or {}) do scripts[#scripts + 1] = makeScript(script, entry.Id) end
    catalog[#catalog + 1] = {
        Id = entry.Id, Name = entry.Name, Description = entry.Description or "",
        PlaceId = entry.PlaceId, UniverseId = entry.UniverseId, Image = entry.Image,
        Order = entry.Order or index, Scripts = scripts,
    }
end

if CONFIG.ShowDemo then
    catalog[#catalog + 1] = {
        Id = "demo-current-session",
        Name = "Demonstração · jogo atual",
        Description = "Teste do hub. Desative ShowDemo na configuração quando teu catálogo estiver pronto.",
        PlaceId = game.PlaceId > 0 and game.PlaceId or nil,
        UniverseId = game.GameId > 0 and game.GameId or nil,
        Order = 1000000,
        Scripts = {{
            Id = "testar-hub", Title = "Testar o hub", Icon = "info",
            Author = CONFIG.Author, Version = CONFIG.Version,
            Description = "Mostra uma notificação para testar o Play e o retorno da execução.",
            Callback = function(ctx, activeHub)
                ctx:ThrowIfCancelled()
                activeHub.Window:Notify({Title = CONFIG.Name, Content = "Tudo pronto! Agora é só cadastrar teus jogos e scripts.", Kind = "success"})
                return true
            end,
        }},
    }
end

local RetroBox = loadRetroBox()
local hub = RetroBox:CreateScriptHub({
    Id = "mano-gustavo-hub", HubId = "catalogo",
    Title = CONFIG.Name, Subtitle = CONFIG.Subtitle .. " · v" .. CONFIG.Version,
    Theme = CONFIG.Theme, Locale = "pt-BR", Icon = "gamepad",
    Size = Vector2.new(920, 650), ToggleKey = Enum.KeyCode.RightShift,
    Launcher = true, LauncherText = "MGH", Settings = true, ShowProfile = true,
    PixelIcons = true, PixelDecorations = true, SmoothDragging = true,
    DestroyOnClose = false, ConfigFolder = CONFIG.Preferences.Folder,
    AutoDetectGame = true, ConfirmTeleport = true,
    Games = catalog,
})
local window = hub.Window
hub.Tab:SetTitle("Jogos & Scripts")

local function notify(kind, title, content)
    window:Notify({Title = title, Content = tostring(content), Kind = kind, Duration = 5})
end

local function savePreferences()
    local ok, reason = window:SaveConfig(CONFIG.Preferences.Profile)
    notify(ok and "success" or "error", "Preferências", ok and "Preferências salvas." or reason)
    return ok, reason
end

local function loadPreferences()
    local ok, reason = window:LoadConfig(CONFIG.Preferences.Profile, {Silent = true})
    notify(ok and "success" or "error", "Preferências", ok and "Preferências restauradas." or reason)
    return ok, reason
end

local tools = window:CreateTab({Title = "Ferramentas", Icon = "settings", Columns = 2})
local session = tools:CreateSection({Title = "Jogo atual", Icon = "gamepad"})
session:AddLabel({Title = "IDs desta sessão", Height = 74,
    Description = "PlaceId: " .. tostring(game.PlaceId) .. "\nUniverseId (game.GameId): " .. tostring(game.GameId)})
session:AddButton({Id = "mgh/copy-ids", Title = "Copiar IDs do jogo", Icon = "copy", Disabled = type(setclipboard) ~= "function",
    Description = "Cole estes valores no cadastro do jogo.",
    Callback = function()
        if type(setclipboard) ~= "function" then return false, "O ambiente não oferece setclipboard." end
        local ok, reason = pcall(setclipboard, "PlaceId = " .. tostring(game.PlaceId) .. ",\nUniverseId = " .. tostring(game.GameId) .. ",")
        notify(ok and "success" or "error", "IDs do jogo", ok and "IDs copiados." or reason)
        return ok, reason
    end})
session:AddButton({Id = "mgh/current-game", Title = "Selecionar o jogo atual", Icon = "gamepad",
    Callback = function()
        local id = hub:DetectCurrentGame()
        if not id then notify("normal", "Jogo atual", "Este jogo ainda não está no catálogo. Cadastre o PlaceId ou UniverseId."); return end
        hub:SelectGame(id); hub:Show()
    end})

local preferences = tools:CreateSection({Title = "Preferências", Icon = "save"})
preferences:AddLabel({Title = "Favoritos, tema e organização", Height = 82,
    Description = window.StorageMode == "file"
        and "As preferências podem ser salvas entre sessões neste executor. Perfil: " .. CONFIG.Preferences.Profile
        or "Este ambiente usa memória: os saves duram enquanto esta janela existir. Perfil: " .. CONFIG.Preferences.Profile})
preferences:AddButton({Id = "mgh/save-preferences", Title = "Salvar preferências", Icon = "save", Callback = savePreferences})
preferences:AddButton({Id = "mgh/load-preferences", Title = "Carregar preferências", Icon = "folder", Callback = loadPreferences})

local appearance = tools:CreateSection({Title = "Personalização", Icon = "palette", Side = "Right"})
appearance:AddButton({Id = "mgh/settings", Title = "Abrir configurações", Icon = "settings",
    Description = "Temas, escala, animações, atalhos e perfis.", Callback = function() window:ShowSettings(true) end})
appearance:AddButton({Id = "mgh/theme-studio", Title = "Personalizar um tema", Icon = "palette",
    Callback = function() window:OpenThemeStudio() end})
appearance:AddButton({Id = "mgh/commands", Title = "Abrir atalhos · F4", Icon = "bolt",
    Callback = function() window:OpenCommandPalette() end})

local controls = tools:CreateSection({Title = "Janela", Icon = "home", Side = "Right"})
controls:AddLabel({Title = "RightShift abre ou oculta", Height = 64,
    Description = "No celular, use o botão MGH para reabrir a janela."})
controls:AddButton({Id = "mgh/center", Title = "Centralizar janela", Callback = function() window:Center() end})
controls:AddButton({Id = "mgh/hide", Title = "Ocultar hub", Callback = function() hub:Hide() end})

local help = window:CreateTab({Title = "Ajuda", Icon = "info", Columns = 1})
local start = help:CreateSection({Title = "Como preencher teu hub", Icon = "code"})
start:AddLabel({Title = "1. Cadastre os jogos em CONFIG.Games", Height = 82,
    Description = "Edite Name, Description, PlaceId e UniverseId. Duplique um bloco para adicionar outro jogo e escolha um Id diferente."})
start:AddLabel({Title = "2. Preencha Scripts dentro de cada jogo", Height = 82,
    Description = "Edite Title e Description. Use URL para um link raw HTTPS ou Callback para teu código dentro de uma função. Use somente uma dessas opções."})
start:AddLabel({Title = "3. Teste o Play e finalize o catálogo", Height = 82,
    Description = "Os exemplos vazios ficam indisponíveis até serem preenchidos. Quando terminar, troque ShowDemo para false e execute o arquivo novamente."})

local about = help:CreateSection({Title = "Sobre", Icon = "info"})
about:AddLabel({Title = CONFIG.Name .. " · v" .. CONFIG.Version, Height = 98,
    Description = "Criado por " .. CONFIG.Author .. " com RetroBox " .. RetroBox.Version .. ".\n"
        .. #CONFIG.Games .. " jogos cadastrados · " .. configuredScripts .. " scripts configurados.\nPesquisar e selecionar não executa scripts; use Play."})
if #issues > 0 then
    about:AddLabel({Title = "Cadastro pendente · " .. #issues .. " scripts", Height = 122,
        Description = "Há entradas sem código ou com configuração inválida.\nConsulte Status no catálogo e preencha URL ou Callback no início do arquivo."})
end

-- O catálogo está completo antes de restaurar os favoritos e a seleção.
if CONFIG.Preferences.AutoLoad then
    local names, reason = window:GetConfigNames()
    if reason then
        notify("error", "Preferências", reason)
    elseif table.find(names, CONFIG.Preferences.Profile) then
        local ok, loadReason = window:LoadConfig(CONFIG.Preferences.Profile, {Silent = true})
        if not ok then notify("error", "Preferências", loadReason) end
    end
end
-- Evita salvar os valores iniciais antes de terminar a restauração.
if CONFIG.Preferences.AutoSave then window.AutoSave = CONFIG.Preferences.Profile end

hub:Show()
notify("normal", CONFIG.Name, "Hub pronto. Teus jogos ficam em Jogos & Scripts; o cadastro fica em CONFIG.Games.")
return hub
