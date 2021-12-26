-- PlayerSpeed Mod

-- FS17 refactor, FS19 and FS22 by *TurboStar*

-- v1.0.0.0  		Initial FS22 release

PlayerSpeed = {}

function PlayerSpeed:loadMap(...)
	self.SPEEDS = {0.8, 2.0, 2.8, 4.0, 12.0, 32.0, 60.0, 80.0} -- m/s
	self.SPEEDS_LENGTH = #self.SPEEDS
	self.TEXTS = {[0.8] = "keyslow3", [2.0] = "keyslow2", [2.8] = "keyslow1", [4.0] = "key0", [12.0] = "key1", [32.0] = "key2", [60.0] = "key15", [80.0] = "key3", ["other"] = "othermod"}
	self.cont = 4 -- It starts with default speed
	self.eventIdReduce, self.eventIdIncrease = "", ""
	self.errorDisplayed, self.firstTime = false, true
end

function PlayerSpeed:registerActionEvents()
	if self.isClient then
		-- Reset maxCheatRunningSpeed at start
		if PlayerSpeed.firstTime then
			local spe = PlayerSpeed.SPEEDS[4]
			PlayerSpeed.setSpeed(spe)
			PlayerSpeed.firstTime = false
		end
		_, PlayerSpeed.eventIdReduce = g_inputBinding:registerActionEvent(InputAction.SPEEDMINUS, PlayerSpeed, PlayerSpeed.reduceSpeed, false, true, false, true, -1, true) --
		_, PlayerSpeed.eventIdIncrease = g_inputBinding:registerActionEvent(InputAction.SPEEDPLUS, PlayerSpeed, PlayerSpeed.incrementSpeed, false, true, false, true, 1, true) --
	end
end
Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, PlayerSpeed.registerActionEvents)

--- Event callback used to reduce cont, so the speed
function PlayerSpeed:reduceSpeed()
	if (self.cont == 1) then return end
	self.cont = self.cont - 1
	-- g_inputBinding.events[PlayerSpeed.eventIdReduce].callbackState is -1 here

	local spe = self.SPEEDS[self.cont]
	self.setSpeed(spe)
end
--- Event callback used to increase cont, so the speed
function PlayerSpeed:incrementSpeed()
	if (self.cont == self.SPEEDS_LENGTH) then return end
	self.cont = self.cont + 1
	-- g_inputBinding.events[PlayerSpeed.eventIdIncrease].callbackState is 1 here

	local spe = self.SPEEDS[self.cont]
	self.setSpeed(spe)
end

--- Set speed changing each player informations
-- @param speed of the player (m/s)
function PlayerSpeed.setSpeed(speed)
	local info = g_currentMission.player.motionInformation
	if info ~= nil and speed ~= nil then
		-- Ratio taken from default speeds
		info.maxWalkingSpeed = tonumber(speed)
		info.maxRunningSpeed = tonumber(speed * (9/4))
		info.maxSwimmingSpeed = tonumber(speed * (3/4))
		info.maxCrouchingSpeed = tonumber(speed / 2)
		info.maxFallingSpeed = tonumber(speed * 1.5)
		info.maxCheatRunningSpeed = info.maxRunningSpeed -- Same as maxRunningSpeed
	end
end

function PlayerSpeed:update(dt)
	if not g_currentMission:getIsClient() or not g_currentMission.controlPlayer or g_gui.currentGui ~= nil then
        return
    end

	if (self.cont ~= nil and (self.cont < 1 or self.cont > self.SPEEDS_LENGTH)) or self.cont == nil then
		if not self.errorDisplayed then
			print("PlayerSpeed: something is wrong on PlayerSpeed.cont variable... Aborting functionality. Please report your log.txt")
			self.errorDisplayed = true
		end
		return
	end

	g_inputBinding:setActionEventActive(self.eventIdReduce, self.cont ~= 1)
	g_inputBinding:setActionEventTextVisibility(self.eventIdReduce, self.cont ~= 1)
	g_inputBinding:setActionEventActive(self.eventIdIncrease, self.cont ~= self.SPEEDS_LENGTH)
	g_inputBinding:setActionEventTextVisibility(self.eventIdIncrease, self.cont ~= self.SPEEDS_LENGTH)

	local info = g_currentMission.player.motionInformation
	if info ~= nil and self.TEXTS[info.maxWalkingSpeed] ~= nil then
		g_currentMission:addExtraPrintText(g_i18n:getText(self.TEXTS[info.maxWalkingSpeed]))
	else
		g_currentMission:addExtraPrintText(g_i18n:getText(self.TEXTS["other"]))
	end
end

addModEventListener(PlayerSpeed)
print("    Loading PlayerSpeed Mod...")
