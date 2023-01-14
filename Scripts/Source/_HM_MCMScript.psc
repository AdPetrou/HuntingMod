Scriptname _HM_MCMScript extends ski_configbase  

GlobalVariable Property _HM_SkillSkinning Auto
GlobalVariable Property _HM_SkillHarvesting Auto
GlobalVariable Property _HM_SkillButchering Auto
GlobalVariable Property _HM_SkillMax Auto
GlobalVariable Property _HM_ToggleMod Auto

Book Property _HM_BookRef Auto
Perk Property _HM_HuntingRestriction Auto
Perk Property _HM_HuntingPerk Auto

Actor player
bool _HM_Toggled = false
string[] skillMenuEntries

string stateToggleMod = "ToggleModST"
string stateForcePerk = "ForcePerkST"
string stateForceSkinningSkill = "ForceSkinningSkillST"
string stateForceHarvestingSkill = "ForceHarvestingSkillST"
string stateForceButcheringSkill = "ForceButcheringSkillST"

string stateToggleMod_ReadOnly = "ToggleModST_READONLY"
string stateSkinningSkill_Readonly = "SkinningSkill_READONLY"
string stateHarvestingSkill_Readonly = "HarvestingSkill_READONLY"
string stateButcheringSkill_Readonly = "ButcheringSkill_READONLY"


Event OnInit()

    parent.OnInit()
    player = Game.GetPlayer()

    Pages[0] = "Main"
    Pages[1] = "Stats"

    int i = 0
    skillMenuEntries = Utility.CreateStringArray(_HM_SkillMax.GetValueInt() + 1)
    While (i < skillMenuEntries.Length)
        skillMenuEntries[i] = i
        i += 1
    EndWhile

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

    ;-----------------------------------------------
    AddHeaderOption("Toggle Mod")
    AddHeaderOption("")
    ;-----------------------------------------------

    if(_HM_ToggleMod.GetValue() == 1)
        AddTextOptionST(stateToggleMod, "Toggle Mod", "Disable?")
        AddToggleOptionST(stateToggleMod_ReadOnly, "Mod Status", true, OPTION_FLAG_DISABLED)
    else
        AddTextOptionST(stateToggleMod, "Toggle Mod", "Enable?")
        AddToggleOptionST(stateToggleMod_ReadOnly, "Mod Status", false, OPTION_FLAG_DISABLED)
    endif

    ;-----------------------------------------------
    AddHeaderOption("Cheat & Debug Menu")
    AddHeaderOption("")
    ;-----------------------------------------------

    if( _HM_ToggleMod.GetValue() == 0)
        AddTextOptionST(stateForcePerk, "Force Perk", "Add Hunting Ability", OPTION_FLAG_DISABLED)
        AddEmptyOption()
        ;-----------------------------------------------
        AddEmptyOption()
        AddEmptyOption()
        ;-----------------------------------------------

        AddMenuOptionST(stateForceSkinningSkill, "Set Skill", "Force Skinning Skill", OPTION_FLAG_DISABLED)
        AddTextOptionST(stateSkinningSkill_Readonly, "Skinning Skill:", _HM_SkillSkinning.GetValueInt(), OPTION_FLAG_DISABLED)

        AddMenuOptionST(stateForceHarvestingSkill, "Set Skill", "Force Harvesting Skill", OPTION_FLAG_DISABLED)
        AddTextOptionST(stateHarvestingSkill_Readonly, "Harvesting Skill:", _HM_SkillHarvesting.GetValueInt(), OPTION_FLAG_DISABLED)
        
        AddMenuOptionST(stateForceButcheringSkill, "Set Skill", "Force Butchering Skill", OPTION_FLAG_DISABLED)
        AddTextOptionST(stateButcheringSkill_Readonly, "Butchering Skill:", _HM_SkillButchering.GetValueInt(), OPTION_FLAG_DISABLED)

    else

        if(player.HasPerk(_HM_HuntingPerk))
            AddTextOptionST(stateForcePerk, "Force Perk", "Add Hunting Ability", OPTION_FLAG_DISABLED)
        else
            AddTextOptionST(stateForcePerk, "Force Perk", "Add Hunting Ability")
        endif
        AddEmptyOption()

        ;-----------------------------------------------
        AddEmptyOption()
        AddEmptyOption()
        ;-----------------------------------------------

        AddMenuOptionST(stateForceSkinningSkill, "Set Skill", "Force Skinning Skill")
        AddTextOptionST(stateSkinningSkill_Readonly, "Skinning Skill:", _HM_SkillSkinning.GetValueInt())

        AddMenuOptionST(stateForceHarvestingSkill, "Set Skill", "Force Harvesting Skill")
        AddTextOptionST(stateHarvestingSkill_Readonly, "Harvesting Skill:", _HM_SkillHarvesting.GetValueInt())
        
        AddMenuOptionST(stateForceButcheringSkill, "Set Skill", "Force Butchering Skill")
        AddTextOptionST(stateButcheringSkill_Readonly, "Butchering Skill:", _HM_SkillButchering.GetValueInt())
    endif

    ;-----------------------------------------------
    AddHeaderOption("")
    AddHeaderOption("")
    ;-----------------------------------------------
    
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

State ForceSkinningSkillST

    Event OnHighlightST()
        SetInfoText("Set Skinning Skill")
    EndEvent

    Event OnMenuOpenST()
        SetMenuDialogStartIndex(0)
        SetMenuDialogDefaultIndex(0)
        SetMenuDialogOptions(skillMenuEntries)
    EndEvent
    
    Event OnMenuAcceptST(int a_value)
        _HM_SkillSkinning.SetValue(a_value * 38)
        SetTextOptionValueST(_HM_SkillSkinning.GetValueInt(), false, stateSkinningSkill_Readonly)
    EndEvent

EndState
State ForceHarvestingSkillST

    Event OnHighlightST()
        SetInfoText("Set Harvesting Skill")
    EndEvent

    Event OnMenuOpenST()
        SetMenuDialogStartIndex(0)
        SetMenuDialogDefaultIndex(0)
        SetMenuDialogOptions(skillMenuEntries)
    EndEvent
    
    Event OnMenuAcceptST(int a_value)
        _HM_SkillHarvesting.SetValue(a_value * 38)
        SetTextOptionValueST(_HM_SkillHarvesting.GetValueInt(), false, stateHarvestingSkill_Readonly)
    EndEvent

EndState
State ForceButcheringSkillST

    Event OnHighlightST()
        SetInfoText("Set Butchering Skill")
    EndEvent

    Event OnMenuOpenST()
        SetMenuDialogStartIndex(0)
        SetMenuDialogDefaultIndex(0)
        SetMenuDialogOptions(skillMenuEntries)
    EndEvent
    
    Event OnMenuAcceptST(int a_value)
        _HM_SkillButchering.SetValue(a_value * 38)
        SetTextOptionValueST(_HM_SkillButchering.GetValueInt(), false, stateButcheringSkill_Readonly)
    EndEvent

EndState
