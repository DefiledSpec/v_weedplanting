local shared = require 'config.shared';
-- local ITEMS = exports.ox_inventory:Items();

local plants = {};
local spawnedPlants = {};
local updating = false;

local function addTargetOptions(handle, plant)

end

local function deletePlant(model, coords)
    if not model or not coords then return end
    local closest = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.5, model, false, false, false);
    if closest == 0 then return end
    DeleteObject(closest);
end

local function placePlant(model, coords)
    local plant = CreateObject(joaat(model), coords.x, coords.y, coords.z, false, false, false);

    while not plant do
        Wait(0);
    end

    PlaceObjectOnGroundProperly(plant);
    Wait(10)
    FreezeEntityPosition(plant, true);
    SetEntityAsMissionEntity(plant, false, false);

    return plant;
end

local function despawnPlant(handle)
    if handle ~= 0 then
        if IsEntityAMissionEntity(handle) then
            SetEntityAsMissionEntity(handle, false, true);
        end
        DeleteObject(handle);
    end
end

local function despawnPlants()
    for i, plant in pairs(spawnedPlants) do
        despawnPlant(plant.handle)
    end
    spawnedPlants = {};
end


local function refreshPlants()
    print('refreshing plants')
    updating = true;

    local playerCoords = GetEntityCoords(cache.ped);
    for id, spawned in pairs(spawnedPlants) do
        if #(playerCoords - vector3(spawned.coords.x, spawned.coords.y, spawned.coords.z)) > shared.proximityDistance then
            despawnPlant(spawned.handle);
            spawnedPlants[id] = nil;
        end
    end
    
    for k, plant in pairs(plants) do
        -- print('test', json.encode(plant, {indent = true}))
        if #(playerCoords - vector3(plant.coords.x, plant.coords.y, plant.coords.z)) <= shared.proximityDistance and not spawnedPlants[plant.id] then
            -- despawnPlant(plant.handle)
            local model = plant.data.stages[plant.stage];
            local handle = placePlant(model, plant.coords);

            local data = plant;
            data.handle = handle;
            data.model = model;

            
            spawnedPlants[data.id] = data;
        end
    end
    for i, plant in pairs(spawnedPlants) do
        addTargetOptions(plant.handle, plant);
    end
    updating = false;
end

RegisterNetEvent('v_weedplanting:client:plantWeed', function(plant)
    -- table.insert(plants, plant);
    plants[plant.id] = plant;
    local playerCoords = GetEntityCoords(cache.ped);

    if #(playerCoords - vector3(plant.coords.x, plant.coords.y, plant.coords.z)) < shared.proximityDistance then
        local model = plant.data.stages[plant.stage];
        local handle = placePlant(model, plant.coords);

        local data = plant;
        data.handle = handle;
        data.model = model;

        -- table.insert(spawnedPlants, data);
        spawnedPlants[data.id] = data;
    end
end)

RegisterNetEvent('v_weedplanting:client:updatePlants', function(weedPlants)
    if source == '' or GetInvokingResource() then return end
    plants = weedPlants;
    refreshPlants();
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    despawnPlants();
end)

RegisterCommand('plant', function(_, args)
    local plant = 'prodigy_purp';
    if args and args[1] and table.contains({
        'prodigy_purp',
    }, args[1]) then plant = args[1]; end

    local ped = PlayerPedId();
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0, 1, 0);

    TriggerServerEvent('v_weedplanting:server:plantWeed', plant, offset);
end, false);

RegisterCommand('water', function(_, args)
    local id = 1;
    local water = 0;
    if args and args[1] then id = tonumber(args[1]); end
    if args and args[2] then water = tonumber(args[2]); end

    local ped = PlayerPedId();
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0, 1, 0);
    local plantData = plants?[id];
    if not plantData then return end
    -- local plant = GetClosestObjectOfType(plantData.coords.x, plantData.coords.y, plantData.coords.z, 3.5, plantData.model, false, false, false)
    SetEntityDrawOutlineColor(0, 0, 255, 1);
    SetEntityDrawOutlineShader(1);
    SetEntityDrawOutline(plantData.handle, true);
    local update = math.min(plantData.water + water, 100);
    local updated = lib.callback.await('v_weedplanting:waterPlant', false, plantData.id, update);
    exports.qbx_core:Notify('updated water ' .. update);
end, false);

RegisterCommand('listplants', function(_, args)
    print('plants', json.encode(plants, { indent = true }));
    print('spawnedPlants', json.encode(spawnedPlants, { indent = true }));
end, false);


CreateThread(function()
    plants = lib.callback.await('v_weedplanting:getPlants', false);
    while(true) do
        refreshPlants();
        Wait(5000);
    end
end)


-- CreateThread(function()
--     for i, stage in pairs(shared.plants.prodigy_purp.stageProps) do
--         local plant = CreateObject(joaat(stage), test.x, test.y, test.z, false, false, false);

--         while not plant do
--             Wait(0);
--         end

--         PlaceObjectOnGroundProperly(plant);
--         Wait(10)
--         FreezeEntityPosition(plant, true);
--         SetEntityAsMissionEntity(plant, false, false);
--         table.insert(plants, {
--             plant = 'Prodigiy Purple',
--             coords = test,
--             model = stage,
--             obj = plant,
--         });
--         test = vector3(test.x + 2, 1498.66, 113.61);
--     end
--     print('plants', json.encode(plants, { indent = true }));
-- end)
