
require("scripts/autotracking/item_mapping")
require("scripts/autotracking/location_mapping")
require("scripts/autotracking/hints_mapping")
require("scripts/autotracking/level_mapping")
require("scripts/autotracking/elemental_mapping")

CUR_INDEX = -1

SLOT_DATA = {}
PORTAL_MAP = {}
RANDOMIZED_LEVELS = {
    
}

CUR_STAGE = ""

function has_value (t, val)
    for i, v in ipairs(t) do
        if v == val then return 1 end
    end
    return 0
end

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ','
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function onClear(slot_data)

    CUR_INDEX = -1
    -- reset locations
    for _, location_array in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_array) do
            if location then
                local location_obj = Tracker:FindObjectForCode(location)
                if location_obj then
                    if location:sub(1, 1) == "@" then
                        location_obj.AvailableChestCount = location_obj.ChestCount
                    else
                        location_obj.Active = false
                    end
                end
            end
        end
    end

    -- reset items
    for _, item_pair in pairs(ITEM_MAPPING) do
        local item_code = item_pair[1]
        local item_type = item_pair[2]
        local item_obj = Tracker:FindObjectForCode(item_code)
        if item_obj then
            if item_obj.Type == "toggle" then
                item_obj.Active = false
            elseif item_obj.Type == "progressive" then
                item_obj.CurrentStage = 0
                item_obj.Active = false
            elseif item_obj.Type == "consumable" then
                if item_obj.MinCount then
                    item_obj.AcquiredCount = item_obj.MinCount
                else
                    item_obj.AcquiredCount = 0
                end
            elseif item_obj.Type == "progressive_toggle" then
                item_obj.CurrentStage = 0
                item_obj.Active = false
            end
        end
    end
    
    if slot_data == nil  then
        print("welp")
        return
    end

    if slot_data['ProgressiveLevel'] then
        local deathlink = Tracker:FindObjectForCode("progressive_level_setting")
        deathlink.Active = (slot_data['ProgressiveLevel'])
    end

    if slot_data['ProgressiveElementals'] then
        local scalesanity = Tracker:FindObjectForCode("progressive_rang_setting")
        scalesanity.Active = (slot_data['ProgressiveElementals'])
    end
    if slot_data['DeathLink'] then
        local deathlink = Tracker:FindObjectForCode("deathlink")
        deathlink.Active = (slot_data['DeathLink'])
    end

    if slot_data['Scalesanity'] then
        local scalesanity = Tracker:FindObjectForCode("scale_sanity")
        scalesanity.Active = (slot_data['Scalesanity'])
    end

    if slot_data['Signsanity'] then
        local scalesanity = Tracker:FindObjectForCode("sign_sanity")
        scalesanity.Active = (slot_data['Signsanity'])
    end

    if slot_data['Lifesanity'] then
        local scalesanity = Tracker:FindObjectForCode("life_sanity")
        scalesanity.Active = (slot_data['Lifesanity'])
    end

    if slot_data['Framesanity'] then
        local framesanity = Tracker:FindObjectForCode("frames")
        framesanity.CurrentStage = (slot_data['Framesanity'])
    end

    if slot_data['FramesRequireInfra'] then
        local frameinfra = Tracker:FindObjectForCode("frames_require_infra")
        frameinfra.Active = (slot_data['FramesRequireInfra'])
    end

    if slot_data['GateTimeAttacks'] then
        local frameinfra = Tracker:FindObjectForCode("gateTimeAttacks")
        frameinfra.Active = (slot_data['GateTimeAttacks'])
    end

    if slot_data['CogGating'] then
        local cogGating = Tracker:FindObjectForCode("cogGating")
        cogGating.AcquiredCount = (slot_data['CogGating'])
    end

    if slot_data['TheggGating'] then
        local theggGating = Tracker:FindObjectForCode("theggGating")
        theggGating.AcquiredCount = (slot_data['TheggGating'])
    end

    if slot_data['LevelUnlockStyle'] then
        local uls = Tracker:FindObjectForCode("levelunlockstyle")
        uls.CurrentStage = (slot_data['LevelUnlockStyle'])
    end

    if slot_data['PortalMap'] then
        local uls = Tracker:FindObjectForCode("levelunlockstyle")
        local int i = 1;
        for _,id in pairs(slot_data['PortalMap']) do
            local portal = Tracker:FindObjectForCode("portal"..i)
            portal.CurrentStage = LEVEL_MAPPING[id][2]
            if uls.CurrentStage == 0 then
                portal.Active = true
                local portalitem = Tracker:FindObjectForCode(LEVEL_MAPPING[id][1])
                portalitem.Active = true
            else
                portal.Active = false
            end
            
            i = i+1
        end
        if uls.CurrentStage ~= 0 then
            local firstportal = Tracker:FindObjectForCode(LEVEL_MAPPING[slot_data['PortalMap'][1]][1])
            firstportal.Active = true
            local portal1 = Tracker:FindObjectForCode("portal1")
            portal1.Active = true
        else
            local portalitem = Tracker:FindObjectForCode("portal-cass'pass")
            portalitem.Active = true
        end
       
       PORTAL_MAP = slot_data['PortalMap']
    end
    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0
    SLOT_DATA = slot_data

    -- if Archipelago.PlayerNumber > -1 then

    --     HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
    --     Archipelago:SetNotify({HINTS_ID})
    --     Archipelago:Get({HINTS_ID})
    -- end

    if Archipelago.PlayerNumber > -1 then
        CUR_STAGE = "ty1_level_"..Archipelago.TeamNumber.."_"..Archipelago:GetPlayerAlias(Archipelago.PlayerNumber)
        
        Archipelago:SetNotify({CUR_STAGE})
        Archipelago:Get({CUR_STAGE})
    end
