local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local FavoriteAnims = {}
local KeybindAnims = {}
local KeybindsLoaded = false
local isListeningForKeybind = false
local keybindAnimName = nil
local selectedCategory = "All"
local searchText = ""
local activeTrack = nil
local animationListGui = nil
local animListFrame = nil
local scrollFrame = nil
local searchBar = nil
local allButton = nil
local favoritesButton = nil
local keybindConnection = nil
local buttonHeight = 30
local buttonSpacing = 5

pcall(function()
    if not isfolder("ASTRALIX") then
        makefolder("ASTRALIX")
    end
    if not isfolder("ASTRALIX/ugc") then
        makefolder("ASTRALIX/ugc")
    end
end)

local Emotes = {{name="Around Town",id=3576747102},{name="TWICE TAKEDOWN DANCE 2",id=85623000473425},{name="Fashionable",id=3576745472},{name="Swish",id=3821527813},{name="Top Rock",id=3570535774},{name="Fancy Feet",id=3934988903},{name="Idol",id=4102317848},{name="Sneaky",id=3576754235},{name="Elton John - Piano Jump",id=11453096488},{name="Cartwheel - George Ezra",id=10370929905},{name="Super Charge",id=10478368365},{name="Rise Above - The Chainsmokers",id=13071993910},{name="Elton John - Elevate",id=11394056822},{name="Sturdy Dance - Ice Spice",id=17746270218},{name="YUNGBLUD – HIGH KICK",id=14022978026},{name="Robot",id=3576721660},{name="Louder",id=3576751796},{name="Twirl",id=3716633898},{name="Bodybuilder",id=3994130516},{name="NBA Monster Dunk",id=117511481049460},{name="Jacks",id=3570649048},{name="Shuffle",id=4391208058},{name="Still Standing",id=11435177473},{name="Cat Man",id=11435175895},{name="Shrek Roar",id=18524331128},{name="Dorky Dance",id=4212499637},{name="HOLIDAY Dance - Lil Nas X (LNX)",id=5938396308},{name="Old Town Road Dance - Lil Nas X (LNX)",id=5938394742},{name="Panini Dance - Lil Nas X (LNX)",id=5915781665},{name="Rodeo Dance - Lil Nas X (LNX)",id=5938397555},{name="Drum Master - Royal Blood",id=6531538868},{name="It Ain't My Fault - Zara Larsson",id=6797948622},{name="Flex Walk",id=15506506103},{name="Dizzy",id=3934986896},{name="Uprise - Tommy Hilfiger",id=10275057230},{name="Tommy - Archer",id=13823339506},{name="Mean Mug - Tommy Hilfiger",id=10214415687},{name="Rock Star - Royal Blood",id=6533100850},{name="Floor Rock Freeze - Tommy Hilfiger",id=10214411646},{name="Saturday Dance - Twenty One Pilots",id=7422833723},{name="V Pose - Tommy Hilfiger",id=10214418283},{name="Boxing Punch - KSI",id=7202896732},{name="Drum Solo - Royal Blood",id=6532844183},{name="Frosty Flair - Tommy Hilfiger",id=10214406616},{name="Hips Poppin' - Zara Larsson",id=6797919579},{name="Drummer Moves - Twenty One Pilots",id=7422838770},{name="On The Outside - Twenty One Pilots",id=7422841700},{name="Thanos Happy Jump - Squid Game",id=82217023310738},{name="Block Partier",id=6865011755},{name="Up and Down - Twenty One Pilots",id=7422843994},{name="Ay-Yo Dance Move - NCT 127",id=12804173616},{name="Young-hee Head Spin - Squid Game",id=134615135651900},{name="T",id=3576719440},{name="Air Dance",id=4646302011},{name="TMNT Dance",id=18665886405},{name="Take Me Under - Zara Larsson",id=6797938823},{name="Sticker Dance Move - NCT 127",id=12259885838},{name="Line Dance",id=4049646104},{name="NBA WNBA Fadeaway",id=18526373545},{name="SpongeBob Imaginaaation",id=18443268949},{name="Chill Vibes - George Ezra",id=10370918044},{name="Wake Up Call - KSI",id=7202900159},{name="Kick It Dance Move - NCT 127",id=12259888240},{name="The Weeknd Starboy Strut",id=130245358716273},{name="Baddies Dance Move",id=12259890638},{name="Rock Guitar - Royal Blood",id=6532155086},{name="Show Dem Wrists - KSI",id=7202898984},{name="Dancin' Shoes - Twenty One Pilots",id=7405123844},{name="Arm Twist",id=9710992846},{name="AOK - Tai Verdes",id=7942960760},{name="M3GAN's Dance",id=127271798262177},{name="High Hands",id=9710994651},{name="Cobra Arms - Tai Verdes",id=7942964447},{name="Lasso Turn - Tai Verdes",id=7942972744},{name="Beauty Touchdown",id=16303091119},{name="Sidekicks - George Ezra",id=10370922566},{name="Boom Boom Clap - George Ezra",id=10370934040},{name="DearALICE - Ariana",id=133765015173412},{name="Chappell Roan HOT TO GO!",id=79312439851071},{name="Bone Chillin' Bop",id=15123050663},{name="Power Blast",id=4849497510},{name="Flowing Breeze",id=7466047578},{name="Swan Dance",id=7466048475},{name="Quiet Waves",id=7466046574},{name="Rolling Stones Guitar Strum",id=18148839527},{name="Break Dance",id=5915773992},{name="KATSEYE - Touch",id=139021427684680},{name="Zombie",id=4212496830},{name="Olivia Rodrigo Head Bop",id=15554010118},{name="Rasputin Boney M.",id=133477296392756},{name="Tommy K-Pop Mic Drop",id=14024722653},{name="TWICE Feel Special",id=14900153406},{name="Olivia Rodrigo good 4 u",id=15554013003},{name="Olivia Rodrigo Fall Back to Float",id=15554016057},{name="Air Guitar",id=15506499986},{name="Fashion Klossette - Runway my way",id=126683684984862},{name="Elton John - Heart Skip",id=11309263077},{name="Baby Dance",id=4272484885},{name="Cha Cha",id=6865013133},{name="Dolphin Dance",id=5938365243},{name="Elton John - Rock Out",id=11753545334},{name="Couldn't Care Less",id=92859581691366},{name="Fashion Roadkill",id=73683655527605},{name="Paris Hilton Sanasa",id=16126526506},{name="TWICE I GOT YOU 1",id=16215060261},{name="The Zabb",id=71389516735424},{name="Y",id=4391211308},{name="Wanna play?",id=16646438742},{name="TWICE I GOT YOU 2",id=16256253954},{name="Nicki Minaj Starships",id=15571540519},{name="Mean Girls Dance Break",id=15963348695},{name="TWICE Takedown",id=94796833553521},{name="Samba",id=6869813008},{name="Rock Out Bebe Rexha",id=18225077553},{name="TWICE LIKEY",id=14900151704},{name="Sol de Janeiro - Samba",id=16276506814},{name="The Weeknd Opening Night",id=105098895743105},{name="Paris Hilton - Sliving For The Groove",id=15392927897},{name="Paris Hilton - Checking My Angles",id=15392937495},{name="Nicki Minaj Boom Boom Boom",id=15571538346},{name="Stray Kids Walkin On Water",id=100773414188482},{name="Team USA Breaking Emote",id=18526338976},{name="Side to Side",id=3762641826},{name="Skibidi Toilet - Titan Speakerman Laser Spin",id=103102322875221},{name="Paris Hilton - Iconic IT-Grrrl",id=15392932768},{name="Dave's Spin Move - Glass Animals",id=16276501655},{name="HUGO Let's Drive!",id=17360720445},{name="Fast Hands",id=4272351660},{name="PARROT PARTY DANCE",id=121067808279598},{name="Dance n' Prance",id=99031916674986},{name="R15 Death",id=114899970878842},{name="Wally West",id=133948663586698},{name="Take The L",id=123159156696507},{name="Xaviersobased",id=131763631172236},{name="Belly Dancing",id=131939729732240},{name="RAT DANCE",id=133461102795137},{name="CaramellDansen",id=93105950995997},{name="Biblically Accurate",id=133596366979822},{name="Rambunctious",id=108128682361404},{name="Die Lit",id=121001502815813},{name="Nyan Nyan!",id=73796726960568},{name="Teto Territory",id=114428584463004},{name="Skibidi",id=124828909173982},{name="Chronoshift",id=92600655160976},{name="Floating on Clouds",id=111426928948833},{name="Jersey Joe",id=134149640725489},{name="Virtual Insanity",id=83261816934732},{name="Doodle Dance",id=107091254142209},{name="Subject 3",id=83732367439808},{name="Club Penguin",id=98099211500155},{name="Kazotsky",id=97629500912487},{name="Miku Dance",id=117734400993750},{name="Deltarune - Tenna Swing",id=103139492736941},{name="Hakari Dance",id=80270168146449},{name="Addendum Dance [R6]",id=134442882516163},{name="Gangnam Style",id=77205409178702},{name="Push-Up",id=117922227854118},{name="Split",id=98522218962476},{name="PROXIMA",id=81390693780805},{name="HeadBanging",id=87447252507832},{name="Assumptions",id=127507691649322},{name="Jumpstyle",id=99563839802389},{name="Lemon Melon Cookie (Miku)",id=79874689836683},{name="Flopping Fish",id=133142324349281},{name="Kicking Feet Sit",id=78758922757947},{name="Fancy Feets",id=124512151372711},{name="Cute Sit",id=90244178386698},{name="Absolute Cinema",id=97258018304125},{name="Bubbly Sit",id=112758073578333},{name="Become A Car",id=131544122623505},{name="Hiding Human Box",id=124935873390035},{name="Magical Pose",id=135489824748823},{name="Griddy",id=116065653184749},{name="Biblically Accurate V2",id=122425945545800},{name="Lost In Paradise [R15]",id=118281485763031},{name="Lost In Paradise [R6]",id=122487491363945},{name="Ragdoll V2",id=130129866437608},{name="GMod",id=121792397276961},{name="Arona Dance",id=91909406426962},{name="Piano Tiles",id=102077049561224},{name="Mannrobics - Taunt",id=83530950920167},{name="DO YOU HEAR THE WHISTLE FLOWER",id=140106789061586},{name="What you lack is this - Dante Provocation Taunt",id=112292818054770},{name="Parker Dance R6",id=123803076248023},{name="Demoman Laugh Tf2",id=123666247839656},{name="Cube Aura",id=107265951109884},{name="Ragdoll Wiggle",id=123750365300358},{name="Ragdoll",id=87483175844613},{name="Gon Rage",id=139639173024927},{name="Become Couch",id=93335594132613},{name="Spare Change",id=126749574427431},{name="Paranoid",id=123407922818447},{name="Little Obbyist",id=134584040095037},{name="Aura Fly",id=78755795767408},{name="Invisible",id=109899950448992},{name="Slenderman",id=81926508907412},{name="Chill pose",id=77058107325712},{name="house",id=93552301087938},{name="baby",id=82824758023484},{name="zenitsu",id=92750276568993},{name="Gun",id=73562814360939},{name="Spy Laugh tf2",id=137720205462499},{name="GlitchStuff",id=97629104004619},{name="Head Juggling",id=82224981519682},{name="Omniman Think",id=70560694892323},{name="Shake Dancing",id=138386881919239},{name="Wait",id=106569806588657},{name="Shinji Pose",id=97629500912487},{name="Jotaro",id=116340986352846},{name="Nuh Uh",id=83882148066651},{name="sukuna pose",id=122409062451923},{name="Uma Musume T.M Opera O Win",id=124486899651175},{name="alibi",id=79790557070326},{name="Oscillating Fan",id=71493999860590},{name="Locked In",id=110145155419199},{name="BirdBrain",id=105730788757021},{name="How A Creeper Walk",id=108714986908463},{name="Hakari (R6)",id=127103118569243},{name="Strongest Stance",id=80146495484274},{name="Cat Things",id=131193808160056},{name="Doggy Things",id=105206768873249},{name="Wally West Edit",id=72247161810866},{name="24 Hour Cinderella",id=122972776209997},{name="i-sits",id=97816601478937},{name="I Wanna Runaway",id=128173540343014},{name="Mesmerizer",id=107326070391840},{name="Reanimated R6",id=72473122653280},{name="Best Mates",id=73271793399763},{name="Garou",id=86200585395371},{name="Dio Pose",id=76736978166708},{name="IGAKU Medicine - Kasane Teto",id=97637255016141},{name="do the thing",id=134450870095571},{name="Michael Myers Dance",id=120250678461066},{name="Teto Dance",id=93031502567721},{name="Gun Shot",id=105055412595333},{name="Rabbit Hole",id=133481721436918},{name="Uma Musume - Jukebox 1",id=121616328669412},{name="TwerkStuff",id=86809344898533},{name="Tuff",id=97505694413413},{name="Chad",id=77174196926331},{name="Golden Freddy",id=122463450997235},{name="Neco arc",id=106066270716590},{name="Nika",id=76601820484387},{name="Noclip, Speed",id=137006085779408},{name="Static [Hatsune Miku]",id=84534006084837},{name="GOALL",id=78830825254717},{name="Lethal Dance",id=77108921633993},{name="Plug Walk",id=100359724990859},{name="At Ease",id=76993139936388},{name="Conga",id=97547955535086},{name="Barrel",id=84511772437190},{name="Helicopter",id=84555218084038},{name="Aura Farm Boat",id=88042995626011},{name="Prince Of Egypt",id=133751526608969},{name="Jersey Joe2",id=115782117564871},{name="Static.. Again",id=89824446568758},{name="Deltarune - Tenna Dance",id=73715378215546},{name="California Girl",id=132074413582912},{name="Default Dance",id=80877772569772},{name="Shocked meme",id=129501229484294},{name="Family Guy",id=78459263478161},{name="Car Transformation",id=96887377943085},{name="Insanity",id=129843344424281},{name="Honored One",id=121643381580730},{name="Sukuna",id=91839607010745},{name="Dropper",id=130358790702800},{name="Be Not Afraid",id=70635223083942},{name="Macarena",id=91274761264433},{name="Helicopter2",id=119431985170060},{name="RONALDO",id=97547486465713},{name="Nya Anime Dance",id=126647057611522},{name="Do that thang",id=113772829398170},{name="Squat?",id=95441477641149},{name="Slickback",id=103789826265487}}

