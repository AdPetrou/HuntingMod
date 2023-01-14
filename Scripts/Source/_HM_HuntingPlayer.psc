Scriptname _HM_HuntingPlayer extends ReferenceAlias  

GlobalVariable Property _HM_ToggleMod Auto
Perk Property huntingRestriction Auto
Form Property tanningRack Auto

Event OnInit()

	RegisterForSingleUpdate(1)

EndEvent

Event OnUpdate()

	; Add Perk when the games opening scene is finished.
	If (!Game.IsFightingControlsEnabled() )
		RegisterForSingleUpdate(30)
		Return
	EndIf

    if(_HM_ToggleMod.GetValue() == 1)
        Game.GetPlayer().AddPerk(huntingRestriction)
    endif

EndEvent

Event OnActivate(ObjectReference akTargetRef)

	if(akTargetRef.GetBaseObject() == tanningRack)
	endif

EndEvent
