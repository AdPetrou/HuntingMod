Scriptname _HM_HuntingMain extends Quest  

import PO3_SKSEFunctions

_HM_HuntingSkill Property huntingSkills Auto
_HM_RecipeAdjuster Property huntingRecipes Auto
iWant_Widgets Property widgetManager Auto

MiscObject Property keyDressed Auto
MiscObject Property keySkinned Auto
MiscObject Property keyHarvested Auto
MiscObject Property keyButchered Auto

string[] Property skinningFilter Auto
string[] Property harvestFilter Auto
string[] Property butcherFilter Auto

ObjectReference Property skinningContainer auto
ObjectReference Property harvestContainer auto
ObjectReference Property butcherContainer auto

Idle Property idleSkinning Auto
Idle Property idleStop Auto

bool returnFP = false

ObjectReference previousReference = NONE
int progressMeter = 0

Event OnInit()

	RegisterForSingleUpdate(1)

EndEvent

Event OnUpdate()

	; Add Perk when the games opening scene is finished.
	If (!Game.IsFightingControlsEnabled() )
		RegisterForSingleUpdate(30)
		Return
	EndIf

	Int xPos = Utility.GetIniInt("iSize W:Display") / 3
	Int yPos = Utility.GetIniInt("iSize H:Display") / 3 + 40
	progressMeter = widgetManager.loadMeter(xPos, yPos, true)
	widgetManager.setSize(progressMeter, 25, 300)
	widgetManager.setMeterFillDirection(progressMeter, "right")
	widgetManager.setMeterRGB(progressMeter, 255,255,255, 245,245,245)
	UpdateWidget(false, 0)
	
EndEvent

Function CarcassActivateFilterOnly(ObjectReference akTargetRef, Actor akActor)

	if(previousReference != akTargetRef)
		FilterItems(akTargetRef, akActor)
		previousReference = akTargetRef
	endif

	akTargetRef.Activate(akActor)

EndFunction
Function CarcassActivate(ObjectReference akTargetRef, Actor akActor)
	; In case the player decides to switch to skinning a different animal before the previous is finished
	if(previousReference != akTargetRef)
		FilterItems(akTargetRef, akActor)
		previousReference = akTargetRef
	endif

	float animalWeight = (akTargetRef as Actor).GetMass() / 100
	int overallSkill = huntingSkills._HM_SkillHunting

	if(animalWeight * 10 - 5 > overallSkill)
		akTargetRef.Activate(akActor)
		return
	endif
	
	ToggleControls(false)

	bool isDressed = false
	GlobalVariable skill = NONE
	Form itemAdd = NONE
	Form itemRemove = NONE
	ObjectReference targetContainer = NONE
	float time = huntingSkills.GetTotalSkillTime(0.5) * animalWeight

	if (akTargetRef.GetItemCount(keyHarvested) > 0)

		skill = huntingSkills._HM_SkillButchering
		targetContainer = butcherContainer
		itemAdd = keyButchered
		itemRemove = keyHarvested

		time = huntingSkills.GetSkillTime(skill, 2.5) * animalWeight
		isDressed = true

	elseIf (akTargetRef.GetItemCount(keySkinned) > 0)

		skill = huntingSkills._HM_SkillHarvesting
		targetContainer = harvestContainer
		itemAdd = keyHarvested
		itemRemove = keySkinned

		time = huntingSkills.GetSkillTime(skill, 0.75) * animalWeight
		isDressed = true
		
	elseIf (akTargetRef.GetItemCount(keyDressed) > 0)

		skill = huntingSkills._HM_SkillSkinning
		targetContainer = skinningContainer
		itemAdd = keySkinned
		itemRemove = keyDressed

		time = huntingSkills.GetSkillTime(skill, 1) * animalWeight
		isDressed = true

	EndIf

	if(!isDressed)
		CarcassDress(akTargetRef, akActor, time)	
	else
		CarcassAction(akTargetRef, akActor, time, targetContainer, itemRemove, itemAdd, skill)
	endif

	UpdateWidget(false, 0)
	ToggleControls(true)

EndFunction

Function FilterItems(ObjectReference akTargetRef, Actor akActor)

	; If the creature was not fully harvested then the container will put the items back into the creatures inventory
	ResetCondition(skinningContainer)
	ResetCondition(harvestContainer)
	ResetCondition(butcherContainer)

	; Return a JContainer array (basically a list) with items seperated
	int skinningItems = ApplyFilter(akTargetRef, skinningFilter, -1)
	int harvestItems = ApplyFilter(akTargetRef, harvestFilter, 30)
	int butcherItems = ApplyFilter(akTargetRef, butcherFilter, 46)

	; Move the items into temporary containers
	MoveToContainer(akTargetRef, skinningItems, skinningContainer)
	MoveToContainer(akTargetRef, harvestItems, harvestContainer)
	MoveToContainer(akTargetRef, butcherItems, butcherContainer)

	; Add levelled list items, 
	; Filter needs to be called for items that aren't part of the filter or are quest items
	float targetMass = akTargetRef.GetMass() / 100

	skinningContainer.RemoveAllItems()
	if(skinningContainer.GetNumItems() == 0)
		huntingRecipes.AddSkillItems\
		(\
			FilterDeathItems(akTargetRef, skinningFilter),\
			huntingSkills.GetSkillLevel(huntingSkills._HM_SkillSkinning),\
			skinningContainer, targetMass, true\
		)
	endif

	huntingRecipes.AddSkillItems\
	(\
		FilterDeathItems(akTargetRef, harvestFilter, 30),\
		huntingSkills.GetSkillLevel(huntingSkills._HM_SkillHarvesting),\
		harvestContainer, targetMass\
	)

	huntingRecipes.AddSkillItems\
	(\
		FilterDeathItems(akTargetRef, butcherFilter, 46),\
		huntingSkills.GetSkillLevel(huntingSkills._HM_SkillButchering),\
		butcherContainer, targetMass\
	)