local function UI(className, properties, parent)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    if parent then
        element.Parent = parent
    end
    return element
end

local function Corner(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = element
    return corner
end

local function SaveFavorites()
    pcall(function()
        if writefile then
            writefile("ASTRALIX/ugc/favs.json", HttpService:JSONEncode(FavoriteAnims))
        end
    end)
end

local function LoadFavorites()
    pcall(function()
        if readfile and isfile and isfile("ASTRALIX/ugc/favs.json") then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile("ASTRALIX/ugc/favs.json"))
            end)
            if success and type(data) == "table" then
                FavoriteAnims = data
            end
        end
    end)
end

local function SaveKeybinds()
	return pcall(function()
		if not isfolder("ASTRALIX") then
			makefolder("ASTRALIX")
		end
		if not isfolder("ASTRALIX/ugc") then
			makefolder("ASTRALIX/ugc")
		end
		writefile("ASTRALIX/ugc/keys.json", HttpService:JSONEncode(KeybindAnims))
	end)
end

local function LoadKeybinds()
	if KeybindsLoaded then
		return
	end
	local success, data = pcall(function()
		return isfile("ASTRALIX/ugc/keys.json") and HttpService:JSONDecode(readfile("ASTRALIX/ugc/keys.json")) or {}
	end)
	if success and data then
		KeybindAnims = data
		KeybindsLoaded = true
	end
