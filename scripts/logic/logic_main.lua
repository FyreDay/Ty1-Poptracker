
-- ScriptHost:AddWatchForCode("ow_dungeon details handler", "ow_dungeon_details", owDungeonDetails)


ty_the_tasmanian_tiger_location = {}
ty_the_tasmanian_tiger_location.__index = ty_the_tasmanian_tiger_location

accessLVL= {
    [0] = "none",
    [1] = "partial",
    [3] = "inspect",
    [5] = "sequence break",
    [6] = "normal",
    [7] = "cleared"
}

-- Table to store named locations
named_locations = {}
staleness = 0

-- 
function can_reach(name)
    local location
    -- if type(region_name) == "function" then
    --     location = self
    -- else
    if type(name) == "table" then
        -- print(name.name)
        location = named_locations[name.name]
    else 
        location = named_locations[name]
    end
    -- print(location, name)
    -- end
    if location == nil then
        -- print(location, name)
        if type(name) == "table" then
        else
            print("Unknown location : " .. tostring(name))
        end
        return AccessibilityLevel.None
    end
    return location:accessibility()
end

-- creates a lua object for the given name. it acts as a representation of a overworld region or indoor location and
-- tracks its connected objects via the exit-table
function ty_the_tasmanian_tiger_location.new(name)
    local self = setmetatable({}, ty_the_tasmanian_tiger_location)
    if name then
        named_locations[name] = self
        self.name = name
    else
        self.name = self
    end

    self.exits = {}
    self.staleness = -1
    self.keys = math.huge
    self.accessibility_level = AccessibilityLevel.None
    return self
end

local function always()
    return AccessibilityLevel.Normal
end

