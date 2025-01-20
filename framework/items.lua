exports('plant_weed', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
        if data then
            PlantWeed(data.name);
        end
    end)
end);
