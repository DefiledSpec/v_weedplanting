local shared = require 'config.shared';
local config = require 'config.client';

local plants = {};
local spawnedPlants = {};
local targets = {};

local function deletePlant(model, coords)
    if not model or not coords then return end
    local closest = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.5, model, false, false, false);
    if closest == 0 then return end
    DeleteObject(closest);
end

local function addTargetOptions(handle, plant)
    local options = {
        {
            label = 'Check Status',
            name = ('water_plant_%d'):format(plant.id),
            distance = 10,
            onSelect = function()
                local plantData = plants?[plant.id];
                lib.notify({
                    description = ('Humidity: %d | Health: %d | Stage: %d/%d\nStrain: %s'):format(plantData.water, plantData.health, plantData.stage, #plantData.data.stages, plantData.data.label),
                    type = 'success',
                    icon = 'fa-cannabis'
                });
            end,
        },
        {
            label = 'Water',
            name = ('water_plant_%d'):format(plant.id),
            distance = 10,
            canInteract = function()
                local plantData = plants?[plant.id];
                if plantData.water >= 100 or plantData.dead then return false end
                return true;
            end,
            onSelect = function()
                local plantData = plants?[plant.id];
                if not plantData then return print('no plant', plantData, plant.id) end
                if plantData.water >= 100 or plantData.dead then return end
                local input = lib.inputDialog('How much water would you like to use?', {
                    { type = 'slider', required = true, min = 1, max = 100 - plantData.water }
                });
                if lib.progressBar({
                    duration = config.waterDuration,
                    label = 'Watering plant...',
                    canCancel = true,
                    anim = config.waterAnim,
                    disable = {
                        move = true,
                        combat = true,
                    }
                }) then
                    if input[1] then
                        local water = math.min(plantData.water + input[1], 100);
                        local updated = lib.callback.await('v_weedplanting:waterPlant', false, plantData.id, water);
                        if updated then
                            plants[plantData.id].water = water;
                            spawnedPlants[plantData.id].water = water;
                            lib.notify({
                                description = ('Humidity %d'):format(water)..'%',
                                type = 'success',
                                icon = 'fa-cannabis'
                            });
                        end
                    end
                end
            end,
        },
        {
            label = 'Harvest',
            name = ('harvest_plant_%d'):format(plant.id),
            distance = 10,
            canInteract = function()
                local plantData = plants?[plant.id];
                return plantData.harvestable or plantData.dead;
            end,
            onSelect = function()
                local plantData = plants?[plant.id];
                if plantData.harvestable or plantData.dead then
                    if lib.progressBar({
                        duration = config.harvestDuration,
                        label = 'Harvesting plant...',
                        canCancel = true,
                        anim = config.harvestAnim,
                        disable = {
                            move = true,
                            combat = true,
                        }
                    }) then
                        local success = lib.callback.await('v_weedplanting:harvestPlant', false, plant.id);
                        if success then
                            deletePlant(plant.model, plant.coords);
                        end
                    end
                end
            end,
        },
    };
    if shared.debug then
        table.insert(options, {
            label = 'DEBUG (' .. plant.id .. ')',
            name = ('debug_plant_%d'):format(plant.id),
            distance = 10,
            onSelect = function(one)
                print(json.encode(plant, { indent = true }));
            end,
        });
    end
    local target = exports.ox_target:addLocalEntity(handle, options);
    table.insert(targets, { handle = handle, target = target });
end

local function placePlant(model, coords)
    local plant = CreateObject(joaat(model), coords.x, coords.y, coords.z, false, false, false);

    while not plant do Wait(0) end

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
    local playerCoords = GetEntityCoords(cache.ped);
    for id, spawned in pairs(spawnedPlants) do
        if #(playerCoords - vector3(spawned.coords.x, spawned.coords.y, spawned.coords.z)) > shared.proximityDistance then
            despawnPlant(spawned.handle);
            spawnedPlants[id] = nil;
        else
            local plant = plants?[id];
            if plant and spawned.model ~= plant.data.stages[plant.stage] then
                despawnPlant(spawned.handle);
                local model = plant.data.stages[plant.stage];
                local handle = placePlant(model, plant.coords);

                local data = plant;
                data.handle = handle;
                data.model = model;
                addTargetOptions(data.handle, data);

                spawnedPlants[data.id] = data;
            end
        end
    end

    for k, plant in pairs(plants) do
        if #(playerCoords - vector3(plant.coords.x, plant.coords.y, plant.coords.z)) <= shared.proximityDistance and not spawnedPlants?[plant.id] then
            local model = plant.data.stages[plant.stage];
            local handle = placePlant(model, plant.coords);

            local data = plant;
            data.handle = handle;
            data.model = model;
            addTargetOptions(data.handle, data);

            spawnedPlants[data.id] = data;
        end
    end
end

RegisterNetEvent('v_weedplanting:client:plantWeed', function(plant)
    plants[plant.id] = plant;
    local playerCoords = GetEntityCoords(cache.ped);

    if #(playerCoords - vector3(plant.coords.x, plant.coords.y, plant.coords.z)) < shared.proximityDistance then
        local model = plant.data.stages[plant.stage];
        local handle = placePlant(model, plant.coords);

        local data = plant;
        data.handle = handle;
        data.model = model;
        addTargetOptions(data.handle, data);

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
    for key, value in pairs(targets) do
        exports.ox_target:removeLocalEntity(value.handle, value.target);
    end
    despawnPlants();
end)

function PlantWeed(strain)
    local ped = PlayerPedId();
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0);

    TriggerServerEvent('v_weedplanting:server:plantWeed', strain, offset);
end
exports('PlantWeed', PlantWeed);

CreateThread(function()
    plants = lib.callback.await('v_weedplanting:getPlants', false);
    while(true) do
        refreshPlants();
        Wait(2500);
    end
end)

-- DEV COMMANDS
RegisterCommand('plant', function(_, args)
    local plant = 'prodigy_purp';
    if args and args[1] then plant = args[1]; end

    PlantWeed(plant);
end, false);

RegisterCommand('water', function(_, args)
    local id = 1;
    local water = 0;
    if args and args[1] then id = tonumber(args[1]); end
    if args and args[2] then water = tonumber(args[2]); end

    local plantData = plants?[id];
    if not plantData then return print('no plant', plantData, id) end

    local update = math.min(plantData.water + water, 100);
    local updated = lib.callback.await('v_weedplanting:waterPlant', false, plantData.id, update);
    if updated then
        plants[id].water = update;
    end
    print('updated water ' .. update, updated)
    lib.notify({
        description = ('Humidity %d'):format(water)..'%',
        type = 'success',
        icon = 'fa-cannabis'
    });
end, false);

RegisterCommand('listplants', function(_, args)
    print('plants', json.encode(plants, { indent = true }));
    print('spawnedPlants', json.encode(spawnedPlants, { indent = true }));
end, false);


RegisterCommand('debugstages', function(_, args)
    local ped = PlayerPedId();
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0);
    for i, stage in pairs(shared.plants.prodigy_purp.stages) do
        local plant = CreateObject(joaat(stage), coords.x, coords.y, coords.z, false, false, false);

        while not plant do
            Wait(0);
        end

        PlaceObjectOnGroundProperly(plant);
        Wait(10)
        FreezeEntityPosition(plant, true);
        SetEntityAsMissionEntity(plant, false, false);

        coords = vector3(coords.x + 1.5, coords.y, coords.z);
    end
end, false);
