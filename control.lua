playersMoving = {}

function movePlayers()
  for _, playerData in pairs(playersMoving) do
    local player = playerData.player
    local direction = playerData.direction
    player.walking_state = {walking = true, direction = direction}
  end
end

function getBeltUnder(player)
  local px, py = player.position.x, player.position.y
  local ps = 0.15 -- Half of player size (0.5)

  --                Start X and Y  |  End X and Y
  local beltArea = {{px-ps, py-ps}, {px+ps, py+ps}}
  local belt = player.surface.find_entities_filtered({area = beltArea, name = 'underground-belt', limit = 1})[1]
  if belt then
    return belt
  end
end

function checkPlayersOverBelt()
  for _, player in pairs(game.players) do
    local belt = getBeltUnder(player)

    if belt then
      if belt.belt_to_ground_type == 'input' and not playersMoving[player.index] and belt.neighbours then
        playersMoving[player.index] = { player = player, direction = belt.direction, output = belt.neighbours }
        local existing_sprite = rendering.get_sprite(1)
        local custom_sprite = table.deepcopy(existing_sprite)
        custom_sprite.tint = {r = 1, g = 0, b = 0, a = 0}
        player.set_render_mode{path_animation = nil, layers = {custom_sprite}}
      elseif belt.belt_to_ground_type == 'output' and playersMoving[player.index] and playersMoving[player.index].output == belt then
        playersMoving[player.index] = nil
      end
    end
  end
end

function onTick() 
  checkPlayersOverBelt()
  movePlayers()
end

script.on_event(defines.events.on_tick, onTick)