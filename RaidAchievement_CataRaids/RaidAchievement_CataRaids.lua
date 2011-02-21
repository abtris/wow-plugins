function crraonload()

crralocalem()

if GetLocale()=="deDE" or GetLocale()=="ruRU" or GetLocale()=="zhTW" or GetLocale()=="frFR" or GetLocale()=="koKR" or GetLocale()=="esES" or GetLocale()=="esMX" then
crralocale()
end

SetMapToCurrentZone()
if GetCurrentMapAreaID()==754 or GetCurrentMapAreaID()==758 then
	RaidAchievement_crra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	RaidAchievement_crra:RegisterEvent("UNIT_POWER")
end
	RaidAchievement_crra:RegisterEvent("PLAYER_REGEN_DISABLED")
	RaidAchievement_crra:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	RaidAchievement_crra:RegisterEvent("ADDON_LOADED")



crraspisokach25={
5306,
5307,
5308,
5309,
--4849,--temp

--Emerald Whelp 8 штук предположим что смерть ласта нужна на ачивку..
--5300, --ыытестубрать??
--5311,--temp
5312,

}



if (crraspisokon==nil) then
crraspisokon={}
end


end


function crra_OnUpdate(crracurtime)

if racrtimerbossrecheck and crracurtime>racrtimerbossrecheck then
racrtimerbossrecheck=nil
	if UnitGUID("boss1") and UnitName("boss1")~="" then
		local id2=UnitGUID("boss1")
		local id=tonumber(string.sub(id2,-12,-9),16)
		if id==43296 then
			racrcheckdeadth43296=0
		end
		if id==41442 then
			racrzvukcheck=1
		end
	end
end

if rcradelayzonech and crracurtime>rcradelayzonech then
rcradelayzonech=nil
SetMapToCurrentZone()
if GetCurrentMapAreaID()==754 or GetCurrentMapAreaID()==758 then
RaidAchievement_crra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
RaidAchievement_crra:RegisterEvent("UNIT_POWER")
else
RaidAchievement_crra:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
RaidAchievement_crra:UnregisterEvent("UNIT_POWER")
end
end


end


function crraonevent(self,event,...)

local arg1, arg2, arg3,arg4,arg5,arg6 = ...



if event == "PLAYER_REGEN_DISABLED" then
if (rabilresnut and GetTime()<rabilresnut+3) or racheckbossincombat then
else
--обнулять все данные при начале боя тут:

racrcheckdeadth43296=nil
racrzvukcheck=nil
	if UnitGUID("boss1") and UnitName("boss1")~="" then
		local id2=UnitGUID("boss1")
		local id=tonumber(string.sub(id2,-12,-9),16)
		if id==43296 then
			racrcheckdeadth43296=0
		end
		if id==41442 then
			racrzvukcheck=1
		end
	else
		racrtimerbossrecheck=GetTime()+3
	end
end

end


if event == "ZONE_CHANGED_NEW_AREA" then

rcradelayzonech=GetTime()+2
racrcheckdeadth43296=nil

end

if event == "ADDON_LOADED" then
	if arg1=="RaidAchievement_CataRaids" then

for i=1,#crraspisokach25 do
if crraspisokon[i]==nil then crraspisokon[i]=1 end
end
	end
end


if event == "UNIT_POWER" then
if UnitName("boss1") and UnitName("boss1")~="" then
if racrzvukcheck then
SetMapToCurrentZone()
if GetCurrentMapAreaID()==754 then
if arg2=="ALTERNATE" and arg1 then
	local power = UnitPower(arg1, 10)
	if power>50 then
		local aa1=UnitName(arg1)
		local gugu=UnitGUID(arg1)
		raunitisplayer(gugu,aa1)
		if raunitplayertrue then
			if crraspisokon[3]==1 and raachdone1 then
				crrafailnoreason(3,aa1..", "..power.."%")
			end
		end
	end
end
end
end
end
end




if GetNumRaidMembers() > 0 and event == "COMBAT_LOG_EVENT_UNFILTERED" then
local arg1, arg2, arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20 = ...
--ТУТ АЧИВЫ


--Blackwing Descent
if GetCurrentMapAreaID()==754 then

if arg2=="SPELL_AURA_APPLIED" and (arg9==78941 or arg9==91913 or arg9==94678 or arg9==94679) then
	if crraspisokon[1]==1 and raachdone1 then
		crrafailnoreason(1,arg7)
	end
end

--2
if (arg2=="SPELL_DAMAGE" or arg2=="SPELL_MISSED") and (arg9==79912 or arg9==91458 or arg9==91457 or arg9==91456) then
	if crraspisokon[2]==1 and raachdone1 then
		crratronpartfail(arg6,arg7,1,crraraidpartachloc1)
	end
end

if (arg2=="SPELL_DAMAGE" or arg2=="SPELL_MISSED") and (arg9==80092 or arg9==91498 or arg9==91499 or arg9==91500) then
	if crraspisokon[2]==1 and raachdone2 then
		crratronpartfail(arg6,arg7,2,crraraidpartachloc2)
	end
end

if (arg2=="SPELL_DAMAGE" or arg2=="SPELL_MISSED") and (arg9==79710 or arg9==91540 or arg9==91541 or arg9==91542) then
	if crraspisokon[2]==1 and raachdone3 then
		crratronpartfail(arg6,arg7,3,crraraidpartachloc3)
	end
end

