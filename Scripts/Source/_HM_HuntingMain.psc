Scriptname _HM_HuntingMain extends Quest  

import PO3_SKSEFunctions

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

Function ActivateCarcassFilterOnly(ObjectReference akTargetRef, Actor akActor)

	if(previousReference != akTargetRef)
		FilterItems(akTargetRef, akActor)
		previousReference = akTargetRef
	endif

	akTargetRef.Activate(akActor)

EndFunction

Function ActivateCarcass(ObjectReference akTargetRef, Actor akActor)

	ToggleControls(false)

	; In case the player decides to switch to skinning a different animal before the previous is finished
	if(previousReference != akTargetRef)
		FilterItems(akTargetRef, akActor)
		previousReference = akTargetRef
	endif

	int i = 0 
	int count = akTargetRef.GetNumItems()
	bool loop = true
	While (loop)

		if(i >= count)
			loop = false
		endif

		If (akTargetRef.GetNthForm(i) == keyButchered)
			akTargetRef.Delete()
			loop = false
		elseIf (akTargetRef.GetNthForm(i) == keyHarvested)
			ButcherCarcass(akTargetRef, akActor, 10.0)
			loop = false
		elseIf (akTargetRef.GetNthForm(i) == keySkinned)
			HarvestCarcass(akTargetRef, akActor, 2.0)
			loop = false	
		elseIf (akTargetRef.GetNthForm(i) == keyDressed)
			SkinCarcass(akTargetRef, akActor, 4.0)
			loop = false			
		EndIf

		if(loop == true)
			i += 1
		endif

	EndWhile

	if(i >= count)
		DressCarcass(akTargetRef, akActor, 3.0)	
	endif

	UpdateWidget(false, 0)
	ToggleControls(true)

EndFunction

Function FilterItems(ObjectReference akTargetRef, Actor akActor)

	; If the creature was not fully harvested then the container will put the items back into the creatures inventory
	ResetInventory(skinningContainer)
	ResetInventory(harvestContainer)
	ResetInventory(butcherContainer)

	; Return a JContainer array (basically a list) with items seperated
	int skinningItems = ApplyFilter(akTargetRef, skinningFilter)
	int harvestItems = ApplyFilter(akTargetRef, harvestFilter, 30)
	int butcherItems = ApplyFilter(akTargetRef, butcherFilter, 46)

	; Move the items into temporary containers
	MoveToContainer(akTargetRef, skinningItems, skinningContainer)
	MoveToContainer(akTargetRef, harvestItems, harvestContainer)
	MoveToContainer(akTargetRef, butcherItems, butcherContainer)

	; Add levelled list items on condition, 
	; Filter needs to be called for items that aren't part of the filter or are quest items
	if(skinningContainer.GetNumItems() == 0)
		AddDeathItems(akTargetRef, skinningFilter, 1, skinningContainer)
	endif

EndFunction

Function ResetInventory(ObjectReference containerRef)

	if(containerRef != NONE && containerRef.GetNumItems() > 0)
		containerRef.RemoveAllItems(previousReference, false, true)
	endif

EndFunction

; Returns a JArray from JContainers, stored as an int because of whatever voodoo magic he did
int Function ApplyFilter(ObjectReference akTargetRef, string[] filter, int typeFilter = -1)

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

Function AddDeathItems(ObjectReference akTargetRef, string[] filter, int amount, ObjectReference addTo)
	; Get Death levelled list, function from papyrus extender
	LeveledItem list = GetDeathItem((akTargetRef as Actor).GetActorBase())

	; This works like the Filter above but instead adds items from the levelled list to the containers
	; I can control the quantity of items directly from this
	int i = 0
	While (i < list.GetNumForms())

		Form item = list.GetNthForm(i)

		int u = 0 	
		While (u < filter.Length)
			If (StringUtil.Find(item.GetName(), filter[u]) != -1)
				addTo.AddItem(item, amount, true)
			EndIf
			
			u += 1
		EndWhile

		i += 1
	EndWhile

EndFunction

Function MoveToContainer(ObjectReference akTargetRef, int itemList, ObjectReference newContainer)

	int index = 0
	While (index < JArray.count(itemList))
		Form item = JArray.getForm(itemList, index)
		akTargetRef.RemoveItem(item, 1000, true, newContainer)

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
		Game.ForceThirdPerson()		
		player.PlayIdle(idleSkinning)	
	else
		player.PlayIdle(idleStop)
		Utility.Wait(0.2)
		Game.EnablePlayerControls()		
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
		akActor.AddItem(targetContainer.GetNthForm(i))
		i += 1
	EndWhile

	targetContainer.RemoveAllItems()

EndFunction

Function DressCarcass(ObjectReference akTargetRef, Actor akActor, float time)

	if(ActionTimer(time))
		akTargetRef.Activate(akActor)
		akTargetRef.AddItem(keyDressed)
	endif

EndFunction

Function SkinCarcass(ObjectReference akTargetRef, Actor akActor, float time)

	if(ActionTimer(time))
		akTargetRef.RemoveItem(keyDressed)		

		AddItemsFromContainer(skinningContainer, akActor)
		akTargetRef.AddItem(keySkinned)
	endif
	
EndFunction

Function HarvestCarcass(ObjectReference akTargetRef, Actor akActor, float time)

	if(ActionTimer(time))
		akTargetRef.RemoveItem(keySkinned)

		AddItemsFromContainer(harvestContainer, akActor)
		akTargetRef.AddItem(keyHarvested)
	endif

EndFunction

Function ButcherCarcass(ObjectReference akTargetRef, Actor akActor, float time)

	if(ActionTimer(time))
		akTargetRef.RemoveItem(keyHarvested)

		AddItemsFromContainer(butcherContainer, akActor)
		akTargetRef.AddItem(keyButchered)

		akTargetRef.Delete()
	endif

EndFunction