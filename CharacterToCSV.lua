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


dofile("Detail/LUA_UNIT_TEMPLET_BASE.lua");     --m_dicNKMUnitTempletBaseByStrID
dofile("Detail/LUA_UNIT_STAT_TEMPLET.lua");     --m_dicNKMUnitStatByID
dofile("Lang/LUA_STRING_ENG.lua");              --m_dicString
EngString = m_dicString;
dofile("Lang/LUA_SI_UNIT_KOREA.lua");           --m_dicString
KorString = m_dicString;

FILE = io.open("CharacterData.csv", "w");
io.output(FILE);
io.write("m_UnitID,m_UnitStrID,m_Title English,m_Name English,m_Title Korean,m_Name Korean,m_NKM_UNIT_STYLE_TYPE,m_NKM_UNIT_STYLE_TYPE_SUB,m_NKM_UNIT_ROLE_TYPE,m_NKM_FIND_TARGET_TYPE,m_bAirUnit,HP,ATK,DEF,CRITICAL,HIT,EVADE,DAMAGE_LIMIT_RATE_BY_HP,ATTACK_COUNT_REDUCE,HP/LEVEL,ATK/LEVEL,DEF/LEVEL,CRITICAL/LEVEL,HIT/LEVEL,EVADE/LEVEL,m_UnitSizeX,m_SpeedRun,m_SeeRange,m_SeeRangeMax,m_TargetNearRange,m_fDamageUpFactor,m_fDamageBackFactor\n");

