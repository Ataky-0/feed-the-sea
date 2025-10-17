local timerManager = {}
timerManager.timers = {}
timerManager.nextId = 1
-- ZA WARUDO!!!!!!!!!

-- Cria um novo timer
function timerManager:set(duration, callback, loop)
  local id = timerManager.nextId
  timerManager.nextId = timerManager.nextId + 1
  
  timerManager.timers[id] = {
    duration = duration,
    elapsed = 0,
    callback = callback,
    loop = loop or false,
    active = true
  }
  return id
end

-- Cria um timer que se repete
function timerManager:every(duration, callback)
  return timerManager.set(duration, callback, true)
end

-- Remove um timer
function timerManager:cancel(id)
  if timerManager.timers[id] then
    timerManager.timers[id].active = false
    timerManager.timers[id] = nil
  end
end

-- Atualiza todos os timers
function timerManager:update(dt)
  local toCall = {}

  -- A gente separa as tabelas para evitar problemas de memória inválida
  for id, timer in pairs(timerManager.timers) do
    if timer.active then
      timer.elapsed = timer.elapsed + dt
      if timer.elapsed >= timer.duration then
        table.insert(toCall, {id = id, timer = timer})
      end
    end
  end

  for _, entry in ipairs(toCall) do
    local id, timer = entry.id, entry.timer
    if timer.active then
      timer.callback()
      if timer.loop then
        timer.elapsed = 0
      else
        timerManager:cancel(id)
      end
    end
  end
end

-- Verifica se um timer está ativo
function timerManager:isActive(id)
  return timerManager.timers[id] and timerManager.timers[id].active
end

-- Limpa todos os timers
function timerManager:clear()
  timerManager.timers = {}
end

return timerManager