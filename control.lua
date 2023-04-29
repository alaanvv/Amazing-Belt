-- Falta deixar invisivel e imune a belt
playersMoving = {}

function movePlayers()
  for _, playerData in pairs(playersMoving) do
    local player = playerData.player
    local direction = playerData.direction
    player.character_running_speed_modifier = 0.3
    if playerData.flag == 0 then
      player.walking_state = {walking = true, direction = direction}
      playerData.flag = playerData.spd
    else 
      player.walking_state = {walking = false, direction = direction}
      playerData.flag = playerData.flag - 1
    end

  end
end

function setUnderground(player, belt, spd)
  setInvisible()
  playersMoving[player.index] = { player = player, direction = belt.direction, output = belt.neighbours, spd = spd, flag = spd, flashOn = player.is_flashlight_enabled() }
  player.disable_flashlight()
end

function resetPlayer(player, belt)
  setVisible()
  local playerData = playersMoving[player.index]
  if playerData.flashOn then player.enable_flashlight() end
  playersMoving[player.index] = nil
end

function getBeltUnder(player)
  local px, py = player.position.x, player.position.y
  local ps = 0.1

  --                Start X and Y  |  End X and Y
  local beltArea = {{px-ps, py-ps}, {px+ps, py+ps}}
  local belt = player.surface.find_entities_filtered({area = beltArea, name = 'underground-belt', limit = 1})[1]
  if belt then
    return { belt = belt, spd = 2 }
  end
  local belt = player.surface.find_entities_filtered({area = beltArea, name = 'fast-underground-belt', limit = 1})[1]
  if belt then
    return { belt = belt, spd = 1 }
  end
  local belt = player.surface.find_entities_filtered({area = beltArea, name = 'express-underground-belt', limit = 1})[1]
  if belt then
    return { belt = belt, spd = 0 }
  end
end

function checkPlayersOverBelt()
  for _, player in pairs(game.players) do
    local beltData = getBeltUnder(player)

    if beltData then
      local belt = beltData.belt
      local spd = beltData.spd
      if belt.belt_to_ground_type == 'input' and not playersMoving[player.index] and belt.neighbours then
        setUnderground(player, belt, spd)
      elseif playersMoving[player.index] and playersMoving[player.index].output == belt then
        resetPlayer(player, belt)
      end
    end
  end
end

function onTick() 
  checkPlayersOverBelt()
  movePlayers()
end

script.on_event(defines.events.on_tick, onTick)

function print(msg, use_serpent)
  use_serpent = use_serpent or true
  if use_serpent then game.print(serpent.block(msg))
  else game.print(tostring(msg)) end
end