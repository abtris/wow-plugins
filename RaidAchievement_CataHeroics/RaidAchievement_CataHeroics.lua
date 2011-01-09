function chraonload()

chralocalem()
if GetLocale()=="deDE" or GetLocale()=="ruRU" or GetLocale()=="zhTW" or GetLocale()=="frFR" or GetLocale()=="koKR" or GetLocale()=="esES" or GetLocale()=="esMX" then
chralocale()
end


	chraachdone1=true
	chracounter1=0
	_, chraenglishclass = UnitClass("player")
	chrahuntertime=0

local _, a2 = GetInstanceInfo()
if GetInstanceDifficulty()==2 and a2=="party" then
	RaidAchievement_chra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	RaidAchievement_chra:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	RaidAchievement_chra:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	RaidAchievement_chra:RegisterEvent("PLAYER_ALIVE")
end
	RaidAchievement_chra:RegisterEvent("PLAYER_REGEN_DISABLED")
	RaidAchievement_chra:RegisterEvent("PLAYER_REGEN_ENABLED")
	RaidAchievement_chra:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	RaidAchievement_chra:RegisterEvent("ADDON_LOADED")




chraspisokach5={
5366,
5367,
5368,
5369,
5370,
5371,

5503,
5504,

5285,--9
--проп

5281,
5282,
5283,
5284,
--проп

5288,--Vortex Pinnacle
--проп


5297,
--5298, --no for Don't Need to Break Eggs to Make an Omelet

--hallsof origi
5293,
5296, --мб убрать нада будет?!
5295,


--5290,
5292,
--2 пропуска

--27 итог
}



if (chraspisokon==nil) then
chraspisokon={}
end


end


function chraonupdate()

if rachtimerhoo and GetTime()>rachtimerhoo then
rachtimerhoo=nil
SetMapToCurrentZone()
if GetCurrentMapAreaID()==759 then
if chraspisokon[17]==1 and chraachdone1 then
chrafailnoreason(17)
end
end
end

if rachtimervanessa and GetTime()>rachtimervanessa then
rachtimervanessa=nil
if GetCurrentMapAreaID()==756 then
if chraspisokon[6]==1 and chraachdone1 then
chrafailnoreason(6)
end
end
end

if chratimerstart and GetTime()>chratimerstart+15 then
chratimerstart=nil
if GetCurrentMapAreaID()==759 then
chrafailnoreason(16) --ыытест проверить ИД совпадает ли в конце
end
end


if chracheckzonedelay and GetTime()>chracheckzonedelay then
chracheckzonedelay=nil

local _, a2 = GetInstanceInfo()
if GetInstanceDifficulty()==2 and a2=="party" then
	RaidAchievement_chra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	RaidAchievement_chra:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	RaidAchievement_chra:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	RaidAchievement_chra:RegisterEvent("PLAYER_ALIVE")
else
	RaidAchievement_chra:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	RaidAchievement_chra:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
	RaidAchievement_chra:UnregisterEvent("CHAT_MSG_MONSTER_SAY")
	RaidAchievement_chra:UnregisterEvent("PLAYER_ALIVE")
end

end


end


function chraonevent(self,event,...)
local arg1, arg2, arg3,arg4,arg5,arg6 = ...

if event == "PLAYER_ALIVE" then
ralldelaycombatrezet=GetTime()+4
end


if event == "PLAYER_REGEN_DISABLED" then
if ralldelaycombatrezet==nil or (ralldelaycombatrezet and GetTime()>ralldelaycombatrezet) then

--ханты 3.5 сек проверка
if chraenglishclass=="HUNTER" and GetTime()>chrahuntertime then

--ТОЛЬКО ДЛЯ ХАНТОВ

chraachdone1=true
chracounter1=0
chratableid=nil

if UnitGUID("boss1") then
	local id=tonumber(string.sub(UnitGUID("boss1"),-12,-9),16)

	if id==49541 or id==49429 then
		rachtimervanessa=nil
	end
end

elseif chraenglishclass=="HUNTER" then else

--ТУТ ОБНУЛЯТЬ ВСЕ

chraachdone1=true
chracounter1=0
chratableid=nil

if UnitGUID("boss1") then
	local id=tonumber(string.sub(UnitGUID("boss1"),-12,-9),16)

	if id==49541 then
		rachtimervanessa=nil
	end
end


end --хантер


end
end

if event == "PLAYER_REGEN_ENABLED" then

	chrahuntertime=GetTime()+3.5

end

if event == "ZONE_CHANGED_NEW_AREA" then

chracheckzonedelay=GetTime()+2
chratableid=nil

end


if event == "ADDON_LOADED" then
	if arg1=="RaidAchievement_CataHeroics" then

for i=1,#chraspisokach5 do
if chraspisokon[i]==nil then chraspisokon[i]=1 end
end
	end
