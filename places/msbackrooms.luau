type ESP = {
    Color: Color3,
    IsEntity: boolean,
    IsDoubleDoor: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}
local Script = {
    Binded = {},
    Connections = {},
    FeatureConnections = {
        Clip = {},
        Door = {},
        Player = {},
    },
    ESPTable = {
        Chest = {},
        Door = {},
        Entity = {},
        SideEntity = {},
        Gold = {},
        Guiding = {},
        Item = {},
        Objective = {},
        Player = {},
        HidingSpot = {},
        None = {}
    },
    Functions = {
    },
    Temp = {
        
    }
}

local repo = 'https://raw.githubusercontent.com/deividcomsono/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = getgenv().Linoria.Options
local Toggles = getgenv().Linoria.Toggles
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/MS-ESP/refs/heads/main/source.lua"))()

local ChestsTable = {"Crate","Medical Box","Metal cabinet","Ammo Box"}
local EntitiesTable = {"Duller","Howler","Melee Raider","DamageBox","Bacteria","Bone Thief","EnragedFemaleDeathMoth","SkinStealer","Smiler","SmilerSpider","Stalker"}

local Players = game:GetService("Players")
function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        IsDoubleDoor = args.IsDoubleDoor or false,
        Type = args.Type or "None",

        Invisible = false,
        Humanoid = nil
    }

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
        if ESPManager.Object.PrimaryPart.Transparency == 1 then
            ESPManager.Invisible = true
            ESPManager.Object.PrimaryPart.Transparency = 0.99
        end

        local humanoid = ESPManager.Object:FindFirstChildOfClass("Humanoid")
        if not humanoid then humanoid = Instance.new("Humanoid", ESPManager.Object) end
        ESPManager.Humanoid = humanoid
    end

    local highlight = ESPLibrary.ESP.Highlight({
        Name = ESPManager.Text,
        Model = ESPManager.Object,
        StudsOffset = ESPManager.Offset,

        FillColor = ESPManager.Color,
        OutlineColor = ESPManager.Color,
        TextColor = ESPManager.Color,
        TextSize = Options.ESPTextSize.Value or 16,

        Tracer = {
            Enabled = Toggles.ESPTracer.Value,
            From = Options.ESPTracerStart.Value,
            Color = ESPManager.Color
        },

        OnDestroy = function()
            if ESPManager.Object.PrimaryPart and ESPManager.Invisible then ESPManager.Object.PrimaryPart.Transparency = 1 end
            if ESPManager.Humanoid then ESPManager.Humanoid:Destroy() end
        end
    })

    table.insert(Script.ESPTable[args.Type], highlight)
end
function Script.Functions.ChestESP(chest)
    local locked = chest:GetAttribute("Locked")

    Script.Functions.ESP({
        Type = "Chest",
        Object = chest,
        Text = chest.Name,
        Color = Options.ChestEspColor.Value
    })
end
function Script.Functions.EntityESP(entity)

    Script.Functions.ESP({
        Type = "Entity",
        Object = entity,
        Text = entity.Name,
        Color = Options.EntityEspColor.Value
    })
end
function Script.Functions.PlayerESP(player: Player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerEsp = Script.Functions.ESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%.1f]", player.DisplayName, player.Character.Humanoid.Health),
        TextParent = player.Character.PrimaryPart,
        Color = Options.PlayerEspColor.Value
    })

    player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.Text = string.format("%s [%.1f]", player.DisplayName, newHealth)
        else
            playerEsp.Destroy()
        end
    end)
