undergroundPlayersData = {}

function setUnderground(player, belt)
  local char = player.character
  local car = char.surface.create_entity({
      name = 'invisible-car',
      position = char.position,
      force = char.force,
      direction = belt.direction
  })
  car.speed = belt.prototype.belt_speed
  player.driving = true

  undergroundPlayersData[player.index] = { entrance = belt, exit = belt.neighbours, car = car }
end

function setOverground(player, belt)
  player.vehicle.destroy()
  player.driving = false
  player.teleport(belt.position)

  undergroundPlayersData[player.index] = nil
end

function goBackToEntrance(player)
  local data = undergroundPlayersData[player.index]
  player.teleport(data.entrance.position)
  data.car.destroy()

  undergroundPlayersData[player.index] = nil
end

script.on_event(defines.events.on_player_changed_position, function(e)
  local player = game.players[e.player_index]

  local belt = player.surface.find_entities_filtered({ position = player.position, radius = 1, type = 'underground-belt' })[1]
  if not belt then return end

  if not player.vehicle and belt.belt_to_ground_type == 'input' then setUnderground(player, belt)
  elseif player.vehicle and player.vehicle.name == 'invisible-car' and belt == undergroundPlayersData[player.index].exit then setOverground(player, belt) 
  end

  if not player.vehicle and undergroundPlayersData[player.index] then goBackToEntrance(player) end
end)
script.on_event(defines.events.on_player_driving_changed_state, function (e)
  local player = game.players[e.player_index]

  if not undergroundPlayersData[player.index] then return end

  goBackToEntrance(player)
end)