-- marks a 1-way connections between 2 "locations/regions" in the source "locations" exit-table with rules if provided
function ty_the_tasmanian_tiger_location:connect_one_way(exit, rule)
    if type(exit) == "string" then
        exit = ty_the_tasmanian_tiger_location.new(exit)
    end
    if rule == nil then
        rule = always
    end
    self.exits[#self.exits + 1] = { exit, rule }
end

-- marks a 2-way connection between 2 locations. acts as a shortcut for 2 connect_one_way-calls 
function ty_the_tasmanian_tiger_location:connect_two_ways(exit, rule)
    self:connect_one_way(exit, rule)
    exit:connect_one_way(self, rule)
end

-- creates a 1-way connection from a region/location to another one via a 1-way connector like a ledge, hole,
-- self-closing door, 1-way teleport, ...
function ty_the_tasmanian_tiger_location:connect_one_way_entrance(name, exit, rule)
    if rule == nil then
        rule = always
    end
    self.exits[#self.exits + 1] = { exit, rule }
end

-- creates a connection between 2 locations that is traversable in both ways using the same rules both ways
-- acts as a shortcut for 2 connect_one_way_entrance-calls
function ty_the_tasmanian_tiger_location:connect_two_ways_entrance(name, exit, rule)
    if exit == nil then -- for ER
        return
    end
    self:connect_one_way_entrance(name, exit, rule)
    exit:connect_one_way_entrance(name, self, rule)
end

-- creates a connection between 2 locations that is traversable in both ways but each connection follow different rules.
-- acts as a shortcut for 2 connect_one_way_entrance-calls
function ty_the_tasmanian_tiger_location:connect_two_ways_entrance_door_stuck(name, exit, rule1, rule2)
    self:connect_one_way_entrance(name, exit, rule1)
    exit:connect_one_way_entrance(name, self, rule2)
end

-- checks for the accessibility of a regino/location given its own exit requirements
function ty_the_tasmanian_tiger_location:accessibility()
    if self.staleness < staleness then
        return AccessibilityLevel.None
    else
        return self.accessibility_level
    end
end

-- 
function ty_the_tasmanian_tiger_location:discover(accessibility, keys)

    local change = false
    if accessibility > self:accessibility() then
        change = true
        self.staleness = staleness
        self.accessibility_level = accessibility
        self.keys = math.huge
    end
    if keys < self.keys then
        self.keys = keys
        change = true
    end

    if change then
        for _, exit in pairs(self.exits) do
            local location = exit[1]
            local rule = exit[2]

            local access, key = rule(keys)
            -- print(access)
            if access == 5 then
                access = AccessibilityLevel.SequenceBreak
            elseif access == true then
                access = AccessibilityLevel.Normal
            elseif access == false then
                access = AccessibilityLevel.None
            end
            if key == nil then
                key = keys
            end
            -- print(self.name) 
            -- print(accessLVL[self.accessibility_level], "from", self.name, "to", location.name, ":", accessLVL[access])
            location:discover(access, key)
        end
    end
end

entry_point = ty_the_tasmanian_tiger_location.new("entry_point")

-- 
function stateChanged()
    staleness = staleness + 1
    entry_point:discover(AccessibilityLevel.Normal, 0)
end

function frameInfraRule()
    if not has("frames_require_infra") then
        return AccessibilityLevel.Normal
    end
    if not has("infrarang") then
        return AccessibilityLevel.SequenceBreak
    end
    return AccessibilityLevel.Normal
end

function zoomerangRule()
    return Tracker:ProviderCountForCode("goldencog") >= Tracker:ProviderCountForCode("cogGating") 
end

function multirangRule()
    return Tracker:ProviderCountForCode("goldencog") >= Tracker:ProviderCountForCode("cogGating")*2 
end

function infrarangRule()
    return Tracker:ProviderCountForCode("goldencog") >= Tracker:ProviderCountForCode("cogGating")*3 
end

function megarangRule()
    return Tracker:ProviderCountForCode("goldencog") >= Tracker:ProviderCountForCode("cogGating")*4 
end

function kaboomerangRule()
    return Tracker:ProviderCountForCode("goldencog") >= Tracker:ProviderCountForCode("cogGating")*5 
end

function chronorangRule()
    return Tracker:ProviderCountForCode("goldencog") >= Tracker:ProviderCountForCode("cogGating")*6 
end

function flamerangRule()
    return Tracker:ProviderCountForCode("firethunderegg") >= Tracker:ProviderCountForCode("theggGating") 
    and Tracker:FindObjectForCode("@Rainbow Cliffs/Hub 1/Frog Talisman").AvailableChestCount == 0
end

function frostyrangRule()
    return Tracker:ProviderCountForCode("icethunderegg") >= Tracker:ProviderCountForCode("theggGating") --and has("platypustalisman")
    and Tracker:FindObjectForCode("@Rainbow Cliffs/Hub 2/Platypus Talisman").AvailableChestCount == 0
end

function zappyrangRule()
    return Tracker:ProviderCountForCode("airthunderegg") >= Tracker:ProviderCountForCode("theggGating") --and has("cockatootalisman")
    and Tracker:FindObjectForCode("@Rainbow Cliffs/Hub 3/Cockatoo Talisman").AvailableChestCount == 0
end

function ProgressivePortalUpdated(item_obj, LEVEL_MAPPING, PORTAL_MAP)
    --progressivelevel is always 1 less then the unlocked indexes
    local unlockstyle = Tracker:FindObjectForCode("levelunlockstyle")
    if(unlockstyle.CurrentStage == 1) then
        if(item_obj.AcquiredCount+1 > 12) then
            return Tracker:FindObjectForCode("portal-cass'pass")
        end
        if(item_obj.AcquiredCount+1 == 12) then
            return Tracker:FindObjectForCode("portal-fluffy'sfjord")
        end
        if(item_obj.AcquiredCount+1 > 8) then
            local code = LEVEL_MAPPING[PORTAL_MAP[item_obj.AcquiredCount-1]][1]
            toggleDisplayPortal(code, LEVEL_MAPPING)
            return Tracker:FindObjectForCode(code)
        end
        if(item_obj.AcquiredCount+1 == 8) then
            return Tracker:FindObjectForCode("portal-crikey'scove")
        end
        if(item_obj.AcquiredCount+1 > 4) then
            local code = LEVEL_MAPPING[PORTAL_MAP[item_obj.AcquiredCount]][1]
            toggleDisplayPortal(code, LEVEL_MAPPING)
            return Tracker:FindObjectForCode(code)
        end
        if(item_obj.AcquiredCount+1 == 4) then
            return Tracker:FindObjectForCode("portal-bull'spen")
        end
        local code = LEVEL_MAPPING[PORTAL_MAP[item_obj.AcquiredCount+1]][1]
        toggleDisplayPortal(code, LEVEL_MAPPING)
        return Tracker:FindObjectForCode(code)
        
    elseif(unlockstyle.CurrentStage == 2) then

        if(item_obj.AcquiredCount+1 < 10) then
            local code = LEVEL_MAPPING[PORTAL_MAP[item_obj.AcquiredCount+1]][1]
            toggleDisplayPortal(code, LEVEL_MAPPING)
            return Tracker:FindObjectForCode(code)
        end
        return Tracker:FindObjectForCode("portal-cass'pass")
    end
    
end
--nullable
function toggleDisplayPortal(item_code, LEVEL_MAPPING)
    local index
    for _,pair in pairs(LEVEL_MAPPING) do
        if pair[1] == item_code then
            index = pair[2]
            break
        end
    end
    if index == nil then
        return
    end

    for i = 1, 9 do
        local portal = Tracker:FindObjectForCode("portal"..i)
        if portal.CurrentStage == index then
            portal.Active = true
            break
        end
    end
end

ScriptHost:AddWatchForCode("stateChanged", "*", stateChanged)
        