end


if event == "CHAT_MSG_MONSTER_YELL" or event=="CHAT_MSG_MONSTER_SAY" then

if arg1==chhrbrannyell and GetCurrentMapAreaID()==759 then
if chraspisokon[17]==1 and chraachdone1 then
rachtimerhoo=GetTime()+298
end
end

end


if event == "COMBAT_LOG_EVENT_UNFILTERED" then
local arg1, arg2, arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20 = ...


--проверка на возможный выход с боя
if arg4==UnitName("player") and arg2=="SPELL_AURA_REMOVED" and (arg9==58984 or arg9==66 or arg9==26888 or arg9==11327 or arg9==11329) then
ralldelaycombatrezet=GetTime()+4
end




--achieves:

--dead mines
if GetCurrentMapAreaID()==756 then
if (arg2=="SPELL_DAMAGE" or (arg2=="SPELL_MISSED" and arg12 and (arg12=="ABSORB" or arg12=="RESIST"))) and arg9==91397 then
if chraspisokon[1]==1 and chraachdone1 then
local _, _, _, chramyach = GetAchievementInfo(5366)
if arg7==UnitName("player") then
if (chramyach) then else
chramyfail(1)
end
end
end
end



if chraspisokon[2]==1 and chraachdone1 then
if arg2=="UNIT_DIED" and arg6 then
local id=tonumber(string.sub(arg6,-12,-9),16)
if id==51462 then
chracounter1=chracounter1+1
if chracounter1==20 then
chraachcompl(2)
end
end
end
end


if chraspisokon[3]==1 and chraachdone1 then
	if (arg2=="SPELL_MISSED" or arg2=="SPELL_DAMAGE" or arg2=="SPELL_PERIODIC_DAMAGE" or arg2=="SWING_DAMAGE") and arg6 then
		local id=tonumber(string.sub(arg6,-12,-9),16)
		local id2=1
if UnitGUID("boss1") then
		id2=tonumber(string.sub(UnitGUID("boss1"),-12,-9),16)
end

		if id==49208 and UnitGUID("boss1") and id2==43778 then
		if UnitGUID("boss1") then
		local bossid=tonumber(string.sub(UnitGUID("boss1"),-12,-9),16)
		if bossid==43778 then
			local percent=100
			if UnitGUID("pet") then
				local iiid=tonumber(string.sub(UnitGUID("pet"),-12,-9),16)
				if iiid==49208 then
					percent=UnitHealth("pet")*100/UnitHealthMax("pet")
				end
			end
			for op=1,4 do
				if UnitGUID("partypet"..op) then
					local iiid=tonumber(string.sub(UnitGUID("partypet"..op),-12,-9),16)
					if iiid==49208 then
						percent=UnitHealth("partypet"..op)*100/UnitHealthMax("partypet"..op)
					end
				end
			end
			if percent<90 then
				chrafailnoreason(3)
			end
		end
		end
		end
	end
end

if chraspisokon[4]==1 and chraachdone1 then
	if (arg2=="SPELL_CAST_SUCCESS" or arg2=="SPELL_CAST_START") and arg9==92042 then
		if chratableid==nil then
			chratableid={}
			table.insert(chratableid,arg3)
		else
			local bil=0
			for i=1,#chratableid do
				if chratableid[i]==arg3 then
					bil=1
				end
			end
			if bil==0 then
				table.insert(chratableid,arg3)
			end
			if #chratableid==3 then
				chraachcompl(4)
			end
		end
	end
end

if arg2=="SPELL_AURA_APPLIED_DOSE" and arg7==UnitName("player") and arg9==92066 and arg13 and arg13>1 then
	if chraspisokon[5]==1 and chraachdone1 then
local _, _, _, whramyach = GetAchievementInfo(chraspisokach5[5])
if (whramyach) then else
		chramyfail(5)
end
	end
end



if arg2=="SPELL_CAST_SUCCESS" and arg9==92100 then
	if chraspisokon[6]==1 and chraachdone1 then
		rachtimervanessa=GetTime()+300
	end
end

end



--Shadowfang Keep
if GetCurrentMapAreaID()==764 then

if arg2=="SPELL_CAST_SUCCESS" and arg9==93710 then
ralldelaycombatrezet=GetTime()+15
end

if arg2=="SPELL_HEAL" and arg9==93706 then
	if chraspisokon[7]==1 and chraachdone1 then
		local id=tonumber(string.sub(arg6,-12,-9),16)
		if id==46962 then
			chrafailnoreason(7)
		end
	end
end

if arg2=="SPELL_HEAL" and arg9==93844 then
	if chraspisokon[8]==1 and chraachdone1 then
		local id=tonumber(string.sub(arg6,-12,-9),16)
		if id==4278 then
			chrafailnoreason(8)
		end
	end
