;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 25
Scriptname PRKF__HM_CantHunt Extends Perk Hidden

;BEGIN FRAGMENT Fragment_19
Function Fragment_19(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
mainScript.CarcassActivateFilterOnly(akTargetRef, akActor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_HM_HuntingMain Property mainScript  Auto  
