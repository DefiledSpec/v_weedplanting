# Task
Task will be weed planting.
Requirements:
> usage ox_lib / ox_target if possible
> no networked props (but all of the crops have to be synced between players)
> should be very well configurable
> should have few stages of crop growth (prop models can be placeholders)
> have option to water the plant, configured value of humidity accelerates growth
> It does not need to be fully polished, but all of the functionalities should just work
you also are not required to do any fancy UI's. Whatever you gonna find useful from ox_lib you can use.

By watering the plant & humidity I mean a system, where player is able to use item "water" to increase / decrease "water level / humidity" of plant's soil 
It should be configurable as much as possible
also the "water level / humidity" when plant grows fastest should be configurable as range of values in between
If something is not understandable please let me know

# Problems Faced

1. Deleting all props and respawning closest causes props to blink when refreshing
 > Solution: Check spawned props and delete any that are out of view distance, loop all plants that arent already spawned and spawn them if in distance
 ```lua
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
 ```