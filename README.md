# Counterside Analysis Tools

A collection of tools for synthesizing information from Counterside's game data. Note that while the files don't need to be serialized, the file names must be decrypted. [This project handles that part.](https://github.com/davxwang/CS-CaesarCipher-Serialize)

## CharacterToCSV.lua

Finds employee level information, such as Size, Speed, Sight. 

Run by executing the script while in the same directory as the Unit, Lang, and Detail folders from the sheet output of the other project.

[Example of processed output](https://docs.google.com/spreadsheets/d/1rE6CUhnkY3DfDGAIWLNpCZK2eVD0T1wwIJjCLiAZUKs/), and [another variant](https://docs.google.com/spreadsheets/d/1wNUpetToPutdbLZas0Da2dDkJEJtdAOEmuPMtATK74g/).

## CharacterStateToCSV.lua

Finds employee attack information. This outputs two .csv files. One summarizes the information, and the other offers more insight into each attack at the cost of readability.

Run by executing the script while in the same directory as the Unit, Lang, and Detail folders from the sheet output of the other project.

[Example of processed output](https://docs.google.com/spreadsheets/d/11aYjHUd9XtxVtKtJjGAQqYs-Ikk0Omdw77-NrdqBm8g/), and [its detailed companion sheet](https://docs.google.com/spreadsheets/d/1clPe7zu_IHaPxHr5K8sLvnKB9d8ZD-gDw_0gBx9Zpog/).

## GuildCCBArena.lua

Finds and describes the consortium coop arena artifact loot tracks, and the artifacts themselves. Note that the output is two different files.

Run by executing the script while in the same directory as a folder called "Guild" and "Lang", each holding the following files:
* Guild: LUA_BATTLE_CONDITION_TEMPLET.lua, LUA_BUFF_TEMPLET.lua, LUA_BUFF_TEMPLET2.lua, LUA_BUFF_TEMPLET3.lua, LUA_GUILD_DUNGEON_ARTIFACT_TEMPLET.lua, LUA_GUILD_DUNGEON_INFO_TEMPLET.lua, LUA_GUILD_DUNGEON_SCHEDULE_TEMPLET.lua, LUA_GUILD_RAID_TEMPLET.lua, LUA_GUILD_SEASON_TEMPLET.lua
* Lang: LUA_SI_UNIT_KOREA.lua, LUA_STRING_ENG.lua

[Example of a sheet powered by the output of this.](https://docs.google.com/spreadsheets/d/1HWFB8izzDA0m_no9aGQMfksIrjDFBDhSJTwK3E6fLv8/) Note that editting rights are needed for the dynamic component to be noticeable (make a copy), and that the two output sheets are hidden. 
