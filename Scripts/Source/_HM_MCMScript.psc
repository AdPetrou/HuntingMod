Scriptname _HM_MCMScript extends ski_configbase  

GlobalVariable Property _HM_ToggleMod Auto
Book Property _HM_BookRef Auto
Perk Property _HM_HuntingRestriction Auto
Perk Property _HM_HuntingPerk Auto

Actor player
bool _HM_Toggled = false

string stateToggleMod = "ToggleModST"
string stateToggleMod_ReadOnly = "ToggleModST_READONLY"
string stateForcePerk = "ForcePerkST"

Event OnInit()

    parent.OnInit()
    player = Game.GetPlayer()

    Pages[0] = "Main"
    Pages[1] = "Stats"

EndEvent

Event OnPageReset(string page)

    if(_HM_Toggled)
        _HM_Toggled = false
    endif

    SetCursorFillMode(LEFT_TO_RIGHT)
    SetCursorPosition(0)

    if(page == Pages[0])
        SetMainPage()
    endif

EndEvent

Function SetMainPage()

    AddHeaderOption("Main")
    AddHeaderOption("")

    if(_HM_ToggleMod.GetValue() == 1)
        AddTextOptionST(stateToggleMod, "Toggle Mod", "Disable?")
        AddToggleOptionST(stateToggleMod_ReadOnly, "Mod Status", true, OPTION_FLAG_DISABLED)
    else
        AddTextOptionST(stateToggleMod, "Toggle Mod", "Enable?")
        AddToggleOptionST(stateToggleMod_ReadOnly, "Mod Status", false, OPTION_FLAG_DISABLED)
    endif

    if(player.HasPerk(_HM_HuntingPerk) || _HM_ToggleMod.GetValue() == 0)
        AddTextOptionST(stateForcePerk, "Force Perk", "Add Hunting Ability", OPTION_FLAG_DISABLED)
        AddEmptyOption()
    else
        AddTextOptionST(stateForcePerk, "Force Perk", "Add Hunting Ability")
        AddEmptyOption()
    endif

    AddHeaderOption("")
    AddHeaderOption("")
    
EndFunction

State ToggleModST

    Event OnHighlightST()
         if(_HM_ToggleMod.GetValue() == 1)
            SetInfoText("Disable Divine Hunting")
         else
            SetInfoText("Enable Divine Hunting")
         endif
    EndEvent

    Event OnSelectST()

        if(_HM_ToggleMod.GetValue() == 1)

            player.RemovePerk(_HM_HuntingRestriction)
            player.RemovePerk(_HM_HuntingPerk)

            _HM_ToggleMod.SetValue(0)
            SetToggleOptionValueST(0)
            SetTextOptionValueST("Disabling, please exit MCM", false, stateToggleMod)

            _HM_Toggled = true

        ElseIf (_HM_ToggleMod.GetValue() == 0)

            If (_HM_BookRef.IsRead())
                player.AddPerk(_HM_HuntingPerk)
            else
                player.AddPerk(_HM_HuntingRestriction)
            EndIf

            _HM_ToggleMod.SetValue(1)
            SetToggleOptionValueST(1)
            SetTextOptionValueST("Enabling, please exit MCM", false, stateToggleMod)

            _HM_Toggled = true

        EndIf
    EndEvent
EndState

State ForcePerkST

    Event OnHighlightST()
        SetInfoText("Adds the Hunting Ability to the Player")
    EndEvent

    Event OnSelectST()
        if(player.HasPerk(_HM_HuntingRestriction))
            player.RemovePerk(_HM_HuntingRestriction)
        endif

        player.AddPerk(_HM_HuntingPerk)
        SetOptionFlagsST(OPTION_FLAG_DISABLED, false, stateForcePerk)
    EndEvent

EndState
