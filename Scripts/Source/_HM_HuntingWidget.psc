Scriptname _HM_HuntingWidget extends SKI_WidgetBase

int widgetScale = 100
int widgetAlphaVal = 100
Bool widgetVisible = true
int widgetPercentage = 0

int property Percentage
	int function get()
		return widgetPercentage
	endFunction

	function set(int num)
		widgetPercentage = num
		UpdateWidgetNo()
	endFunction
endProperty

bool property Shown
{Set to true to show the widget}
	bool function get()
		return widgetVisible
	endFunction

	function set(bool isShown)
		widgetVisible = isShown
		UpdateShown()
	endFunction
endProperty

int property WidgetAlpha
	; 0 - 100%
	int function get()
		return widgetAlphaVal
	endFunction

	function set(int valAlpha)
		widgetAlphaVal = valAlpha
		UpdateShown()
	endFunction
endProperty

int property Scale
	; 0 - 100%
	int function get()
		return widgetScale
	endFunction

	function set(int valScale)
		widgetScale = valScale
		if(Ready)
			UpdateScale()
		endIf
	endFunction
endProperty

function UpdateWidgetNo()
	if(Ready)
		UI.InvokeInt(HUD_MENU, WidgetRoot + ".setPercent", widgetPercentage) 
	endIf
endFunction

function UpdateShown()
	if(widgetVisible)
		showWidget()
	else
		hideWidget()
	endIf
endFunction

function ShowWidget()
	if(Ready)
		UpdateWidgetModes()
		FadeTo(100, 0.2)
	endIf
endFunction

function HideWidget()
	if(Ready)
		FadeTo(0, 0.2)
	endIf
endFunction

function UpdateScale()	
	UI.SetInt(HUD_MENU, WidgetRoot + ".Scale", widgetScale) 
endFunction

function UpdatePosition()
	;Int xPos = Utility.GetIniInt("iSize H:Display") / 2
	;Int yPos = Utility.GetIniInt("iSize W:Display") / 2 - 100
	X = 0
	Y = -50
endFunction

; @override SKI_WidgetBase
event OnWidgetLoad()
	WidgetName = "Hunting Widget"
	OnWidgetReset()
	updateShown()
endEvent

; @override SKI_WidgetBase
event OnWidgetReset()
	UpdateWidgetNo()	
	UpdateScale()
	parent.OnWidgetReset()

	UpdateShown()
	UpdatePosition()
endEvent

string function GetWidgetSource()
	return "_HM_HuntingMeter.swf"
endFunction

string function GetWidgetType()
	return "_HM_HuntingWidget"
endFunction