if arg2=="SPELL_AURA_APPLIED" and (arg9==79505 or arg9==91531 or arg9==91532 or arg9==91533) and raachdone4 and crraspisokon[2]==1 then
rallatrontemp1=GetTime()
rallatrontemp2=arg7
end

if rallatrontemp1 and (arg2=="SPELL_DAMAGE" or arg2=="SPELL_MISSED") and (arg9==79504 or arg9==91535 or arg9==91536 or arg9==91537) and GetTime()<rallatrontemp1+10 and rallatrontemp2 and arg7~=rallatrontemp2 then
	if crraspisokon[2]==1 and raachdone4 then
		crratronpartfail(arg6,arg7,4,crraraidpartachloc4)
	end
end

--4
if arg2=="UNIT_DIED" and racrcheckdeadth43296 and UnitGUID("boss1") and UnitName("boss1")~="" then
	if crraspisokon[4]==1 and raachdone1 then
		raunitisplayer(arg6,arg7)
		if raunitplayertrue and UnitIsFeignDeath(arg7)==nil and UnitIsDeadOrGhost(arg7) then
			racrcheckdeadth43296=racrcheckdeadth43296+1
			if racrcheckdeadth43296==3 then
				crrafailnoreason(4,arg7)
				racrcheckdeadth43296=nil
			end
		end
	end
end



end
--


--The Bastion of Twilight
if GetCurrentMapAreaID()==758 then
if arg2=="SPELL_AURA_APPLIED_DOSE" and arg9==93187 and arg13 and arg13>30 then
	if crraspisokon[5]==1 and raachdone1 then
		crrafailnoreason(5,arg7)
	end
end

end
--




end
end --КОНЕЦ ОНЕВЕНТ

function crra_closeallpr()
crramain6:Hide()
end


function crra_button2()
PSFea_closeallpr()
crramain6:Show()
openmenureportcrra()



if (crranespamit==nil) then

crraspislun= # crraspisokach25
crracbset={}

for i=1,crraspislun do

if i>14 then
l=280
j=i-14
else
l=0
j=i
end

if GetAchievementLink(crraspisokach25[i]) then

local _, crraName, _, completed, _, _, _, Description, _, crraImage = GetAchievementInfo(crraspisokach25[i])

if completed then
crraName="|cff00ff00"..crraName.."|r"
else
crraName="|cffff0000"..crraName.."|r"
end



--текст
local f = CreateFrame("Frame",nil,crramain6)
f:SetFrameStrata("DIALOG")
f:SetWidth(248)
f:SetHeight(24)


if i==2 then
for q=1,10 do
	local a1,_,a3=GetAchievementCriteriaInfo(crraspisokach25[i],q)
	if a1==nil then
		q=11
	else
		if a3 then
			Description=Description.."\n|cff00ff00"..a1.."|r"
		else
			Description=Description.."\n|cffff0000"..a1.."|r"
		end
	end
end
end


f:SetScript("OnEnter", function(self) Raiccshowtxt(self,Description) end )
f:SetScript("OnLeave", function(self) Raiccshowtxt2() end )
f:SetScript("OnMouseDown", function(self) if IsShiftKeyDown() then if ChatFrame1EditBox:GetText() and string.len(ChatFrame1EditBox:GetText())>0 then ChatFrame1EditBox:SetText(ChatFrame1EditBox:GetText().." "..GetAchievementLink(crraspisokach25[i])) else ChatFrame_OpenChat(GetAchievementLink(crraspisokach25[i])) end end end )

--картинка
local t = f:CreateTexture(nil,"OVERLAY")
t:SetTexture(crraImage)
t:SetWidth(24)
t:SetHeight(24)
t:SetPoint("TOPLEFT",0,0)

local t = f:CreateFontString()
t:SetFont(GameFontNormal:GetFont(), rafontsset[2])
t:SetWidth(248)
t:SetText(crraName)
t:SetJustifyH("LEFT")
t:SetPoint("LEFT",27,0)


f:SetPoint("TOPLEFT",l+45,-14-j*30)
f:Show()

end

--чекбатон
local c = CreateFrame("CheckButton", nil, crramain6, "UICheckButtonTemplate")
c:SetWidth("25")
c:SetHeight("25")
c:SetPoint("TOPLEFT", l+20, -14-j*30)
c:SetScript("OnClick", function(self) crragalka(i) end )
table.insert(crracbset, c)


end --for i
crranespamit=1
end --nespam


crragalochki()




end --конец бутон2

function Raiccshowtxt(self,i)
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_TOP")
	GameTooltip:SetText(i)
end

function Raiccshowtxt2(i)
GameTooltip:Hide()
end


function crragalochki()
for i=1,#crraspisokach25 do
if(crraspisokon[i]==1)then crracbset[i]:SetChecked() else crracbset[i]:SetChecked(false) end
end
end

function crragalka(nomersmeni)
if crraspisokon[nomersmeni]==1 then crraspisokon[nomersmeni]=0 else crraspisokon[nomersmeni]=1 end
end

function crra_buttonchangeyn(yesno)
crraspislun= # crraspisokach25
for i=1,crraspislun do
crraspisokon[i]=yesno
end
crragalochki()
end

function crra_button1()
crraspislun= # crraspisokach25
for i=1,crraspislun do
if crraspisokon[i]==1 then crraspisokon[i]=0 else crraspisokon[i]=1 end
end
crragalochki()
end


function openmenureportcrra()
if not DropDownMenureportcrra then
CreateFrame("Frame", "DropDownMenureportcrra", crramain6, "UIDropDownMenuTemplate")
end
rachatdropm(DropDownMenureportcrra,5,7)
end