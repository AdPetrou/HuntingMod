Scriptname _HM_HuntingPlayer extends ReferenceAlias  

Perk Property huntingRestriction Auto

Event OnInit()

	RegisterForSingleUpdate(1)

EndEvent

Event OnUpdate()

	; Add Perk when the games opening scene is finished.
	If (!Game.IsFightingControlsEnabled() )
		RegisterForSingleUpdate(30)
		Return
	EndIf

    Game.GetPlayer().AddPerk(huntingRestriction)
    
EndEvent