end

local function SetKeybind(animName, keyCode)
	LoadKeybinds()
	for key, anim in pairs(KeybindAnims) do
		if anim == animName then
			KeybindAnims[key] = nil
		end
	end
	if keyCode then
		KeybindAnims[keyCode.Name] = animName
	end
	SaveKeybinds()
end

local function GetKeybind(animName)
	LoadKeybinds()
	for key, anim in pairs(KeybindAnims) do
		if anim == animName then
			return key
		end
	end
	return nil
end

local function RemoveKeybind(animName)
	LoadKeybinds()
	for key, anim in pairs(KeybindAnims) do
		if anim == animName then
			KeybindAnims[key] = nil
			break
		end
	end
	SaveKeybinds()
end

local function ToggleFavorite(id)
    if type(id) == "number" then
        local idStr = tostring(id)
        if FavoriteAnims[idStr] then
            FavoriteAnims[idStr] = nil
        else
            FavoriteAnims[idStr] = true
        end
        SaveFavorites()
    end
end

local function IsFavorite(id)
    if type(id) == "number" then
        return FavoriteAnims[tostring(id)] == true
    end
    return false
end

local function PlayEmote(name, id)
    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local Description = Humanoid and Humanoid:FindFirstChildOfClass("HumanoidDescription")
	if not Description then
		return
	end
    if LocalPlayer.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
        if activeTrack and typeof(activeTrack) == "Instance" and activeTrack.IsPlaying then
            activeTrack:Stop()
        end
        local success, track = pcall(function()
            return Humanoid:PlayEmoteAndGetAnimTrackById(id)
        end)
        if not success then
            Description:AddEmote(name, id)
            track = Humanoid:PlayEmoteAndGetAnimTrackById(id)
        end
        if track then
            activeTrack = track
        end
    end
