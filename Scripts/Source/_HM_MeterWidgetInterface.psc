Scriptname _HM_MeterWidgetInterface extends commonmeterinterfacehandler  

Event OnInit()

    Int sizeHeight = Utility.GetIniInt("iSize H:Display") 
	Int sizeWidth = Utility.GetIniInt("iSize W:Display")
	meter.X = sizeWidth / 2
	meter.Y =  sizeHeight / 2 - 100
    
EndEvent

function RegisterForEvents()
	RegisterForModEvent("_HM_ForceHuntingMeterDisplay", "ForceMeterDisplay")
	RegisterForModEvent("_HM_RemoveHuntingMeter", "RemoveMeter")
	RegisterForModEvent("_HM_UpdateHuntingMeter", "UpdateMeterDelegate")
	RegisterForModEvent("_HM_CheckHuntingRequirements", "CheckMeterRequirements")

	RegisterForModEvent("_HM_UpdateHuntingMeterIndicator", "UpdateMeterIndicator")
endFunction

Event UpdateMeterIndicator(float percent)
	(Meter as _HM_HuntingWidget).SetIndicatorPercent(percent)
endEvent