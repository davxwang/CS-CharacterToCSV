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

--returns a table of tables from a lua file
function LoadTableFromFile (filePath)
    --set up environment for file loading
    local mt = {__newindex = {}};
    local newENV = {};
    setmetatable(newENV, mt);
    --load file. Table goes in mt["__newindex"]
    local file = loadfile(filePath,"bt",newENV);
    file();

    return mt["__newindex"];
end

--procedure
function WriteArena (arenaInfo)
    io.output(FileArena);
    if (arenaInfo == nil) then
        --header
        io.write("arena",",","level");
        for i=1,12 do
            io.write(",","artifact_" .. i)
        end
        io.write("\n")
    else
        --contents
        io.write(arenaInfo["arena"],",",arenaInfo["level"]);

        for i=1,12 do
            io.write(",",FindString(EngString, arenaInfo['table_artifactNames'][i]));
        end

        io.write("\n");
    end
end

--procedure
function WriteArtifact (artifactInfo)
    io.output(FileArtifact);
    if (artifactInfo == nil) then
        --header
        io.write("name",",","description",",","effectCategory",",","effectType",",","effectValue","\n");
    else
        --content
        io.write(FindString(EngString, artifactInfo["name"]),",",FindString(EngString, artifactInfo["description"]),",",artifactInfo["effectCategory"]);
        local effectTypeEng = FindString(EngString,"SI_STAT_SHORT_NAME_" .. artifactInfo["effectType"]);
        if (effectTypeEng ~= nil) then
            io.write(",",effectTypeEng);
        else
            io.write(",",artifactInfo["effectType"]);
        end
        io.write(",",artifactInfo["effectValue"]);

        io.write("\n");
    end
end

--returns the string given the language table and the key
function FindString (langTable, stringKey)
    for _,value in ipairs(langTable) do
        if value[1] == stringKey then
            return value[2];
        end
    end
    return nil;
end

--returns the first matching entry given the table and key. 
function FindSubtable (table_subtable, string_keyName, string_keyValue)
    for _, value in ipairs(table_subtable) do
        if (value[string_keyName] == string_keyValue) then
            return value;
        end
    end
    return nil;
end