end

local function createAnimationListGUI()
    if animationListGui then
        animationListGui:Destroy()
    end
    if _G.EmoteMenuGui then
        _G.EmoteMenuGui:Destroy()
    end
    local playerGui = plr:WaitForChild("PlayerGui")
    animationListGui = UI(
        "ScreenGui",
        {
            Name = "AnimationListGUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = (syn and syn.protect_gui and game:GetService("CoreGui")) or playerGui
        }
    )
    if syn and syn.protect_gui then
        syn.protect_gui(animationListGui)
    end
    animListFrame = UI(
        "Frame",
        {
            Name = "AnimListFrame",
		Size = UDim2.new(0, 280, 0, 350),
		Position = UDim2.new(0.5, 140, 0.5, -185),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 0.3,
            Parent = animationListGui,
            Active = true
        }
    )
    Corner(animListFrame, 12)
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart
    local startPos
    local function UpdateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            local tweenInfo = TweenInfo.new(0.1)
			local tween = TweenService:Create(animListFrame, tweenInfo, {
				Position = newPosition
			})
            tween:Play()
        end
    end
    animListFrame.InputBegan:Connect(function(input)
        if 
            (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and 
            not dragging 
        then
            dragging = true
            dragStart = input.Position
            startPos = animListFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if 
            input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch 
        then
            UpdateDrag(input)
        end
    end)
    local animGradient = Instance.new("UIGradient", animListFrame)
    animGradient.Color = ColorSequence.new(
        {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 40, 70)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(40, 80, 140)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 120, 200)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(40, 80, 140)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 70))
        }
    )
    animGradient.Rotation = 45
    task.spawn(function()
        while animListFrame.Parent do
            for i = 0, 360, 2 do
                if not animListFrame.Parent then
                    break
                end
                animGradient.Rotation = i
                task.wait(0.05)
            end
        end
    end)
    local animTopBar = UI(
        "Frame",
        {
            Name = "AnimTopBar",
            Size = UDim2.new(1, -2, 0, 40),
            Position = UDim2.new(0, 1, 0, 0),
            BackgroundTransparency = 1,
            Parent = animListFrame
        }
    )
    local animTitleLabel = UI(
        "TextLabel",
        {
		Size = UDim2.new(1, -50, 0, 40),
		Position = UDim2.new(0, -40, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            Text = "UGC Animations",
            TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = animTopBar
        }
    )
	local closeButton = UI(
        "TextButton",
        {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -10, 0, 5),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 25,
		Parent = animTopBar
	}
    )
	Corner(closeButton, 6)
	local minimizeButton = UI(
        "TextButton",
        {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -45, 0, 5),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Text = "−",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		Parent = animTopBar
	}
    )
	Corner(minimizeButton, 6)
	closeButton.MouseButton1Click:Connect(function()
		if keybindConnection then
			keybindConnection:Disconnect()
			keybindConnection = nil
		end
		if animationListGui then
			animationListGui:Destroy()
			animationListGui = nil
		end
	end)
    local animContentContainer = UI(
        "Frame",
        {
            Name = "AnimContentContainer",
            Size = UDim2.new(1, 0, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = animListFrame
        }
    )
    local categoriesFrame = UI(
        "Frame",
        {
            Name = "CategoriesFrame",
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.new(0.5, 0, 0, 5),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(20, 20, 30),
            BackgroundTransparency = 1,
            Parent = animContentContainer
        }
    )
    local function updateCategoryButtons()
        allButton.BackgroundTransparency = selectedCategory == "All" and 0.3 or 0.8
        favoritesButton.BackgroundTransparency = selectedCategory == "Favorites" and 0.3 or 0.8
    end
    local function updateAnimationList()
		if not scrollFrame or not animListFrame then
			return
		end
        local isUpdating = scrollFrame:GetAttribute("isUpdating")
		if isUpdating then
			return
		end
        scrollFrame:SetAttribute("isUpdating", true)
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
        local yOffset = 5
        local filteredEmotes = {}
        for _, emote in ipairs(Emotes) do
            local nameMatches = searchText == "" or 
                              (type(emote.name) == "string" and 
                               string.find(string.lower(emote.name), string.lower(searchText), 1, true))
            local categoryMatches = selectedCategory == "All" or 
                                  (selectedCategory == "Favorites" and IsFavorite(emote.id))
            if nameMatches and categoryMatches then
                table.insert(filteredEmotes, emote)
            end
        end
        for _, emote in ipairs(filteredEmotes) do
            local containerFrame = UI(
                "Frame",
                {
                    Size = UDim2.new(1, -10, 0, buttonHeight),
                    Position = UDim2.new(0, 5, 0, yOffset),
                    BackgroundTransparency = 1,
                    Parent = scrollFrame
                }
            )
			local keybindButton = UI(
                "TextButton",
                {
				Name = "KeybindButton",
				Size = UDim2.new(0, 35, 1, 0),
				Position = UDim2.new(0, 5, 0, 0),
				BackgroundColor3 = Color3.fromRGB(25, 25, 35),
				BackgroundTransparency = 0.8,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 10,
                    Font = Enum.Font.Gotham,
				Text = GetKeybind(emote.name) or "KEY",
                    Parent = containerFrame
                }
            )
            local starButton = UI(
                "TextButton",
                {
				Size = UDim2.new(0, 22, 1, 0),
				Position = UDim2.new(0, 43, 0, 0),
				BackgroundColor3 = Color3.fromRGB(25, 25, 35),
				BackgroundTransparency = 0.8,
                    TextColor3 = IsFavorite(emote.id) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150),
                    Text = "★",
				TextSize = 14,
				Font = Enum.Font.Gotham,
                    Parent = containerFrame
                }
            )
			local button = UI(
                "TextButton",
                {
				Name = emote.name,
				Size = UDim2.new(1, -75, 1, 0),
				Position = UDim2.new(0, 70, 0, 0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 40),
				BackgroundTransparency = 0.7,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				Font = Enum.Font.Gotham,
				Text = emote.name,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = containerFrame
			}
            )
			Corner(keybindButton, 4)
            Corner(starButton, 4)
			Corner(button, 4)
            local textPadding = UI(
                "UIPadding",
                {
                    PaddingLeft = UDim.new(0, 10),
                    Parent = button
                }
            )
			keybindButton.MouseButton1Click:Connect(function()
				if isListeningForKeybind then
					return
				end
				isListeningForKeybind = true
				keybindAnimName = emote.name
				keybindButton.Text = "Press Key..."
				keybindButton.TextColor3 = Color3.fromRGB(255, 215, 0)
				local rightClickConnection
				rightClickConnection = keybindButton.MouseButton2Click:Connect(function()
					RemoveKeybind(emote.name)
					keybindButton.Text = "KEY"
					keybindButton.TextColor3 = Color3.fromRGB(150, 150, 150)
					rightClickConnection:Disconnect()
				end)
			end)
            starButton.MouseButton1Click:Connect(function()
                ToggleFavorite(emote.id)
                starButton.TextColor3 = IsFavorite(emote.id) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
                if selectedCategory == "Favorites" then
                    updateAnimationList()
                end
            end)
            button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2), {
					TextColor3 = Color3.fromRGB(200, 200, 200)
				}):Play()
            end)
            button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
            end)
            button.MouseButton1Click:Connect(function()
                PlayEmote(emote.name, emote.id)
				TweenService:Create(button, TweenInfo.new(0.1), {
					TextColor3 = Color3.fromRGB(150, 150, 150)
				}):Play()
                task.delay(0.2, function()
					TweenService:Create(button, TweenInfo.new(0.2), {
						TextColor3 = Color3.fromRGB(255, 255, 255)
					}):Play()
                end)
            end)
            yOffset = yOffset + buttonHeight + buttonSpacing
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
        scrollFrame:SetAttribute("isUpdating", false)
    end
    allButton = UI(
        "TextButton",
        {
            Size = UDim2.new(0.48, -2, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 0.3,
            Text = "All",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Parent = categoriesFrame
        }
    )
    Corner(allButton, 4)
    favoritesButton = UI(
        "TextButton",
        {
            Size = UDim2.new(0.48, -2, 1, 0),
            Position = UDim2.new(0.52, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 0.8,
            Text = "Favorites",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Parent = categoriesFrame
        }
    )
    Corner(favoritesButton, 4)
    allButton.MouseButton1Click:Connect(function()
        if selectedCategory ~= "All" then
            selectedCategory = "All"
            if updateCategoryButtons then
                updateCategoryButtons()
            end
            task.wait()  
            if updateAnimationList then
                updateAnimationList()
            end
        end
    end)
    favoritesButton.MouseButton1Click:Connect(function()
        if selectedCategory ~= "Favorites" then
            selectedCategory = "Favorites"
            if updateCategoryButtons then
                updateCategoryButtons()
            end
            task.wait()  
            if updateAnimationList then
                updateAnimationList()
            end
        end
    end)
    searchBar = UI(
        "TextBox",
        {
            Name = "SearchBar",
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0.5, 0, 0, 38),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            BackgroundTransparency = 0.2,
            PlaceholderText = "Search...",
            PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            Text = "",
            ClearTextOnFocus = true,
            Parent = animContentContainer
        }
    )
    Corner(searchBar, 6)
    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        searchText = searchBar.Text
        updateAnimationList()
    end)
    LoadFavorites()
	LoadKeybinds()
    local contentFrame = UI(
        "Frame",
        {
            Name = "ContentFrame",
            Size = UDim2.new(1, -20, 1, -90),
            Position = UDim2.new(0, 10, 0, 73),
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = 0.5,
            Parent = animContentContainer
        }
    )
    Corner(contentFrame, 10)
    scrollFrame = UI(
        "ScrollingFrame",
        {
            Name = "AnimationsScroll",
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = contentFrame
        }
    )
    local buttonHeight = 30
    local buttonSpacing = 5
    local yOffset = 5
    for _, emote in ipairs(Emotes) do
		local keybindButton = UI(
            "TextButton",
            {
			Name = "KeybindButton",
			Size = UDim2.new(0, 35, 0, buttonHeight),
			Position = UDim2.new(0, 5, 0, yOffset),
			BackgroundColor3 = Color3.fromRGB(25, 25, 35),
			BackgroundTransparency = 0.8,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 10,
                Font = Enum.Font.Gotham,
			Text = GetKeybind(emote.name) or "KEY",
                Parent = scrollFrame
            }
        )
        local starButton = UI(
            "TextButton",
            {
			Size = UDim2.new(0, 22, 0, buttonHeight),
			Position = UDim2.new(0, 43, 0, yOffset),
			BackgroundColor3 = Color3.fromRGB(25, 25, 35),
			BackgroundTransparency = 0.8,
                TextColor3 = IsFavorite(emote.id) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150),
                Text = "★",
			TextSize = 14,
			Font = Enum.Font.Gotham,
                Parent = scrollFrame
            }
        )
		local button = UI(
            "TextButton",
            {
			Name = emote.name,
			Size = UDim2.new(1, -75, 0, buttonHeight),
			Position = UDim2.new(0, 70, 0, yOffset),
			BackgroundColor3 = Color3.fromRGB(30, 30, 40),
			BackgroundTransparency = 0.7,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Font = Enum.Font.Gotham,
			Text = emote.name,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = scrollFrame
		}
        )
		Corner(keybindButton, 4)
		Corner(starButton, 4)
        Corner(button, 4)
        local textPadding = UI(
            "UIPadding",
            {
                PaddingLeft = UDim.new(0, 10),
                Parent = button
            }
        )
		keybindButton.MouseButton1Click:Connect(function()
			if isListeningForKeybind then
				return
			end
			isListeningForKeybind = true
			keybindAnimName = emote.name
			keybindButton.Text = "Press Key..."
			keybindButton.TextColor3 = Color3.fromRGB(255, 215, 0)
			local rightClickConnection
			rightClickConnection = keybindButton.MouseButton2Click:Connect(function()
				RemoveKeybind(emote.name)
				keybindButton.Text = "KEY"
				keybindButton.TextColor3 = Color3.fromRGB(150, 150, 150)
				rightClickConnection:Disconnect()
			end)
		end)
		starButton.MouseButton1Click:Connect(function()
			ToggleFavorite(emote.id)
			starButton.TextColor3 = IsFavorite(emote.id) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(150, 150, 150)
			if selectedCategory == "Favorites" then
				updateAnimationList()
			end
		end)
        button.MouseEnter:Connect(function()
            TweenService:Create(
                button,
                TweenInfo.new(0.2),
                {
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }
            ):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(
                button,
                TweenInfo.new(0.2),
                {
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }
            ):Play()
        end)
        button.MouseButton1Click:Connect(function()
            PlayEmote(emote.name, emote.id)
            TweenService:Create(
                button,
                TweenInfo.new(0.1),
                {
                    TextColor3 = Color3.fromRGB(150, 150, 150)
                }
            ):Play()
            task.delay(0.2, function()
                TweenService:Create(
                    button,
                    TweenInfo.new(0.2),
                    {
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    }
                ):Play()
            end)
        end)
        yOffset = yOffset + buttonHeight + buttonSpacing
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            animListFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
    animTopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = animListFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    animTopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
	local isMinimized = false
	minimizeButton.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		local newHeight = isMinimized and 40 or 350
		TweenService:Create(animListFrame, TweenInfo.new(0.3), {
			Size = UDim2.new(0, 280, 0, newHeight)
		}):Play()
		if isMinimized then
			animContentContainer.Visible = false
		else
			animContentContainer.Visible = true
		end
		minimizeButton.Text = isMinimized and "+" or "−"
	end)