end


end

--


if arg2=="SPELL_DAMAGE" and arg9==91469 and arg13 and arg13>0 then
	if chraspisokon[9]==1 and chraachdone1 then
		local id=tonumber(string.sub(arg6,-12,-9),16)
		if id==40633 or id==44404 then
			chraachcompl(9)
		end
	end
end


--blackrock
if GetCurrentMapAreaID()==753 then

if arg2=="SPELL_DAMAGE" and arg9==93454 then
	if chraspisokon[10]==1 and chraachdone1 then
		local id=tonumber(string.sub(arg6,-12,-9),16)
		if id==50376 then
			chracounter1=chracounter1+1
			if chracounter1==10 then
				chraachcompl(10)
			end
		end
	end
end

if arg2=="UNIT_DIED" then
	if chraspisokon[11]==1 and chraachdone1 then
		local id=tonumber(string.sub(arg6,-12,-9),16)
		if id==50284 then
			chracounter1=chracounter1+1
			if chracounter1==3 then
				chraachcompl(11)
			end
		end
	end
end

if arg2=="SPELL_AURA_APPLIED_DOSE" and arg9==93567 and arg13 and arg13>14 then
	if chraspisokon[12]==1 and chraachdone1 then
		--local id=tonumber(string.sub(arg6,-12,-9),16)
		--if id==39698 then
			chraachcompl(12)
		--end
	end
end

if arg2=="SPELL_AURA_APPLIED_DOSE" and arg9==76189 and arg13 and arg13>3 then
if chraspisokon[13]==1 and chraachdone1 then
--raunitisplayer(arg6,arg7)
--if raunitplayertrue then
chrafailnoreason(13, arg7)
--end
end
end



end



if arg2=="SPELL_AURA_APPLIED" and arg9==87618 and arg7==UnitName("player") then
	if chraspisokon[14]==1 and chraachdone1 then
local _, _, _, whramyach = GetAchievementInfo(chraspisokach5[14])
if (whramyach) then else
		chramyfail(14)
end
	end
end


--grim batol
if GetCurrentMapAreaID()==757 then

if arg2=="SPELL_AURA_APPLIED" and arg9==90170 then
	if chraspisokon[15]==1 and chraachdone1 then
		local id=tonumber(string.sub(arg6,-12,-9),16)
		if id==39625 then
			chramyfailgood(15,2)
		end
	end
end

--there is something strange in combatlog!
--ыытест
--if arg2=="SPELL_CAST_SUCCESS" or arg2=="SPELL_CAST_START" and arg9==91049 then
--	if chraspisokon[16]==1 and chraachdone1 then
--		if UnitGUID("boss1") then
--			local a2=tonumber(string.sub(UnitGUID("boss1"),-12,-9),16)
--			if a2==40484 then
--				chrafailnoreason(16)
--			end
--		end
--	end
--end


end
--

--halls of orig
if GetCurrentMapAreaID()==759 then
if arg2=="SPELL_AURA_APPLIED" and arg9==75322 then                 --ЫЫТЕСТ меняя тут ИД менять также и в онапдейт функции!
	if chraspisokon[16]==1 and chraachdone1 then
		chratimerstart=GetTime()
	end
end

if arg2=="SPELL_AURA_REMOVED" and arg9==75322 then
chratimerstart=nil
end

--Faster Than the Speed of Light
if arg2=="UNIT_DIED" then
	local id=tonumber(string.sub(arg6,-12,-9),16)
	if id==39788 then
		rachtimerhoo=nil
	end
end


if arg2=="SPELL_PERIODIC_ENERGIZE" and arg9==89879 then
	if chraspisokon[18]==1 and chraachdone1 then
		chracounter1=chracounter1+1
		if chracounter1>19 then            --ыытестили больше 18???
			chrafailnoreason(18)
		end
	end
end


end

--lost city
if GetCurrentMapAreaID()==747 then
--if arg2=="UNIT_DIED" then
--	local id=tonumber(string.sub(arg6,-12,-9),16)
--	if id==43934 then
--		if chraspisokon[19]==1 and chraachdone1 then
--			chracounter1=chracounter1+1
--			if chracounter1==3 then
--				if UnitGUID("boss1") then
--					chraachcompl(19)
--				end
--			end
--		end
--	end
--end

if arg2=="SPELL_AURA_APPLIED_DOSE" and (arg9==93959 or arg9==91871) and arg13==3 then

if chraspisokon[19]==1 and chraachdone1 then
local _, _, _, chramyach = GetAchievementInfo(5292)
if arg7==UnitName("player") then
if (chramyach) then else
chramyfailgood(19,1)
end
end
end

end


end
--



end
end --КОНЕЦ ОНЕВЕНТ