--main block
EngString = LoadTableFromFile("Lang/LUA_STRING_ENG.lua")['m_dicString'];
KorString = LoadTableFromFile("Lang/LUA_SI_UNIT_KOREA.lua")['m_dicString'];
ArenaTemplet = LoadTableFromFile("Guild/LUA_GUILD_DUNGEON_INFO_TEMPLET.lua")['GUILD_DUNGEON_INFO_TEMPLET'];
ArtifactTemplet = LoadTableFromFile("Guild/LUA_GUILD_DUNGEON_ARTIFACT_TEMPLET.lua")['GUILD_DUNGEON_ARTIFACT_TEMPLET'];
BattlefieldEffectTemplet = LoadTableFromFile("Guild/LUA_BATTLE_CONDITION_TEMPLET.lua")['m_dicNKMBcondTemplet'];
BuffTemplet = {};
for i=1,3 do
    if (i == 1) then
        BuffTemplet = LoadTableFromFile("Guild/LUA_BUFF_TEMPLET.lua")['m_dicNKMBuffTemplet'];
    else
        local buffTempletBuffer = LoadTableFromFile("Guild/LUA_BUFF_TEMPLET" .. i .. ".lua")['m_dicNKMBuffTemplet'];
        table.move(buffTempletBuffer, 1, #buffTempletBuffer, #BuffTemplet, BuffTemplet);
    end
end

--open output files, and write in header
FileArena = io.open("GuildArena.csv", "w");
WriteArena(nil);
FileArtifact = io.open("GuildArtifact.csv", "w");
WriteArtifact(nil);

--iterate through arenas
local table_usedArtifacts = {};
for _, arena in ipairs(ArenaTemplet) do
    --all seasons are the same
    if (arena['listContentsTagAllow'][1] == 'GUILD_DUNGEON_SEASON_V2_1') then
        local arenaInfo = {};
        arenaInfo['arena'] = arena['m_StageArenaIndex'];

        --map level index to level
        local table_mapArenaLevelIndex = {50, 80, 100, 120};
        arenaInfo['level'] = table_mapArenaLevelIndex[arena['m_StageLevelIndex']];

        --retrieve artifacts
        local table_artifactNames = {}
        for _, artifact in ipairs(ArtifactTemplet) do
            if (artifact['m_StageRewardArtifactGroup'] == arena['m_StageRewardArtifactGroup']) then
                table_artifactNames[artifact['m_ArtifactOrder']] = artifact['m_ArtifactName'];
                table_usedArtifacts[artifact['m_ArtifactName']] = artifact;
            end
        end

        arenaInfo['table_artifactNames'] = table_artifactNames;

        WriteArena(arenaInfo);
    end
end

--iterate through artifacts that are used
for _, artifact in pairs(table_usedArtifacts) do
    local artifactInfo = {};

    local battlefieldEffect = FindSubtable(BattlefieldEffectTemplet, 'm_BCondID', artifact['m_RefBattleConditionID']);

    --guild coop artifacts only have one effect, do not add flat stats, and do not affect the enemy.
    --deployment generation increase
    if (battlefieldEffect['m_BoostResource'] ~= nil) then
        artifactInfo['effectCategory'] = 'resouce';
        artifactInfo['effectType'] = 'Deployment Resource';
        artifactInfo['effectValue'] = battlefieldEffect['m_BoostResource']*(10/3);
    --buff
    elseif (battlefieldEffect['m_bAffectCOUNTER'] or battlefieldEffect['m_bAffectMECHANIC'] or battlefieldEffect['m_bAffectSOLDIER']) then
        --buff effects
        local buff = FindSubtable(BuffTemplet, 'm_BuffStrID', battlefieldEffect['m_listAllyBuffStrID'][1]);
        artifactInfo['effectType'] = buff['m_StatType1'];
        --remove trailing zeros, then convert to percentage format
        artifactInfo['effectValue'] = ((buff['m_StatFactor1'] or buff['m_StatValue1'])/100)/100;

        --buff affects
        if (battlefieldEffect['m_bAffectCOUNTER'] and battlefieldEffect['m_bAffectMECHANIC'] and battlefieldEffect['m_bAffectSOLDIER']) then
            artifactInfo['effectCategory'] = 'all'
        elseif battlefieldEffect['m_bAffectCOUNTER'] then
            artifactInfo['effectCategory'] = 'counter';
        elseif battlefieldEffect['m_bAffectMECHANIC'] then
            artifactInfo['effectCategory'] = 'mechanic';
        elseif battlefieldEffect['m_bAffectSOLDIER'] then
            artifactInfo['effectCategory'] = 'soldier';
        end
    end

    artifactInfo['name'] = artifact['m_ArtifactName'];
    artifactInfo['icon'] = artifact['m_ArtifactMiscIconName'];
    artifactInfo['description'] = artifact['m_ArtifactMiscDesc_1'];
    artifactInfo['descriptionShort'] = artifact['m_ArtifactMiscDesc_2'];

    WriteArtifact(artifactInfo);
end

--probing
local table_artifactRepeats = {};
setmetatable(table_artifactRepeats, {__index = function () return 0 end});
local table_battlefieldConditionRepeat = {};
setmetatable(table_battlefieldConditionRepeat, {__index = function () return 0 end});
local table_buffKey = {};
setmetatable(table_buffKey, {__index = function () return 0 end});
local table_buff = {};
for _, value in ipairs(ArtifactTemplet) do
    local battlefieldCondition = FindSubtable(BattlefieldEffectTemplet, 'm_BCondID', value['m_RefBattleConditionID']);

    if (battlefieldCondition['m_listAllyBuffStrID'] ~= nil) then
        if (battlefieldCondition['m_listAllyBuffStrID'][2] ~= nil) then
            print('check: ' .. battlefieldCondition['m_BCondID']);
        end

        local buff = FindSubtable(BuffTemplet, 'm_BuffStrID', battlefieldCondition['m_listAllyBuffStrID'][1]);

        for buffKey, _ in pairs(buff) do
            table_buffKey[buffKey] = table_buffKey[buffKey] + 1;
        end

        table_buff[#table_buff+1] = buff;
    end
end

--close output files
io.close(FileArena);
io.close(FileArtifact);