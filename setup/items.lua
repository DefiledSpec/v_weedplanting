["prodigy_purp"] = {
    label = "Prodigy Purple",
    weight = 0,
    stack = true,
    close = true,
    description = "A small weed seed, strain Prodigy Purple.",
    client = {
        anim = { dict = 'amb@world_human_gardener_plant@male@idle_a', clip = 'idle_a', flag = 49 },
        disable = { move = true, car = true, combat = true },
        usetime = 5000,
        cancel = true,
        strain = 'prodigy_purple',
        export = 'v_weedplanting.plant_weed',
        image = "weed_seed.png",
    }
},
["weed_prodigy"] = {
    label = "Prodigy Purple",
    weight = 0,
    stack = true,
    close = true,
    description = "A small nug of weed, strain Prodigy Purple.",
    client = {
        image = "weed_nug.png",
    }
},
["soil"] = {
    label = "Dirt",
    weight = 0,
    stack = true,
    close = true,
    description = "Its just dirt, idk what you expected.",
    client = {
        image = "dirt.png",
    }
},
["watering_can"] = {
    label = "Watering Can",
    weight = 0,
    stack = true,
    close = true,
    description = "Endless water can, how does it all fit in there?",
    client = {
        image = "watering_can.png",
    }
},
