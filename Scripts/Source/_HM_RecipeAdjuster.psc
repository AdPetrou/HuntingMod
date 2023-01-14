Scriptname _HM_RecipeAdjuster extends Quest  

string[] itemQualitySuffix

Event OnInit()

    itemQualitySuffix = new string[11]
    itemQualitySuffix[0] = "Useless"
    itemQualitySuffix[1] = " (Pathetic)"
    itemQualitySuffix[2] = " (Poor)"
    itemQualitySuffix[3] = " (Average)"
    itemQualitySuffix[4] = " (Decent)"
    itemQualitySuffix[5] = " (Good)"
    itemQualitySuffix[6] = " (Great)"
    itemQualitySuffix[7] = " (Impressive)"
    itemQualitySuffix[8] = " (Exquisite)"
    itemQualitySuffix[9] = " (Flawless)"
    itemQualitySuffix[10]= " (Legendary)"

EndEvent

int Function SampleInt(int LowerBound, int UpperBound, int SampleSize)

    int result = 0
    int index = 0
    While (index < SampleSize)
        result += PO3_SKSEFunctions.GenerateRandomInt(LowerBound, UpperBound)
        index += 1
    EndWhile

    return result / SampleSize
EndFunction

Function AddSkillItems(int itemArray, int HuntingSkill, ObjectReference targetContainer, float mass = 1.0, bool checkSuffix = false)

    int effectiveSkill = SampleInt(HuntingSkill - 1, HuntingSkill + 1, 3)

    if(effectiveSkill < 0)
        effectiveSkill = 0
    elseif (effectiveSkill > itemQualitySuffix.Length - 1)
        effectiveSkill = itemQualitySuffix.Length - 1
    endif

    Form item = NONE
    int count = JArray.count(itemArray)
    
    ; Check Suffixes for Pelts and Hides
    if(checkSuffix)
        int i = 0
        While (i < count)
            item = JArray.GetForm(itemArray, i)
            
            if(StringUtil.Find(item.GetName(), itemQualitySuffix[HuntingSkill]) != -1)
                targetContainer.AddItem(item)
                return
            endif

            i += 1
        EndWhile
    endif

    ; Keywords will be used for defining rarity
    ; If Suffixes are not going to be checked or are not applicable then add a random amount with skill value as base
    int u = 0
    While (u < count)        
        item = JArray.GetForm(itemArray, u)
        
        int amount = (PO3_SKSEFunctions.GenerateRandomInt(HuntingSkill / 2 - 1, HuntingSkill / 2 + 2) * mass) as int
        if(amount <= 0)
            return
        endif
        targetContainer.AddItem(item, amount)

        u += 1
    EndWhile

EndFunction
