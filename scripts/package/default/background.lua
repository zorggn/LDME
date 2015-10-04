-- Default package - background visuals
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Since this should be somewhat simplistic, every submenu will use this background, reducing code duplication.
	- This also means, that all of them must call the below state's update and draw routines.
	--]]



local path

local script = {}

script.init = function(self)

	path = getPackageDir()

	self.squareVertices = {{0,0,0,0}, {1,0,1,0}, {1,1,1,1}, {0,1,0,1}}

	self.vine = love.graphics.newImage(path..'assets/vines.png')
	self.vine:setFilter('nearest','nearest',4)
	self.vine:setWrap('repeat','repeat')
	self.vineUVOffset = {0,0}
	self.vineMesh = love.graphics.newMesh(self.squareVertices,self.vine,"fan")

	self.glass = love.graphics.newImage(path..'assets/glasswork_transparent.png')
	self.glass:setFilter('linear','linear',4)
	self.glass:setWrap('repeat','repeat')
	self.glassUVOffset = {0,0}
	self.glassMesh = love.graphics.newMesh(self.squareVertices,self.glass,"fan")

	self.weed = {}
	self.weed[1] = love.graphics.newImage(path..'assets/weed_default.png')
	self.weed[2] = love.graphics.newImage(path..'assets/weed_deepblue.png')
	self.weed[3] = love.graphics.newImage(path..'assets/weed_vibrantgreen.png')
	self.weed[4] = love.graphics.newImage(path..'assets/weed_accidentalred.png')
	self.weedNega = love.graphics.newImage(path..'assets/weed_negative.png')
	self.weed[1]:setFilter('nearest','nearest',4)
	self.weed[2]:setFilter('nearest','nearest',4)
	self.weed[3]:setFilter('nearest','nearest',4)
	self.weed[4]:setFilter('nearest','nearest',4)
	self.weedNega:setFilter('nearest','nearest',4)
	self.weedSwapTime = 4 -- seconds
	self.weedState = {1,2,1,3,1,4} -- def blu def grn def red (repeat)
	self.weedCurrent = 0

	self.weedOverlay = love.graphics.newImage(path..'assets/weed_transparent.png')
	self.weedOverlay:setFilter('nearest','nearest',1)
	self.weedOverlayOffset = {0,0} -- random variations for shadow effect BELOW normal weed graphics
end

script.enter = function(self, from)
	self.vineUVOffset = {0,0}
	self.glassUVOffset = {0,0}
	self.weedCurrent = 0
	self.weedOverlayOffset = {0,0}
end