end


function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local item = ITEM_MAPPING[item_id]
    if not item or not item[1] then
        print(string.format("onItem: could not find item mapping for id %s", item_id))
        return
    end
    local item_code = item[1]
    local item_type = item[2]
    local item_obj = Tracker:FindObjectForCode(item_code)
    if item_obj then
        if item_obj.Type == "toggle" then
            item_obj.Active = true 
            if string.find(item_code, "portal") then
                toggleDisplayPortal(item_code, LEVEL_MAPPING)
            else
                
            end
        elseif item_obj.Type == "progressive" then
            item_obj.Active = true

        elseif item_obj.Type == "consumable" then
            item_obj.AcquiredCount = item_obj.AcquiredCount + item_obj.Increment * (tonumber(item[3]) or 1)
            if(item_code == "progressiverang") then
                local nextrang = Tracker:FindObjectForCode(ELEMENTAL_MAPPING[item_obj.AcquiredCount][1])
                nextrang.Active = true
            end

            if(item_code == "progressivelevel") then
                
                local nextportal = ProgressivePortalUpdated(item_obj, LEVEL_MAPPING, PORTAL_MAP)
                nextportal.Active = true
            end

            local uls = Tracker:FindObjectForCode("levelunlockstyle")
            if((uls.CurrentStage == 0 or uls.CurrentStage == 2) and item_code == "firethunderegg") then
                
                if item_obj.AcquiredCount >= Tracker:ProviderCountForCode("theggGating") then
                    local boss = Tracker:FindObjectForCode("portal-bull'spen")
                    boss.Active = true
                end
            end

            if((uls.CurrentStage == 0 or uls.CurrentStage == 2) and item_code == "icethunderegg") then
                
                if item_obj.AcquiredCount >= Tracker:ProviderCountForCode("theggGating")then
                    local boss = Tracker:FindObjectForCode("portal-crikey'scove")
                    boss.Active = true
                end
            end

            if((uls.CurrentStage == 0 or uls.CurrentStage == 2) and item_code == "airthunderegg") then
                
                if item_obj.AcquiredCount >= Tracker:ProviderCountForCode("theggGating") then
                    local boss = Tracker:FindObjectForCode("portal-fluffy'sfjord")
                    boss.Active = true
                end
            end

        elseif item_obj.Type == "progressive_toggle" then
            if item_obj.Active then
                item_obj.CurrentStage = item_obj.CurrentStage + 1
            else
                item_obj.Active = true
            end
        end
    else
        print(string.format("onItem: could not find object for code %s", item_code[1]))
    end

end

