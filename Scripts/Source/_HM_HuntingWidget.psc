Scriptname _HM_HuntingWidget extends Common_SKI_MeterWidget

Bool widgetVisible = false
float widgetPercentage = 0.0

event OnWidgetReset()
	debug.trace("Widget " + self + " was reset.")
	parent.OnWidgetReset()
EndEvent

float property indicatorPercent
	{Percent of the meter [0.0, 1.0]. Default: 0.0}
	float function get()
		return widgetPercentage
	endFunction
endProperty

function SetIndicatorPercent(float a_percent, bool a_force = false)
	{Sets the meter percent, a_force sets the meter percent without animation}
	widgetPercentage = a_percent
	if (Ready)
		float[] args = new float[2]
		args[0] = a_percent
		args[1] = a_force as float
		UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".setIndicatorPercent", args)
	endIf
endFunction


String Function GetWidgetSource()
    Return "HuntingMod/meter.swf"
EndFunction
    
String Function GetWidgetType()
    Return "_HM_HuntingWidget"
EndFunction