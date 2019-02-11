-- Constants
local GAME_WIDTH = 200
local GAME_HEIGHT = 200
local RENDER_SCALE = 3

-- Game vars
local mousePressX
local mousePressY

-- Game objects
local units

-- Images
local unitsImage
local backgroundImage

-- Sound effects
-- ...

-- Initializes the game
function love.load()
  -- Initialize game vars
  -- ...

  -- Load images
  unitsImage = love.graphics.newImage('img/units.png')
  unitsImage:setFilter('nearest', 'nearest')
  backgroundImage = love.graphics.newImage('img/bg.png')
  backgroundImage:setFilter('nearest', 'nearest')

  -- Load sound effects
  -- ...

  -- Create the game objects
  units = {}
  createUnit('carrot', 50, 50)
  createUnit('beet', 80, 50)
end

-- Updates the game state
function love.update(dt)
  -- Units move towards the target they were given
  for _, unit in ipairs(units) do
    if unit.targetX and unit.targetY then
      local dx = unit.targetX - unit.x
      local dy = unit.targetY - unit.y
      local dist = math.sqrt(dx * dx + dy * dy)
      local movement = unit.speed * dt
      if dist < movement then
        unit.targetX = nil
        unit.targetY = nil
      else
        unit.x = unit.x + movement * dx / dist
        unit.y = unit.y + movement * dy / dist
      end
    end
  end
end

-- Renders the game
function love.draw()
  -- Set some drawing filters
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)

  -- Draw the background pattern
  love.graphics.setColor(1, 1, 1, 1)
  local backgroundWidth = backgroundImage:getWidth()
  local backgroundHeight = backgroundImage:getHeight()
  for x = 1, GAME_WIDTH, backgroundWidth do
    for y= 1, GAME_HEIGHT, backgroundHeight do
      love.graphics.draw(backgroundImage, x, y)
    end
  end

  -- Draw the selection rectangle
  love.graphics.setColor(117 / 255, 206 / 255, 18 / 255, 1)
  if mousePressX and mousePressY then
    local mouseX = love.mouse.getX() / RENDER_SCALE
    local mouseY = love.mouse.getY() / RENDER_SCALE
    love.graphics.rectangle('line', mousePressX, mousePressY, mouseX - mousePressX, mouseY - mousePressY)
  end

  -- Draw all of the units
  love.graphics.setColor(1, 1, 1, 1)
  for _, unit in ipairs(units) do
    local spriteNum
    if unit.type == 'carrot' then
      spriteNum = 2
    elseif unit.type == 'beet' then
      spriteNum = 4
    end
    if unit.isSelected then
      drawImage(unitsImage, 1, 15, 37, unit.x - 7.5, unit.y - 33.5)
    end
    drawImage(unitsImage, spriteNum, 15, 37, unit.x - 7.5, unit.y - 33.5)
  end
end

-- Click a unit to select it, or drag a rectangle
function love.mousepressed(x, y, button)
  if button == 1 then
    mousePressX = x / RENDER_SCALE
    mousePressY = y / RENDER_SCALE
  end
end
function love.mousereleased(x, y, button)
  local mouseReleaseX = x / RENDER_SCALE
  local mouseReleaseY = y / RENDER_SCALE
  if button == 2 then
    for _, unit in ipairs(units) do
      if unit.isSelected then
        unit.targetX = mouseReleaseX
        unit.targetY = mouseReleaseY
      end
    end
  elseif button == 1 and mousePressX and mousePressY then
    local dx = mouseReleaseX - mousePressX
    local dy = mouseReleaseY - mousePressY
    deselectAllUnits()
    if math.abs(dx) < 5 and math.abs(dy) < 5 then
      selectUnit(mouseReleaseX, mouseReleaseY)
    else
      selectUnits(math.min(mousePressX, mouseReleaseX), math.min(mousePressY, mouseReleaseY), math.abs(dx), math.abs(dy))
    end
    mousePressX = nil
    mousePressY = nil
  end
end

-- Creates a new unit
function createUnit(type, x, y)
  table.insert(units, {
    type = type,
    x = x,
    y = y,
    targetX = nil,
    targetY = nil,
    speed = 50,
    isSelected = false
  })
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

-- Draws a sprite from an image, spriteNum=1 is the upper-leftmost sprite
function drawImage(image, spriteNum, spriteWidth, spriteHeight, x, y)
  local columns = math.floor(image:getWidth() / spriteWidth)
  local col = (spriteNum - 1) % columns
  local row = math.floor((spriteNum - 1) / columns)
  local quad = love.graphics.newQuad(col * spriteWidth, row * spriteHeight, spriteWidth, spriteHeight, image:getDimensions())
  love.graphics.draw(image, quad, x, y)
end
