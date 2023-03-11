if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot_sprite"
-- Misc --
ENT.PrintName = "Template"
ENT.Category = "DRGBase"
ENT.CollisionBounds = Vector(10, 30, 90)
ENT.SpawnHealth = 999999
ENT.Models = {"models/props_junk/garbage_glassbottle003a.mdl"}
--get rid of the -- if you want to use sounds.
--ENT.OnIdleSounds = {
	--"templatesound.ogg"
--}
-- AI --
ENT.MeleeAttackRange = 80
ENT.ReachEnemyRange = 80
ENT.AvoidEnemyRange = 0
-- Animations --
ENT.SpriteFolder = "template"
ENT.FramesPerSecond = 1
ENT.WalkAnimRate = 1
ENT.IdleAnimRate = 1
ENT.RunAnimRate = 1
ENT.JumpAnimation = "jump"
ENT.IdleAnimation = "idle"
ENT.WalkAnimation = "walk"
ENT.RunAnimation = "run"
-- Climbing --
ENT.ClimbLedges = false
ENT.ClimbProps = false
ENT.ClimbLadders = true
ENT.ClimbLaddersUp = true
ENT.ClimbLaddersDown = true
ENT.ClimbUpAnimation = "climb"
ENT.ClimbDownAnimation = "climb"
ENT.ClimbAnimRate = 0.5
ENT.ModelScale = 1
-- Detection --
ENT.EyeOffset = Vector(0, 0, 30)

-- Possession --
--if you want the nextbot to be possessable, put it at true.
--if you dont want the nextbot to be possessable, put it at false.
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_8DIR
ENT.PossessionViews = {
  {
    offset = Vector(0, 50, 20),
    distance = 100
  },
  {
    offset = Vector(5, 0, 0),
    distance = 0,
    eyepos = true
  }
}
--change the faction if you want to (ex. FACTION_DYS, FACTION_CHA)
ENT.Factions = {"FACTION_UN"}
if SERVER then

  --This is what helps the nextbot open doors. DO NOT REMOVE--

  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:SetPlayersRelationship(D_HT)
    self:SpriteAnimEvent("idle", {1, 2}, function(self, frame)
    end)
    self:SpriteAnimEvent("idle", {1, 2}, function(self, frame)
      if self:IsClimbingLadder() then self:EmitSound("player/footsteps/ladder"..math.random(4)..".wav") end
    end)
  end
end
function ENT:CustomThink(ent)
	for k,ball in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,75)), 50)) do
		if IsValid(ball) then
			if ball:GetClass() == "prop_door_rotating" then ball:Fire("open") end
			if ball:GetClass() == "func_door_rotating" then ball:Fire("open") end
			if ball:GetClass() == "func_door" then ball:Fire("open") end
		end
	end
end