end

local function Initialize()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EmoteMenuGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if (syn and syn.protect_gui) then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif game:GetService("RunService"):IsStudio() then
        ScreenGui.Parent = plr:WaitForChild("PlayerGui")
    else
        ScreenGui.Parent = plr:WaitForChild("PlayerGui")
    end
	createAnimationListGUI()
	if animationListGui and animationListGui.AnimListFrame then
		animationListGui.AnimListFrame.Visible = true
	end
	keybindConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if isListeningForKeybind and keybindAnimName then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				SetKeybind(keybindAnimName, input.KeyCode)
				for _, child in pairs(scrollFrame:GetChildren()) do
					if child:IsA("Frame") then
						local keybindBtn = child:FindFirstChild("KeybindButton")
						if keybindBtn then
							local animBtn = nil
							for _, subChild in pairs(child:GetChildren()) do
								if subChild:IsA("TextButton") and subChild.Name == keybindAnimName then
									animBtn = subChild
									break
								end
							end
							if animBtn then
								keybindBtn.Text = input.KeyCode.Name
								keybindBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
								TweenService:Create(keybindBtn, TweenInfo.new(0.3), {
									TextColor3 = Color3.fromRGB(150, 150, 150)
								}):Play()
								break
							end
						end
					end
				end
				isListeningForKeybind = false
				keybindAnimName = nil
			end
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			LoadKeybinds()
			local animName = KeybindAnims[input.KeyCode.Name]
			if animName then
				for _, emote in ipairs(Emotes) do
					if emote.name == animName then
						PlayEmote(emote.name, emote.id)
						break
					end
				end
			end
		end
		if input.KeyCode == Enum.KeyCode.Comma then
			if animationListGui and animationListGui.AnimListFrame then
				animationListGui.AnimListFrame.Visible = not animationListGui.AnimListFrame.Visible
            end
        end
    end)
    return ScreenGui
end

local module = {
    Initialize = Initialize
}

task.spawn(function()
    Initialize()
end)

return module
