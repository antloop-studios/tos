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
      uid = 0,
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

   local event = host:service()
   while event do
      if event.type == "receive" then
         local d = ser.d(event.data)[1]
         if d.uid then
            data.uid = d.uid
         else
            entities = d
         end
      end
      event = host:service()
   end
   server:send(ser.s(data))
end

function love.draw()
   for i, entity in pairs(entities) do
      if entity.uid == data.uid then
         love.graphics.setColor(0.2, 0.5, 0.7, 1)
      else
         love.graphics.setColor(0.5, 0.5, 0.5, 1)
      end
      love.graphics.circle("fill", entity.x or 0, entity.y or 0, 10)
   end

   love.graphics.print(dump(entities))
end