function chra_closeallpr()
chramain6:Hide()
end


function chra_button2()
PSFea_closeallpr()
chramain6:Show()
openmenureportchra()



if (chranespamit==nil) then

chraspislun= # chraspisokach5
chracbset={}
for i=1,chraspislun do

if i>14 then
l=280
j=i-14
else
l=0
j=i
end

if GetAchievementLink(chraspisokach5[i]) then

local _, chraName, _, completed, _, _, _, Description, _, chraImage = GetAchievementInfo(chraspisokach5[i])


--текст
local f = CreateFrame("Frame",nil,chramain6)
f:SetFrameStrata("DIALOG")
f:SetWidth(248)
f:SetHeight(24)
f:SetScript("OnEnter", function(self) Rawhershowtxt(self,Description) end )
f:SetScript("OnLeave", function(self) Rawhershowtxt2() end )
f:SetScript("OnMouseDown", function(self) if IsShiftKeyDown() then if ChatFrame1EditBox:GetText() and string.len(ChatFrame1EditBox:GetText())>0 then ChatFrame1EditBox:SetText(ChatFrame1EditBox:GetText().." "..GetAchievementLink(chraspisokach5[i])) else ChatFrame_OpenChat(GetAchievementLink(chraspisokach5[i])) end end end )

--картинка
local t = f:CreateTexture(nil,"OVERLAY")
t:SetTexture(chraImage)
t:SetWidth(24)
t:SetHeight(24)
t:SetPoint("TOPLEFT",0,0)

local t = f:CreateFontString()
t:SetFont(GameFontNormal:GetFont(), rafontsset[2])
t:SetWidth(248)
if completed then
t:SetText("|cff00ff00"..chraName.."|r")
else
t:SetText("|cffff0000"..chraName.."|r")
end
t:SetJustifyH("LEFT")
t:SetPoint("LEFT",27,0)


f:SetPoint("TOPLEFT",l+45,-14-j*30)
f:Show()

end

--чекбатон
local c = CreateFrame("CheckButton", nil, chramain6, "UICheckButtonTemplate")
c:SetWidth("25")
c:SetHeight("25")
c:SetPoint("TOPLEFT", l+20, -14-j*30)
c:SetScript("OnClick", function(self) chragalka(i) end )
table.insert(chracbset, c)

end --for i
chranespamit=1
end --nespam

chragalochki()



end --конец бутон2

function Rawhershowtxt(self,i)
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_TOP")
	GameTooltip:SetText(i)
end

function Rawhershowtxt2(i)
GameTooltip:Hide()
end


function chragalochki()
for i=1,#chraspisokach5 do
if chracbset[i] then
if(chraspisokon[i]==1)then chracbset[i]:SetChecked() else chracbset[i]:SetChecked(false) end
end
end
end

function chragalka(nomersmeni)
if chraspisokon[nomersmeni]==1 then chraspisokon[nomersmeni]=0 else chraspisokon[nomersmeni]=1 end
end

function chra_buttonchangeyn(yesno)
chraspislun= # chraspisokach5
for i=1,chraspislun do
chraspisokon[i]=yesno
end
chragalochki()
end

function chra_button1()
chraspislun= # chraspisokach5
for i=1,chraspislun do
if chraspisokon[i]==1 then chraspisokon[i]=0 else chraspisokon[i]=1 end
end
chragalochki()
end


function openmenureportchra()
if not DropDownMenureportchra then
CreateFrame("Frame", "DropDownMenureportchra", chramain6, "UIDropDownMenuTemplate")
end

DropDownMenureportchra:ClearAllPoints()
DropDownMenureportchra:SetPoint("BOTTOMLEFT", 5, 7)
DropDownMenureportchra:Show()

local items = lowmenuchatlistea

local function OnClick(self)
UIDropDownMenu_SetSelectedID(DropDownMenureportchra, self:GetID())

lowmenuchatea(self:GetID())
wherereportpartyach=wherereporttempbigma
end

local function initialize(self, level)
local info = UIDropDownMenu_CreateInfo()
for k,v in pairs(items) do
	info = UIDropDownMenu_CreateInfo()
	info.text = v
	info.value = v
	info.func = OnClick
	UIDropDownMenu_AddButton(info, level)
end
end

lowmenuchatea2(wherereportpartyach)
if bigma2num==0 then
bigma2num=1
wherereportpartyach="party"
end

UIDropDownMenu_Initialize(DropDownMenureportchra, initialize)
UIDropDownMenu_SetWidth(DropDownMenureportchra, 90);
UIDropDownMenu_SetButtonWidth(DropDownMenureportchra, 105)
UIDropDownMenu_SetSelectedID(DropDownMenureportchra,bigma2num)
UIDropDownMenu_JustifyText(DropDownMenureportchra, "LEFT")
end