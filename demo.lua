local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/millicas/champagne/refs/heads/main/loader/init.lua"))()
local Window = Library:Window({
    Name = "Champagne",
    Subtitle = "Every feature, in one demo.",
    Version = "",
    Size = UDim2.fromOffset(780, 520),
})
local MainTab = Window:Tab({ Name = "Main" })
local GeneralSection = MainTab:Section({ Name = "General" })
Library.Label(GeneralSection, {
    Name = "Welcome to the Champagne demo — toggle, slide, and click away.",
})
GeneralSection:Toggle({
    Name = "Enabled",
    Flag = "Enabled",
    Default = true,
    Callback = function(value)
        print("Enabled set to:", value)
    end,
})
GeneralSection:Slider({
    Name = "Speed",
    Flag = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Decimal = 0,
    Suffix = "%",
    Callback = function(value)
        print("Speed set to:", value)
    end,
})
GeneralSection:Slider({
    Name = "Field of View",
    Flag = "FOV",
    Min = 70,
    Max = 120,
    Default = 90,
    Decimal = 1,
    Suffix = "°",
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end,
})
local ActionsSection = MainTab:Section({ Name = "Actions" })
ActionsSection:Button({
    Name = "Launch",
    Primary = true,
    Callback = function()
        print("Launch pressed!")
    end,
})
ActionsSection:Button({
    Name = "Reset Settings",
    Callback = function()
        print("Settings reset!")
    end,
})
ActionsSection:Button({
    Name = "Show Notification",
    Callback = function()
        Library:Notify({
            Title = "Champagne",
            Content = "Settings saved successfully.",
            Duration = 4,
        })
    end,
})
local PlayerTab = Window:Tab({ Name = "Player" })
local StatsSection = PlayerTab:Section({ Name = "Stats" })
StatsSection:Slider({
    Name = "Walk Speed",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end,
})
StatsSection:Slider({
    Name = "Jump Power",
    Flag = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = value
        end
    end,
})
StatsSection:Toggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump",
    Default = false,
    Callback = function(value)
        print("Infinite Jump:", value)
    end,
})
local IdentitySection = PlayerTab:Section({ Name = "Identity" })
IdentitySection:Textbox({
    Name = "Display Name",
    Flag = "DisplayName",
    Default = "",
    PlaceHolder = "Enter a name...",
    Callback = function(value)
        print("Display name set to:", value)
    end,
})
IdentitySection:Keybind({
    Name = "Toggle Menu",
    Flag = "MenuKeybind",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        -- Hides/shows the GUI (doesn't destroy it, unlike the Close button)
        Window:ToggleVisibility()
    end,
})
local SettingsTab = Window:Tab({ Name = "Settings" })
local ConfigSection = SettingsTab:Section({ Name = "Configuration" })
ConfigSection:Textbox({
    Name = "Webhook URL",
    Flag = "Webhook",
    Default = "",
    PlaceHolder = "https://...",
    Callback = function(value)
        print("Webhook set to:", value)
    end,
})
ConfigSection:Toggle({
    Name = "Auto Save",
    Flag = "AutoSave",
    Default = true,
    Callback = function(value)
        print("Auto Save:", value)
    end,
})
ConfigSection:Keybind({
    Name = "Panic Key",
    Flag = "PanicKey",
    Default = Enum.KeyCode.End,
    Callback = function(key)
        print("Panic key set to:", key.Name)
    end,
})
local DangerSection = SettingsTab:Section({ Name = "Danger Zone" })
Library.Label(DangerSection, {
    Name = "This will close the interface completely.",
})
DangerSection:Button({
    Name = "Unload Champagne",
    Callback = function()
        Library:Unload()
    end,
})
return Window
