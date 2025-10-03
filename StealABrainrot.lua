local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
local Window = Starlight:CreateWindow({
    Name = "Auto Buy Brainrot by LKQ",
    Subtitle = "by LKQ",
    LoadingSettings = {
        Title = "by LKQ",
        Subtitle = "by LKQ",
    },
    FileSettings = {
        ConfigFolder = "NyansakenHubScript"
    },
})
local TabSection = Window:CreateTabSection("Steal A Brainrot")
local Tab = TabSection:CreateTab({
    Name = "Steal A Brainrot",
    Columns = 2,
}, "INDEX1")
local Groupbox = Tab:CreateGroupbox({
    Name = "Auto Mua Brainrot",
    Column = 1,
}, "INDEX2")
local checkBrainrot = false
local selectedBrainrots = {}
local selectedRarities = {}
local selectedMutations = {}
local toggle = Groupbox:CreateToggle({
   Name = "Tự Động Mua Brainrot",
   CurrentValue = false,
   Callback = function(Value)
      checkBrainrot = Value
   end
}, "TuDongMuaBrainrot")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local animalsFolder = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Animals")
local brainrotNames = {}
for _, child in ipairs(animalsFolder:GetChildren()) do
    if child:IsA("Model") then
        table.insert(brainrotNames, child.Name)
    end
end
local Dropdown1 = toggle:AddDropdown({
    Name = "Chọn Brainrot",
    Options = brainrotNames,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedBrainrots = Options
    end
}, "ChonBrainrot")
local Dropdown2 = toggle:AddDropdown({
    Name = "Chọn Độ Hiếm",
    Options = {"Common","Rare","Epic","Legendary","Mythic","Brainrot God","Secret","OG"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedRarities = Options
    end
}, "ChonDoHiem")
local Dropdown3 = toggle:AddDropdown({
    Name = "Chọn Dòng",
    Options = {"Gold","Diamond","Bloodrot","Rainbow","Candy","Lava","Galaxy","YinYang"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedMutations = Options
    end
}, "ChonDong")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local runFreezeEnabled = false
local targetPos = Vector3.new(-410, -7, 235)
local reachThreshold = 2
local function goAndFreeze(character)
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    repeat
        humanoid:MoveTo(targetPos)
        task.wait()
    until not runFreezeEnabled or (hrp.Position - targetPos).Magnitude <= reachThreshold
    if runFreezeEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                part.Anchored = true
            end
        end
    end
end
local function unfreeze(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored then
            part.Anchored = false
        end
    end
end
local freezeToggle = Groupbox:CreateToggle({
    Name = "Chạy Tới Chỗ Mua Brainrot",
    CurrentValue = false,
    Callback = function(Value)
        runFreezeEnabled = Value
        if Value and LocalPlayer.Character then
            task.spawn(function()
                goAndFreeze(LocalPlayer.Character)
            end)
        else
            if LocalPlayer.Character then
                unfreeze(LocalPlayer.Character)
            end
        end
    end,
}, "AutoChayFreeze")
LocalPlayer.CharacterAdded:Connect(function(char)
    if runFreezeEnabled then
        task.spawn(function()
            goAndFreeze(char)
        end)
    else
        task.spawn(function()
            unfreeze(char)
        end)
    end
end)
local function getNearestModelInfo(origin)
	local nearestModel, nearestIndex, nearestRarity, nearestMutation
	local nearestDistance = math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") then
			local index = obj:GetAttribute("Index")
			if index then
				local pos
				if obj.PrimaryPart then
					pos = obj.PrimaryPart.Position
				else
					local part = obj:FindFirstChildWhichIsA("BasePart")
					if part then
						pos = part.Position
					end
				end
				if pos then
					local dist = (pos - origin.Position).Magnitude
					if dist < nearestDistance then
						nearestDistance = dist
						nearestModel = obj
						nearestIndex = index
						local rarityLabel = obj:FindFirstChild("Part")
							and obj.Part:FindFirstChild("Info")
							and obj.Part.Info:FindFirstChild("AnimalOverhead")
							and obj.Part.Info.AnimalOverhead:FindFirstChild("Rarity")
						if rarityLabel and rarityLabel:IsA("TextLabel") then
							nearestRarity = rarityLabel.Text
						else
							nearestRarity = nil
						end
						local mutationLabel = obj:FindFirstChild("Part")
							and obj.Part:FindFirstChild("Info")
							and obj.Part.Info:FindFirstChild("AnimalOverhead")
							and obj.Part.Info.AnimalOverhead:FindFirstChild("Mutation")
						if mutationLabel and mutationLabel:IsA("TextLabel") then
							local text = mutationLabel.Text
							text = string.gsub(text, "<.->", "")
							text = text:gsub("^%s*(.-)%s*$", "%1")
							nearestMutation = text
						else
							nearestMutation = nil
						end
					end
				end
			end
		end
	end
	return nearestModel, nearestIndex, nearestRarity, nearestMutation, nearestDistance
end
local VirtualInputManager = game:GetService("VirtualInputManager")
local function interactBrainrot()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end
task.spawn(function()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	while true do
		if checkBrainrot then
			local model, index, rarity, mutation, distance = getNearestModelInfo(hrp)
			if model then
				local target = true
				if #selectedBrainrots > 0 and not table.find(selectedBrainrots, index) then
					target = false
				end
				if #selectedRarities > 0 and not table.find(selectedRarities, rarity) then
					target = false
				end
				if #selectedMutations > 0 and not table.find(selectedMutations, mutation) then
					target = false
				end
				if target then
					interactBrainrot()
				end
			end
		end
		task.wait()
	end
end)
Tab:BuildConfigGroupbox(2)
Starlight:LoadAutoloadConfig()