script.update = function(self, dt, tick)

	self.weedCurrent = ((self.weedCurrent + (dt / self.weedSwapTime)) % #self.weedState) -- floor this in state.draw (also +1)

	self.vineUVOffset[1] = self.vineUVOffset[1] + dt/50
	self.vineUVOffset[2] = self.vineUVOffset[2] + dt/50
		self.vineMesh:setVertex(1,self.squareVertices[1][1],self.squareVertices[1][2],  self.vineUVOffset[1],  self.vineUVOffset[2])
		self.vineMesh:setVertex(2,self.squareVertices[2][1],self.squareVertices[2][2],1+self.vineUVOffset[1],  self.vineUVOffset[2])
		self.vineMesh:setVertex(3,self.squareVertices[3][1],self.squareVertices[3][2],1+self.vineUVOffset[1],1+self.vineUVOffset[2])
		self.vineMesh:setVertex(4,self.squareVertices[4][1],self.squareVertices[4][2],  self.vineUVOffset[1],1+self.vineUVOffset[2])

	self.glassUVOffset[1] = self.glassUVOffset[1] - dt/20
	self.glassUVOffset[2] = self.glassUVOffset[2] - dt/200
		self.glassMesh:setVertex(1,self.squareVertices[1][1],self.squareVertices[1][2],  self.glassUVOffset[1],  self.glassUVOffset[2])
		self.glassMesh:setVertex(2,self.squareVertices[2][1],self.squareVertices[2][2],1+self.glassUVOffset[1],  self.glassUVOffset[2])
		self.glassMesh:setVertex(3,self.squareVertices[3][1],self.squareVertices[3][2],1+self.glassUVOffset[1],1+self.glassUVOffset[2])
		self.glassMesh:setVertex(4,self.squareVertices[4][1],self.squareVertices[4][2],  self.glassUVOffset[1],1+self.glassUVOffset[2])

	self.weedOverlayOffset[1] = math.min(math.max(self.weedOverlayOffset[1] + love.math.random()/4, 1.5), -1.5)
	self.weedOverlayOffset[2] = math.min(math.max(self.weedOverlayOffset[2] + love.math.random()/4, 1.5), -1.5)
		self.weedOverlayOffset[1] = self.weedOverlayOffset[1] > 1 and self.weedOverlayOffset[1] - love.math.random()/4 or self.weedOverlayOffset[1]
		self.weedOverlayOffset[1] = self.weedOverlayOffset[1] <-1 and self.weedOverlayOffset[1] + love.math.random()/4 or self.weedOverlayOffset[1]
		self.weedOverlayOffset[2] = self.weedOverlayOffset[2] > 1 and self.weedOverlayOffset[2] - love.math.random()/4 or self.weedOverlayOffset[2]
		self.weedOverlayOffset[2] = self.weedOverlayOffset[2] <-1 and self.weedOverlayOffset[2] + love.math.random()/4 or self.weedOverlayOffset[2]
end



script.draw = function(self, df)
	local t = self.weedCurrent % 1
	local f = t <=0.5 and t*2 or (0.5-t/2)*4
	local k = self.weedState[math.floor(self.weedCurrent)+1]

	love.graphics.setBackgroundColor(0,0,0)

	love.graphics.setBlendMode('alpha')

	love.graphics.setColor(255,255,255,(1-f)*191)
	love.graphics.draw(self.weedNega,0,0,0,640/340,720/340)
	love.graphics.draw(self.weedNega,640,0,0,640/340,720/340)


	love.graphics.setColor(255,255,255,f*255)
	love.graphics.draw(self.weed[k],0,0,0,640/340,720/340)
	love.graphics.draw(self.weed[k],640,0,0,640/340,720/340)

	love.graphics.setColor(255,255,255,f*63)
	love.graphics.draw(self.weedOverlay, -1,-2,0,641/340,722/340,self.weedOverlayOffset[1],self.weedOverlayOffset[2])
	love.graphics.draw(self.weedOverlay,640,-2,0,641/340,722/340,self.weedOverlayOffset[1],self.weedOverlayOffset[2])
	love.graphics.draw(self.weedOverlay, -1,-2,0,641/340,722/340,self.weedOverlayOffset[2],self.weedOverlayOffset[1])
	love.graphics.draw(self.weedOverlay,640,-2,0,641/340,722/340,self.weedOverlayOffset[2],self.weedOverlayOffset[1])
	love.graphics.draw(self.weedOverlay, -1,-2,0,641/340,722/340,self.weedOverlayOffset[1],self.weedOverlayOffset[1])
	love.graphics.draw(self.weedOverlay,640,-2,0,641/340,722/340,self.weedOverlayOffset[1],self.weedOverlayOffset[1])
	love.graphics.draw(self.weedOverlay, -1,-2,0,641/340,722/340,self.weedOverlayOffset[2],self.weedOverlayOffset[2])
	love.graphics.draw(self.weedOverlay,640,-2,0,641/340,722/340,self.weedOverlayOffset[2],self.weedOverlayOffset[2])

	love.graphics.setColor(255,255,255,127)
	love.graphics.draw(self.vineMesh,0,0,0,1280,720)

	love.graphics.setColor(255,255,255,31)
	love.graphics.draw(self.glassMesh,0,0,0,1280,720)
end



----------

return script