end
local Window = Library:CreateWindow({
	Title = 'msbackrooms | Da Backrooms | dev build',
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	TabPadding = 8,
	MenuFadeTime = 0
})
local Tabs = {
	Main = Window:AddTab('Main'),
    Visuals = Window:AddTab('Visuals'),
    Levels = Window:AddTab('Levels'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

local ESPTabBox = Tabs.Visuals:AddLeftTabbox() do
    local ESPTab = ESPTabBox:AddTab("ESP") do
        ESPTab:AddToggle("EntityESP", {
            Text = "Entity",
            Default = false,
        }):AddColorPicker("EntityEspColor", {
            Default = Color3.new(1, 0, 0),
        })
        ESPTab:AddToggle("ChestESP", {
            Text = "Chest",
            Default = false,
        }):AddColorPicker("ChestEspColor", {
            Default = Color3.new(1, 1, 0),
        })
    
        ESPTab:AddToggle("PlayerESP", {
            Text = "Player",
            Default = false,
        }):AddColorPicker("PlayerEspColor", {
            Default = Color3.new(1, 1, 1),
        })
    end

    local ESPSettingsTab = ESPTabBox:AddTab("Settings") do
        ESPSettingsTab:AddToggle("ESPHighlight", {
            Text = "Enable Highlight",
            Default = true,
        })

        ESPSettingsTab:AddToggle("ESPTracer", {
            Text = "Enable Tracer",
            Default = true,
        })
    
        ESPSettingsTab:AddToggle("ESPRainbow", {
            Text = "Rainbow ESP",
            Default = false,
        })
    
        ESPSettingsTab:AddToggle("ESPDistance", {
            Text = "Show Distance",
            Default = true,
            Visible = false,
        })
    
        ESPSettingsTab:AddSlider("ESPFillTransparency", {
            Text = "Fill Transparency",
            Default = 0.75,
            Min = 0,
            Max = 1,
            Rounding = 2
        })
    
        ESPSettingsTab:AddSlider("ESPOutlineTransparency", {
            Text = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Rounding = 2
        })
    
        ESPSettingsTab:AddSlider("ESPTextSize", {
            Text = "Text Size",
            Default = 22,
            Min = 16,
            Max = 26,
            Rounding = 0
        })

        ESPSettingsTab:AddDropdown("ESPTracerStart", {
            AllowNull = false,
            Values = {"Bottom", "Center", "Top", "Mouse"},
            Default = "Bottom",
            Multi = false,

            Text = "Tracer Start Position"
        })
    end
end
Toggles.ESPTracer:OnChanged(function(value)
    ESPLibrary.Tracers.Set(value)
end)

Toggles.ChestESP:OnChanged(function(value)
        if value then
            local currentRoomModel = workspace:WaitForChild("Loot")
            if currentRoomModel then
                for _, chest in pairs(currentRoomModel:GetDescendants()) do
                    if table.find(ChestsTable, chest.Name) then
                        Script.Functions.ChestESP(chest)
                    end
                end
            end
        else
            for _, esp in pairs(Script.ESPTable.Chest) do
                esp.Destroy()
            end
        end
end)
Options.ChestEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Chest) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)

Toggles.EntityESP:OnChanged(function(value)
	-- here we get our toggle object & then get its value
        if value then
            local currentRoomModel = workspace:WaitForChild("Monsters")
            if currentRoomModel then
                for _, thing in pairs(currentRoomModel:GetDescendants()) do
                    if table.find(EntitiesTable, thing.Name) then
                        Script.Functions.EntityESP(thing)
                    end
                end
            end
        else
            for _, esp in pairs(Script.ESPTable.Chest) do
                esp.Destroy()
            end
        end
end)
Options.EntityEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Entity) do
        esp.Update({
            FillColor = value,
            OutlineColor = value,
            TextColor = value,
        })
    end
end)
Toggles.PlayerESP:OnChanged(function(value)
    if value then
        for _, player in pairs(Players:GetPlayers()) do
            if player == game.Players.LocalPlayer or not player.Character then continue end
            
            Script.Functions.PlayerESP(player)
        end
    else
        for _, esp in pairs(Script.ESPTable.Player) do
            esp.Destroy()
        end
    end
end)
Options.PlayerEspColor:OnChanged(function(value)
    for _, esp in pairs(Script.ESPTable.Player) do
        esp.SetColor(value)
    end
end)
-- This should print to the console: "My toggle state changed! New value: false"
Toggles.ChestESP:SetValue(false)
Toggles.PlayerESP:SetValue(false)
Toggles.EntityESP:SetValue(false)

-- 1/15/23
-- Deprecated old way of creating buttons in favor of using a table
-- Added DoubleClick button functionality

--[[
	Groupbox:AddButton
	Arguments: {
		Text = string,
		Func = function,
		DoubleClick = boolean
		Tooltip = string,
	}

	You can call :AddButton on a button to add a SubButton!
]]