EndFunction
; Returns a JArray from JContainers, stored as an int because of whatever voodoo magic he did
int Function ApplyFilter(ObjectReference akTargetRef, string[] filter, \ 
int typeFilter = -1)

	; Initialise array 
	int result = JArray.object()

	; This loops all the items in the targets inventory
	int i = 0 
	int count = akTargetRef.GetNumItems()
	While (i < count)
		Form item = akTargetRef.GetNthForm(i)

		; If the type matches then add the item
		if(typeFilter == item.GetType())
			JArray.addForm(result, item)

		; Otherwise run a loop that checks if the item contains any of the phrases or words in the string filter			
		else
			int u = 0 	
			While (u < filter.Length)
				if(StringUtil.Find(item.GetName(), filter[u]) != -1)
					JArray.addForm(result, item)

				endif
				u += 1
			EndWhile
		endif
		i += 1
	EndWhile

	return result

EndFunction
int Function FilterDeathItems(ObjectReference akTargetRef, string[] filter, int typeFilter = -1)
	; Get Death levelled list, function from papyrus extender
	LeveledItem list = GetDeathItem((akTargetRef as Actor).GetActorBase())
	int result = JArray.object()

	; This works like the Filter above but instead adds items from the levelled list to the containers
	; I can control the quantity of items directly from this
	int i = 0
	While (i < list.GetNumForms())

		Form item = list.GetNthForm(i)	

		if(typeFilter == item.GetType())
			JArray.addForm(result, item)

		else

			int u = 0 	
			While (u < filter.Length)
				If (StringUtil.Find(item.GetName(), filter[u]) != -1)
					JArray.addForm(result, item)

				EndIf			
				u += 1
			EndWhile

		endif
		i += 1
	EndWhile

	return result
EndFunction

Function ResetCondition(ObjectReference containerRef)

	if(containerRef != NONE && containerRef.GetNumItems() > 0)
		containerRef.RemoveAllItems(previousReference, false, true)
	endif

EndFunction

Function MoveToContainer(ObjectReference akTargetRef, int itemList, ObjectReference newContainer)

	int index = 0
	While (index < JArray.count(itemList))
		Form item = JArray.getForm(itemList, index)
		akTargetRef.RemoveItem(item, akTargetRef.GetItemCount(item), true, newContainer)

		index += 1
	EndWhile

EndFunction

Function UpdateWidget(bool visible, int percentage)
	widgetManager.setAllVisible(visible)
	widgetManager.setMeterPercent(progressMeter, percentage)
EndFunction

Function ToggleControls(bool toggle)

	Actor player = Game.GetPlayer()

	if(!toggle)
		Game.DisablePlayerControls(false, false, true, true, false, false, true, false)
		player.PlayIdle(idleSkinning)
		if(Game.GetCameraState() == 0)
			returnFP = true
			Game.ForceThirdPerson()
		endif
	else
		player.PlayIdle(idleStop)
		Utility.Wait(0.2)
		Game.EnablePlayerControls()	
		if(returnFP)
			returnFP = false
			Game.ForceFirstPerson()
		endif	
	endif
	;Toggles Players ability to control their character

EndFunction

bool Function ActionTimer(float time)

	float i = 0.0
	float increment = 0.01

	while(Input.GetNumKeysPressed() == 0 && i < time)
		Utility.Wait(increment)
		i += increment
		UpdateWidget(true, (i / time * 100) as int)
	EndWhile
	
	if(i < time)
		return false
	endif

	return true
	
EndFunction

Function AddItemsFromContainer(ObjectReference targetContainer, Actor akActor)

	int i = 0
	int count = targetContainer.GetNumItems()
	While (i < count)
		Form item = targetContainer.GetNthForm(i)
		akActor.AddItem(item, targetContainer.GetItemCount(item))
		i += 1
	EndWhile

	targetContainer.RemoveAllItems()

EndFunction

Function CarcassDress(ObjectReference akTargetRef, Actor akActor, float time)

	if(ActionTimer(time))
		akTargetRef.Activate(akActor)
		akTargetRef.AddItem(keyDressed)
	endif

EndFunction

Function CarcassAction(ObjectReference akTargetRef, Actor akActor, float time, ObjectReference targetContainer, \
Form keyRemove = NONE, Form keyAdd = NONE, GlobalVariable thisSkill = NONE)

	if(ActionTimer(time))
		akTargetRef.RemoveItem(keyRemove)		

		AddItemsFromContainer(targetContainer, akActor)
		akTargetRef.AddItem(keyAdd)

		thisSkill.SetValue(thisSkill.GetValue() + 1)
	endif
EndFunction