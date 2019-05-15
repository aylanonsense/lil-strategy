-- Game constants
local GAME_WIDTH = 200
local GAME_HEIGHT = 200

-- Game vars
local mousePressX
local mousePressY
local units

-- Assets
local unitsImage
local backgroundImage

-- Initializes the game
function love.load()
  -- Load assets
  love.graphics.setDefaultFilter('nearest', 'nearest')
  unitsImage = love.graphics.newImage('img/units.png')
  backgroundImage = love.graphics.newImage('img/bg.png')

  -- Create the units
  units = {}
  for i = 1, 30 do
    local unitType = ({ 'carrot', 'beet', 'turnip'})[math.random(1, 3)]
    table.insert(units, {
      type = unitType,
      x = math.random(15, GAME_WIDTH - 15),
      y = math.random(30, GAME_HEIGHT - 15),
      targetX = nil,
      targetY = nil,
      timeToLoseTarget = 0.0,
      speed = (unitType == 'carrot' and 20 or 60),
      isSelected = false
    })
  end
end

-- Updates the game state
function love.update(dt)
  -- Units move towards clicked point
  for _, unit in ipairs(units) do
    if unit.targetX and unit.targetY then
      unit.timeToLoseTarget = unit.timeToLoseTarget - dt
      local dx = unit.targetX - unit.x
      local dy = unit.targetY - unit.y
      local dist = math.sqrt(dx * dx + dy * dy)
      local movement = unit.speed * dt
      if dist < movement or unit.timeToLoseTarget <= 0.0 then
        unit.targetX = nil
        unit.targetY = nil
        unit.timeToLoseTarget = 0.0
      else
        unit.x = unit.x + movement * dx / dist
        unit.y = unit.y + movement * dy / dist
      end
    end
  end

  -- Prevent the units from overlapping
  for i = 1, #units do
    local unit1 = units[i]
    for j = i + 1, #units do
      local unit2 = units[j]
      local dx = unit2.x - unit1.x
      local dy = unit2.y - unit1.y
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist < 10 then
        local movement = (10 - dist) / 2
        unit1.x = unit1.x - movement * dx / dist
        unit1.y = unit1.y - movement * dy / dist
        unit2.x = unit2.x + movement * dx / dist
        unit2.y = unit2.y + movement * dy / dist
      end
    end
  end

  -- Sort the list of units for rendering
  table.sort(units, function(a, b)
    return a.y < b.y
  end)
end

-- Renders the game
function love.draw()
  -- Draw the background pattern
  love.graphics.setColor(1, 1, 1)
  local backgroundWidth = backgroundImage:getWidth()
  local backgroundHeight = backgroundImage:getHeight()
  for x = 1, GAME_WIDTH, backgroundWidth do
    for y= 1, GAME_HEIGHT, backgroundHeight do
      love.graphics.draw(backgroundImage, x, y)
    end
  end

  -- Draw the selection rectangle
  love.graphics.setColor(88 / 255, 203 / 255, 45 / 255)
  if mousePressX and mousePressY then
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    love.graphics.rectangle('line', mousePressX, mousePressY, mouseX - mousePressX, mouseY - mousePressY)
  end

  -- Draw the unit shadows
  love.graphics.setColor(1, 1, 1)
  for _, unit in ipairs(units) do
    drawSprite(unitsImage, 15, 37, 2, unit.x - 7.5, unit.y - 33.5)
  end

  -- Draw the selection circles
  for _, unit in ipairs(units) do
    if unit.isSelected then
      drawSprite(unitsImage, 15, 37, 1, unit.x - 7.5, unit.y - 33.5)
    end
  end

  -- Draw the units
  for _, unit in ipairs(units) do
    local spriteNum
    if unit.type == 'carrot' then
      spriteNum = 3
    elseif unit.type == 'beet' then
      spriteNum = 5
    elseif unit.type == 'turnip' then
      spriteNum = 7
    end
    if unit.timeToLoseTarget and unit.timeToLoseTarget % 0.4 > 0.2 then
      spriteNum = spriteNum + 1
    end
    drawSprite(unitsImage, 15, 37, spriteNum, unit.x - 7.5, unit.y - 33.5)
  end
end

-- Click a unit to select it, or drag a rectangle
function love.mousepressed(x, y, button)
  if button == 1 then
    mousePressX, mousePressY = x, y
  end
end

function love.mousereleased(x, y, button)
  if button == 2 then
    for _, unit in ipairs(units) do
      if unit.isSelected then
        unit.targetX, unit.targetY = x, y
        local dx, dy = unit.targetX - unit.x, unit.targetY - unit.y
        local dist = math.sqrt(dx * dx + dy * dy)
        unit.timeToLoseTarget = 1.2 * dist / unit.speed
      end
    end
  elseif button == 1 and mousePressX and mousePressY then
    local dx, dy = x - mousePressX, y - mousePressY
    deselectAllUnits()
    if math.abs(dx) < 5 and math.abs(dy) < 5 then
      selectUnit(x, y)
    else
      selectUnits(math.min(mousePressX, x), math.min(mousePressY, y), math.abs(dx), math.abs(dy))
    end
    mousePressX, mousePressY = nil, nil
  end
end

-- Deselects all units
function deselectAllUnits()
  for _, unit in ipairs(units) do
    unit.isSelected = false
  end
end

-- Selects a single unit near the given point
function selectUnit(x, y)
  for _, unit in ipairs(units) do
    if x - 7 < unit.x and unit.x < x + 7 and y - 4 < unit.y and unit.y < y + 16 then
      unit.isSelected = true
      break
    end
  end
end

-- Selects all units within a bounding rectangle
function selectUnits(x, y, width, height)
  for _, unit in ipairs(units) do
    if x <= unit.x and unit.x <= x + width and y <= unit.y and unit.y <= y + height then
      unit.isSelected = true
    end
  end
end

-- Draws a sprite from a sprite sheet, spriteNum=1 is the upper-leftmost sprite
function drawSprite(spriteSheetImage, spriteWidth, spriteHeight, sprite, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  local numColumns = math.floor(width / spriteWidth)
  local col, row = (sprite - 1) % numColumns, math.floor((sprite - 1) / numColumns)
  love.graphics.draw(spriteSheetImage,
    love.graphics.newQuad(spriteWidth * col, spriteHeight * row, spriteWidth, spriteHeight, width, height),
    x + spriteWidth / 2, y + spriteHeight / 2,
    rotation or 0,
    flipHorizontal and -1 or 1, flipVertical and -1 or 1,
    spriteWidth / 2, spriteHeight / 2)
end