--[[local MyButton = LeftGroupBox:AddButton({
	Text = 'Button',
	Func = function()
		print('You clicked a button!')
		Library:Notify("This is a notification")
	end,
	DoubleClick = false,
	Tooltip = 'This is the main button'
})

local MyButton2 = MyButton:AddButton({
	Text = 'Sub button',
	Func = function()
		print('You clicked a sub button!')
		Library:Notify("This is a notification with sound", nil, 4590657391)
	end,
	DoubleClick = true, -- You will have to click this button twice to trigger the callback
	Tooltip = 'This is the sub button (double click me!)'
})]]

--[[
	NOTE: You can chain the button methods!
	EXAMPLE:

	LeftGroupBox:AddButton({ Text = 'Kill all', Func = Functions.KillAll, Tooltip = 'This will kill everyone in the game!' })
		:AddButton({ Text = 'Kick all', Func = Functions.KickAll, Tooltip = 'This will kick everyone in the game!' })
]]

-- Groupbox:AddLabel
-- Arguments: Text, DoesWrap
--LeftGroupBox:AddLabel('This is a label')
--LeftGroupBox:AddLabel('This is a label\n\nwhich wraps its text!', true)

-- Groupbox:AddDivider
-- Arguments: None
--LeftGroupBox:AddDivider()

--[[
	Groupbox:AddSlider
	Arguments: Idx, SliderOptions

	SliderOptions: {
		Text = string,
		Default = number,
		Min = number,
		Max = number,
		Suffix = string,
		Rounding = number,
		Compact = boolean,
		HideMax = boolean,
	}

	Text, Default, Min, Max, Rounding must be specified.
	Suffix is optional.
	Rounding is the number of decimal places for precision.

	Compact will hide the title label of the Slider

	HideMax will only display the value instead of the value & max value of the slider
	Compact will do the same thing
]]
--[[LeftGroupBox:AddSlider('MySlider', {
	Text = 'This is my slider!',
	Default = 0,
	Min = 0,
	Max = 5,
	Rounding = 1,
	Compact = false,

	Callback = function(Value)
		print('[cb] MySlider was changed! New value:', Value)
	end
})]]

-- Options is a table added to getgenv() by the library
-- You index Options with the specified index, in this case it is 'MySlider'
-- To get the value of the slider you do slider.Value

--local Number = Options.MySlider.Value
--Options.MySlider:OnChanged(function()
	--print('MySlider was changed! New value:', Options.MySlider.Value)
--end)

-- This should print to the console: "MySlider was changed! New value: 3"
--Options.MySlider:SetValue(3)

-- Groupbox:AddInput
-- Arguments: Idx, Info
--[[LeftGroupBox:AddInput('MyTextbox', {
	Default = 'My textbox!',
	Numeric = false, -- true / false, only allows numbers
	Finished = false, -- true / false, only calls callback when you press enter
	ClearTextOnFocus = true, -- true / false, if false the text will not clear when textbox focused
		
	Text = 'This is a textbox',
	Tooltip = 'This is a tooltip', -- Information shown when you hover over the textbox

	Placeholder = 'Placeholder text', -- placeholder text when the box is empty
	-- MaxLength is also an option which is the max length of the text

	Callback = function(Value)
		print('[cb] Text updated. New text:', Value)
	end
})]]

--Options.MyTextbox:OnChanged(function()
	--print('Text updated. New text:', Options.MyTextbox.Value)
--end)

-- Groupbox:AddDropdown
-- Arguments: Idx, Info

--[[LeftGroupBox:AddDropdown('MyDropdown', {
	Values = { 'This', 'is', 'a', 'dropdown' },
	Default = 1, -- number index of the value / string
	Multi = false, -- true / false, allows multiple choices to be selected

	Text = 'A dropdown',
	Tooltip = 'This is a tooltip', -- Information shown when you hover over the dropdown

	Callback = function(Value)
		print('[cb] Dropdown got changed. New value:', Value)
	end
})]]

--Options.MyDropdown:OnChanged(function()
	--print('Dropdown got changed. New value:', Options.MyDropdown.Value)
--end)

--Options.MyDropdown:SetValue('This')

