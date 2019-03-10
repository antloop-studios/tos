local enet = require "enet"
local ser = require "lib/binser"
require "lib/dump"

function love.load()
   local address, port = "dev.antloop.world", 5700

   entities = {}

   host = enet.host_create()
   server = host:connect(address..":"..port)
   status = {add=function(self, ...) self[(#self+1)%5] = {...} end}
   data = {
      id = 0,
      left=false,
      right=false,
      up=false,
      down=false
   }
end

function love.update()
   data.left = love.keyboard.isDown 'a'
   data.right = love.keyboard.isDown 'd'
   data.up = love.keyboard.isDown 'w'
   data.down = love.keyboard.isDown 's'

   local event = host:service(100)
   while event do
      if event.type == "receive" then
         local d = ser.d(event.data)[1]
         if d.id then
            data.id = d.id
         else
            entities = d
         end
      elseif event.type == "connect" then
         status:add(event.peer, "connected.")
      elseif event.type == "disconnect" then
         status:add(event.peer, "disconnected.")
      end
      event = host:service()
   end
   server:send(ser.s(data))
end

function love.draw()
   for i, entity in ipairs(entities) do
      love.graphics.circle("fill", entity.x or 0, entity.y or 0, 10)
   end
end
