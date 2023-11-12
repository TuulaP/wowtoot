
--dofile( "tablesave.lua" )

local f3

SLASH_CMTV1 = "/czv"
SLASH_CMTV2 = "/countzonevisits"


local options  = {
    ["totalSwaps"] = 0,
    class = "mega",
}

local zoneVisits = {} 
zoneVisits["magetower"] = 0



local function maxFromHash(hash) 

    local max = 0
    local key = nil
    for k,v in pairs(hash) do
        if v > max then
            max = v
            key = k
        end
    end

    return key, max;


end


--- display popup

local function showPopup (data)

    f3 = CreateFrame("Frame", "YourFrameName", UIParent) -- BUG: creates new frame every time
    f3:SetSize(400, 400)
    f3:SetPoint("CENTER")
    -- (2)
--    f3:SetBackdrop({
--    	bgFile = "Interface/ChatFrame/ChatFrameBackground",
--    	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
--    	edgeSize = 1, tile=true,
--        insets = { left = 4, right = 4, top = 4, bottom = 4 }
--    })
--    f3:SetBackdropColor(0, 0, 0, .5)
--    f3:SetBackdropBorderColor(0, 0, 0)

    -- (3)
    f3:EnableMouse(true)
    f3:SetMovable(true)
    f3:RegisterForDrag("LeftButton")
    f3:SetScript("OnDragStart", f3.StartMoving)
    f3:SetScript("OnDragStop", f3.StopMovingOrSizing)
    f3:SetScript("OnHide", f3.StopMovingOrSizing)
    -- f3:Timeout(30)

    -- (4)
    local close = CreateFrame("Button", "Close window", f3, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f3, "TOPRIGHT")
    close:SetScript("OnClick", function()
        f3:Hide()
    end)

    -- (5)
    local text = f3:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("CENTER")
    text:SetText("In zone: " .. data)

end


local function CountZoneVisitsHandler()


    if CountZoneVisitsData == nil then
        -- This is the first time this addon is loaded; set SVs to default values
        CountZoneVisitsData = 0
    end

    options["totalSwaps"] = CountZoneVisitsData

    print("CZV: Saved visits: " .. CountZoneVisitsData )
    print("CZV: Realms visited: " .. options["totalSwaps"])

    local isshamanmagetower = false
    local isdpsmagetower = false -- fiendish vault , agatha

    local mapID = ""

    if IsInInstance() then
        print("CZV: In instance?")

        local diids = "kissa"
        local errorc = false

        local errorc, diids = pcall( C_Map.GetInstanceInfo, mapID )


        local errorc, diids = pcall( GetZoneText )

        if not errorc then
            print("CZV2: Error! ")
        else
            print("CZV2 instance : " .. diids)
        end

        local plist={}
        local tank = ""
        if diids == "Black Rook Hold" then
            print("CZV2: Black Rook Hold")

            if IsInGroup() then
                for i=1,4 do
                    if (UnitName('party'..i)) then
                       tank = UnitName('party'..i)
                       print("Raid member: " .. tank)
                       tinsert(plist,(UnitName('party'..i)))
                       if tank == "Commander Jarod Shadowsong" then
                           isshamanmagetower = true
                       end
                    end
                end
            end

        end

        if diids == "Fiendish Vault" then
            print("CZV2: DPS MAge tower:  Fiendish Vault")
        end


    else
        mapID = C_Map.GetBestMapForUnit("player");
        
        if mapID == nil then
            print("CZV: mapID: nil " )
        else 
            print("CZV: Current map: " .. mapID)
        end 
    end

    local zoneName = ""
    if not IsInInstance() then
        -- mapID = C_Map.GetBestMapForUnit("player");
        mapID = C_Map.GetBestMapForUnit("player");
        if mapID == nil then
            print("CZV: mapid NIL2")            
        else
            zoneName = C_Map.GetMapInfo(mapID).name
        end

        if zoneVisits[zoneName] then
            zoneVisits[zoneName] = zoneVisits[zoneName] + 1
        else
            zoneVisits[zoneName] = 1
        end
    end

    -- if (isshamanmagetower) then
    --     showPopup("Shaman mage tower!" .. CountZoneVisitsData)

    --     print("Alldata: " .. table.concat(zoneVisits, ", "))

    -- end

    local name
    local instanceType
    local difficulty
    local difficultyName
    local maxPlayers
    local tsup

    name, instanceType, difficulty, difficultyName, maxPlayers = GetInstanceInfo()

    tsup = GetSubZoneText()

    -- print("CZV :: You are at instance: " .. name )  -- gives Pandaria
    print("CZV :: You are at subzone: " .. tsup .. " OR " ..  zoneName)


    options["totalSwaps"] = options["totalSwaps"] + 1
    --showPopup(CountZoneVisitsData)

    local location, qty = maxFromHash(zoneVisits)

    CountZoneVisitsData = options["totalSwaps"]

    print("CZV: " .. location .. " with " .. qty .. " visits")




end


-- RegisterNewSlashCommand("CZV", "CountZoneVisitsHandler")


local frame = CreateFrame("FRAME", "FoobarAddonFrame");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
local function eventHandler(self, event, ...)
    CountZoneVisitsHandler();
end
frame:SetScript("OnEvent", eventHandler);




SlashCmdList["CZV"] = CountZoneVisitsHandler()


local frame2 = CreateFrame("FRAME", "FoobarAddonFrame2");

frame2:RegisterEvent("ADDON_LOADED")
frame2:RegisterEvent("PLAYER_LOGOUT")

frame2:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "CountZoneVisits" then
        -- Our saved variables, if they exist, have been loaded at this point.
        if CountZoneVisitsData == nil then
            -- This is the first time this addon is loaded; set SVs to default values
            CountZoneVisitsData = 0
        end

        if CountZoneVisitsData == nil then
            -- Haven't yet seen this character, so increment the number of characters met
            CountZoneVisitsData = CountZoneVisitsData + 1
            options['totalSwaps'] = CountZoneVisitsData
            text:SetText("Zones visited: " .. CountZoneVisitsData)

        end

    elseif event == "PLAYER_LOGOUT" then
            -- Save the time at which the character logs out
            CountZoneVisitsData = options["totalSwaps"]
            -- TODO: closing of frame somewhere here
            --f3.Hide()
            --print("CZV: Bye, popup closed?")
    end
end)
