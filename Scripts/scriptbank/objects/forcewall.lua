-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Forcewall script v7: 
-- DESCRIPTION: Attach object to use as a forcefield wall. Set Static to Physics ON.
-- DESCRIPTION: [PROMPT_TEXT$="You cannot pass"]
-- DESCRIPTION: [@FORCE_MODE=1(1=Static, 2=Repel, 3=Hurt, 4=Kill)]
-- DESCRIPTION: [@STATE=1(1=Active, 2=Inactive)] to activate/deactivate forcewall.
-- DESCRIPTION: [@TRIGGER=1(1=None, 2=Linked/IfUsed)]
-- DESCRIPTION: [@VISIBILITY!=2(1=Invisible, 2=Visible)] to hide/unhide forcewall.
-- DESCRIPTION: [@PROMPT_DISPLAY=1(1=Local,2=Screen)]
-- DESCRIPTION:	<Sound0> loop active sound
-- DESCRIPTION:	<Sound1> for impact	

local U = require "scriptbank\\utillib"
		
local forcewall = {}
local prompt_text = {}
local force_mode = {}
local state = {}
local trigger = {}
local visibility = {}

local status = {}
local doonce = {}
local colobj = {}
	
function forcewall_properties(e, prompt_text, force_mode, state, trigger, visibility, prompt_display)
	forcewall[e].prompt_text = prompt_text
	forcewall[e].force_mode = force_mode
	forcewall[e].state = state
	forcewall[e].trigger = trigger	
	forcewall[e].visibility = visibility
	forcewall[e].prompt_display	= prompt_display
end 

function forcewall_init(e)
	forcewall[e] = g_Entity[e]	
	forcewall[e].prompt_text = "You cannot pass"
	forcewall[e].force_mode = 1
	forcewall[e].state = 1
	forcewall[e].trigger = 1		
	forcewall[e].visibility = 1
	forcewall[e].prompt_display = 1
	
	status[e] = "init"
	doonce[e] = 0
	colobj[e] = 0
end

function forcewall_main(e)

	if status[e] == "init" then
		if forcewall[e].force_mode == nil then forcewall[e].force_mode = 1 end		
		if forcewall[e].state == 1 then SetActivated(e,1) end
		if forcewall[e].state == 2 then SetActivated(e,0) end
		if forcewall[e].visibility == 1 then Hide(e) end
		if forcewall[e].visibility == 2 then Show(e) end
		status = "endinit"
	end

	-- forcewall active ----------------------------------------------------------------
	if g_Entity[e]['activated'] == 1 then
		CollisionOn(e)
		LoopSound(e,0)
		local px, py, pz = g_PlayerPosX, g_PlayerPosY + 35, g_PlayerPosZ
		local rayX, rayY, rayZ = 0,0,45
		local paX, paY, paZ = math.rad(g_PlayerAngX), math.rad(g_PlayerAngY), math.rad(g_PlayerAngZ)
		rayX, rayY, rayZ = U.Rotate3D(rayX, rayY, rayZ, paX, paY, paZ)
		colobj[e]=(IntersectAll(px,py,pz, px+rayX, py+rayY, pz+rayZ,e))		
		if colobj[e] > 0 then
			if forcewall[e].prompt_display == 1 then PromptLocal(e,forcewall[e].prompt_text) end
			if forcewall[e].prompt_display == 2 then Prompt(forcewall[e].prompt_text) end
			if forcewall[e].force_mode == 1 and g_PlayerHealth > 0 then
				PlaySound(e,1)
				ForcePlayer(g_PlayerAngY + 180, 0)
				HurtPlayer(-1,0)
			elseif				
				forcewall[e].force_mode == 2 and g_PlayerHealth > 0 then
				PlaySound(e,1)
				ForcePlayer(g_PlayerAngY + 180, 1)
				HurtPlayer(-1,0)				
			elseif	
				forcewall[e].force_mode == 3 and g_PlayerHealth > 0 then
				PlaySound(e,1)
				ForcePlayer(g_PlayerAngY + 180, 1)
				HurtPlayer(-1,2)				
				PlayCharacterSound(e,"onHurt")
			elseif	
				forcewall[e].force_mode == 4 and g_PlayerHealth > 0 then				
				PlaySound(e,1)
				ForcePlayer(g_PlayerAngY + 180, 3)				
				HurtPlayer(-1,1000)
				PlayCharacterSound(e,"onHurt")
			end
			if doonce[e] == 0 then
				if forcewall[e].trigger == 2 then
					PerformLogicConnections(e)
					ActivateIfUsed(e)
				end
				doonce[e] = 1
			end	
		end	
	else
		CollisionOff(e)	
	end
end