-- Multi dropdowns
--[[LeftGroupBox:AddDropdown('MyMultiDropdown', {
	-- Default is the numeric index (e.g. "This" would be 1 since it if first in the values list)
	-- Default also accepts a string as well

	-- Currently you can not set multiple values with a dropdown

	Values = { 'This', 'is', 'a', 'dropdown' },
	Default = 1,
	Multi = true, -- true / false, allows multiple choices to be selected

	Text = 'A dropdown',
	Tooltip = 'This is a tooltip', -- Information shown when you hover over the dropdown

	Callback = function(Value)
		print('[cb] Multi dropdown got changed:', Value)
	end
})]]

--[[Options.MyMultiDropdown:OnChanged(function()
	-- print('Dropdown got changed. New value:', )
	print('Multi dropdown got changed:')
	for key, value in next, Options.MyMultiDropdown.Value do
		print(key, value) -- should print something like This, true
	end
end)

Options.MyMultiDropdown:SetValue({
	This = true,
	is = true,
})]]

--[[LeftGroupBox:AddDropdown('MyPlayerDropdown', {
	SpecialType = 'Player',
	Text = 'A player dropdown',
	Tooltip = 'This is a tooltip', -- Information shown when you hover over the dropdown

	Callback = function(Value)
		print('[cb] Player dropdown got changed:', Value)
	end
})]]

-- Label:AddColorPicker
-- Arguments: Idx, Info

-- You can also ColorPicker & KeyPicker to a Toggle as well

--[[LeftGroupBox:AddLabel('Color'):AddColorPicker('ColorPicker', {
	Default = Color3.new(0, 1, 0), -- Bright green
	Title = 'Some color', -- Optional. Allows you to have a custom color picker title (when you open it)
	Transparency = 0, -- Optional. Enables transparency changing for this color picker (leave as nil to disable)

	Callback = function(Value)
		print('[cb] Color changed!', Value)
	end
})]]

--Options.ColorPicker:OnChanged(function()
	--print('Color changed!', Options.ColorPicker.Value)
	--print('Transparency changed!', Options.ColorPicker.Transparency)
--end)

--Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

-- Label:AddKeyPicker
-- Arguments: Idx, Info

--[[LeftGroupBox:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {
	-- SyncToggleState only works with toggles.
	-- It allows you to make a keybind which has its state synced with its parent toggle

	-- Example: Keybind which you use to toggle flyhack, etc.
	-- Changing the toggle disables the keybind state and toggling the keybind switches the toggle state

	Default = 'MB2', -- String as the name of the keybind (MB1, MB2 for mouse buttons)
	SyncToggleState = false,


	-- You can define custom Modes but I have never had a use for it.
	Mode = 'Toggle', -- Modes: Always, Toggle, Hold

	Text = 'Auto lockpick safes', -- Text to display in the keybind menu
	NoUI = false, -- Set to true if you want to hide from the Keybind menu,

	-- Occurs when the keybind is clicked, Value is `true`/`false`
	Callback = function(Value)
		print('[cb] Keybind clicked!', Value)
	end,

	-- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
	ChangedCallback = function(New)
		print('[cb] Keybind changed!', New)
	end
})

-- OnClick is only fired when you press the keybind and the mode is Toggle
-- Otherwise, you will have to use Keybind:GetState()
Options.KeyPicker:OnClick(function()
	print('Keybind clicked!', Options.KeyPicker:GetState())
end)

Options.KeyPicker:OnChanged(function()
	print('Keybind changed!', Options.KeyPicker.Value)
end)]]

--[[task.spawn(function()
	while true do
		wait(1)

		-- example for checking if a keybind is being pressed
		local state = Options.KeyPicker:GetState()
		if state then
			print('KeyPicker is being held down')
		end

		if Library.Unloaded then break end
	end
end)

Options.KeyPicker:SetValue({ 'MB2', 'Toggle' })]] -- Sets keybind to MB2, mode to Hold

