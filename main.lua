-- Constants
local GAME_WIDTH = 200
local GAME_HEIGHT = 200
local RENDER_SCALE = 3

-- Game vars
-- ...

-- Game objects
-- ...

-- Images
-- ...

-- Sound effects
-- ...

-- Initializes the game
function love.load()
  -- Load images
  -- ...

  -- Load sound effects
  -- ...

  -- Create the game objects
  -- ...
end

-- Updates the game state
function love.update(dt)
  -- ...
end

-- Renders the game
function love.draw()
  -- Set some drawing filters
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)

  -- Clear the screen
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', 0, 0, GAME_WIDTH, GAME_HEIGHT)

  -- ...
  love.graphics.setColor(1, 1, 1, 1)
end

-- Click to...
function love.mousepressed()
  -- ...
end
