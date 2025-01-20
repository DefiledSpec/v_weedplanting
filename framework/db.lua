local config = require 'config.server';
local shared = require 'config.shared';

function InsertWeedPlant(data, coords)
    local id = MySQL.insert.await([[
        INSERT INTO `v_weed_plants` (data, coords)
        VALUES (:data, :coords);
    ]], { data = json.encode(data), coords = json.encode(coords) });
    return id;
end

function GetWeedPlantById(id)
    local plant = MySQL.single.await([[
        SELECT * FROM `v_weed_plants` WHERE id = :id
    ]], { id = id });
    if plant then
        plant.data = json.decode(plant.data);
        plant.coords = json.decode(plant.coords);
    end
    return plant;
end

function UpdatePlantWater(id, water)
    local updated = MySQL.update.await([[
        UPDATE `v_weed_plants`
            SET `water` = :water
            WHERE id = :id
    ]], {
        water = water,
        id = id
    });

    return updated > 0;
end

function UpdateWeedProgress()
    local plants = MySQL.query.await([[SELECT * FROM `v_weed_plants` WHERE `dead` = 0;]]);
    local updates = {};

    for rowid, row in pairs(plants) do
        row.data = json.decode(row.data);
        local plantData = row.data;
        local newPlantData = row;

        if not row.harvestable then
            local maxStage = #plantData.stages;
            if row.water > 0 then -- update stage growth
                if row.water >= plantData.targetWater.min and row.water <= plantData.targetWater.max then
                    newPlantData.stageProgress = row.stageProgress + math.random(config.targetBonus.min, config.targetBonus.max);
                else
                    newPlantData.stageProgress = row.stageProgress + math.random(config.growProgress.min, config.growProgress.max);
                end

                if newPlantData.stageProgress >= 100 then -- increase stage, check if stage is final stage
                    newPlantData.stage = row.stage + 1;
                    newPlantData.stageProgress = 0;
                    if newPlantData.stage == maxStage then
                        newPlantData.harvestable = true;
                    end
                end
            end
        end

        if newPlantData.water <= 0 then -- tick down health till dead
            newPlantData.health = math.max(row.health - math.random(config.dieRate.min, config.dieRate.max), 0);
            if newPlantData.health <= 0 then
                newPlantData.dead = true;
            end
        end
        newPlantData.water = math.max(row.water - math.random(config.waterUsage.min, config.waterUsage.max), 0);

        table.insert(updates, {
            [[
                UPDATE `v_weed_plants` 
                    SET `stageProgress` = :stageProgress,
                    `stage` = :stage,
                    `water` = :water,
                    `health` = :health,
                    `dead` = :dead,
                    `harvestable` = :harvestable
                WHERE `id` = :id;
            ]], {
                stageProgress = newPlantData.stageProgress,
                stage = newPlantData.stage,
                water = newPlantData.water,
                health = newPlantData.health,
                dead = newPlantData.dead,
                harvestable = newPlantData.harvestable,
                id = newPlantData.id
            }
        });
    end

    local success = MySQL.transaction.await(updates);

    if shared.debug then
        print('updates ' .. #updates, success);
    end

    return success;
end

function GetAllPlants()
    local rows = MySQL.query.await([[SELECT * FROM `v_weed_plants`]]);
    for i, row in pairs(rows) do
        row.data = json.decode(row.data);
        row.coords = json.decode(row.coords);
        row.coords = vector3(row.coords.x, row.coords.y, row.coords.z);
    end
    return rows;
end
