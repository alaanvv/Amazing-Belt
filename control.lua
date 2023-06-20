playersUndergroung = {}

function setUnderground(player, belt, spd)
  playersUndergroung[player.index] = { player = player, direction = belt.direction, output = belt.neighbours, spd = spd, flag = spd, flashOn = player.is_flashlight_enabled() }
  player.disable_flashlight()
end

function setOverground(player, belt)
  local playerData = playersUndergroung[player.index]
  if playerData.flashOn then player.enable_flashlight() end
  playersUndergroung[player.index] = nil
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

function checkPlayersOverInputBelt()
  for _, player in pairs(game.players) do
    local beltData = getBeltUnder(player)

    if not beltData then return end

    local belt = beltData.belt
    local speed = beltData.speed

    -- Is an input + Player is over ground + Belt has an exit
    if belt.belt_to_ground_type == 'input' and not playersUndergroung[player.index] and belt.neighbours then
      setUnderground(player, belt, speed)
    -- Player is under ground + Belt is the exit
    elseif playersUndergroung[player.index] and playersUndergroung[player.index].output == belt then
      setOverground(player, belt)
    end
  end
end

function moveUndergroundPlayers()
  for _, playerData in pairs(playersUndergroung) do
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

function onTick() 
  checkPlayersOverInputBelt()
  moveUndergroundPlayers()
end

-- 

script.on_event(defines.events.on_tick, onTick)
