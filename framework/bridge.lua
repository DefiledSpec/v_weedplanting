function AddItem(id, item, amount)
    return exports.ox_inventory:AddItem(id, item, amount);
end

function RemoveItem(id, item, count)
    return exports.ox_inventory:RemoveItem(id, item, count);
end
