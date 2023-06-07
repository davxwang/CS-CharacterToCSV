--rounding from http://lua-users.org/wiki/SimpleRound
function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--returns a shallow copy of the table
function CloneTable (table)
    local newTable = {};
    for key, value in pairs(table) do
        if (type(value) == "table") then
            newTable[key] = CloneTable (value);
        else
            newTable[key] = value;
        end
    end
    return newTable;
end

--returns a serialized table for CSV files
function TableToCSVString (table, isIterative)
    local outString = "";

    if (isIterative) then
        for i, value in ipairs(table) do
            --bool to string
            if (type(value) == "boolean") then
                value = tostring(value)
            end
            if (i == 1) then
                if (type(value) == "table") then
                    outString = "{" .. TableToCSVString(value, false) .. "}";
                else
                    outString = value;
                end
            else
                if (type(value) == "table") then
                    outString = outString .. " | " .. "{" .. TableToCSVString(value, false) .. "}";
                else
                    outString = outString .. " | " .. value;
                end
            end
        end
    else
        local first = true;
        for key, value in pairs(table) do
            --bool to string
            if (type(value) == "boolean") then
                value = tostring(value)
            end
            if (first) then
                if (type(value) == "table") then
                    outString = key .. ":" .. "{" .. TableToCSVString(value, false) .. "}";
                else
                    outString = key .. ":" .. value;
                end
                first = false;
            else
                if (type(value) == "table") then
                    outString = outString .. " | " .. key .. ":" .. "{" .. TableToCSVString(value, false) .. "}";
                else
                    outString = outString .. " | " .. key .. ":" .. value;
                end
            end
        end
    end

    return outString;
end

--procedure
function WriteState (stateInfo)
    io.output(FileState);
    if (stateInfo == nil) then
        --header
        io.write("m_UnitID",",","m_UnitStrID",",","m_Title English",",","m_Name English",",","m_Title Korean",",","m_Name Korean",",","m_StateName",",","Animation Time",",","m_StateCoolTime",",","Empower Modifier",",","Damage Modifier",",","Damage Current Hp",",","Damage Max Hp",",","Damage Modifier PvP",",","Damage Current Hp PvP",",","Hit Count",",","Cast Range Max",",","Cast Range Min",",","Invincibility Time",",","Stop Time",",","Loop: m_bAnimLoop",",","Loop: m_StateTimeChangeStateTime",",","Buff: m_BuffStrID",",","Buff: m_BuffLevel",",","Buff: m_bMyTeam",",","Buff: m_fRange",",","Summon: m_UnitStrID",",","Summon: m_bUseMasterData",",","Summon: m_MaxCount",",","Summon: m_fOffsetX","\n");
    else
        --contents
        io.write(stateInfo["m_UnitID"],",",stateInfo["m_UnitStrID"],",",stateInfo["cTitleEng"],",",stateInfo["cNameEng"],",",stateInfo["cTitleKor"],",",stateInfo["cNameKor"],",",stateInfo["m_StateName"],",",stateInfo["animTime"]);
        --conditional writes
        --cool time
        if (stateInfo["m_StateCoolTime"] ~= nil) then
            io.write(",");
            if (type(stateInfo["m_StateCoolTime"]) == "number") then
                io.write(stateInfo["m_StateCoolTime"]);
            else
                for index, value in ipairs(stateInfo["m_StateCoolTime"]) do
                    if (index == 1) then
                        io.write(value)
                    else
                        io.write("|",value);
                    end
                end
            end
        else
            io.write(",","-");
        end
        --Damage Modifiers
        if (stateInfo["m_fEmpowerFactor"] ~= nil) then
            io.write(",",stateInfo["m_fEmpowerFactor"]);
        else
            io.write(",","-");
        end
        if (stateInfo["atkModSum"] ~= 0) then
            io.write(",",stateInfo["atkModSum"]);
        else
            io.write(",","-");
        end
        if (stateInfo["atkHPRateModSum"] ~= 0) then
            io.write(",",stateInfo["atkHPRateModSum"]);
        else
            io.write(",","-");
        end
        if (stateInfo["atkMaxHPRateModSum"] ~= 0) then
            io.write(",",stateInfo["atkMaxHPRateModSum"]);
        else
            io.write(",","-");
        end
        if (stateInfo["atkPVPModSum"] ~= 0) then
            io.write(",",stateInfo["atkPVPModSum"]);
        else
            io.write(",","-");
        end
        if (stateInfo["atkHPRatePVPModSum"] ~= 0) then
            io.write(",",stateInfo["atkHPRatePVPModSum"]);
        else
            io.write(",","-");
        end
        --hit count
        if (stateInfo["hitCount"] ~= 0) then
            io.write(",",stateInfo["hitCount"]);
        else
            io.write(",","-");
        end
        --cast range
        if (stateInfo["m_bNoTarget"] == nil) then
            if (stateInfo["skillMaxRange"] ~= nil) then
                io.write(",",stateInfo["skillMaxRange"]);
            else
                io.write(",","-");
            end
            if (stateInfo["skillMinRange"] ~= nil) then
                io.write(",",stateInfo["skillMinRange"]);
            else
                io.write(",","-");
            end
        else
            --does not use cast range in a meaningful way
            io.write(",","-",",","-");
        end
        --Invincibility Time
        if (stateInfo["invincibilityTime"] ~= nil) then
            io.write(",",stateInfo["invincibilityTime"]);
        else
            io.write(",","-");
        end
        --stop time
        if (stateInfo["m_fStopTime"] ~= nil) then
            io.write(",",stateInfo["m_fStopTime"]);
        else
            io.write(",","-");
        end
        --animation loop
        if (stateInfo["loopAnimLoop"]) then
            io.write(",","true",",",stateInfo["loopStateTimeChangeStateTime"] or "-")
        else
            io.write(",","false",",","-");
        end
        --buff
        if (stateInfo["hasBuff"]) then
            io.write(",",stateInfo["buffBuffStrID"],",",stateInfo["buffBuffLevel"],",",stateInfo["buffMyTeam"],",",stateInfo["buffRange"]);
        else
            io.write(",","-",",","-",",","-",",","-")
        end
        --summon
        if (stateInfo["hasSummon"]) then
            io.write(",",stateInfo["summonUnitStrID"],",",stateInfo["summonUseMasterData"],",",stateInfo["summonMaxCount"],",",stateInfo["summonOffsetX"]);
        else
            io.write(",","-",",","-",",","-",",","-")
        end

        io.write("\n");
    end
end

