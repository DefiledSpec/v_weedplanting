exports('plant_weed', function(item, slot)
    exports.ox_inventory:useItem(item, function(data)
        if data then
            PlantWeed(item.name);
        end
    end)
end);
