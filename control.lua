undergroundPlayersData = {}

function setUnderground(player, belt)
  -- Create a car and put the player in
  local char = player.character
  local car = char.surface.create_entity({
      name = 'Underground',
      position = char.position,
      force = char.force,
      direction = belt.direction
  })
  car.speed = belt.prototype.belt_speed
  player.driving = true

  -- Calculates timer
  local belts_distance = math.abs(belt.position.x - belt.neighbours.position.x) + math.abs(belt.position.y - belt.neighbours.position.y)
  local belt_speed = belt.prototype.belt_speed
  local timer = belts_distance / belt_speed

  undergroundPlayersData[player.index] = { exit = belt.neighbours, exit_coord = belt.neighbours.position, direction = belt.direction, car = car, timer = timer }
end
function setOverground(player)
  -- Saving it before deleting
  local data = undergroundPlayersData[player.index]
  undergroundPlayersData[player.index] = nil

  -- Destroy car
  player.vehicle.destroy()
  player.driving = false

  -- Teleport to exit
  local offx = 0
  local offy = 0
  local gap = 0.51

  if data.direction == 6 then offx = offx - gap
  elseif data.direction == 2 then offx = offx + gap
  elseif data.direction == 0 then offy = offy - gap
  elseif data.direction == 4 then offy = offy + gap
  end

  player.teleport({x = data.exit_coord.x + offx, y = data.exit_coord.y + offy})
end

script.on_event(defines.events.on_player_changed_position, function(e)
  local player = game.players[e.player_index]

  local belt = player.surface.find_entities_filtered({ position = player.position, radius = 1, type = 'underground-belt' })[1]
  if not belt or not belt.neighbours then return end

  if not player.vehicle and belt.belt_to_ground_type == 'input' then setUnderground(player, belt)
  elseif player.vehicle and player.vehicle.name == 'Underground' and belt == undergroundPlayersData[player.index].exit then setOverground(player) 
  end
end)
script.on_event(defines.events.on_player_driving_changed_state, function (e)
  -- Forces player to stay on the car
  local player = game.players[e.player_index]
  if not undergroundPlayersData[player.index] then return end
  
  player.driving = true
end)
script.on_event(defines.events.on_tick, function (e)
  -- Iterate all underground players, decreasing it timer, and setting overground if the timer is done
  for player_id, data in pairs(undergroundPlayersData) do
    undergroundPlayersData[player_id].timer = undergroundPlayersData[player_id].timer - 1
    if data.timer <= 0 then setOverground(game.get_player(player_id)) end
  end
end)
