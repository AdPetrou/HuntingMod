Scriptname _HM_HuntingSkill extends Quest  

GlobalVariable Property _HM_SkillSkinning Auto
GlobalVariable Property _HM_SkillHarvesting Auto
GlobalVariable Property _HM_SkillButchering Auto
GlobalVariable Property _HM_SkillMax Auto

int[] skillMargin

float minTime = 0.1

;/
Level Thresholds
0
3
8
13
21
34
55
89
144
233
377
/;

int Property _HM_SkillHunting 
    int Function Get()      
        return GetSkillLevel(_HM_SkillSkinning) + GetSkillLevel(_HM_SkillHarvesting) + GetSkillLevel(_HM_SkillButchering)
    EndFunction
EndProperty

Event OnInit()

    skillMargin = new int[11]

    skillMargin[0] = 0
    skillMargin[1] = 3
    skillMargin[2] = 8
    skillMargin[3] = 13
    skillMargin[4] = 21
    skillMargin[5] = 34
    skillMargin[6] = 55
    skillMargin[7] = 89
    skillMargin[8] = 144
    skillMargin[9] = 233
    skillMargin[10] = 377

EndEvent

int function GetSkillLevel(GlobalVariable skill)

    int currentLevel = 0
    int index = 0
    While (index < skillMargin.Length)
        
        if(skill.GetValueInt() >= skillMargin[index])
            currentLevel = index
        else
            return currentLevel
        endif

        index += 1
    EndWhile

    return currentLevel
EndFunction

float function GetSkillTime(GlobalVariable skill, float baseTime, float additional = 0.0)
    ; This Formula should give a rough balancing of the time
    float result = ((_HM_SkillMax.GetValue() - GetSkillLevel(skill)) / 4) * baseTime + minTime
    if(result - additional > minTime)
        result -= additional
    endif

    return result
EndFunction

float function GetTotalSkillTime(float baseTime, float additional = 0.0)
    ; This Formula should give a rough balancing of the time
    float result = ((_HM_SkillMax.GetValue() * 3 - _HM_SkillHunting) / 4) * baseTime + minTime
    if(result - additional > minTime)
        result -= additional
    endif

    return result
EndFunction

