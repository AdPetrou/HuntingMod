;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 24
Scriptname PRKF_HM_HuntingFreshCarcass Extends Perk Hidden

;BEGIN FRAGMENT Fragment_19
Function Fragment_19(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
(mainScript as _HM_HuntingMain).CarcassActivate(akTargetRef, akActor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property mainScript  Auto  