-- Long text label to demonstrate UI scrolling behaviour.
local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox('Groupbox #2');
LeftGroupBox2:AddLabel('Oh no...\nThis label spans multiple lines!\n\nWe\'re gonna run out of UI space...\nJust kidding! Scroll down!\n\n\nHello from below!', true)
if game.PlaceId == 10178836156 then
    local LV1TabBox = Tabs.Levels:AddLeftGroupbox('Level 1');
    --local LV1TabBox = Tabs.Main:AddLeftTabbox()
    local CodeButton = LV1TabBox:AddButton({
        Text = 'Reveal Elevator Code',
        Func = function()
            --print('You clicked a sub button!')
            Library:Notify(("The elevator code is : "..game.Workspace.Symbols.TriangleCode.SurfaceGui.TextLabel.Text:gsub('%D+', '')..game.Workspace.Symbols.SquareCode.SurfaceGui.TextLabel.Text:gsub('%D+', '')..game.Workspace.Symbols.PentagonCode.SurfaceGui.TextLabel.Text:gsub('%D+', '')..game.Workspace.Symbols.CircleCode.SurfaceGui.TextLabel.Text:gsub('%D+', '')), nil, 4590657391)
        end,
        DoubleClick = false, -- You will have to click this button twice to trigger the callback
        Tooltip = 'Reveal the elevator code to exit the level.'
    }) 
end
local TabBox = Tabs.Main:AddRightTabbox() -- Add Tabbox on right side

-- Anything we can do in a Groupbox, we can do in a Tabbox tab (AddToggle, AddSlider, AddLabel, etc etc...)
local Tab1 = TabBox:AddTab('Tab 1')
Tab1:AddToggle('Tab1Toggle', { Text = 'Tab1 Toggle' });

local Tab2 = TabBox:AddTab('Tab 2')
Tab2:AddToggle('Tab2Toggle', { Text = 'Tab2 Toggle' });

-- Dependency boxes let us control the visibility of UI elements depending on another UI elements state.
-- e.g. we have a 'Feature Enabled' toggle, and we only want to show that features sliders, dropdowns etc when it's enabled!
-- Dependency box example:
local RightGroupbox = Tabs.Main:AddRightGroupbox('Groupbox #3');
RightGroupbox:AddToggle('ControlToggle', { Text = 'Dependency box toggle' });

local Depbox = RightGroupbox:AddDependencyBox();
Depbox:AddToggle('DepboxToggle', { Text = 'Sub-dependency box toggle' });

-- We can also nest dependency boxes!
-- When we do this, our SupDepbox automatically relies on the visiblity of the Depbox - on top of whatever additional dependencies we set
local SubDepbox = Depbox:AddDependencyBox();
SubDepbox:AddSlider('DepboxSlider', { Text = 'Slider', Default = 50, Min = 0, Max = 100, Rounding = 0 });
SubDepbox:AddDropdown('DepboxDropdown', { Text = 'Dropdown', Default = 1, Values = {'a', 'b', 'ĉ'} });

local SecretDepbox = SubDepbox:AddDependencyBox();
SecretDepbox:AddLabel('You found a seĉret!')

Depbox:SetupDependencies({
	{ Toggles.ControlToggle, true } -- We can also pass `false` if we only want our features to show when the toggle is off!
});

SubDepbox:SetupDependencies({
	{ Toggles.DepboxToggle, true }
});

SecretDepbox:SetupDependencies({
	{ Options.DepboxDropdown, 'ĉ'} -- In the case of dropdowns, it will automatically check if the specified dropdown value is selected
})

-- Library functions
-- Sets the watermark visibility
Library:SetWatermarkVisibility(false)

-- Example of dynamically-updating watermark with common traits (fps and ping)
--local FrameTimer = tick()
--local FrameCounter = 0;
--local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
	--FrameCounter += 1;

	--if (tick() - FrameTimer) >= 1 then
		--FPS = FrameCounter;
		--FrameTimer = tick();
		--FrameCounter = 0;
	--end;

	--Library:SetWatermark(('LinoriaLib demo | %s fps | %s ms'):format(
		--math.floor(FPS),
		--math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
	--));
end);

Library.KeybindFrame.Visible = false; -- todo: add a function for this

Library:OnUnload(function()
	WatermarkConnection:Disconnect()

	print('msbackrooms unloaded successfully !')
	Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('msbackrooms')
SaveManager:SetFolder('msbackrooms/dabackrooms')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
--loadstring(game:HttpGet("https://raw.githubusercontent.com/PalaCraftYT/msbackrooms/main/places/msbackrooms.lua"))()
