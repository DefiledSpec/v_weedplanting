local shared = require 'config.shared';
local config = require 'config.server';

RegisterNetEvent('v_weedplanting:server:plantWeed', function(name, coords)
    local id = InsertWeedPlant(shared.plants[name], coords);
    local plant = GetWeedPlantById(id);
    TriggerClientEvent('v_weedplanting:client:plantWeed', -1, plant);
end);

lib.callback.register('v_weedplanting:getPlants', function(source)
    local results = GetAllPlants();
    local plants = {};
    for i, plant in pairs(results) do
        plants[plant.id] = plant;
    end

    return plants;
end);

lib.callback.register('v_weedplanting:waterPlant', function (source, id, water)
    local success = UpdatePlantWater(id, water);
    return success;
end);

lib.callback.register('v_weedplanting:harvestPlant', function (source, id)
    local plant = GetWeedPlantById(id);
    local success = false;

    if plant and (plant.harvestable or plant.dead) then
        if plant.dead then
            local rewardQty = math.random(config.rewardDead.min, config.rewardDead.max);
            AddItem(source, config.rewardDead.item, rewardQty);
        else
            local rewardQty = math.random(plant.data.reward.min, plant.data.reward.max);
            AddItem(source, plant.data.reward.item, rewardQty);
        end
        DeletePlantById(id);
        success = true;
    end
    
    return success;
end);

lib.cron.new(config.updateRate, function()
    local success = UpdateWeedProgress();
    if success then
        local results = GetAllPlants();
        local plants = {};
        for i, plant in pairs(results) do
            plants[plant.id] = plant;
        end

        TriggerClientEvent('v_weedplanting:client:updatePlants', -1, plants);
    end
end, { debug = shared.debug });