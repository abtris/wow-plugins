function nxraonload()

nxralocaleuim()
nxralocalebossm()

if GetLocale()=="deDE" or GetLocale()=="ruRU" or GetLocale()=="zhTW" or GetLocale()=="frFR" or GetLocale()=="koKR" or GetLocale()=="esES" or GetLocale()=="esMX" then
nxralocaleui()
nxralocaleboss()
end



	nxramexna=0
	nxratimer1=0
	nxrabosskilled=0
	nxraonycast=GetSpellInfo(17086)

	RaidAchievement_nxra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	RaidAchievement_nxra:RegisterEvent("PLAYER_REGEN_DISABLED")
	RaidAchievement_nxra:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	RaidAchievement_nxra:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	RaidAchievement_nxra:RegisterEvent("ADDON_LOADED")




nxraspisokach25={
"1859",
"2140",
"2183",
"2179",
"2185",
"2048",
"4407"
}

nxraspisokach10={
"1858",
"1997",
"2182",
"2178",
"2184",
"2047",
"4404"
}


if (nxraspisokon==nil) then
nxraspisokon={}
end


end

--онапдейт
function nxra_OnUpdate()

if nxrafobiaend and GetTime()>nxrafobiaend then
nxramexna=0
if GetInstanceDifficulty()==1 or GetInstanceDifficulty()==3 then
raplaysound(3,nxraspisokach10[1])
end
if GetInstanceDifficulty()==2 or GetInstanceDifficulty()==4 then
raplaysound(3,nxraspisokach25[1])
end
pseareportfailnoreason()
nxrafobiaend=nil
end

if racnxnotinnax and GetTime()>racnxnotinnax+120 then
racnxnotinnax=nil
nxramexna=0
nxrafobiaend=nil
end

end




function nxraonevent(self,event,...)
local arg1, arg2, arg3,arg4,arg5,arg6 = ...


if event == "PLAYER_REGEN_DISABLED" then
if rabilresnut==1 then
else
--обнулять все данные при начале боя тут:


nxratimer1=0



end

end


if event == "ZONE_CHANGED_NEW_AREA" then

SetMapToCurrentZone()
if GetCurrentMapAreaID()==535 and nxramexna==1 then
racnxnotinnax=nil
elseif nxramexna==1 and racnxnotinnax==nil then
racnxnotinnax=GetTime()
end


nxrabosskilled=0

end

if event == "ADDON_LOADED" then
	if arg1=="RaidAchievement_Naxxramas" then
for i=1,#nxraspisokach25 do
if nxraspisokon[i]==nil or nxraspisokon[i]=="" then nxraspisokon[i]="yes" end
end
	end
end

if event == "CHAT_MSG_RAID_BOSS_EMOTE" then

if string.find(arg1, nxraonyemote)==nil then else
if arg2==nxraonyxiab then
ratime1=GetTime()

end end



end


if GetNumRaidMembers() > 0 and event == "COMBAT_LOG_EVENT_UNFILTERED" then
local arg1, arg2, arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20 = ...

--по 2 ачиву таймер
if nxratimer1>0 then
if arg1>nxratimer1+1.5 then
nxratimer1=0
nxrafailnoreason(2)
end end


if arg2=="SPELL_AURA_REMOVED" and arg9==54100 then
if nxraspisokon[2]=="yes" and raachdone1 then
raachdone1=nil
nxratimer1=arg1
end
end



if arg2=="UNIT_DIED" then

local id=tonumber(string.sub(arg6,-12,-9),16)

if id==16011 then
if nxraspisokon[3]=="yes" and raachdone1 then
raachdone1=nil
nxrabosskilled=1
end
end


if id==16286 then
if nxraspisokon[3]=="yes" and raachdone1 and nxrabosskilled==0 then
nxrafailnoreason(3)
end
end


if id==15956 then
if nxraspisokon[1]=="yes" then
nxrafobiaend=GetTime()+1200
nxramexna=1
end
end

if id==15952 then
nxramexna=0
end


if id==15953 then
if nxraspisokon[2]=="yes" then
nxratimer1=0
end
end


if id==23562 or id==16428 then
if nxraspisokon[5]=="yes" and raachdone1 then
ratime1=ratime1+1
if ratime1>17 then
nxraachcompl(5)
end
end
end

end



if (arg2=="SPELL_DAMAGE" or (arg2=="SPELL_MISSED" and arg12 and (arg12=="ABSORB" or arg12=="RESIST"))) and (arg9==28085 or arg==28059) then
if nxraspisokon[4]=="yes" and raachdone1 then
nxrafailnoreason(4)
end
end


if (arg2=="SPELL_DAMAGE" or (arg2=="SPELL_MISSED" and arg12 and (arg12=="ABSORB" or arg12=="RESIST"))) and arg9==57591 and UnitName("player")==arg7 and rabattlev==1 then
if nxraspisokon[6]=="yes" and raachdone1 then
--проверка на ачивку у себя!
if GetInstanceDifficulty()==1 or GetInstanceDifficulty()==3 then
_, _, _, nxrasarto = GetAchievementInfo(2047)
elseif GetInstanceDifficulty()==2 or GetInstanceDifficulty()==4 then
_, _, _, nxrasarto = GetAchievementInfo(2048)
end
if (nxrasarto) then else
nxramyfail(6)
end
end
end

