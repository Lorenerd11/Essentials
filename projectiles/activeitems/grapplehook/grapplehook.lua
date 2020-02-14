require "/scripts/vec2.lua"

function init()
  self.returning = false
  self.anchored = true
  self.pickupDistance = config.getParameter("pickupDistance", 2)
  self.breakOnSlipperyCollision = config.getParameter("breakOnSlipperyCollision")
  
  self.ropeHook = config.getParameter("ropeHook", false)
  
  self.timeToLive = config.getParameter("timeToLive")
  self.speed = config.getParameter("speed")
  self.ownerId = projectile.sourceEntity()
  
  self.returnTime = 2
  self.returnTimer = self.returnTime
  
  message.setHandler("returnToSender", returnToSender)
end

function update(dt)
  if anchored() and self.anchored then
    self.anchored = true
  end
  if not anchored() and mcontroller.isColliding() then
    returnToSender()
  end

  if self.ownerId and world.entityExists(self.ownerId) and self.returning and not self.anchored then
    local toTarget = world.distance(world.entityPosition(self.ownerId), mcontroller.position())
	
	--sb.logInfo("Distance to owner %s", vec2.mag(toTarget))
    if vec2.mag(toTarget) < self.pickupDistance then
      kill()
    elseif projectile.timeToLive() < self.timeToLive * 0.5 then
	  mcontroller.applyParameters({collisionEnabled=false})
	  mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), 500)
    elseif self.returnTimer <= 0 then
	  mcontroller.applyParameters({collisionEnabled=false})
	  mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), 500)
	elseif self.returnTimer > 0 then
	  mcontroller.applyParameters({collisionEnabled=true})
	  self.returnTimer = self.returnTime
	else
      self.returnTimer = math.max(0, self.returnTimer - dt)
	  mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), 500)
    end
  end
end

function anchored()
  if not self.returning then return mcontroller.stickingDirection() else return false end
end

function returnToSender(ownerId)
  if self.ropeHook then
    kill()
  end

  if ownerId then
    self.ownerId = ownerId
  end
  self.anchored = false
  self.returning = true
end

function kill()
  projectile.die()
end

function shouldDestroy()
  if not (self.ownerId and world.entityExists(self.ownerId)) then return true end
  if self.anchored then return false end
  local toTarget = world.distance(world.entityPosition(self.ownerId), mcontroller.position())
  return vec2.mag(toTarget) < self.pickupDistance
end