for i,character in ipairs(m_dicNKMUnitTempletBaseByStrID) do
    -- not type system, ship related, type operator, style trainer, tutorial unit, monster, or NPC
    -- tutorial unit is found by matching for "tutorial" in the template file path, and "_TR$" and "_TR_" in unitStrID
    if character["m_NKM_UNIT_TYPE"] ~= "NUT_SYSTEM" and string.find(character["m_UnitStrID"],"NKM_SHIP") == nil and character["m_NKM_UNIT_TYPE"] ~= "NUT_OPERATOR" and character["m_NKM_UNIT_STYLE_TYPE"] ~= "NUST_TRAINER" and string.find(character["m_UnitTempletFileName"],"TUTORIAL") == nil and string.find(character["m_UnitStrID"],"_TR$") == nil and string.find(character["m_UnitStrID"],"_TR_") == nil and character["m_bMonster"] == false and string.find(character["m_UnitStrID"],"NKM_NPC") == nil then
        --title and name
        local cTitleEng, cNameEng = FindString(EngString, character);
        local cTitleKor, cNameKor = FindString(KorString, character);

        --air from boolean to string
        local isAir;
        if character["m_bAirUnit"] then
            isAir = "true";
        else
            isAir = "false";
        end
        
        --subtype
        local cTypeSub;
        if character["m_NKM_UNIT_STYLE_TYPE_SUB"] ~= nil then
            cTypeSub = character["m_NKM_UNIT_STYLE_TYPE_SUB"];
        else
            cTypeSub = "-";
        end

        --stats
        local sHP,sATK,sDEF,sCRITICAL,sHIT,sEVADE,sDAMAGE_LIMIT_RATE_BY_HP,sATTACK_COUNT_REDUCE,sHPG,sATKG,sDEFG,sCRITICALG,sHITG,sEVADEG;
        if character["m_UnitStrID"] == m_dicNKMUnitStatByID[i]["m_UnitStrID"] then
            local stats = m_dicNKMUnitStatByID[i]["m_StatData"];
            sHP,sATK,sDEF,sCRITICAL,sHIT,sEVADE,sDAMAGE_LIMIT_RATE_BY_HP,sATTACK_COUNT_REDUCE = stats["m_Stat"]["NST_HP"], stats["m_Stat"]["NST_ATK"], stats["m_Stat"]["NST_DEF"], stats["m_Stat"]["NST_CRITICAL"], stats["m_Stat"]["NST_HIT"], stats["m_Stat"]["NST_EVADE"], stats["m_Stat"]["NST_DAMAGE_LIMIT_RATE_BY_HP"], stats["m_Stat"]["NST_ATTACK_COUNT_REDUCE"];
            sHPG,sATKG,sDEFG,sCRITICALG,sHITG,sEVADEG = stats["m_StatPerLevel"]["NST_HP"], stats["m_StatPerLevel"]["NST_ATK"], stats["m_StatPerLevel"]["NST_DEF"], stats["m_StatPerLevel"]["NST_CRITICAL"], stats["m_StatPerLevel"]["NST_HIT"], stats["m_StatPerLevel"]["NST_EVADE"];
        else
            sHP,sATK,sDEF,sCRITICAL,sHIT,sEVADE,sDAMAGE_LIMIT_RATE_BY_HP,sATTACK_COUNT_REDUCE,sHPG,sATKG,sDEFG,sCRITICALG,sHITG,sEVADEG = "?","?","?","?","?","?","?","?","?","?","?","?","?","?";
        end

        --unit info
        local moveSpeed,knockUpScale,knockBackScale;
        local filePath = "Unit/" .. character["m_UnitTempletFileName"] .. ".lua";
        dofile(filePath);                       --NKMUnitTemplet
        if NKMUnitTemplet["BASE_UNIT_STR_ID"] ~= nil then
            --load base file
            local temp = NKMUnitTemplet;
            filePath = "Unit/" .. NKMUnitTemplet["BASE_UNIT_STR_ID"] .. ".lua";
            dofile(filePath);
            --replace all relevant entries
            for key, value in pairs(temp) do
                NKMUnitTemplet[key] = value;
            end
        end

        --default values
        NKMUnitTemplet["m_UnitSizeX"] = NKMUnitTemplet["m_UnitSizeX"] or 0;
        NKMUnitTemplet["m_SpeedRun"] = NKMUnitTemplet["m_SpeedRun"] or 0;
        NKMUnitTemplet["m_SeeRange"] = NKMUnitTemplet["m_SeeRange"] or 0;
        NKMUnitTemplet["m_SeeRangeMax"] = NKMUnitTemplet["m_SeeRangeMax"] or 0;
        NKMUnitTemplet["m_TargetNearRange"] = NKMUnitTemplet["m_TargetNearRange"] or 0;
        NKMUnitTemplet["m_fDamageUpFactor"] = NKMUnitTemplet["m_fDamageUpFactor"] or 1;
        NKMUnitTemplet["m_fDamageBackFactor"] = NKMUnitTemplet["m_fDamageBackFactor"] or 1;

        --print(character["m_UnitID"],",",character["m_UnitStrID"],",",cTitleEng,",",cNameEng,",",cTitleKor,",",cNameKor,",",character["m_NKM_UNIT_STYLE_TYPE"],",",cTypeSub,",",character["m_NKM_UNIT_ROLE_TYPE"],",",character["m_NKM_FIND_TARGET_TYPE"],",",isAir,",",sHP,",",sATK,",",sDEF,",",sCRITICAL,",",sHIT,",",sEVADE,",",sDAMAGE_LIMIT_RATE_BY_HP,",",sATTACK_COUNT_REDUCE,",",sHPG,",",sATKG,",",sDEFG,",",sCRITICALG,",",sHITG,",",sEVADEG,",",NKMUnitTemplet["m_UnitSizeX"],",",moveSpeed,",",NKMUnitTemplet["m_SeeRange"],",",NKMUnitTemplet["m_SeeRangeMax"],",",NKMUnitTemplet["m_TargetNearRange"],",",knockUpScale,",",knockBackScale,",","\n");
        io.write(character["m_UnitID"],",",character["m_UnitStrID"],",",cTitleEng,",",cNameEng,",",cTitleKor,",",cNameKor,",",character["m_NKM_UNIT_STYLE_TYPE"],",",cTypeSub,",",character["m_NKM_UNIT_ROLE_TYPE"],",",character["m_NKM_FIND_TARGET_TYPE"],",",isAir,",",sHP,",",sATK,",",sDEF,",",sCRITICAL,",",sHIT,",",sEVADE,",",sDAMAGE_LIMIT_RATE_BY_HP,",",sATTACK_COUNT_REDUCE,",",sHPG,",",sATKG,",",sDEFG,",",sCRITICALG,",",sHITG,",",sEVADEG,",",NKMUnitTemplet["m_UnitSizeX"],",",NKMUnitTemplet["m_SpeedRun"],",",NKMUnitTemplet["m_SeeRange"],",",NKMUnitTemplet["m_SeeRangeMax"],",",NKMUnitTemplet["m_TargetNearRange"],",",NKMUnitTemplet["m_fDamageUpFactor"],",",NKMUnitTemplet["m_fDamageBackFactor"],",","\n");
    end
end

io.close(FILE);