require "/scripts/vec2.lua"

function init()
  self.returning = false
  self.anchored = true
  self.snapDistance = config.getParameter("snapDistance", 12)
  self.pickupDistance = config.getParameter("pickupDistance", 2)
  
  self.timeToLive = config.getParameter("timeToLive")
  self.speed = config.getParameter("speed")
  self.ownerId = projectile.sourceEntity()
  
  message.setHandler("returnToSender", returnToSender)
end

function update(dt)
  if anchored() and self.anchored then
    self.anchored = true
  end

  if self.ownerId and world.entityExists(self.ownerId) and self.returning and not self.anchored then
    local toTarget = world.distance(world.entityPosition(self.ownerId), mcontroller.position())
	--sb.logInfo("Distance to owner %s", vec2.mag(toTarget))
    if vec2.mag(toTarget) < self.pickupDistance then
      kill()
    elseif projectile.timeToLive() < self.timeToLive * 0.5 then
	  mcontroller.applyParameters({collisionEnabled=false})
	  mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), 500)
    else
	  mcontroller.approachVelocity(vec2.mul(vec2.norm(toTarget), self.speed), 500)
    end
  end
end

function anchored()
  if not self.returning then return mcontroller.stickingDirection() else return false end
end

function returnToSender(ownerId)
  self.anchored = false
  self.ownerId = ownerId
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