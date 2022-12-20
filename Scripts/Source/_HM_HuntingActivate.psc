Scriptname _HM_HuntingActivate extends Perk

 Function Main(Actor akTarget)
    Debug.MessageBox("This " + akTarget.GetActorBase().GetName() + " is being activated")
 EndFunction