--procedure
function WriteDamage (attackInfo)
    io.output(FileDamage);
    if (attackInfo == nil) then
        --header
        io.write("m_UnitID",",","m_UnitStrID",",","m_Title English",",","m_Name English",",","m_Title Korean",",","m_Name Korean",",","Source m_StateName",",","m_fEmpowerFactor",",","m_fAtkFactor",",","m_fAtkHPRateFactor",",","m_fAtkMaxHPRateFactor",",","m_fAtkFactorPVP",",","m_fAtkHPRateFactorPVP",",","m_DamageCountMax",",","m_AttackUnitCount",",","m_BackSpeedX",",","m_CrashSuperArmorLevel",",","m_ReActType",",","m_fReAttackGap",",","m_ReAttackCount",",","m_bHitLand",",","m_bHitAir",",","m_bCleanHit",",","m_bForceCritical",",","m_bForceHit",",","m_fGetAgroTime",",","m_Condition",",","m_listNKM_UNIT_STYLE_TYPE",",","m_listAllowStyle",",","m_listIgnoreStyle",",","Attack Time Min",",","Attack Time Max",",","Attack Range Min",",","Attack Range Max",",","Targeting History","\n");
    else
        --contents
        io.write(attackInfo["m_UnitID"],",",attackInfo["m_UnitStrID"],",",attackInfo["cTitleEng"],",",attackInfo["cNameEng"],",",attackInfo["cTitleKor"],",",attackInfo["cNameKor"],",",attackInfo["m_StateName"]);
        --conditional writes
        if (attackInfo["m_fEmpowerFactor"] ~= nil) then
            io.write(",",attackInfo["m_fEmpowerFactor"]);
        else
            io.write(",","-");
        end
        --Damage Modifiers
        if (attackInfo["m_fAtkFactor"] ~= 0) then
            io.write(",",attackInfo["m_fAtkFactor"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_fAtkHPRateFactor"] ~= 0) then
            io.write(",",attackInfo["m_fAtkHPRateFactor"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_fAtkMaxHPRateFactor"] ~= 0) then
            io.write(",",attackInfo["m_fAtkMaxHPRateFactor"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_fAtkFactorPVP"] ~= 0) then
            io.write(",",attackInfo["m_fAtkFactorPVP"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_fAtkHPRateFactorPVP"] ~= 0) then
            io.write(",",attackInfo["m_fAtkHPRateFactorPVP"]);
        else
            io.write(",","-");
        end
        --max and valid hit
        if (attackInfo["m_DamageCountMax"] ~= nil) then
            io.write(",",attackInfo["m_DamageCountMax"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_AttackUnitCount"] ~= 0) then
            io.write(",",attackInfo["m_AttackUnitCount"]);
        else
            io.write(",","-");
        end
        --knockback
        if (attackInfo["m_BackSpeedX"] ~= nil) then
            io.write(",",attackInfo["m_BackSpeedX"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_CrashSuperArmorLevel"] ~= nil) then
            io.write(",",attackInfo["m_CrashSuperArmorLevel"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_ReActType"] ~= nil) then
            io.write(",",attackInfo["m_ReActType"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_fReAttackGap"] ~= nil) then
            io.write(",",attackInfo["m_fReAttackGap"]);
        else
            io.write(",","-");
        end
        if (attackInfo["m_ReAttackCount"] ~= nil) then
            io.write(",",attackInfo["m_ReAttackCount"]);
        else
            io.write(",","-");
        end
        --valid target's move type
        io.write(",",attackInfo["m_bHitLand"]);
        io.write(",",attackInfo["m_bHitAir"]);
        --surefire, force crit, and force hit
        io.write(",",tostring(attackInfo["m_bCleanHit"]));
        io.write(",",tostring(attackInfo["m_bForceCritical"]));
        io.write(",",tostring(attackInfo["m_bForceHit"]));
        --get aggro (taunt)
        if (attackInfo["m_fGetAgroTime"] ~= nil) then
            io.write(",",attackInfo["m_fGetAgroTime"]);
        else
            io.write(",","-");
        end
        --conditionals for the attack
        if (attackInfo["m_Condition"] ~= nil or attackInfo["m_ConditionTarget"] ~= nil or attackInfo["conditionHistory"] ~= nil) then
            io.write(",");

            if (attackInfo["m_Condition"] ~= nil) then
                io.write("{",TableToCSVString(attackInfo["m_Condition"], false),"}");
            end
            if (attackInfo["conditionHistory"] ~= nil) then
                for _, value in ipairs(attackInfo["conditionHistory"]) do
                    io.write("{",TableToCSVString(value, false),"}");
                end
            end
            if (attackInfo["m_ConditionTarget"] ~= nil) then
                io.write("ConditionTarget:{",TableToCSVString(attackInfo["m_ConditionTarget"], false),"}");
            end
        else
            io.write(",","-");
        end
        --valid target's type
        if (attackInfo["m_listNKM_UNIT_STYLE_TYPE"] ~= nil) then
            io.write(",","{",TableToCSVString(attackInfo["m_listNKM_UNIT_STYLE_TYPE"], true),"}");
        else
            io.write(",","-");
        end
        --newer valid target's type
        if (attackInfo["m_listAllowStyle"] ~= nil) then
            io.write(",","{",TableToCSVString(attackInfo["m_listAllowStyle"], true),"}");
        else
            io.write(",","-");
        end
        --invalid target's type
        if (attackInfo["m_listIgnoreStyle"] ~= nil) then
            io.write(",","{",TableToCSVString(attackInfo["m_listIgnoreStyle"], true),"}");
        else
            io.write(",","-");
        end
        --damage timing
        if (attackInfo["attackTimeMin"] ~= nil) then
            io.write(",",attackInfo["attackTimeMin"]);
        else
            io.write(",","-");
        end
        if (attackInfo["attackTimeMax"] ~= nil) then
            io.write(",",attackInfo["attackTimeMax"]);
        else
            io.write(",","-");
        end
        --targeting information
        if (attackInfo["attackRangeMin"] ~= nil) then
            io.write(",",attackInfo["attackRangeMin"]);
        else
            io.write(",","-");
        end
        if (attackInfo["attackRangeMax"] ~= nil) then
            io.write(",",attackInfo["attackRangeMax"]);
        else
            io.write(",","-");
        end
        --target range changes
        if (attackInfo["targetingHistory"] ~= nil) then
            io.write(",",attackInfo["targetingHistory"]);
        else
            io.write(",","-");
        end

        io.write("\n");
    end
end

--procedure for debugging
function WriteUnhandledCondition (m_Condition)
    io.output(FileUnhandledCondition);
    for key, value in pairs(m_Condition) do
        if (type(value) == "table") then
            local tableString = "{";
            for i, v in ipairs(value) do
                if (type(v) == "boolean") then
                    v = tostring(v);
                end
                tableString = tableString .. " " .. v;
                if (i ~= #value) then
                    tableString = tableString .. ",";
                end
            end
            tableString = tableString .. " }";

            io.write(key,"=\t",tableString);
        else
            if (type(value) == "boolean") then
                value = tostring(value);
            end
            io.write(key,"=\t",value);
        end
        io.write("\n");
    end
    io.write("\n");
end

--replaces damage effects that have a m_BASE_ID
function ReplaceEffect (damageEffect, m_BASE_ID)
    local baseDamageEffect = FindEffect(m_BASE_ID);

    --recursive references
    if (baseDamageEffect["m_BASE_ID"] ~= nil) then
        baseDamageEffect = ReplaceEffect(baseDamageEffect, baseDamageEffect["m_BASE_ID"]);
    end

    for effectKey, effectValue in pairs(damageEffect) do
        --special case for state
        if (type(effectValue) == "table" and effectKey == "m_dicNKMState") then
            for _, value in ipairs(effectValue) do
                ReplaceTable(FindState(baseDamageEffect["m_dicNKMState"], value["m_StateName"]), value);
            end
        elseif (type(effectValue) == "table") then
            if baseDamageEffect[effectKey] == nil then
                baseDamageEffect[effectKey] = {};
            end
            ReplaceTable(baseDamageEffect[effectKey], effectValue);
        else
            baseDamageEffect[effectKey] = effectValue;
        end
    end

    return baseDamageEffect;
end

--replaces everything in table1 with table2. Recursively called for nested tables
function ReplaceTable (table1, table2)
    for key, value in pairs(table2) do
        if (type(value) ~= "table") then
            table1[key] = value;
        else
            if table1[key] == nil then
                table1[key] = {};
            end
            ReplaceTable(table1[key], value);
        end
    end
end

--returns the title and name from the given language table
function FindString (langTable, character)
    local foundTitle, foundName = false, false;
    local title, name;
    for _,value in ipairs(langTable) do
        if value[1] == character["m_Title"] then
            title = value[2];
            foundTitle = true;
        end
        if value[1] == character["m_Name"] then
            name = value[2];
            foundName = true;
        end
        if foundTitle and foundName then
            break;
        end
    end
    if title == nil then
        title = " -";
    end
    if name == nil then
        name = "?";
    end
    return title, name;
end

--returns the animation spine as a table
function FindAnimSpine (m_SpriteName)
    for _, value in ipairs(m_dicUnitAnim) do
        if value["animName"] == m_SpriteName then
            return value;
        end
    end
    --not found
    return nil;
end

--returns damage templet, and damage templet base as tables
function FindDamage (m_DamageTempletName)
    --load tables
    if (Table_m_dicDamageTempletStrID == nil or Table_base_m_dicDamageTempletStrID == nil) then
        Table_m_dicDamageTempletStrID = {};
        Table_base_m_dicDamageTempletStrID = {};

        --Table_m_dicDamageTempletStrID
        for i=1,6 do
            local filePath;
            if (i == 1) then
                filePath = "Detail/Damage/LUA_DAMAGE_TEMPLET.lua";
            else
                filePath = "Detail/Damage/LUA_DAMAGE_TEMPLET" .. i .. ".lua";
            end
            local mt = {__newindex = {}};
            local newENV = {};
            setmetatable(newENV, mt);
            local file = loadfile(filePath,"bt",newENV);
            file();

            for _, value in pairs(mt["__newindex"]) do
                Table_m_dicDamageTempletStrID[#Table_m_dicDamageTempletStrID+1] = value;
            end
        end

        --Table_base_m_dicDamageTempletStrID
        for i=1,6 do
            local filePath;
            if (i == 1) then
                filePath = "Detail/Damage/LUA_DAMAGE_TEMPLET_BASE.lua";
            else
                filePath = "Detail/Damage/LUA_DAMAGE_TEMPLET_BASE" .. i .. ".lua";
            end
            local mt = {__newindex = {}};
            local newENV = {};
            setmetatable(newENV, mt);
            local file = loadfile(filePath,"bt",newENV);
            file();

            for _, value in pairs(mt["__newindex"]) do
                Table_base_m_dicDamageTempletStrID[#Table_base_m_dicDamageTempletStrID+1] = value;
            end
        end
    end

    local damage, damageBase = nil, nil;

    --damage
    for _, entry in ipairs(Table_m_dicDamageTempletStrID) do
        for _, value in ipairs(entry) do
            if value["m_DamageTempletName"] == m_DamageTempletName then
                damage = CloneTable(value);
                break;
            end
        end
    end

    --damageBase
    for _, entry in ipairs(Table_base_m_dicDamageTempletStrID) do
        for _, value in ipairs(entry) do
            if value["m_DamageTempletName"] == m_DamageTempletName then
                damageBase = CloneTable(value);
                break;
            end
        end
    end

    return damage, damageBase;
end

--returns the damage effect as a table
function FindEffect (m_DamageEffectID)
    --load tables
    if (Table_m_dicNKMDamageEffectTemplet == nil) then
        Table_m_dicNKMDamageEffectTemplet = {};

        --Table_m_dicNKMDamageEffectTemplet
        for i=1,6 do
            local filePath;
            if (i == 1) then
                filePath = "Detail/Damage/LUA_DAMAGE_EFFECT_TEMPLET.lua";
            else
                filePath = "Detail/Damage/LUA_DAMAGE_EFFECT_TEMPLET" .. i .. ".lua";
            end
            local mt = {__newindex = {}};
            local newENV = {};
            setmetatable(newENV, mt);
            local file = loadfile(filePath,"bt",newENV);
            file();

            for _, value in pairs(mt["__newindex"]) do
                Table_m_dicNKMDamageEffectTemplet[#Table_m_dicNKMDamageEffectTemplet+1] = value;
            end
        end
    end

    --find effect
    for _, entry in ipairs(Table_m_dicNKMDamageEffectTemplet) do
        for _, value in ipairs(entry) do
            if value["m_DamageEffectID"] == m_DamageEffectID then
                return CloneTable(value);
            end
        end
    end
    --not found
    return nil;
end

--returns the skill empower factor
function FindEmpowerFactor (table_m_SkillStrID, m_NKM_SKILL_TYPE)
    --[[
    if (m_UnitSkillTemplet == nil) then
        dofile("Detail/LUA_UNIT_SKILL_TEMPLET.lua");--m_UnitSkillTemplet
    end
    ]]

    local m_fEmpowerFactor = 1;
    local currentSkillLevel = -1;
    
    for _, value in ipairs(m_UnitSkillTemplet) do
        local inTable = false;
        for _, target in ipairs(table_m_SkillStrID) do
            if (value["m_UnitSkillStrID"] == target) then
                inTable = true;
            end
        end

        if (inTable and value["m_NKM_SKILL_TYPE"] == m_NKM_SKILL_TYPE and value["m_Level"] > currentSkillLevel) then
            currentSkillLevel = value["m_Level"];
            m_fEmpowerFactor = value["m_fEmpowerFactor"] or 1;
        end
    end

    return m_fEmpowerFactor;
end

--returns the specified unit state as a table
function FindState (dicState,m_StateName)
    for _, value in ipairs(dicState) do
        if value["m_StateName"] == m_StateName then
            return value;
        end
    end
    --not found
    return nil;
end

--returns total animation time in seconds
function CalculateAnimTime (animSpine, m_AnimName, m_fAnimSpeed, m_listNKMEventAnimSpeed)
    --defaults to 1
    if m_fAnimSpeed == nil then
        m_fAnimSpeed = 1.0;
    end

    --find animation time
    local animTime;
    for _, value in ipairs(animSpine) do
        if value[1] == m_AnimName then
            animTime = value[2];
            break;
        end
    end

    --calculate
    local duration = 0.0;
    --no change in animation speed
    if (m_listNKMEventAnimSpeed == nil or m_listNKMEventAnimSpeed[1] == nil) then
        duration = animTime/m_fAnimSpeed;
    --animation speed changes
    else
        duration = m_listNKMEventAnimSpeed[1]["m_fEventTime"]/m_fAnimSpeed;
        for index, value in ipairs(m_listNKMEventAnimSpeed) do
            if m_listNKMEventAnimSpeed[index + 1] ~= nil then
                duration = duration + (m_listNKMEventAnimSpeed[index + 1]["m_fEventTime"] - value["m_fEventTime"])/value["m_fAnimSpeed"];
            else
                duration = duration + (animTime - value["m_fEventTime"])/value["m_fAnimSpeed"];
            end
        end
    end

    return Round(duration, 2);
end

--interface for calculating animation time for the special case of animations being cut short
function IcalculateAnimTimeChangeState(animSpine, m_AnimName, m_fAnimSpeed, m_listNKMEventAnimSpeed, changeStateTime)
    --copy table to avoid side effects
    local adjustedAnimSpine = CloneTable(animSpine);

    --if no changeStateTime exists, then it defaults to zero.
    if (changeStateTime == nil) then
        changeStateTime = 0
    end

    --replace the relevant animSpine entry's duration with the new cutoff time
    for key, value in ipairs(adjustedAnimSpine) do
        if value[1] == m_AnimName then
            adjustedAnimSpine[key][2] = changeStateTime;
            break;
        end
    end

    --call CalculateAnimTime with adjusted spine
    return CalculateAnimTime (adjustedAnimSpine, m_AnimName, m_fAnimSpeed, m_listNKMEventAnimSpeed);
end

--returns table with true as value for redundant entries in the original table
function AnalyzeConditions (list, ignoreBuff)
    local skip = {};
    local buff = {};
    local buffIgnore = {};
    for i, value in ipairs(list) do
        if (value["m_Condition"] ~= nil) then
            local unhandled = true;
            local condition = value["m_Condition"];

            --skill level
            if (condition["m_SkillStrID"] ~= nil and condition["m_SkillLevel"] ~= nil) then
                unhandled = false;
                if (condition["m_SkillLevel"][2] ~= 99 and condition["m_SkillLevel"][2] ~= 10) then
                    skip[i] = true;
                end
            end
            --master skill level
            if (condition["m_MasterSkillStrID"] ~= nil and condition["m_MasterSkillLevel"] ~= nil) then
                unhandled = false;
                if (condition["m_MasterSkillLevel"][2] ~= 99 and condition["m_MasterSkillLevel"][2] ~= 10) then
                    skip[i] = true;
                end
            end
            --skip skills disabled in pve
            if (condition["m_bUsePVE"] == false) then
                unhandled = false;
                skip[i] = true;
            end
            --buffs
            --special case for HARMONY units: ignore Maestro Nequitia's buff
            if (condition["m_NeedBuffStrID"] == "BUFF_HARMONY_CA_CONDUCT_PASSIVE2" and ignoreBuff == false) then
                unhandled = false;
                skip[i] = true;
            --normal case
            else
                if (condition["m_IgnoreBuffStrID"] ~= nil and ignoreBuff == false) then
                    unhandled = false;
                    --add to absense of buff table
                    if (buffIgnore[condition["m_IgnoreBuffStrID"]] ~= nil) then
                        local innerTable = buffIgnore[condition["m_IgnoreBuffStrID"]];
                        innerTable[#innerTable+1] = i;
                    else
                        buffIgnore[condition["m_IgnoreBuffStrID"]] = {i};
                    end

                    --ckeck buff list and update skip list if a copy exists
                    if (buff[condition["m_IgnoreBuffStrID"]] ~= nil) then
                        for _, buffIgnoreValue in ipairs(buffIgnore[condition["m_IgnoreBuffStrID"]]) do
                            skip[buffIgnoreValue] = true;
                        end
                    end
                end
                if (condition["m_NeedBuffStrID"] ~= nil and ignoreBuff == false) then
                    unhandled = false;
                    --add to absense of buff table
                    if (buff[condition["m_NeedBuffStrID"]] ~= nil) then
                        local innerTable = buff[condition["m_NeedBuffStrID"]];
                        innerTable[#innerTable+1] = i;
                    else
                        buff[condition["m_NeedBuffStrID"]] = {i};
                    end

                    --ckeck buffIgnore list and update skip list for all instances of copies
                    if (buffIgnore[condition["m_NeedBuffStrID"]] ~= nil) then
                        for _, buffIgnoreValue in ipairs(buffIgnore[condition["m_NeedBuffStrID"]]) do
                            skip[buffIgnoreValue] = true;
                        end
                    end
                end
            end

            --no matching conditions
            if (unhandled == true) then
                WriteUnhandledCondition(condition);
            end
        end

        --conditional on the one getting hit
        if (value["m_ConditionTarget"] ~= nil) then
            local unhandled = true;
            local condition = value["m_ConditionTarget"];

            --skip skills disabled in pve
            if (condition["m_bUsePVE"] == false) then
                unhandled = false;
                skip[i] = true;
            end

            --assume target does not have any status effects
            if (condition["m_NeedStatusEffect"]) then
                unhandled = false;
                skip[i] = true;
            end

            --assume the target has full health
            if (condition["m_fHPRate"] ~= nil and condition["m_fHPRate"][2] < 1) then
                unhandled = false;
                skip[i] = true;
            end

            --assume the target has no buffs/debuffs. Absence of buffs/debuffs currently unhandled
            if (condition["m_NeedBuffStrID"] ~= nil and ignoreBuff == false) then
                unhandled = false;
                skip[i] = true;
            end

            --no matching conditions
            if (unhandled == true) then
                WriteUnhandledCondition(condition);
            end
        end
        
        --overly restrictive style count
        if (value["m_listAllowStyle"] ~= nil or value["m_listIgnoreStyle"] ~= nil) then
            --arbitrary thresholds
            --too few allowed styles. Likely some kind of attack that only hits one or two types.
            if (value["m_listAllowStyle"] ~= nil and #(value["m_listAllowStyle"]) <= 2) then
                skip[i] = true;
            end
            --too many disallowed styles. Likely an older implementation of the above.
            if (value["m_listIgnoreStyle"] ~= nil and #(value["m_listIgnoreStyle"]) >= 4) then
                --make sure that the table size isn't being bloated by ship ignoring restrictions
                local tempIgnoreTable = {};
                for _, ignoreStyleValue in ipairs(value["m_listIgnoreStyle"]) do
                    if (string.find(ignoreStyleValue, "NUST_SHIP_") == nil) then
                        tempIgnoreTable[#tempIgnoreTable+1] = ignoreStyleValue;
                    end
                end

                if (#(value["m_listIgnoreStyle"]) - #tempIgnoreTable >= 4) then
                    skip[i] = true;
                end
            end
        end
    end

    return skip;
end

--returns table with true as value for duplicate target states in the original table. Merges with ignoreTable.
function AnalyzeDuplicateStates (stateTable, targetStateKey, ignoreTable)
    if (ignoreTable == nil) then
        ignoreTable = {};
    end
    local duplicate = {};
    local unique = {};
    for tableIndex, tableEntry in ipairs(stateTable) do
        local found = false;
        for _, uniqueValue in ipairs(unique) do
            if (tableEntry[targetStateKey] == uniqueValue and ignoreTable[tableIndex] == nil) then
                found = true;
                break;
            end
        end

        if (found) then
            duplicate[tableIndex] = true;
        else
            if (ignoreTable[tableIndex] == nil) then
                unique[#unique+1] = tableEntry[targetStateKey];
            end
        end
    end

    --merge tables
    for i=1,#stateTable do
        if (ignoreTable[i] ~= nil) then
            duplicate[i] = ignoreTable[i];
        end
    end

    return duplicate;
end

--procedure
function AnalyzeUnitState (state, info, animSpine, m_dicNKMUnitState, isParent)
    local stateInfo = CloneTable(info);

    --state name
    stateInfo["m_StateName"] = state["m_StateName"];

    --animation time
    local mode = "default";
    local changeStateTime = {};
    --decide how animation time will be calculated based on the existence of state changes
    -- default: normal operations
    -- single: single state change. Assumed to cut off the current state unconditionally.
    -- multiple: multiple state changes. Makes no assumptions about the condition, and outputes them all.
    if (state["m_listNKMEventChangeState"] ~= nil) then
        --skip list
        local skip = AnalyzeConditions(state["m_listNKMEventChangeState"], true);

        --tracks whether multiple relevant changes exist
        local first = true;
        for key,value in ipairs(state["m_listNKMEventChangeState"]) do
            --changes to the state of other units does not affect this unit's animation time
            if (skip[key] == nil and value["m_TargetUnitID"] == nil) then
                if (first == true) then
                    mode = "single";
                    changeStateTime[#changeStateTime+1] = value["m_fEventTime"];
                    first = false;
                else
                    mode = "multiple";
                    changeStateTime[#changeStateTime+1] = value["m_fEventTime"];
                end
            end
        end
    end
    --insert into animTime key based on the detected mode
    if (mode == "default") then
        --fix for an unaddressed case of state change
        if (state["m_AnimTimeChangeState"] ~= nil and state["m_AnimTimeChangeStateTime"] ~= nil) then
            stateInfo["animTime"] = IcalculateAnimTimeChangeState(animSpine, state["m_AnimName"], state["m_fAnimSpeed"], state["m_listNKMEventAnimSpeed"], state["m_AnimTimeChangeStateTime"]);
        else
            stateInfo["animTime"] = CalculateAnimTime(animSpine, state["m_AnimName"], state["m_fAnimSpeed"], state["m_listNKMEventAnimSpeed"]);
        end
    elseif (mode == "single") then
        stateInfo["animTime"] = IcalculateAnimTimeChangeState(animSpine, state["m_AnimName"], state["m_fAnimSpeed"], state["m_listNKMEventAnimSpeed"], changeStateTime[1]);
    elseif (mode == "multiple") then
        stateInfo["animTime"] = CalculateAnimTime(animSpine, state["m_AnimName"], state["m_fAnimSpeed"], state["m_listNKMEventAnimSpeed"]);

        local animTimeString = "";
        for _, value in ipairs(changeStateTime) do
            animTimeString = animTimeString .. "|" .. IcalculateAnimTimeChangeState(animSpine, state["m_AnimName"], state["m_fAnimSpeed"], state["m_listNKMEventAnimSpeed"], value);
        end
        stateInfo["animTime"] = stateInfo["animTime"] .. animTimeString;
    else
        stateInfo["animTime"] = "ERROR";
    end

    --cool time
    stateInfo["m_StateCoolTime"] = state["m_StateCoolTime"];

    --empower
    stateInfo["m_fEmpowerFactor"] = 1;
    if (state["m_NKM_SKILL_TYPE"] ~= nil) then
        stateInfo["m_fEmpowerFactor"] = FindEmpowerFactor(stateInfo["table_m_SkillStrID"], state["m_NKM_SKILL_TYPE"]);
    end

    --invincibility time
    if (state["m_listNKMEventInvincible"] ~= nil and state["m_listNKMEventInvincible"][1] ~= nil) then
        local animSpeed = 1;
        --follows animation speed
        if (state["m_listNKMEventInvincible"][1]['m_bAnimTime'] ~= false) then
            animSpeed = state["m_fAnimSpeed"] or 1;
        end
        local invincibleTimeSum = 0;
        local invincibleTimeStart = state["m_listNKMEventInvincible"][1]["m_fEventTimeMin"] or 0;
        local invincibleTimeEnd = state["m_listNKMEventInvincible"][1]["m_fEventTimeMax"];

        --if animation speed changes
        if (state["m_listNKMEventInvincible"][1]['m_bAnimTime'] ~= false and state["m_listNKMEventAnimSpeed"] ~= nil and state["m_listNKMEventAnimSpeed"][1] ~= nil) then
            --first iteration using base speed
            local nextEventTime = state["m_listNKMEventAnimSpeed"][1]["m_fEventTime"];
            if (invincibleTimeEnd > nextEventTime and invincibleTimeStart < nextEventTime) then
                invincibleTimeSum = (nextEventTime - invincibleTimeStart)/animSpeed;
                invincibleTimeStart = nextEventTime;
            elseif (invincibleTimeEnd <= nextEventTime) then
                invincibleTimeSum = (invincibleTimeEnd - invincibleTimeStart)/animSpeed;
                invincibleTimeStart = invincibleTimeEnd;
            end
            --loop
            for index, value in ipairs(state["m_listNKMEventAnimSpeed"]) do
                --exceeded the bound
                if (invincibleTimeEnd == invincibleTimeStart) then
                    break;
                end
                --look to next entry
                nextEventTime = nil;
                if (state["m_listNKMEventAnimSpeed"][index + 1] ~= nil) then
                    nextEventTime = state["m_listNKMEventAnimSpeed"][index + 1]["m_fEventTime"];
                end

                if (nextEventTime ~= nil) then
                    if (invincibleTimeEnd >= nextEventTime and invincibleTimeStart < nextEventTime) then
                        invincibleTimeSum = invincibleTimeSum + (nextEventTime - invincibleTimeStart)/value["m_fAnimSpeed"];
                        invincibleTimeStart = nextEventTime;
                    elseif (invincibleTimeEnd <= nextEventTime) then
                        invincibleTimeSum = invincibleTimeSum + (invincibleTimeEnd - invincibleTimeStart)/value["m_fAnimSpeed"];
                        invincibleTimeStart = invincibleTimeEnd;
                    end
                else
                    invincibleTimeSum = invincibleTimeSum + (invincibleTimeEnd - invincibleTimeStart)/value["m_fAnimSpeed"];
                end
            end
        else
            invincibleTimeSum = (invincibleTimeEnd - invincibleTimeStart)/animSpeed;
        end

        --invincibility cannot exceed animation time
        if (type(stateInfo["animTime"]) == "number" and invincibleTimeSum > stateInfo["animTime"]) then
            --safety against nil. The 'or invincibilityTimeSum' part is never supposed to be reached.
            invincibleTimeSum = tonumber(stateInfo["animTime"]) or invincibleTimeSum;
        end
        stateInfo["invincibilityTime"] = invincibleTimeSum;
    end

    --stop time
    if (state["m_listNKMEventStopTime"] ~= nil) then
        stateInfo["m_fStopTime"] = state["m_listNKMEventStopTime"][1]["m_fStopTime"];
    end

    --attacks with multiple states do not inherit casting range in a meaningful manner
    if (isParent ~= true) then
        stateInfo["skillMaxRange"] = "-";
    end

    --special case for looped attacks
    if (state["m_bAnimLoop"] == true) then
        stateInfo["loopAnimLoop"] = true;
        stateInfo["loopStateTimeChangeStateTime"] = state["m_StateTimeChangeStateTime"];
        stateInfo["skillMaxRange"] = state["m_TargetDistOverChangeStateDist"];
    else
        stateInfo["loopAnimLoop"] = false;
    end

    --buffs
    if (state["m_listNKMEventBuff"] ~= nil) then
        for i, buff in ipairs(state["m_listNKMEventBuff"]) do
            if (i == 1) then
                stateInfo["hasBuff"] = true;
                stateInfo["buffBuffStrID"] = buff["m_BuffStrID"];
                if (buff["m_bBuffLevel"] ~= nil) then
                    stateInfo["buffBuffLevel"] = buff["m_bBuffLevel"];
                else
                    stateInfo["buffBuffLevel"] = "-";
                end
                if (buff["m_bMyTeam"] ~= nil) then
                    stateInfo["buffMyTeam"] = tostring(buff["m_bMyTeam"]);
                else
                    stateInfo["buffMyTeam"] = "false"
                end
                if (buff["m_fRange"] ~= nil) then
                    stateInfo["buffRange"] = buff["m_fRange"];
                else
                    stateInfo["buffRange"] = "-";
                end
            else
                stateInfo["buffBuffStrID"] = stateInfo["buffBuffStrID"] .. " | " .. buff["m_BuffStrID"];
                if (buff["m_bBuffLevel"] ~= nil) then
                    stateInfo["buffBuffLevel"] = stateInfo["buffBuffLevel"] .. " | " .. buff["m_bBuffLevel"];
                else
                    stateInfo["buffBuffLevel"] = stateInfo["buffBuffLevel"] .. " | " .. "-";
                end
                if (buff["m_bMyTeam"] ~= nil) then
                    stateInfo["buffMyTeam"] = stateInfo["buffMyTeam"] .. " | " .. tostring(buff["m_bMyTeam"]);
                else
                    stateInfo["buffMyTeam"] = stateInfo["buffMyTeam"] .. " | " .. "false"
                end
                if (buff["m_fRange"] ~= nil) then
                    stateInfo["buffRange"] = stateInfo["buffRange"] .. " | " .. buff["m_fRange"];
                else
                    stateInfo["buffRange"] = stateInfo["buffRange"] .. " | " .. "-";
                end
            end
        end
    else
        stateInfo["hasBuff"] = false;
    end

    --summons
    if (state["m_listNKMEventRespawn"] ~= nil) then
        for i, respawn in ipairs(state["m_listNKMEventRespawn"]) do
            if (i == 1) then
                stateInfo["hasSummon"] = true;
                stateInfo["summonUnitStrID"] = respawn["m_UnitStrID"];
                if (respawn["m_bUseMasterData"] ~= nil) then
                    stateInfo["summonUseMasterData"] = tostring(respawn["m_bUseMasterData"]);
                else
                    stateInfo["summonUseMasterData"] = "false";
                end
                if (respawn["m_MaxCount"] ~= nil) then
                    stateInfo["summonMaxCount"] = respawn["m_MaxCount"];
                else
                    stateInfo["summonMaxCount"] = "-";
                end
                if (respawn["m_fOffsetX"] ~= nil) then
                    stateInfo["summonOffsetX"] = respawn["m_fOffsetX"];
                else
                    stateInfo["summonOffsetX"] = 0;
                end
            else
                stateInfo["summonUnitStrID"] = stateInfo["summonUnitStrID"] .. " | " .. respawn["m_UnitStrID"];
                if (respawn["m_bUseMasterData"] ~= nil) then
                    stateInfo["summonUseMasterData"] = stateInfo["summonUseMasterData"] .. " | " .. tostring(respawn["m_bUseMasterData"]);
                else
                    stateInfo["summonUseMasterData"] = stateInfo["summonUseMasterData"] .. " | " .. "false";
                end
                if (respawn["m_MaxCount"] ~= nil) then
                    stateInfo["summonMaxCount"] = stateInfo["summonMaxCount"] .. " | " .. respawn["m_MaxCount"];
                else
                    stateInfo["summonMaxCount"] = stateInfo["summonMaxCount"] .. " | " .. "-";
                end
                if (respawn["m_fOffsetX"] ~= nil) then
                    stateInfo["summonOffsetX"] = stateInfo["summonOffsetX"] .. " | " .. respawn["m_fOffsetX"];
                else
                    stateInfo["summonOffsetX"] = stateInfo["summonOffsetX"] .. " | " .. 0;
                end
            end
        end
    else
        stateInfo["hasSummon"] = false;
    end

    --analyze direct attacks
    if (state["m_listNKMEventAttack"] ~= nil) then
        local skip
        skip = AnalyzeConditions(state["m_listNKMEventAttack"], false);
        for i, event in ipairs(state["m_listNKMEventAttack"]) do
            --ensure the attack is executed within the animation duration
            if ((event["m_bAnimTime"] == false) or CalculateAnimTime(animSpine, state["m_AnimName"], nil, nil) >= (event["m_fEventTimeMin"] or 0)) then
                --special case for looped attacks that don't follow animation time
                if (stateInfo["loopAnimLoop"] == true and event["m_bAnimTime"] == false) then
                    local tempDamageInfo = {atkModSum=stateInfo["atkModSum"], atkHPRateModSum=stateInfo["atkHPRateModSum"], atkMaxHPRateModSum=stateInfo["atkMaxHPRateModSum"], atkPVPModSum=stateInfo["atkPVPModSum"], atkHPRatePVPModSum=stateInfo["atkHPRatePVPModSum"]};

                    if (skip[i] ~= nil) then
                        AnalyzeAttackEvent(event, CloneTable(stateInfo));
                    else
                        AnalyzeAttackEvent(event, stateInfo);
                    end

                    --assume these attacks are distributed over the full loop's duration
                    for _, damageType in ipairs({"atkModSum", "atkHPRateModSum", "atkMaxHPRateModSum", "atkPVPModSum", "atkHPRatePVPModSum"}) do
                        if (tempDamageInfo[damageType] ~= nil or stateInfo[damageType] ~= nil) then
                            stateInfo[damageType] = (tempDamageInfo[damageType] or 0) + ((stateInfo[damageType] or 0) - (tempDamageInfo[damageType] or 0))/stateInfo["loopStateTimeChangeStateTime"];
                        end
                    end
                --default
                else
                    if (skip[i] ~= nil) then
                        AnalyzeAttackEvent(event, CloneTable(stateInfo));
                    else
                        AnalyzeAttackEvent(event, stateInfo);
                    end
                end
            end
        end
    end

    --analyze attacks through damage effects
    if (state["m_listNKMEventDamageEffect"] ~= nil) then
        local skip = AnalyzeConditions(state["m_listNKMEventDamageEffect"], false);
        for i, effect in ipairs(state["m_listNKMEventDamageEffect"]) do
            --ensure the attack is executed within the animation duration
            if ((effect["m_bAnimTime"] == false) or CalculateAnimTime(animSpine, state["m_AnimName"], nil, nil) >= (effect["m_fEventTime"] or 0)) then
                --special case for looped attacks that don't follow animation time
                if (stateInfo["loopAnimLoop"] == true and effect["m_bAnimTime"] == false) then
                    local tempDamageInfo = {atkModSum=stateInfo["atkModSum"], atkHPRateModSum=stateInfo["atkHPRateModSum"], atkMaxHPRateModSum=stateInfo["atkMaxHPRateModSum"], atkPVPModSum=stateInfo["atkPVPModSum"], atkHPRatePVPModSum=stateInfo["atkHPRatePVPModSum"]};

                    --edge case of stacked buff condition
                    if (skip[i] ~= nil or (effect["m_Condition"] ~= nil and effect["m_Condition"]["m_NeedBuffOverlapCount"] ~= nil and effect["m_Condition"]["m_NeedBuffOverlapCount"][1] > 10)) then
                        AnalyzeDamageEffect(effect, CloneTable(stateInfo));
                    else
                        AnalyzeDamageEffect(effect, stateInfo);
                    end

                    --assume these attacks are distributed over the full loop's duration
                    for _, damageType in ipairs({"atkModSum", "atkHPRateModSum", "atkMaxHPRateModSum", "atkPVPModSum", "atkHPRatePVPModSum"}) do
                        if (tempDamageInfo[damageType] ~= nil or stateInfo[damageType] ~= nil) then
                            stateInfo[damageType] = (tempDamageInfo[damageType] or 0) + ((stateInfo[damageType] or 0) - (tempDamageInfo[damageType] or 0))/stateInfo["loopStateTimeChangeStateTime"];
                        end
                    end
                --default
                else
                    --edge case of stacked buff condition
                    if (skip[i] ~= nil or (effect["m_Condition"] ~= nil and effect["m_Condition"]["m_NeedBuffOverlapCount"] ~= nil and effect["m_Condition"]["m_NeedBuffOverlapCount"][1] > 10)) then
                        AnalyzeDamageEffect(effect, CloneTable(stateInfo));
                    else
                        AnalyzeDamageEffect(effect, stateInfo);
                    end
                end
            end
        end
    end

    --output state information to file
    WriteState(stateInfo);

    --unit transforms into another. Track the event by inserting the transformed as a key
    if (state["m_NKMEventUnitChange"] ~= nil and state["m_NKMEventUnitChange"]["m_UnitStrID"] ~= nil) then
        UnitTransformation[state["m_NKMEventUnitChange"]["m_UnitStrID"]] = info["m_UnitStrID"];
    end

    --force state change of other units
    if (state["m_listNKMEventChangeState"] ~= nil) then
        local skip = AnalyzeConditions(state["m_listNKMEventChangeState"], true);
        for i,eventChangeStateEntry in ipairs(state["m_listNKMEventChangeState"]) do
            --ignore changes to the state of this unit. Assumed each unit id will only be changed once.
            if (skip[i] == nil and eventChangeStateEntry["m_TargetUnitID"] ~= nil) then
                --analyze
                --mostly copied from main
                --note to self: encapsulate this code for this and main.
                for _,commandedUnit in ipairs(m_dicNKMUnitTempletBaseByStrID) do
                    if (commandedUnit["m_UnitID"] == eventChangeStateEntry["m_TargetUnitID"]) then
                        local commandedUnitInfo = {};
                        --id, strid, title, and name
                        commandedUnitInfo["m_UnitID"] = commandedUnit["m_UnitID"]
                        commandedUnitInfo["m_UnitStrID"] = commandedUnit["m_UnitStrID"];
                        commandedUnitInfo["cTitleEng"], commandedUnitInfo["cNameEng"] = FindString(EngString, commandedUnit);
                        commandedUnitInfo["cTitleKor"], commandedUnitInfo["cNameKor"] = FindString(KorString, commandedUnit);

                        --load unit
                        local filePath = "Unit/" .. commandedUnit["m_UnitTempletFileName"] .. ".lua";
                        dofile(filePath);                       --NKMUnitTemplet
                        local local_NKMUnitTemplet = NKMUnitTemplet;
                        if local_NKMUnitTemplet["BASE_UNIT_STR_ID"] ~= nil then
                            --load base file
                            local temp = local_NKMUnitTemplet;
                            filePath = "Unit/" .. local_NKMUnitTemplet["BASE_UNIT_STR_ID"] .. ".lua";
                            dofile(filePath);
                            local_NKMUnitTemplet = NKMUnitTemplet;
                            --replace all relevant entries
                            for key, value in pairs(temp) do
                                local_NKMUnitTemplet[key] = value;
                            end
                        end
                
                        --default casting range
                        commandedUnitInfo["skillMaxRange"] = local_NKMUnitTemplet["m_TargetNearRange"];
                        local targetingType = local_NKMUnitTemplet["m_NKM_FIND_TARGET_TYPE"] or commandedUnit["m_NKM_FIND_TARGET_TYPE"];
                        --default damage value
                        commandedUnitInfo["atkModSum"] = 0;
                        commandedUnitInfo["atkHPRateModSum"] = 0;
                        commandedUnitInfo["atkMaxHPRateModSum"] = 0;
                        commandedUnitInfo["atkPVPModSum"] = 0;
                        commandedUnitInfo["atkHPRatePVPModSum"] = 0;
                        --default hit count
                        commandedUnitInfo["hitCount"] = 0;

                        --store SkillStrIDs
                        local table_m_SkillStrID = {};
                        if (commandedUnit["m_bContractable"] == true) then
                            local string_m_SkillStrID = "m_SkillStrID";
                            local current_m_SkillStrID = string_m_SkillStrID .. 1;
                            local counter = 1;
                            while (commandedUnit[current_m_SkillStrID] ~= nil) do
                                table_m_SkillStrID[#table_m_SkillStrID+1] = commandedUnit[current_m_SkillStrID];
                                counter = counter + 1;
                                current_m_SkillStrID = string_m_SkillStrID .. counter;
                            end
                        end
                        commandedUnitInfo["table_m_SkillStrID"] = table_m_SkillStrID;

                        --call analysis
                        commandedUnitInfo["targetingHistory"] = "-";
                        AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], eventChangeStateEntry["m_ChangeState"]), commandedUnitInfo, FindAnimSpine(commandedUnit["m_SpriteName"]), local_NKMUnitTemplet["m_dicNKMUnitState"], true);

                        --only one entry needed
                        break;
                    end
                end
            end
        end
    end

    --special case for commanding a damage event. Damage does not show up in state.
    if (state["m_listNKMEventDEStateChange"] ~= nil) then
        for _, value in ipairs(state["m_listNKMEventDEStateChange"]) do
            local CommandedDEEffectInfo = CloneTable(stateInfo);
            --find effect
            local CommandedDEDamageEffect = FindEffect(value["m_DamageEffectID"]);

            --m_BASE_ID exists
            if (CommandedDEDamageEffect["m_BASE_ID"] ~= nil) then
                CommandedDEDamageEffect = ReplaceEffect(CommandedDEDamageEffect, CommandedDEDamageEffect["m_BASE_ID"]);
            end

            --copy info
            CommandedDEEffectInfo["m_DamageCountMax"] = CommandedDEDamageEffect["m_DamageCountMax"];
            CommandedDEEffectInfo["m_MainEffectName"] = CommandedDEDamageEffect["m_MainEffectName"];
            --record targeting info
            if (CommandedDEDamageEffect["m_NKM_FIND_TARGET_TYPE"] ~= nil and CommandedDEDamageEffect["m_fSeeRange"] ~= nil) then
                CommandedDEEffectInfo["targetingHistory"] = CommandedDEEffectInfo["targetingHistory"] .. " | " .. CommandedDEDamageEffect["m_NKM_FIND_TARGET_TYPE"] .. " TargetRange: " .. CommandedDEDamageEffect["m_fSeeRange"];
            else
                CommandedDEEffectInfo["targetingHistory"] = CommandedDEEffectInfo["targetingHistory"] .. " | -";
            end

            --damage effect state
            AnalyzeEffectState(FindState(CommandedDEDamageEffect["m_dicNKMState"], value["m_ChangeState"]), CommandedDEDamageEffect["m_dicNKMState"], CommandedDEEffectInfo);
        end
    end

    --traversal for attacks with multiple states
    --track states that have already been handled for reducing redundancy
    local traversedState = {};
    if (state["m_AnimEndChangeState"] ~= nil and state["m_AnimEndChangeState"] ~= "" and state["m_AnimEndChangeState"] ~= "USN_ASTAND" and state["m_AnimEndChangeState"] ~= "USN_RUN") then
        if (traversedState[state["m_AnimEndChangeState"]] == nil) then
            AnalyzeUnitState(FindState(m_dicNKMUnitState, state["m_AnimEndChangeState"]), info, animSpine, m_dicNKMUnitState, false);
            traversedState[state["m_AnimEndChangeState"]] = true;
        end
    elseif (state["m_AnimTimeChangeState"] ~= nil and state["m_AnimTimeChangeState"] ~= "" and state["m_AnimTimeChangeState"] ~= "USN_ASTAND" and state["m_AnimTimeChangeState"] ~= "USN_RUN") then
        if (traversedState[state["m_AnimTimeChangeState"]] == nil) then
            AnalyzeUnitState(FindState(m_dicNKMUnitState, state["m_AnimTimeChangeState"]), info, animSpine, m_dicNKMUnitState, false);
            traversedState[state["m_AnimTimeChangeState"]] = true;
        end
    elseif (state["m_bAnimLoop"] == true and state["m_StateTimeChangeState"] ~= nil  and state["m_StateTimeChangeState"] ~= "" and state["m_StateTimeChangeState"] ~= "USN_ASTAND") then
        if (traversedState[state["m_StateTimeChangeState"]] == nil) then
            AnalyzeUnitState(FindState(m_dicNKMUnitState, state["m_StateTimeChangeState"]), info, animSpine, m_dicNKMUnitState, false);
            traversedState[state["m_StateTimeChangeState"]] = true;
        end
    elseif (state["m_listNKMEventChangeState"] ~= nil) then
        for _, value in ipairs(state["m_listNKMEventChangeState"]) do
            --ignore forcing other units to change states
            if (value["m_TargetUnitID"] == nil and value["m_ChangeState"] ~= "USN_ASTAND" and value["m_ChangeState"] ~= "USN_RUN") then
                if (traversedState[value["m_ChangeState"]] == nil) then
                    AnalyzeUnitState(FindState(m_dicNKMUnitState, value["m_ChangeState"]), info, animSpine, m_dicNKMUnitState, false);
                    traversedState[value["m_ChangeState"]] = true;
                end
            end
        end
    --special case for normal counter attack
    elseif (state["m_bNormalRevengeState"] ~= nil) then
        if (traversedState[state["m_RevengeChangeState"]] == nil) then
            AnalyzeUnitState(FindState(m_dicNKMUnitState, state["m_RevengeChangeState"]), info, animSpine, m_dicNKMUnitState, false);
            traversedState[state["m_RevengeChangeState"]] = true;
        end
    end
end

--procedure
function AnalyzeAttackEvent (event, info)
    local attackInfo = CloneTable(info);
    local damage, damageBase;

    --copy details
    attackInfo["attackTimeMin"] = event["m_fEventTimeMin"] or 0;
    attackInfo["attackTimeMax"] = event["m_fEventTimeMax"] or 0;
    attackInfo["attackRangeMin"] = event["m_fRangeMin"] or 0;
    attackInfo["attackRangeMax"] = event["m_fRangeMax"] or 0;
    if (event["m_bHitLand"] == true or event["m_bHitLand"] == nil) then
        attackInfo["m_bHitLand"] = "true";
    else
        attackInfo["m_bHitLand"] = "false";
    end
    if(event["m_bHitAir"] == true or event["m_bHitAir"] == nil) then
        attackInfo["m_bHitAir"] = "true";
    else
        attackInfo["m_bHitAir"] = "false";
    end
    attackInfo["m_AttackUnitCount"] = event["m_AttackUnitCount"] or 0;
    if (event["m_fGetAgroTime"] ~= nil) then
        attackInfo["m_fGetAgroTime"] = event["m_fGetAgroTime"];
    end
    if (event["m_Condition"] ~= nil) then
        attackInfo["m_Condition"] = event["m_Condition"];
    end
    if (event["m_ConditionTarget"] ~= nil) then
        attackInfo["m_ConditionTarget"] = event["m_ConditionTarget"];
    end
    if (info["conditionHistory"] ~= nil) then
        attackInfo["conditionHistory"] = info["conditionHistory"];
    end
    if (event["m_listNKM_UNIT_STYLE_TYPE"] ~= nil) then
        attackInfo["m_listNKM_UNIT_STYLE_TYPE"] = event["m_listNKM_UNIT_STYLE_TYPE"];
    end
    if (event["m_listAllowStyle"] ~= nil) then
        attackInfo["m_listAllowStyle"] = event["m_listAllowStyle"];
    end
    if (event["m_listIgnoreStyle"] ~= nil) then
        attackInfo["m_listIgnoreStyle"] = event["m_listIgnoreStyle"];
    end
    attackInfo["m_bCleanHit"] = event["m_bCleanHit"] or false;
    attackInfo["m_bForceCritical"] = event["m_bForceCritical"] or false;
    attackInfo["m_bForceHit"] = event["m_bForceHit"] or false;

    --find additional details
    damage, damageBase = FindDamage(event["m_DamageTempletName"]);

    --damage modifiers
    attackInfo["m_fAtkFactor"] = damageBase["m_fAtkFactor"] or 0;
    attackInfo["m_fAtkHPRateFactor"] = damageBase["m_fAtkHPRateFactor"] or 0;
    attackInfo["m_fAtkMaxHPRateFactor"] = damageBase["m_fAtkMaxHPRateFactor"] or 0;
    attackInfo["m_fAtkFactorPVP"] = damageBase["m_fAtkFactorPVP"] or 0;
    attackInfo["m_fAtkHPRateFactorPVP"] = damageBase["m_fAtkHPRateFactorPVP"] or 0;

    --pass damage modifier to calling function
    info["atkModSum"] = info["atkModSum"] + attackInfo["m_fAtkFactor"];
    info["atkHPRateModSum"] = info["atkHPRateModSum"] + attackInfo["m_fAtkHPRateFactor"];
    info["atkMaxHPRateModSum"] = info["atkMaxHPRateModSum"] + attackInfo["m_fAtkMaxHPRateFactor"];
    info["atkPVPModSum"] = info["atkPVPModSum"] + attackInfo["m_fAtkFactorPVP"];
    info["atkHPRatePVPModSum"] = info["atkHPRatePVPModSum"] + attackInfo["m_fAtkHPRateFactorPVP"];
    --add to hit count tally
    info["hitCount"] = info["hitCount"] + 1;

    --attack details
    if (damage["m_BackSpeedX"] ~= nil) then
        attackInfo["m_BackSpeedX"] = damage["m_BackSpeedX"];
    end
    if (damage["m_CrashSuperArmorLevel"] ~= nil) then
        attackInfo["m_CrashSuperArmorLevel"] = damage["m_CrashSuperArmorLevel"];
    end
    if (damage["m_ReActType"] ~= nil) then
        attackInfo["m_ReActType"] = damage["m_ReActType"];
    end
    if (damage["m_fReAttackGap"] ~= nil) then
        attackInfo["m_fReAttackGap"] = damage["m_fReAttackGap"];
    end
    if (damage["m_ReAttackCount"] ~= nil) then
        attackInfo["m_ReAttackCount"] = damage["m_ReAttackCount"];
    end

    WriteDamage(attackInfo);
end

--procedure
function AnalyzeDamageEffect (event, info)
    local effectInfo = CloneTable(info);
    --record condition
    if (event["m_Condition"] ~= nil) then effectInfo["conditionHistory"][#effectInfo["conditionHistory"]+1] = event["m_Condition"] end
    --find effect
    local damageEffect = FindEffect(event["m_DEName"]);

    --fix an inconsistency in the files
    if (damageEffect["m_DamageEffectID"] == "DE_UNIT_SCAVENGER_C_COLLECT_HYPER1") then
        --verify inconsistency still exists
        if (damageEffect["m_dicNKMState"][1]["m_StateName"] == damageEffect["m_dicNKMState"][2]["m_StateName"]) then
            damageEffect["m_dicNKMState"][2]["m_StateName"] = damageEffect["m_dicNKMState"][1]["m_StateTimeChangeState"];
        end
    end

    --m_BASE_ID exists
    if (damageEffect["m_BASE_ID"] ~= nil) then
        damageEffect = ReplaceEffect(damageEffect, damageEffect["m_BASE_ID"]);
    end

    --copy info
    effectInfo["m_DamageCountMax"] = damageEffect["m_DamageCountMax"];
    effectInfo["m_MainEffectName"] = damageEffect["m_MainEffectName"];
    --record targeting info
    if (damageEffect["m_NKM_FIND_TARGET_TYPE"] ~= nil and damageEffect["m_fSeeRange"] ~= nil) then
        effectInfo["targetingHistory"] = effectInfo["targetingHistory"] .. " | " .. damageEffect["m_NKM_FIND_TARGET_TYPE"] .. " TargetRange: " .. damageEffect["m_fSeeRange"];
    else
        effectInfo["targetingHistory"] = effectInfo["targetingHistory"] .. " | -";
    end

    --damage effect state
    AnalyzeEffectState(damageEffect["m_dicNKMState"][1], damageEffect["m_dicNKMState"], effectInfo);

    --analyze direct attacks
    if (damageEffect["m_listNKMDieEventAttack"] ~= nil) then
        local skip
        skip = AnalyzeConditions(damageEffect["m_listNKMDieEventAttack"], false);
        for i, event in ipairs(damageEffect["m_listNKMDieEventAttack"]) do
            if (skip[i] ~= nil) then
                AnalyzeAttackEvent(event, CloneTable(effectInfo));
            else
                AnalyzeAttackEvent(event, effectInfo);
            end
        end
    end

    --analyze attacks through damage effects
    if (damageEffect["m_listNKMDieEventDamageEffect"] ~= nil) then
        local skip = AnalyzeConditions(damageEffect["m_listNKMDieEventDamageEffect"], false);
        for i, effect in ipairs(damageEffect["m_listNKMDieEventDamageEffect"]) do
            if (skip[i] ~= nil) then
                AnalyzeDamageEffect(effect, CloneTable(effectInfo));
            else
                AnalyzeDamageEffect(effect, effectInfo);
            end
        end
    end

    --pass relevant data through info
    info["atkModSum"] = effectInfo["atkModSum"];
    info["atkHPRateModSum"] = effectInfo["atkHPRateModSum"];
    info["atkMaxHPRateModSum"] = effectInfo["atkMaxHPRateModSum"];
    info["atkPVPModSum"] = effectInfo["atkPVPModSum"];
    info["atkHPRatePVPModSum"] = effectInfo["atkHPRatePVPModSum"];
    info["hitCount"] = effectInfo["hitCount"];
end

--procedure
function AnalyzeEffectState (state, m_dicNKMState, info)
    local speedXExists = false;

    --check speed for special case of distance based attacks. Threshold arbitrary
    if (state["m_listNKMEventSpeedX"] ~= nil and state["m_listNKMEventSpeedX"][1]["m_SpeedX"] > 500) then
        speedXExists = true;
    end

    --check loop count. This value is 1 if there is no loop, and if the loop isn't time bound.
    local loopCount = 1;
    if (state["m_bAnimLoop"] == true) then
        local animTime = CalculateAnimTime(FindAnimSpine(info["m_MainEffectName"]), state["m_AnimName"], state["m_fAnimSpeed"], state["m_listNKMEventAnimSpeed"]);
        if (state["m_StateTimeChangeStateTime"] ~= nil and animTime < state["m_StateTimeChangeStateTime"]) then
            loopCount = math.floor(state["m_StateTimeChangeStateTime"]/animTime);
        end
    end

    --analyze direct attacks
    if (state["m_listNKMEventAttack"] ~= nil) then
        local skip
        skip = AnalyzeConditions(state["m_listNKMEventAttack"], false);

        --exclude distance attacks from damage mod sum (Xiao, Minato)
        if (speedXExists) then
            local maxEventTimeMax = 0;
            --traverse backwards
            for i=#state["m_listNKMEventAttack"],1,-1 do
                if (skip[i] == nil and state["m_listNKMEventAttack"][i]["m_fEventTimeMax"] > maxEventTimeMax) then
                    maxEventTimeMax = state["m_listNKMEventAttack"][i]["m_fEventTimeMax"];
                elseif (skip[i] == nil) then
                    skip[i] = true;
                end
            end
        end

        for i, event in ipairs(state["m_listNKMEventAttack"]) do
            --m_fEventTime is to handle an edge case with VIOLET. Hopefully it's only on her.
            if (event["m_fEventTime"] ~= nil) then
                event["m_fEventTimeMin"] = event["m_fEventTime"];
            end
            --handles an edge case where an attack cannot be reached due to being after the state changes (cathy wade)
            if (event["m_fEventTimeMin"] < (state["m_StateTimeChangeStateTime"] or math.maxinteger)) then
                --only loop repeatedly if the attack follows animation time
                if (skip[i] ~= nil and event["m_bAnimTime"] ~= false) then
                    for _=1,loopCount do
                        AnalyzeAttackEvent(event, CloneTable(info));
                    end
                elseif (skip[i] ~= nil) then
                    AnalyzeAttackEvent(event, CloneTable(info));
                elseif (event["m_bAnimTime"] ~= false) then
                    for _=1,loopCount do
                        AnalyzeAttackEvent(event, info);
                    end
                else
                    AnalyzeAttackEvent(event, info);
                end
            end
        end
    end

    --analyze attacks through damage effects
    if (state["m_listNKMEventDamageEffect"] ~= nil) then
        local skip = AnalyzeConditions(state["m_listNKMEventDamageEffect"], false);
        for i, effect in ipairs(state["m_listNKMEventDamageEffect"]) do
            --handles an edge case where an attack cannot be reached due to being after the state changes
            if (effect["m_fEventTime"] or 0 < (state["m_StateTimeChangeStateTime"] or math.maxinteger)) then
                --only loop repeatedly if the attack follows animation time
                if (skip[i] ~= nil and effect["m_bAnimTime"] == true) then
                    for _=1,loopCount do
                        AnalyzeDamageEffect(effect, CloneTable(info));
                    end
                elseif (skip[i] ~= nil) then
                    AnalyzeDamageEffect(effect, CloneTable(info));
                elseif (effect["m_bAnimTime"] == true) then
                    for _=1,loopCount do
                        AnalyzeDamageEffect(effect, info);
                    end
                else
                    AnalyzeDamageEffect(effect, info);
                end
            end
        end
    end

    --multiple states
    local nextState = state["m_AnimEndChangeState"] or state["m_StateTimeChangeState"] or state["m_DamageCountChangeState"] or state["m_TargetDistNearChangeState"] or state["m_FootOnLandChangeState"];
    if (nextState ~= nil) then
        AnalyzeEffectState(FindState(m_dicNKMState, nextState), m_dicNKMState, info);
    end
end

--main block
dofile("Detail/LUA_UNIT_TEMPLET_BASE.lua");     --m_dicNKMUnitTempletBaseByStrID
dofile("Lang/LUA_STRING_ENG.lua");              --m_dicString
EngString = m_dicString;
dofile("Lang/LUA_SI_UNIT_KOREA.lua");           --m_dicString
KorString = m_dicString;
dofile("Detail/LUA_ANIM_DATA.lua")              --m_dicUnitAnim
dofile("Detail/LUA_UNIT_SKILL_TEMPLET.lua");    --m_UnitSkillTemplet

--open output files, and write in header
FileState = io.open("CharacterState.csv", "w");
WriteState(nil);
FileDamage = io.open("CharacterDamage.csv", "w");
WriteDamage(nil);

--debug output file
FileUnhandledCondition = io.open("DebugUnhandledConditionsCharacterStateToCSV.txt","w");

--track transformations
UnitTransformation = {};

for _,character in ipairs(m_dicNKMUnitTempletBaseByStrID) do
    -- not type system, ship related, type operator, style trainer, tutorial unit, monster, or NPC
    -- tutorial unit is found by matching for "tutorial" in the template file path, and "_TR$" and "_TR_" in unitStrID
    if character["m_NKM_UNIT_TYPE"] ~= "NUT_SYSTEM" and string.find(character["m_UnitStrID"],"NKM_SHIP") == nil and character["m_NKM_UNIT_TYPE"] ~= "NUT_OPERATOR" and character["m_NKM_UNIT_STYLE_TYPE"] ~= "NUST_TRAINER" and string.find(character["m_UnitTempletFileName"],"TUTORIAL") == nil and string.find(character["m_UnitStrID"],"_TR$") == nil and string.find(character["m_UnitStrID"],"_TR_") == nil and character["m_bMonster"] == false and string.find(character["m_UnitStrID"],"NKM_NPC") == nil and character["m_UnitTempletFileName"] ~= "NKM_UNIT_BASE_BOSS" then
    --if character["m_UnitStrID"] == "NKM_UNIT_GAMECIRCLE_C_VIOLET" then

        local info = {};
        --id, strid, title, and name
        info["m_UnitID"] = character["m_UnitID"]
        info["m_UnitStrID"] = character["m_UnitStrID"];
        info["cTitleEng"], info["cNameEng"] = FindString(EngString, character);
        info["cTitleKor"], info["cNameKor"] = FindString(KorString, character);

        --load unit
        local filePath = "Unit/" .. character["m_UnitTempletFileName"] .. ".lua";
        dofile(filePath);                       --NKMUnitTemplet
        local local_NKMUnitTemplet = NKMUnitTemplet;
        if local_NKMUnitTemplet["BASE_UNIT_STR_ID"] ~= nil then
            --load base file
            local temp = local_NKMUnitTemplet;
            filePath = "Unit/" .. local_NKMUnitTemplet["BASE_UNIT_STR_ID"] .. ".lua";
            dofile(filePath);
            local_NKMUnitTemplet = NKMUnitTemplet;
            --replace all relevant entries
            for key, value in pairs(temp) do
                local_NKMUnitTemplet[key] = value;
            end
        end

        --default casting range
        info["skillMaxRange"] = local_NKMUnitTemplet["m_TargetNearRange"];
        local targetingType = local_NKMUnitTemplet["m_NKM_FIND_TARGET_TYPE"] or character["m_NKM_FIND_TARGET_TYPE"];
        --default damage value
        info["atkModSum"] = 0;
        info["atkHPRateModSum"] = 0;
        info["atkMaxHPRateModSum"] = 0;
        info["atkPVPModSum"] = 0;
        info["atkHPRatePVPModSum"] = 0;
        --default hit count
        info["hitCount"] = 0;
        
        --empty table for condition history
        info["conditionHistory"] = {};

        --load animSpine
        local animSpine = FindAnimSpine(character["m_SpriteName"]);

        --store SkillStrIDs
        local table_m_SkillStrID = {};
        if (character["m_bContractable"] == true or UnitTransformation[character["m_UnitStrID"]] ~= nil) then
            local string_m_SkillStrID = "m_SkillStrID";
            local current_m_SkillStrID = string_m_SkillStrID .. 1;
            local counter = 1;
            while (character[current_m_SkillStrID] ~= nil) do
                table_m_SkillStrID[#table_m_SkillStrID+1] = character[current_m_SkillStrID];
                counter = counter + 1;
                current_m_SkillStrID = string_m_SkillStrID .. counter;
            end
        end
        info["table_m_SkillStrID"] = table_m_SkillStrID;

        --analyze states
        --[[
            m_AttackStateData
            m_listAttackStateData
            m_AirAttackStateData
            m_listAirAttackStateData

            m_SkillStateData
            m_listSkillStateData
            m_listAirSkillStateData

            m_HyperSkillStateData
            m_listHyperSkillStateData

            m_listAccumStateChangePack

            m_listPhaseChangeData
        ]]
        local stateInfo;
        --start
        stateInfo = CloneTable(info);
        stateInfo["targetingHistory"] = "-";
        AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], "USN_START"), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
        --attack
        stateInfo = CloneTable(info);
        if (local_NKMUnitTemplet["m_AttackStateData"] ~= nil) then
            local_NKMUnitTemplet["m_listAttackStateData"] = {local_NKMUnitTemplet["m_AttackStateData"]};
        end
        if (local_NKMUnitTemplet["m_listAttackStateData"] ~= nil) then
            local skip = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listAttackStateData"], "m_StateName", AnalyzeConditions(local_NKMUnitTemplet["m_listAttackStateData"], true));
            for index, value in ipairs(local_NKMUnitTemplet["m_listAttackStateData"]) do
                if (skip[index] == nil) then
                    if (value["m_fRangeMax"] ~= nil) then
                        stateInfo["skillMaxRange"] = value["m_fRangeMax"];
                    end
                    if (value["m_fRangeMin"] ~= nil) then
                        stateInfo["skillMinRange"] = value["m_fRangeMin"];
                    end
                    if (value["m_bNoTarget"] == true) then
                        stateInfo["m_bNoTarget"] = true;
                    end
                    stateInfo["targetingHistory"] = targetingType .. " TargetRange: " .. (stateInfo["skillMaxRange"] or "-");
                    if (value["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = value["m_Condition"] end
                    AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], value["m_StateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                end
            end
        end
        --attack air
        stateInfo = CloneTable(info);
        if (local_NKMUnitTemplet["m_AirAttackStateData"] ~= nil) then
            local_NKMUnitTemplet["m_listAirAttackStateData"] = {local_NKMUnitTemplet["m_AirAttackStateData"]};
        end
        if (local_NKMUnitTemplet["m_listAirAttackStateData"] ~= nil) then
            local skip = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listAirAttackStateData"], "m_StateName", AnalyzeConditions(local_NKMUnitTemplet["m_listAirAttackStateData"], true));
            for index, value in ipairs(local_NKMUnitTemplet["m_listAirAttackStateData"]) do
                if (skip[index] == nil) then
                    if (value["m_fRangeMax"] ~= nil) then
                        stateInfo["skillMaxRange"] = value["m_fRangeMax"];
                    end
                    if (value["m_fRangeMin"] ~= nil) then
                        stateInfo["skillMinRange"] = value["m_fRangeMin"];
                    end
                    if (value["m_bNoTarget"] == true) then
                        stateInfo["m_bNoTarget"] = true;
                    end
                    stateInfo["targetingHistory"] = targetingType .. " TargetRange: " .. (stateInfo["skillMaxRange"] or "-");
                    if (value["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = value["m_Condition"] end
                    AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], value["m_StateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                end
            end
        end
        --phasechange
        stateInfo = CloneTable(info);
        if (local_NKMUnitTemplet["m_listPhaseChangeData"] ~= nil) then
            local skip = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listPhaseChangeData"], "m_ChangeStateName", AnalyzeConditions(local_NKMUnitTemplet["m_listPhaseChangeData"], true));
            for index, value in ipairs(local_NKMUnitTemplet["m_listPhaseChangeData"]) do
                if (skip[index] == nil) then
                    if (value["m_fRangeMax"] ~= nil) then
                        stateInfo["skillMaxRange"] = value["m_fRangeMax"];
                    end
                    if (value["m_fRangeMin"] ~= nil) then
                        stateInfo["skillMinRange"] = value["m_fRangeMin"];
                    end
                    if (value["m_bNoTarget"] == true) then
                        stateInfo["m_bNoTarget"] = true;
                    end
                    stateInfo["targetingHistory"] = targetingType .. " TargetRange: " .. (stateInfo["skillMaxRange"] or "-");
                    if (value["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = value["m_Condition"] end
                    AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], value["m_ChangeStateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                end
            end
        end
        --stack triggered
        stateInfo = CloneTable(info);
        if (local_NKMUnitTemplet["m_listAccumStateChangePack"] ~= nil) then
            local skip = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listAccumStateChangePack"], "m_TargetStateName", AnalyzeConditions(local_NKMUnitTemplet["m_listAccumStateChangePack"], true));
            local skip2 = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listAccumStateChangePack"], "m_AirTargetStateName", AnalyzeConditions(local_NKMUnitTemplet["m_listAccumStateChangePack"], true));
            for index, value in ipairs(local_NKMUnitTemplet["m_listAccumStateChangePack"]) do
                if (skip[index] == nil and skip2[index] == nil) then
                    --in case of multiple entries in m_listAccumStateChange
                    for _, innerValue in ipairs(value["m_listAccumStateChange"]) do
                        if (innerValue["m_fRangeMax"] ~= nil) then
                            stateInfo["skillMaxRange"] = innerValue["m_fRangeMax"];
                        end
                        if (innerValue["m_fRangeMin"] ~= nil) then
                            stateInfo["skillMinRange"] = innerValue["m_fRangeMin"];
                        end
                        if (value["m_bNoTarget"] == true) then
                            stateInfo["m_bNoTarget"] = true;
                        end
                        stateInfo["targetingHistory"] = targetingType .. " TargetRange: " .. (stateInfo["skillMaxRange"] or "-");
                        if (innerValue["m_TargetStateName"] ~= nil) then
                            if (innerValue["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = innerValue["m_Condition"] end
                            AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], innerValue["m_TargetStateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                        end
                        if (innerValue["m_AirTargetStateName"] ~= nil) then
                            if (innerValue["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = innerValue["m_Condition"] end
                            AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], innerValue["m_AirTargetStateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                        end
                    end
                end
            end
        end
        --skill
        stateInfo = CloneTable(info);
        if (local_NKMUnitTemplet["m_SkillStateData"] ~= nil) then
            local_NKMUnitTemplet["m_listSkillStateData"] = {local_NKMUnitTemplet["m_SkillStateData"]};
        end
        if (local_NKMUnitTemplet["m_listSkillStateData"] ~= nil) then
            local skip = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listSkillStateData"], "m_StateName", AnalyzeConditions(local_NKMUnitTemplet["m_listSkillStateData"], true));
            for index, value in ipairs(local_NKMUnitTemplet["m_listSkillStateData"]) do
                if (skip[index] == nil) then
                    if (value["m_fRangeMax"] ~= nil) then
                        stateInfo["skillMaxRange"] = value["m_fRangeMax"];
                    end
                    if (value["m_fRangeMin"] ~= nil) then
                        stateInfo["skillMinRange"] = value["m_fRangeMin"];
                    end
                    if (value["m_bNoTarget"] == true) then
                        stateInfo["m_bNoTarget"] = true;
                    end
                    stateInfo["targetingHistory"] = targetingType .. " TargetRange: " .. (stateInfo["skillMaxRange"] or "-");
                    if (value["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = value["m_Condition"] end
                    AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], value["m_StateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                end
            end
        end
        --skill air
        stateInfo = CloneTable(info);
        if (local_NKMUnitTemplet["m_AirSkillStateData"] ~= nil) then
            local_NKMUnitTemplet["m_listAirSkillStateData"] = {local_NKMUnitTemplet["m_AirSkillStateData"]};
        end
        if (local_NKMUnitTemplet["m_listAirSkillStateData"] ~= nil) then
            local skip = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listAirSkillStateData"], "m_StateName", AnalyzeConditions(local_NKMUnitTemplet["m_listAirSkillStateData"], true));
            for index, value in ipairs(local_NKMUnitTemplet["m_listAirSkillStateData"]) do
                if (skip[index] == nil) then
                    if (value["m_fRangeMax"] ~= nil) then
                        stateInfo["skillMaxRange"] = value["m_fRangeMax"];
                    end
                    if (value["m_fRangeMin"] ~= nil) then
                        stateInfo["skillMinRange"] = value["m_fRangeMin"];
                    end
                    if (value["m_bNoTarget"] == true) then
                        stateInfo["m_bNoTarget"] = true;
                    end
                    stateInfo["targetingHistory"] = targetingType .. " TargetRange: " .. (stateInfo["skillMaxRange"] or "-");
                    if (value["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = value["m_Condition"] end
                    AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], value["m_StateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                end
            end
        end
        --hyper
        stateInfo = CloneTable(info);
        if (local_NKMUnitTemplet["m_HyperSkillStateData"] ~= nil) then
            local_NKMUnitTemplet["m_listHyperSkillStateData"] = {local_NKMUnitTemplet["m_HyperSkillStateData"]};
        end
        if (local_NKMUnitTemplet["m_listHyperSkillStateData"] ~= nil) then
            local skip = AnalyzeDuplicateStates(local_NKMUnitTemplet["m_listHyperSkillStateData"], "m_StateName", AnalyzeConditions(local_NKMUnitTemplet["m_listHyperSkillStateData"], true));
            for index, value in ipairs(local_NKMUnitTemplet["m_listHyperSkillStateData"]) do
                if (skip[index] == nil) then
                    if (value["m_fRangeMax"] ~= nil) then
                        stateInfo["skillMaxRange"] = value["m_fRangeMax"];
                    end
                    if (value["m_fRangeMin"] ~= nil) then
                        stateInfo["skillMinRange"] = value["m_fRangeMin"];
                    end
                    if (value["m_bNoTarget"] == true) then
                        stateInfo["m_bNoTarget"] = true;
                    end
                    stateInfo["targetingHistory"] = targetingType .. " TargetRange: " .. (stateInfo["skillMaxRange"] or "-");
                    if (value["m_Condition"] ~= nil) then stateInfo["conditionHistory"][#stateInfo["conditionHistory"]+1] = value["m_Condition"] end
                    AnalyzeUnitState(FindState(local_NKMUnitTemplet["m_dicNKMUnitState"], value["m_StateName"]), stateInfo, animSpine, local_NKMUnitTemplet["m_dicNKMUnitState"], true);
                end
            end
        end
    end
end

io.close(FileState);
io.close(FileDamage);
io.close(FileUnhandledCondition);