function ENT:DoorCode(door)
	if self:GetCooldown("MRXDoor") == 0 then
		self:SetCooldown("MRXDoor", 6)
		local doorseq,doordur = self:LookupSequence("9200")
		local doorseq2,doordur2 = self:LookupSequence("9201")
		if IsValid(door) and door:GetClass() == "prop_door_rotating" then
			self.CanOpenDoor = false
			self.CanAttack = false
			self:SetNotSolid(true)
			door:SetNotSolid(true)
			-- find ourselves to know which side of the door we're on
			local fwd = door:GetPos()+door:GetForward()*5
			local bck = door:GetPos()-door:GetForward()*5
			local pos = self:GetPos()
			local fuck_double_doors1 = door:GetKeyValues()
			local fuck_double_doors2 = nil
			if isstring(fuck_double_doors1.slavename) and fuck_double_doors1.slavename != "" then
				fuck_double_doors2 = ents.FindByName(fuck_double_doors1.slavename)[1]
			end

			if fwd:DistToSqr(pos) < bck:DistToSqr(pos) then -- entered from forward
				self:SetNotSolid(true)
				door:SetNotSolid(true)
				if isentity(fuck_double_doors2) then
					self:SetPos(door:GetPos()+(door:GetForward()*50)+(door:GetRight()*-50)+(door:GetUp()*-52))
				else
					self:SetPos(door:GetPos()+(door:GetForward()*80)+(door:GetRight()*-32)+(door:GetUp()*-52))
				end
				local ang = door:GetAngles()
				ang:RotateAroundAxis(Vector(0,0,1),180)
				self:SetAngles(ang)
			elseif bck:DistToSqr(pos) < fwd:DistToSqr(pos) then -- entered from backward
				self:SetNotSolid(true)
				door:SetNotSolid(true)
				if isentity(fuck_double_doors2) then
					self:SetPos(door:GetPos()+(door:GetForward()*-50)+(door:GetRight()*-50)+(door:GetUp()*-52))
				else
					self:SetPos(door:GetPos()+(door:GetForward()*-80)+(door:GetRight()*-12)+(door:GetUp()*-52))
				end
				local a = (door:GetAngles())
				a:Normalize()
				self:SetAngles(a)
			end
			-- find ourselves to know which side of the door we're on
			if (fwd:DistToSqr(pos) < bck:DistToSqr(pos)) or (bck:DistToSqr(pos) < fwd:DistToSqr(pos)) then

				self:SetNotSolid(true)
				door:SetNotSolid(true)
				door:Fire("setspeed",500)

				if isentity(fuck_double_doors2) then
					fuck_double_doors2:SetNotSolid(true)
					fuck_double_doors2:Fire("setspeed",500)

					self:Timer(7/30,function()
						self:EmitSound("doors/vent_open3.wav",511,math.random(50,80))
						door:Fire("openawayfrom",self:GetName())
						fuck_double_doors2:Fire("openawayfrom",self:GetName())
					end)
					self:Timer(doordur2,function()
						door:Fire("setspeed",100)
						door:Fire("close")
						fuck_double_doors2:Fire("setspeed",100)
						fuck_double_doors2:Fire("close")
						self:Timer(1,function()
							door:SetNotSolid(false)
							fuck_double_doors2:SetNotSolid(false)
							self.CanOpenDoor = true
							self.CanAttack = true
							self.CanFlinch = false
							self:SetNotSolid(false)
						end)
					end)
					self:PlaySequence("9201",{rate=1, gravity=true, collisions=false})
				else
					self:Timer(0.5,function()
						if !IsValid(self) then return end
						self:EmitSound("doors/vent_open3.wav",511,math.random(50,80))
						door:Fire("openawayfrom",self:GetName())
					end)
					self:Timer(doordur,function()
						if !IsValid(self) then return end
						door:Fire("setspeed",100)
						door:Fire("close")
						self:Timer(0.2,function()
							door:SetNotSolid(false)
							if !IsValid(self) then return end
							self.CanOpenDoor = true
							self.CanAttack = true
							self.CanFlinch = false
							self:SetNotSolid(false)
						end)
					end)
					self:PlaySequence("9200",{rate=1, gravity=true, collisions=false})
				end
			else
				self:Timer(1,function()
					door:SetNotSolid(false)
					self:Timer(1,function()
						if !IsValid(self) then return end
						self.CanOpenDoor = true
					end)
					if !IsValid(self) then return end
					self.CanAttack = true
					self.CanFlinch = false
					self:SetNotSolid(false)
				end)
			end
		end
	end
end

  --ai--
  ENT.WalkSpeed = 500
  ENT.RunSpeed = 500
  --ENT.Acceleration = 500
  --get rid of the -- if you're using acceleration/deceleration.
  --ENT.Deceleration = 500
  function ENT:SIGN()
      self:Attack({
    damage = 100,
    range=100,
    delay=0,
    radius=10,
    force=Vector(800,100,100),
    type = DMG_SLASH,
    viewpunch = Angle(20, math.random(-10, 10), 0),
	}, function(self, hit)
        if #hit > 0 then
          self:EmitSound("")
        else self:EmitSound("") end
      end)
  end
--melee attack, when the entity hits the player
   function ENT:OnMeleeAttack(enemy)
                    self:SIGN()	
end
--range attack, when the player is spotted
   function ENT:OnRangeAttack(enemy)
end
--when the nextbot is not moving
  function ENT:OnIdle()
    self:AddPatrolPos(self:RandomPos(900))
  end
--when the nextbot dies
  function ENT:OnDeath(dmg, hitgroup)
  end
--when the nextbot spawns
  function ENT:OnSpawn()
      self:SetGodMode(true)
  end
--keep it at 10. for some reason if it is not kept at 10 the nextbot simply wont be spawnable.
ENT.AllyDamageTolerance = 10
--DO NOT TOUCH--
AddCSLuaFile()
DrGBase.AddNextbot(ENT)