--called when a location gets cleared
function onLocation(location_id, location_name)
    local location_array = LOCATION_MAPPING[location_id]
    if not location_array or not location_array[1] then
        print(string.format("onLocation: could not find location mapping for id %s", location_array[1]))
        return
    end
    local location = location_array[1]
    local counter = location_array[2]

    local location_obj = Tracker:FindObjectForCode(location)
    if location_obj then
        if location:sub(1, 1) == "@" then
            location_obj.AvailableChestCount = location_obj.AvailableChestCount - 1
        else
            location_obj.Active = true
        end

        if counter then
            local item_obj = Tracker:FindObjectForCode(counter)
            item_obj.AcquiredCount = item_obj.AcquiredCount + item_obj.Increment
        end

        if location == "@Two Up/End/Glide The Gap" then
            Tracker:FindObjectForCode("a1thegg").Active = true
        end
        if location == "@WitP/End/Truck Trouble" then
            Tracker:FindObjectForCode("a2thegg").Active = true
        end
        if location == "@Ship Rex/Main/Spire/Where's Elle?" then
            Tracker:FindObjectForCode("a4thegg").Active = true
        end
        if location == "@BotRT/Upper/Home, Sweet, Home" then
            Tracker:FindObjectForCode("b1thegg").Active = true
        end
        if location == "@Snow Worries/Koala Chaos" then
            Tracker:FindObjectForCode("b2thegg").Active = true
        end
        if location == "@Outback Safari/Shazza Loop/Emu Roundup" then
            Tracker:FindObjectForCode("b3thegg").Active = true
        end
        if location == "@LLPoF/End/Lenny The Lyrebird" then
            Tracker:FindObjectForCode("c1thegg").Active = true
        end
        if location == "@BtBS/Koala Crisis" then
            Tracker:FindObjectForCode("c2thegg").Active = true
        end
        if location == "@RMtS/Skull Island/Treasure Hunt" then
            Tracker:FindObjectForCode("c3thegg").Active = true
        end
    else
        print(string.format("onLocation: could not find location_object for code %s", location))
    end
end

function onEvent(key, value, old_value)
    updateEvents(value)
end

function onEventsLaunch(key, value)
    updateEvents(value)
end

function onNotify(key, value, old_value)
    print("onNotify", key, value, old_value)
    -- if value ~= old_value and key == HINTS_ID then
    --     for _, hint in ipairs(value) do
    --         print("hint", hint, hint.found)
    --         print(dump_table(hint))
    --         if hint.finding_player == Archipelago.PlayerNumber then
    --             if hint.found then
    --                 updateHints(hint.location, true)
    --             else
    --                 updateHints(hint.location, false)
    --             end
    --         end
    --     end
    -- end
    if key == CUR_STAGE and has("automap_on")  then
        local tab = LEVEL_MAPPING[value][3]
        Tracker:UiHint("ActivateTab", tab)
    end
end

function onNotifyLaunch(key, value)
    print("onNotifyLaunch", key, value)
    -- if key == HINTS_ID then
    --     for _, hint in ipairs(value) do
    --         print("hint", hint, hint.found)
    --         print(dump_table(hint))
    --         if hint.finding_player == Archipelago.PlayerNumber then
    --             if hint.found then
    --                 updateHints(hint.location, true)
    --             else
    --                 updateHints(hint.location, false)
    --             end
    --         end
    --     end
    -- end

    if key == CUR_STAGE and has("automap_on") then
        local tab = LEVEL_MAPPING[value][3]
        Tracker:UiHint("ActivateTab", tab)
    end
end

-- function updateHints(locationID, clear)
--     local item_codes = HINTS_MAPPING[locationID]
    
--     for _, item_table in ipairs(item_codes, clear) do
--         for _, item_code in ipairs(item_table) do
--             local obj = Tracker:FindObjectForCode(item_code)
--             if obj then
--                 if not clear then
--                     obj.Active = true
--                 else
--                     obj.Active = false
--                 end
--             else
--                 print(string.format("No object found for code: %s", item_code))
--             end
--         end
--     end
-- end

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)

Archipelago:AddSetReplyHandler("notify handler", onNotify)
Archipelago:AddRetrievedHandler("notify launch handler", onNotifyLaunch)

--doc
--hint layout
-- {
--     ["receiving_player"] = 1,
--     ["class"] = Hint,
--     ["finding_player"] = 1,
--     ["location"] = 67361,
--     ["found"] = false,
--     ["item_flags"] = 2,
--     ["entrance"] = ,
--     ["item"] = 66062,
-- } 
