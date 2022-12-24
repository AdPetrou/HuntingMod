Scriptname _HM_BookScript extends ObjectReference  

Perk Property huntingRestriction Auto
Perk Property huntingPerk Auto

bool firstRead = true

Event OnRead()

    if(firstRead)
        Actor player = Game.GetPlayer()
        player.RemovePerk(huntingRestriction)
        player.AddPerk(huntingPerk)
        firstRead = false
    endif
    
EndEvent