Scriptname _HM_BookScript extends ObjectReference  

GlobalVariable Property _HM_ToggleMod Auto

Perk Property huntingRestriction Auto
Perk Property huntingPerk Auto

bool firstRead = true

Event OnRead()

    Actor player = Game.GetPlayer()

    if(firstRead && player.HasPerk(huntingPerk))
        firstRead = false
        return
    endif

    if(firstRead && _HM_ToggleMod.GetValue() == 1)
        player.RemovePerk(huntingRestriction)
        player.AddPerk(huntingPerk)
        firstRead = false
    endif

EndEvent