if ((arg2=="SPELL_DAMAGE" or arg2=="SPELL_MISSED") and arg10==nxraonycast and GetTime()-ratime1<14) then
if nxraspisokon[7]=="yes" and raachdone1 then
raunitisplayer(arg6,arg7)
if raunitplayertrue then
nxrafailnoreason(7, arg7)
end
end
end





end
end --КОНЕЦ ОНЕВЕНТ

function nxra_closeallpr()
nxramain6:Hide()
end


function nxra_button2()
PSFea_closeallpr()
nxramain6:Show()
openmenureportnxra()



if (nxranespamit==nil) then

nxraspislun= # nxraspisokach25
nxracbset={}
for i=1,nxraspislun do
local _, nxraName, _, completed, _, _, _, Description, _, nxraImage = GetAchievementInfo(nxraspisokach25[i])
local _, _, _, completed2 = GetAchievementInfo(nxraspisokach10[i])

local nxrawheresk=string.find(nxraName, "25")
if nxrawheresk==nil then nxrawheresk=string.find(nxraName, "10") end
if nxrawheresk then
nxraName=string.sub(nxraName, 1, nxrawheresk-3)
end

if completed and completed2 then
nxraName="|cff00ff00"..nxraName.."|r"
elseif completed==false and completed2==false then
nxraName="|cffff0000"..nxraName.."|r"
else
	if completed2 then
		nxraName=nxraName.." |cff00ff00(10)|r"
	else
		nxraName=nxraName.." |cffff0000(10)|r"
	end
	if completed then
		nxraName=nxraName.." |cff00ff00(25)|r"
	else
		nxraName=nxraName.." |cffff0000(25)|r"
	end
end

if i>14 then
l=280
j=i-14
else
l=0
j=i
end


--текст
local f = CreateFrame("Frame",nil,nxramain6)
f:SetFrameStrata("DIALOG")
f:SetWidth(248)
f:SetHeight(24)
f:SetScript("OnEnter", function(self) Ranaxxshowtxt(self,Description) end )
f:SetScript("OnLeave", function(self) Ranaxxshowtxt2() end )
f:SetScript("OnMouseDown", function(self) if IsShiftKeyDown() then if ChatFrame1EditBox:GetText() and string.len(ChatFrame1EditBox:GetText())>0 then ChatFrame1EditBox:SetText(ChatFrame1EditBox:GetText().." "..GetAchievementLink(nxraspisokach10[i]).." "..GetAchievementLink(nxraspisokach25[i])) else ChatFrame_OpenChat(GetAchievementLink(nxraspisokach10[i]).." "..GetAchievementLink(nxraspisokach25[i])) end end end )

--картинка
local t = f:CreateTexture(nil,"OVERLAY")
t:SetTexture(nxraImage)
t:SetWidth(24)
t:SetHeight(24)
t:SetPoint("TOPLEFT",0,0)

local t = f:CreateFontString(Name)
t:SetFont(GameFontNormal:GetFont(), rafontsset[2])
t:SetWidth(248)
t:SetText(nxraName)
t:SetJustifyH("LEFT")
t:SetPoint("LEFT",27,0)

f:SetPoint("TOPLEFT",l+45,-14-j*30)
f:Show()

--чекбатон
local c = CreateFrame("CheckButton", nil, nxramain6, "UICheckButtonTemplate")
c:SetWidth("25")
c:SetHeight("25")
c:SetPoint("TOPLEFT", l+20, -14-j*30)
c:SetScript("OnClick", function(self) nxragalka(i) end )
table.insert(nxracbset, c)

end --for i
nxranespamit=1
end --nespam


nxragalochki()




end --конец бутон2
function Ranaxxshowtxt(self,i)
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_TOP")
	GameTooltip:SetText(i)
end

function Ranaxxshowtxt2(i)
GameTooltip:Hide()
end

function nxragalochki()
for i=1,7 do
if(nxraspisokon[i]=="yes")then nxracbset[i]:SetChecked() else nxracbset[i]:SetChecked(false) end
end
end

function nxragalka(nomersmeni)
if nxraspisokon[nomersmeni]=="yes" then nxraspisokon[nomersmeni]="no" else nxraspisokon[nomersmeni]="yes" end
end

function nxra_buttonchangeyn(yesno)
nxraspislun= # nxraspisokach25
for i=1,nxraspislun do
nxraspisokon[i]=yesno
end
nxragalochki()
end

function nxra_button1()
nxraspislun= # nxraspisokach25
for i=1,nxraspislun do
if nxraspisokon[i]=="yes" then nxraspisokon[i]="no" else nxraspisokon[i]="yes" end
end
nxragalochki()
end


function openmenureportnxra()
if not DropDownMenureportnxra then
CreateFrame("Frame", "DropDownMenureportnxra", nxramain6, "UIDropDownMenuTemplate")
end
rachatdropm(DropDownMenureportnxra,5,7)
end