data:extend{{
    type = "car",
    name = "Underground",
    icon = "__base__/graphics/icons/underground-belt.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-flammable"},
    max_health = 100,
    energy_per_hit_point = 1,
    has_belt_immunity = true,
    resistances = {{
        type = "fire",
        percent = 100
    }, {
        type = "impact",
        percent = 100,
        decrease = 50
    }, {
        type = "acid",
        percent = 100
    }},
    collision_box = {{-1, -1}, {1, 1}},
    collision_mask = {},
    selection_box = {{-0, -0}, {0, 0}},
    effectivity = 1e-44,
    braking_force = 1e-44,
    energy_source = {
        type = "void"
    },
    consumption = "0kW",
    friction = 1e-44,
    render_layer = "object",
    animation = {
        layers = {{
            filename = "__core__/graphics/empty.png",
            priority = "low",
            direction_count = 1,
            width = 1,
            height = 1,
            frame_count = 1
        }}
    },
    turret_rotation_speed = 1e-44,
    rotation_speed = 1e-44,
    weight = 1e-44,
    inventory_size = 0
}}
