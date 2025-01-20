local shared = require 'config.shared';

local ITEMS = exports.ox_inventory:Items();

RegisterNetEvent('v_weedplanting:server:plantWeed', function(name, coords)
    local id = InsertWeedPlant(shared.plants[name], coords);
    local plant = GetWeedPlantById(id);
    TriggerClientEvent('v_weedplanting:client:plantWeed', -1, plant);
end);

lib.callback.register('v_weedplanting:getPlants', function(source)
    local results = GetAllPlants();
    print('results', json.encode(results))
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

lib.cron.new('* * * * *', function()
    local success = UpdateWeedProgress();
    if success then
        local plants = GetAllPlants();
        TriggerClientEvent('v_weedplanting:client:updatePlants', -1, plants);
    end
end, { debug = shared.debug });