local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    BoxColor = Color3.fromRGB(0, 255, 255),
    ModuleColor = Color3.fromRGB(255, 165, 0),
    MaxDistance = 2500,
    UpdateInterval = 0.1
}

local trackedTanks = {}

local function createHighlight(targetModel, color)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = targetModel
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0.2
    highlight.Parent = targetModel
    return highlight
end

local function scanAndTagTanks()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("tank") or obj.Name:lower():find("vehicle")) then
            if not trackedTanks[obj] and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Body")) then
                local isLocalTeam = false
                if obj:FindFirstChild("Team") and LocalPlayer.Team and obj.Team.Value == LocalPlayer.Team then
                    isLocalTeam = true
                end

                if not isLocalTeam then
                    trackedTanks[obj] = {
                        MainHighlight = createHighlight(obj, CONFIG.BoxColor),
                        Modules = {}
                    }

                    for _, part in ipairs(obj:GetChildren()) do
                        local pName = part.Name:lower()
                        if pName:find("turret") or pName:find("engine") or pName:find("track") or pName:find("canon") then
                            trackedTanks[obj].Modules[part] = createHighlight(part, CONFIG.ModuleColor)
                        end
                    end
                end
            end
        end
    end

    for model, data in pairs(trackedTanks) do
        if not model or not model.Parent then
            if data.MainHighlight then data.MainHighlight:Destroy() end
            for _, modHighlight in pairs(data.Modules) do
                modHighlight:Destroy()
            end
            trackedTanks[model] = nil
        end
    end
end

local lastUpdate = 0
RunService.Heartbeat:Connect(function(dt)
    lastUpdate = lastUpdate + dt
    if lastUpdate >= CONFIG.UpdateInterval then
        lastUpdate = 0
        pcall(scanAndTagTanks)
    end
end)
