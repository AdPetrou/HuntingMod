Scriptname _HM_HuntingMain extends Quest  

Actor Property playerRef Auto
Perk Property huntingPerk Auto
FormType Property TypeList Auto

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

ObjectReference previousReference = NONE

Event OnInit()

	RegisterForSingleUpdate(1)

EndEvent

Event OnUpdate()

	; Add Perk when the games opening scene is finished.
	If (!Game.IsFightingControlsEnabled() )
		RegisterForSingleUpdate(30)
		Return
	EndIf

	playerRef.AddPerk(huntingPerk)
    Debug.MessageBox(huntingPerk.GetName() + " Perk Added")
	UpdateWidget(true, 0)	
	
EndEvent

Function ActivateCarcass(ObjectReference akTargetRef, Actor akActor)

	;ToggleControls(false)

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
			ButcherCarcass(akTargetRef, akActor, 30.0)
			loop = false
		elseIf (akTargetRef.GetNthForm(i) == keySkinned)
			HarvestCarcass(akTargetRef, akActor, 5.0)
			loop = false
			return
		elseIf (akTargetRef.GetNthForm(i) == keyDressed)
			SkinCarcass(akTargetRef, akActor, 15.0)
			loop = false			
		EndIf

		i += 1

	EndWhile

	if(i >= count)
		DressCarcass(akTargetRef, akActor, 10.0)	
	endif

	UpdateWidget(false, 0)
	;ToggleControls(true)

EndFunction

Function FilterItems(ObjectReference akTargetRef, Actor akActor)

	; If the creature was not fully harvested then the container will put the items back into the creatures inventory
	ResetInventory(skinningContainer)
	ResetInventory(harvestContainer)
	ResetInventory(butcherContainer)

	; Return a JContainer array (basically a list) with items seperated
	int skinningItems = ApplyFilter(akTargetRef, skinningFilter)
	int harvestItems = ApplyFilter(akTargetRef, harvestFilter, TypeList.kIngredient)
	int butcherItems = ApplyFilter(akTargetRef, butcherFilter, TypeList.kPotion)

	; Move the items into temporary containers
	MoveToContainer(akTargetRef, skinningItems, skinningContainer)
	MoveToContainer(akTargetRef, harvestItems, harvestContainer)
	MoveToContainer(akTargetRef, butcherItems, butcherContainer)

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

		; If using a type filter and the type matches then add the item
		if(typeFilter != -1 || typeFilter == item.GetType())
			JArray.addInt(result, i)	

		; Otherwise run a loop that checks if the item contains any of the phrases or words in the string filter			
		else
			int u = 0 
			int filterCount = filter.Length		
			While (u < filterCount)

				if(StringUtil.Find(item.GetName(), filter[u]) != -1)
					JArray.addInt(result, i)
				endif

				u += 1
			EndWhile
		endif

		i += 1
	EndWhile

	return result

EndFunction

Function MoveToContainer(ObjectReference akTargetRef, int itemList, ObjectReference newContainer)
	int index = 0
	While (index < JArray.count(itemList))
		Form item = akTargetRef.GetNthForm(JArray.getInt(itemList, index))
		akTargetRef.RemoveItem(item, 1, false, newContainer)

		index += 1
	EndWhile
EndFunction

Function UpdateWidget(bool visible, float percentage)
	int displayHandle
	int percentageHandle

	if(visible)
		displayHandle = ModEvent.Create("_HM_ForceHuntingMeterDisplay")
		percentageHandle = ModEvent.Create("_HM_UpdateHuntingMeterIndicator")
	else
		displayHandle = ModEvent.Create("_HM_RemoveHuntingMeterDisplay")
		percentageHandle = ModEvent.Create("_HM_UpdateHuntingMeterIndicator")
	endif

	SendModEvent(displayHandle)
	SendModEvent(percentageHandle, percentage)
EndFunction

Function ToggleControls(bool toggle)
	if(!toggle)
		Game.DisablePlayerControls(true, false, true, true, false, false, true, false)
	else
		Game.EnablePlayerControls()
	endif
	;Toggles Players ability to control their character
EndFunction

bool Function ActionTimer(float time)

	float i = 0.0
	float increment = 0.1

	while(Input.GetNumKeysPressed() == 0 && i < time)
		Utility.Wait(increment)
		i += increment
		;UpdateWidget(true, (i / time * 100) as int)
	EndWhile
	
	if(i < time)
		return false
	endif

	return true
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

		skinningContainer.RemoveAllItems(akActor)
		akTargetRef.AddItem(keySkinned)
	endif
	
EndFunction

Function HarvestCarcass(ObjectReference akTargetRef, Actor akActor, float time)

	if(ActionTimer(time))
		akTargetRef.RemoveItem(keySkinned)

		harvestContainer.RemoveAllItems(akActor)
		akTargetRef.AddItem(keyHarvested)
	endif

EndFunction

Function ButcherCarcass(ObjectReference akTargetRef, Actor akActor, float time)

	if(ActionTimer(time))
		akTargetRef.RemoveItem(keyHarvested)

		butcherContainer.RemoveAllItems(akActor)
		akTargetRef.AddItem(keyButchered)

		akTargetRef.Delete()
	endif

EndFunction