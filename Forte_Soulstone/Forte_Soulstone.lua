-- ForteXorcist v1.974.7 by Xus 22-02-2011 for 4.0.6

local FW = FW;
local FWL = FW.L;
local SS = FW:Module("Soulstone");

local NUM_SOULSTONES = 15;

local SYNC_REQUEST = "SYQ";
local SYNC_REPLY = "SYR";

local DI_TIME = 180;
local SS_RES = 360;
local SS_TIME = 900;

local _G = _G;
local unpack = unpack;
local ipairs = ipairs;
local pairs = pairs;
local tonumber = tonumber;
local strformat = string.format;
local abs = math.abs;

local ss = FW:NEW2D();
local erase = FW.ERASE;
local UnitName = FW.FullUnitName;
local GetTime = GetTime;

local SORT_SOULSTONE_ORDER ={4,1,2};
local SORT_SOULSTONE_ASC =	{true,true,true};
local SORT_CAST_ORDER =		{2};
local SORT_CAST_ASC =		{true};

local FLAG_WARLOCK = FW.FLAG.WARLOCK;
local FLAG_DRUID = FW.FLAG.DRUID;
local FLAG_PALADIN = FW.FLAG.PALADIN;
local FLAG_SHAMAN = FW.FLAG.SHAMAN;

local COOLDOWN_TEXT = {
	[FLAG_WARLOCK] = FWL.FLAG_SOULSTONE,
	[FLAG_DRUID] = FWL.FLAG_REBIRTH,
	[FLAG_PALADIN] = FWL.FLAG_DIVINE_INTERVENTION,
	[FLAG_SHAMAN] = FWL.FLAG_ANKH
};

local function SS_IsResser(class)
	if class == "PALADIN" or class == "SHAMAN" or  class == "PRIEST" or class == "DRUID" then return 1;else return 0;end
end

local function SS_SetSSButton()
	local t1 = FW:BestSoulstone();
	if not InCombatLockdown() then -- update the use function in case it wasnt loaded properly due to combat or whatever
		FWSSButton:SetAttribute("*item2", t1 );
	end
	if FW:GotSoulstone() > 0 and FWSSButton:GetAttribute("*","item","2") then
		FWSSButton:SetNormalTexture("Interface\\AddOns\\Forte_Core\\Textures\\SS2");
		FWSSButton.title=strformat(FWL.USE_,t1);
		FWSSButton.tip=strformat(FWL.RIGHT_CLICK_TO_USE_,t1);
	else
		FWSSButton:SetNormalTexture("Interface\\AddOns\\Forte_Core\\Textures\\SS1");
		FWSSButton.title=strformat(FWL.CREATE_,t1);
		FWSSButton.tip=strformat(FWL.LEFT_CLICK_TO_CREATE_,t1);
	end
end

local SoulstoneShow = nil;
local function SS_SoulstoneShow(self,auto) -- with auto set, will only refresh the frame if it's not hidden/shown properly yet
	if not auto then SoulstoneShow = 1;end
	if FW.Settings.SoulstoneEnable and (not FW.Settings.SoulstoneAuto or FW.GROUPED) then
	
		if (SoulstoneShow or not FWSSFrame:IsShown()) then
			
			FWSSBackground:ClearAllPoints();
			if not InCombatLockdown() then
				SoulstoneShow = nil;
				FWSSFrame:Show();
				FWSSBackground:Show();
				
				FWSSFrame:SetWidth(FW.Settings.SoulstoneWidth+2*FW.BORDER);
				FWSSFrame:SetScale(FW.Settings.FWSSFrame.scale);
				
				FWSSBackground:SetWidth(FW.Settings.SoulstoneWidth+2*FW.BORDER);
				FWSSBackground:SetScale(FW.Settings.FWSSFrame.scale);
				
				FWSSFrame:SetFrameStrata(FW.Settings.SoulstoneStrata);
				FWSSBackground:SetFrameStrata(FW.Settings.SoulstoneStrata);
				
				FW:CorrectPosition(FWSSFrame);
			end
			FWSSBackground:SetAlpha(FW.Settings.FWSSFrame.alpha);
			FWSSFrame:SetAlpha(FW.Settings.FWSSFrame.alpha);
			
			FWSSBackground:SetBackdropColor(unpack(FW.Settings.SoulstoneBgColor));
			FWSSBackground:SetBackdropBorderColor(unpack(FW.Settings.SoulstoneBgColor));
			
			FWSSFrameAmount:SetFont(FW.Settings.SoulstoneFont,FW.Settings.SoulstoneFontSize);
			FWSSFrameTime:SetFont(FW.Settings.SoulstoneFont,FW.Settings.SoulstoneFontSize);

			local r,g,b = unpack(FW.Settings.SoulstoneTextColor);
			
			for i=1,NUM_SOULSTONES,1 do
				_G["FWSSBar"..i]:ClearAllPoints();
				
				_G["FWSSBar"..i.."Name"]:SetFont(FW.Settings.SoulstoneFont,FW.Settings.SoulstoneFontSize);
				_G["FWSSBar"..i.."Time"]:SetFont(FW.Settings.SoulstoneFont,FW.Settings.SoulstoneFontSize);
				_G["FWSSBar"..i.."Warlock"]:SetFont(FW.Settings.SoulstoneFont,FW.Settings.SoulstoneFontSize);
				_G["FWSSBar"..i.."Cooldown"]:SetFont(FW.Settings.SoulstoneFont,FW.Settings.SoulstoneFontSize);
			
				_G["FWSSBar"..i]:SetWidth(FW.Settings.SoulstoneWidth);
				_G["FWSSBar"..i]:SetHeight(FW.Settings.SoulstoneHeight);
				_G["FWSSBar"..i]:SetStatusBarTexture(FW.Settings.SoulstoneTexture);
				_G["FWSSBar"..i.."Back"]:SetTexture(FW.Settings.SoulstoneTexture);

				_G["FWSSBar"..i.."Name"]:SetTextColor(r,g,b);
				_G["FWSSBar"..i.."Warlock"]:SetTextColor(r,g,b);
				_G["FWSSBar"..i.."Cooldown"]:SetTextColor(r,g,b);
				_G["FWSSBar"..i.."Time"]:SetTextColor(r,g,b);

				_G["FWSSBar"..i.."Spark"]:SetWidth(FW.Settings.SoulstoneHeight);
				_G["FWSSBar"..i.."Spark"]:SetHeight(FW.Settings.SoulstoneHeight*2);
				
				if FW.Settings.GlobalSparkEnable then
					_G["FWSSBar"..i.."Spark"]:SetAlpha(FW.Settings.GlobalSpark);
					_G["FWSSBar"..i.."Spark"]:Show();
				else
					_G["FWSSBar"..i.."Spark"]:Hide();
				end
			end
			if FW.Settings.SoulstoneExpand then
				FWSSBackground:SetPoint("BOTTOMRIGHT", FWSSFrame, "BOTTOMRIGHT", 0, 0);
				FWSSBar1:SetPoint("BOTTOMLEFT", FWSSBackground, "BOTTOMLEFT", FW.BORDER, 18);
				
				for i=2,NUM_SOULSTONES,1 do
					_G["FWSSBar"..i]:SetPoint("BOTTOMLEFT", _G["FWSSBar"..(i-1)], "TOPLEFT", 0, FW.Settings.SoulstoneSpace);
				end
			else
				FWSSBackground:SetPoint("TOPLEFT", FWSSFrame, "TOPLEFT", 0, 0);
				FWSSBar1:SetPoint("TOPLEFT", FWSSBackground, "TOPLEFT", FW.BORDER, -18);
				
				for i=2,NUM_SOULSTONES,1 do
					_G["FWSSBar"..i]:SetPoint("TOPLEFT", _G["FWSSBar"..(i-1)], "BOTTOMLEFT", 0, -FW.Settings.SoulstoneSpace);
				end
			end
		end
	else
		if (SoulstoneShow or FWSSFrame:IsShown()) and not InCombatLockdown() then
			SoulstoneShow = nil;
			FWSSFrame:Hide();
			FWSSBackground:Hide();
		end
	end
end

local function ColorVal(v,flag,flag2)
	if flag2 == FW.FLAG.NORMAL then
	
		if flag == FW.FLAG.RES then
			return unpack(FW.Settings.ReadyColor);
		elseif flag == FW.FLAG.TIME then
			return FW:MixColors(v,FW.Settings.SoulstoneMinColor,FW.Settings.SoulstoneMaxColor);
		elseif flag == FLAG_WARLOCK then
			return unpack(FW.Settings.WarlockColor);
		elseif flag == FLAG_DRUID then
			return unpack(FW.Settings.DruidColor);
		elseif flag == FLAG_PALADIN then
			return unpack(FW.Settings.PaladinColor);
		elseif flag == FLAG_SHAMAN then
			return unpack(FW.Settings.ShamanColor);
		end
		
	elseif flag2 == FW.FLAG.DI then
	
		if flag == FW.FLAG.TIME or flag == FW.FLAG.DI then
			return unpack(FW.Settings.ReadyColor);
		elseif flag == FLAG_WARLOCK then
			return unpack(FW.Settings.WarlockColor);
		elseif flag == FLAG_DRUID then
			return unpack(FW.Settings.DruidColor);
		elseif flag == FLAG_PALADIN then
			return unpack(FW.Settings.PaladinColor);
		elseif flag == FLAG_SHAMAN then
			return unpack(FW.Settings.ShamanColor);
		end

	elseif flag2 == FW.FLAG.DEAD then

		if flag == FLAG_WARLOCK then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.DeadColor,FW.Settings.WarlockColor);
		elseif flag == FLAG_DRUID then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.DeadColor,FW.Settings.DruidColor);
		elseif flag == FLAG_PALADIN then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.DeadColor,FW.Settings.PaladinColor);
		elseif flag == FLAG_SHAMAN then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.DeadColor,FW.Settings.ShamanColor);
		end
		
	elseif flag2 == FW.FLAG.OFFLINE then

		if flag == FW.FLAG.TIME then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.OfflineColor,FW.Settings.SoulstoneMaxColor);
		elseif flag == FLAG_WARLOCK then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.OfflineColor,FW.Settings.WarlockColor);
		elseif flag == FLAG_DRUID then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.OfflineColor,FW.Settings.DruidColor);
		elseif flag == FLAG_PALADIN then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.OfflineColor,FW.Settings.PaladinColor);
		elseif flag == FLAG_SHAMAN then
			return FW:MixColors(FW.Settings.Mix,FW.Settings.OfflineColor,FW.Settings.ShamanColor);
		end
	end
end

local function SS_DrawDetails()
	if not FWSSFrame:IsShown() then return; end
	local n = 0;
	local Bar;
	for i=1, NUM_SOULSTONES, 1 do
		Bar = _G["FWSSBar"..i];
		
		if FW.Settings.Details and (not FW.Settings.SoulstoneDetailsAuto or FW.GROUPED) and i <= FW.Settings.SoulstoneMax and i <= ss.rows then
			local t1,t2,t3,t4,t5,_,t7,t8 = unpack(ss[i]);
			local r,g,b = ColorVal(t1,t4,t8);
			if FW.Settings.ShowReady then -- swap the value on cooldown bars, but keep color the same
				if t4 ~= FW.FLAG.TIME and t4 ~= FW.FLAG.RES and t4 ~= FW.FLAG.DI then
					t1=1-t1;
				end
			end
			Bar:SetValue(t1);
			Bar:SetStatusBarColor(r,g,b);
			_G["FWSSBar"..i.."Back"]:SetVertexColor(r,g,b,0.5);
			_G["FWSSBar"..i.."Name"]:SetText(t2);
			_G["FWSSBar"..i.."Time"]:SetText(t3);
			_G["FWSSBar"..i.."Warlock"]:SetText(t5);
			_G["FWSSBar"..i.."Cooldown"]:SetText(t7);
			
			if FW.Settings.GlobalSpark then
				r,g,b = FW:FixIntensity(r,g,b);
				_G["FWSSBar"..i.."Spark"]:SetVertexColor(r,g,b);
			end
			
			_G["FWSSBar"..i.."Spark"]:SetPoint("CENTER", Bar, "LEFT", t1*Bar:GetWidth(), 0);
			n = n + 1;
			Bar:Show();
		elseif Bar:IsShown() then
			Bar:Hide();
		end
	end
	if n>0 then
		FWSSBackground:SetHeight(21+(FW.Settings.SoulstoneHeight+FW.Settings.SoulstoneSpace)*n-FW.Settings.SoulstoneSpace);
	else
		FWSSBackground:SetHeight(20);
	end
end

local function SS_ShowCooldown(class)
	return (class and FW.FLAG[class]) or nil;
end

local sst = {};
local function SS_ProcessSoulstone()
	if FWSSFrame:IsShown() then--does not hide in combat!
		ss:erase();
		erase(sst);
		local t1,t2,t3,t4,t5,t6;
		for name, data in pairs(FW.Saved.Timers) do -- translate to viewable data

			if data[2] == FW.Saved.Update then -- only display ppl currently in the party/raid, meaning only updated entries, but i still want to track someone that left with ss on
				t1=data[1];
				if data[3] == FW.FLAG.RES then t2=data[1]/SS_RES; elseif data[3] == FW.FLAG.DI then t2=data[1]/DI_TIME;else t2=data[1]/SS_TIME; end
				t1 = FW:SecToTime(t1);
				if FW.Saved.Cooldowns[ data[4] ] then sst[ data[4] ] = 1; t3 = FW.Saved.Cooldowns[ data[4] ][1]-FW.Saved.Update; else t3=0; end -- mouseover cd time for the warlock
				t3 = FW:SecToTime(t3);
				ss:insert(t2,name,t1,data[3],"<"..data[4]..">",data[5],t3,data[6]);
			end
		end
		for name, data in pairs(FW.Saved.Cooldowns) do
			if FW.Saved.RaidStatus[name] then
				local class_flag = SS_ShowCooldown(FW.Saved.RaidStatus[name][3]);
				local flag = FW.Saved.RaidStatus[name][1];
				t1 = data[1] - FW.Saved.Update;
				if not sst[name] and flag >= FW.FLAG.OFFLINE and (FW.Settings.ShowAll or class_flag == FLAG_WARLOCK) then
					t2 = t1/data[2];
					t1 = FW:SecToTime(t1);
					ss:insert(t2,name,t1,class_flag,COOLDOWN_TEXT[ class_flag ],0,t1,flag);
				end
			end
		end
		if FW.Settings.ShowReady then
			for name, data in pairs(FW.Saved.RaidStatus) do
				if data[1] >= FW.FLAG.OFFLINE then
					local class_flag = SS_ShowCooldown(data[3]);
					if not FW.Saved.Cooldowns[name] and class_flag and (FW.Settings.ShowAll and FW.RAID or class_flag == FLAG_WARLOCK) then
					
						if data[4] or class_flag == FLAG_WARLOCK then -- got FX, ora3 or is warlock
							t1=FWL.SHORT_READY;
						else
							t1="??";
						end
						ss:insert(0,name,t1,class_flag,COOLDOWN_TEXT[class_flag],0,t1,data[1]);
					end
				end
			end
		end
		ss:sort(SORT_SOULSTONE_ORDER,SORT_SOULSTONE_ASC); -- sort viewable data

		local s1, s2, s3, s4, s5, _ = 0,0,"","","ffffff";
		for i=1, ss.rows, 1 do
			_,_,t3,t4,_,t6 = unpack(ss[i]);
			if t4 == FW.FLAG.TIME then 
				s2 = s2 + 1; s1 = s1 + 1; 
				if s3 == "" then s3 = t3; end
			elseif t4 == FW.FLAG.RES or t4 == FW.FLAG.DI then 
				s1 = s1 + 1; 
			end
			if t6 == 1 then s5 = "00ff00";end -- resser

		end
		if s2 > 1 then
			for i=ss.rows, 1, -1 do
				if ss[i][4] == FW.FLAG.TIME then s4 = ss[i][3]; break; end
			end
		end
		local str = ""; if s3~="" then str=str.." "..s3;end if s4~="" then str=str.."-"..s4;end if str=="" then if s2==s1 then str=FWL.NO_SS_UP;else str=FWL.READY_TO_RES;end end
		FWSSFrameAmount:SetText("|cff"..s5.."x"..s1.."|r");
		FWSSFrameTime:SetText(str);

		SS_DrawDetails();
		SS_SetSSButton();
	end
end

local buffss = FW:SpellName(20707);
local divint = FW:SpellName(19753);
local spirit = FW:SpellName(35618);

local function SS_IsFresh(t,d)
	return t >= d - 10;
end

local function SS_SoulstoneScan(unit,unitName,unitClass,flag,update)
	
	--FW:Show(unit.." "..unitName.." "..unitClass);
	if flag == FW.FLAG.OFFLINE then
		if FW.Saved.Timers[unitName] then
			if FW.Saved.Timers[unitName][3] == FW.FLAG.RES then
				FW.Saved.Timers[unitName] = nil; -- you cant use ss when you are offline, ss expired
			else
				-- dont update the timer, timer paused for offline player
				FW.Saved.Timers[unitName][6] = flag;
			end
		end
	else
		if flag == FW.FLAG.NORMAL and UnitBuff(unit,divint) then
			flag = FW.FLAG.DI;
		end
		local _, _, _, _, _, duration, t1, caster = UnitBuff(unit,buffss);
		local cd_end,cd_dura;
		if t1 then
			cd_end = t1;
			cd_dura = duration;
			
			caster = (caster and UnitName(caster)) or FWL.UNKNOWN;
			if not FW.Saved.Timers[unitName] then
				FW.Saved.Timers[unitName] = {t1-update,update,FW.FLAG.TIME,caster,SS_IsResser(unitClass),FW.FLAG.NORMAL}; -- timer, last update, flag, caster, isresser
				if caster ~= FWL.UNKNOWN and SS_IsFresh(t1-update,duration) then -- only add if new
					if FW.Saved.Cooldowns[caster] then
						FW.Saved.Cooldowns[caster][1],FW.Saved.Cooldowns[caster][2] = cd_end,cd_dura;
					else
						FW.Saved.Cooldowns[caster] = {cd_end,cd_dura};
					end
				end
			else
				FW.Saved.Timers[unitName][3] = FW.FLAG.TIME;
				if caster ~= FWL.UNKNOWN and (caster ~= FW.Saved.Timers[unitName][4] or SS_IsFresh(t1-update,duration)) then -- maybe the same warlock casting again on same target
					FW.Saved.Timers[unitName][4] = caster;
					if FW.Saved.Cooldowns[caster] then
						FW.Saved.Cooldowns[caster][1],FW.Saved.Cooldowns[caster][2] = cd_end,cd_dura;
					else
						FW.Saved.Cooldowns[caster] = {cd_end,cd_dura};
					end
				end
				if flag == FW.FLAG.DI and FW.Saved.Timers[unitName][6] ~= FW.FLAG.DI then
					if FW.Settings.SoulstoneMsgEnable then
						FW:Show(strformat(FWL.DI_GAIN,unitName),unpack(FW.Settings.SoulstoneMsgColor));
					end
				elseif flag ~= FW.FLAG.DI and FW.Saved.Timers[unitName][6] == FW.FLAG.DI then
					if FW.Settings.SoulstoneMsgEnable then
						FW:Show(strformat(FWL.DI_FADE,unitName),unpack(FW.Settings.SoulstoneMsgColor));
					end
				end
				
				FW.Saved.Timers[unitName][6] = flag;
				FW.Saved.Timers[unitName][1] = t1-update;
				if FW.Saved.Timers[unitName][1] < 0 then FW.Saved.Timers[unitName][1] = 0; end
			end
			
		elseif flag == FW.FLAG.DI then
			if not FW.Saved.Timers[unitName] then
				FW.Saved.Timers[unitName] = {DI_TIME,update,FW.FLAG.DI,FWL.UNKNOWN,SS_IsResser(unitClass),FW.FLAG.DI}; -- timer, last update, flag, caster, isresser
			
				if FW.Settings.SoulstoneMsgEnable then
					FW:Show(strformat(FWL.DI_GAIN,unitName),unpack(FW.Settings.SoulstoneMsgColor));
				end
			else
				FW.Saved.Timers[unitName][3] = FW.FLAG.DI;
				FW.Saved.Timers[unitName][6] = FW.FLAG.DI;
				FW.Saved.Timers[unitName][1] = FW.Saved.Timers[unitName][1] + FW.Saved.Timers[unitName][2] - update;
				if FW.Saved.Timers[unitName][1] < 0 then FW.Saved.Timers[unitName][1] = 0; end
			end		
		
		else
			if FW.Saved.Timers[unitName] then			
				if UnitIsDead(unit) or UnitBuff(unit,spirit) then -- ss can be used to res
				-- currently, players that die with a ss on, and no longer show the buff, often don't show as dead yet...
				-- fix by delaying the death check?
					
					if FW.Saved.Timers[unitName][3] ~= FW.FLAG.RES then
						-- message
						if FW.Settings.SoulstoneMsgEnable then
							if FW.Saved.Timers[unitName][4] ~= FWL.UNKNOWN then
								if FW.Saved.Timers[unitName][4] == FW.PLAYER then
									FW:Show(strformat(FWL.SS_DIED_YOUR,unitName),unpack(FW.Settings.SoulstoneMsgColor));
								else
									FW:Show(strformat(FWL.SS_DIED_OTHER,unitName,FW.Saved.Timers[unitName][4]),unpack(FW.Settings.SoulstoneMsgColor));
								end
							else
								FW:Show(strformat(FWL.SS_DIED,unitName),unpack(FW.Settings.SoulstoneMsgColor));
							end
						end
						-- end of message
						FW.Saved.Timers[unitName][1] = SS_RES;
						FW.Saved.Timers[unitName][3] = FW.FLAG.RES;
						
						FW:PlaySound("SoulstoneFadeSound");
					end
					
					FW.Saved.Timers[unitName][1] = FW.Saved.Timers[unitName][1] + FW.Saved.Timers[unitName][2] - update;
					if FW.Saved.Timers[unitName][1] < 0 then FW.Saved.Timers[unitName][1] = 0; end
					
				elseif UnitIsEnemy(unit,"player") or UnitIsCharmed(unit) or UnitIsCharmed("player") then -- avoid weird stuff
				
					FW.Saved.Timers[unitName][1] = FW.Saved.Timers[unitName][1] + FW.Saved.Timers[unitName][2] - update; -- should keep the timer 'running'
					if FW.Saved.Timers[unitName][1] < 0 then FW.Saved.Timers[unitName][1] = 0; end
					
				else
					if FW.Saved.Timers[unitName][3] == FW.FLAG.TIME then
						-- message
						if FW.Settings.SoulstoneMsgEnable then
							if FW.Saved.Timers[unitName][4] ~= FWL.UNKNOWN then
								if FW.Saved.Timers[unitName][4] == FW.PLAYER then
									FW:Show(strformat(FWL.SS_EXPIRE_YOUR,unitName),unpack(FW.Settings.SoulstoneMsgColor));
								else
									FW:Show(strformat(FWL.SS_EXPIRE_OTHER,FW.Saved.Timers[unitName][4],unitName),unpack(FW.Settings.SoulstoneMsgColor));
								end
							else
								FW:Show(strformat(FWL.SS_EXPIRE,unitName),unpack(FW.Settings.SoulstoneMsgColor));
							end
						end
						FW:PlaySound("SoulstoneFadeSound");
						-- end of message
					elseif FW.Saved.Timers[unitName][6] == FW.FLAG.DI then
						if FW.Settings.SoulstoneMsgEnable then
							FW:Show(strformat(FWL.DI_FADE,unitName),unpack(FW.Settings.SoulstoneMsgColor));
						end
					end
					FW.Saved.Timers[unitName] = nil;
					
				end
			end	
		end
	end
	if FW.Saved.Timers[unitName] then FW.Saved.Timers[unitName][2] = update; end
	
	if FW.Saved.Cooldowns[unitName] then
		if FW.Saved.Cooldowns[unitName][1]-update < 0 then --  remove cooldown if his cooldown is done doh
			if FW.Saved.RaidStatus[unitName][3] == "WARLOCK" then
				FW:PlaySound("SoulstoneReadySound");
			end
			FW.Saved.Cooldowns[unitName] = nil;
		end
	end
end

local function SS_GetTimers()
	FW:SendData(SYNC_REQUEST);
end

local function SS_IsUpdated(n,o)
	return abs(n-o) > 10;
end

local function SS_ReceivedTimer(msg)
	local t1,player,t3,t4,t5,t6 = strsplit("|",msg);
	
	if t1 == "T" then
		if not FW.Saved.Timers[player] or (FW.Saved.Timers[player][4] == FWL.UNKNOWN and t5 ~= FWL.UNKNOWN) then
			FW.Saved.Timers[player] = {tonumber(t3),GetTime(),tonumber(t4),t5,tonumber(t6),FW.FLAG.NORMAL}; -- timer, last update, flag, caster, isresser
		end
	elseif t1 == "C" then	
		local t = tonumber(t3)+GetTime();
		if not FW.Saved.Cooldowns[player] then
			FW.Saved.Cooldowns[player] = {t,tonumber(t4)}; -- timer, last update
		elseif SS_IsUpdated(t,FW.Saved.Cooldowns[player][1]) then
			FW.Saved.Cooldowns[player][1] = t;
			FW.Saved.Cooldowns[player][2] = tonumber(t4);
		end
	end
end

local function SS_SendTimers()
	-- of course sends the timers as they should be right now
	local t;
	local now = GetTime();
	for name, data in pairs(FW.Saved.Timers) do
		t = data[1]+data[2]-now; 
		if t > 0 then
			FW:SendData(SYNC_REPLY.."T "..name.."|"..strformat("%.1f",t).."|"..data[3].."|"..data[4].."|"..data[5]);
		end
	end
	for name, data in pairs(FW.Saved.Cooldowns) do
		t = data[1]-now;
		if t > 0 then
			FW:SendData(SYNC_REPLY.."C "..name.."|"..strformat("%.1f",t).."|"..data[2]);
		end
	end
	return 1;
end

local function SS_CooldownReceived(spell,cd,player) -- cooldowns generated by FX or oRA3
	FW:Debug("ora cooldown: "..player.." "..spell.." "..cd);
	if --[[spell ~= FLAG_WARLOCK and]] COOLDOWN_TEXT[spell]then
		local t = cd+GetTime();
		if not FW.Saved.Cooldowns[player] then
			FW.Saved.Cooldowns[player] = {t,cd};-- store the class as well as the total cooldown for shamans
		elseif SS_IsUpdated(t,FW.Saved.Cooldowns[player][1]) then
			FW.Saved.Cooldowns[player][1] = t;
			FW.Saved.Cooldowns[player][2] = cd;
		end
	end
end

--globally accessable

function FW:SSFrame_OnClick(button)
	if FW:Moved() then return; end
	if button == "LeftButton" then
		if FW.Settings.Details then -- toggles between hidden->normal->ready->etc
			if FW.Settings.ShowReady then
				FW.Settings.Details = false;
			else
				FW.Settings.ShowReady = true;
			end
		else
			FW.Settings.Details = true;
			FW.Settings.ShowReady = false;
		end
		SS_DrawDetails();
		FW:RefreshOptions();
		
	else
		FW:ScrollTo(FWL.SOULSTONE_TRACKER);
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function FW:SoulstoneOnload()
	-- includes a quick 2.00 fix!
	FWSSFrame.Update = SS_SoulstoneShow;
	FW:RegisterFrame("FWSSFrame",FWSSFrame,1);

	FW:RegisterButtonPress("SS_CREATESOULSTONE","FWSSButton","LeftButton");
	FW:RegisterButtonPress("SS_USESOULSTONE","FWSSButton","RightButton");
	--FW:RegisterButtonPress("SS_USESOULSTONESELF","FWSSButton","RightButton");
	FW:RegisterButtonPress("SS_OPTIONS","FWSSFrame","RightButton");	
	
	FW:RegisterScan(SS_SoulstoneScan);
	
	FW:RegisterVariablesEvent(function()
		FW:RegisterTimedEvent("UpdateInterval",		SS_ProcessSoulstone);
		FW:RegisterTimedEvent("UpdateInterval",		function() FWSSFrame:Update(1); end);
	end);
	
	FW:RegisterOnEnterCombat(SS_SetSSButton); -- Hopefully set correct spell just before the buttons are locked if loading up in combat
	
	FW:RegisterEnterPartyRaid(function(joined) if joined then SS_GetTimers();end end);
	
	FW:AddCommand("synch",SS_GetTimers);
	
	FW:RegisterMessage(SYNC_REQUEST,SS_SendTimers,nil);
	FW:RegisterMessage(SYNC_REPLY,
		function(m) 
			SS_ReceivedTimer(m);
			return 1;
		end,
	nil);
	

	FW:RegisterORAMessage("^1^SCooldown^N(%d-)^N(%d-)^^",
		function(a1,a2,f)
			a1,a2=tonumber(a1),tonumber(a2);
			if a1 and a2 then
				SS_CooldownReceived(a1,a2,f);
			end
			return 1;
		end,
	nil);--ignore from ppl with FW
	--FW:Show("Soulstone Module Loaded");
end
FW:SetMainCategory(FWL.SOULSTONE_TRACKER,FW.ICON.SS,5,"SOULSTONE","FWSSFrame");
	FW:SetSubCategory(FW.NIL,FW.NIL,1,FW.EXPAND);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.COMBAT_HINT);
		
	FW:SetSubCategory(FWL.BASIC,FW.ICON.BASIC,2,FW.EXPAND);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.ENABLE,		FWL.SS_ENABLE_TT,	"SoulstoneEnable",		SS_SoulstoneShow);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.AUTO_HIDE,	FWL.AUTO_HIDE_TT,	"SoulstoneAuto",	SS_SoulstoneShow);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.AUTO_MINIMIZE,	FWL.AUTO_MINIMIZE_TT,	"SoulstoneDetailsAuto");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.SHOW_BARS,	FWL.SHOW_BARS_TT,	"Details");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.EXPAND_UP,	FWL.EXPAND_UP_TT,	"SoulstoneExpand",	SS_SoulstoneShow);

	FW:SetSubCategory(FWL.SPECIFIC,FW.ICON.SPECIFIC,3);	
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.SHOW_ALL_ABILITIES,	FWL.SHOW_ALL_ABILITIES_TT,	"ShowAll");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.SHOW_READY,		FWL.SHOW_READY_TT,		"ShowReady");
	
	FW:SetSubCategory(FWL.SIZING,FW.ICON.SIZE,4);	
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.BAR_WIDTH,			"",	"SoulstoneWidth",	SS_SoulstoneShow,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.BAR_HEIGHT,			"",	"SoulstoneHeight",	SS_SoulstoneShow,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.BAR_SPACING,			"",	"SoulstoneSpace",	SS_SoulstoneShow,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.MAX_SHOWN,			"",	"SoulstoneMax",		nil,0,NUM_SOULSTONES);

	FW:SetSubCategory(FWL.BAR_COLORING,FW.ICON.FILTER,5);	
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.SS_FULL,				"",	"SoulstoneMax");
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.SS_EMPTY,				"",	"SoulstoneMin");
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.RESURRECT,			"",	"Ready");
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.DEAD,					"",	"Dead");
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.OFFLINE,				"",	"Offline");
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.DEAD_OFFLINE_MIXING,	FWL.DEAD_OFFLINE_MIXING_TT,	"Mix",nil,0,1);
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.WARLOCK,				"",	"Warlock");
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.DRUID,				"",	"Druid");
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.PALADIN,				"",	"Paladin");
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.SHAMAN,				"",	"Shaman");

	FW:SetSubCategory(FWL.APPEARANCE,FW.ICON.APPEARANCE,6);	
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.BAR_TEXT,			"",	"SoulstoneText",	SS_SoulstoneShow);
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.FRAME_BACKGROUND,	"",	"SoulstoneBg",		SS_SoulstoneShow);
		FW:RegisterOption(FW.FNT,2,FW.NON,FWL.BAR_FONT,			"",	"SoulstoneFont",	SS_SoulstoneShow);
		FW:RegisterOption(FW.TXT,2,FW.NON,FWL.BAR_TEXTURE,		"",	"SoulstoneTexture",	SS_SoulstoneShow);

FW:SetMainCategory(FWL.SELF_MESSAGES,FW.ICON.SELFMESSAGE,11,"SELFMESSAGES");
	FW:SetSubCategory(FW.NIL,FW.NIL,1);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.SELF_MESSAGES_HINT1);

	FW:SetSubCategory(FWL.SOULSTONE_TRACKER,FW.ICON.BASIC,2);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.SOULSTONE_MESSAGES_COLOR,		FWL.SHOW_SOULSTONE_MESSAGES_TT,"SoulstoneMsg");
	
FW:SetMainCategory(FWL.SOUND,FW.ICON.SOUND,12,"SOUND");
	FW:SetSubCategory(FW.NIL,FW.NIL,1);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.SOUND_HINT1);
	FW:SetSubCategory(FWL.SOULSTONE_TRACKER,FW.ICON.DEFAULT,2);
		FW:RegisterOption(FW.SND,2,FW.NON,FWL.EXPIRED,"","SoulstoneFadeSound");
		FW:RegisterOption(FW.SND,2,FW.NON,FWL.READY,"","SoulstoneReadySound");
		
FW:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT");
	FW:SetSubCategory(FWL.SOULSTONE_TRACKER,FW.ICON.DEFAULT,5);
		FW:RegisterOption(FW.MS0,1,FW.NON,FWL.FRAME_LEVEL,FWL.FRAME_LEVEL_TT,	"SoulstoneStrata", SS_SoulstoneShow);

FW.Default.SoulstoneStrata = FW.Default.Strata;
		
FW.Default.Mix = 0.5;
FW.Default.WarlockColor =		{0.58,0.51,0.79};
FW.Default.ReadyColor = 		{1.00,1.00,0.00};
FW.Default.SoulstoneMaxColor = 	{0.64,0.21,0.93};
FW.Default.SoulstoneMinColor =	{1.00,0.00,0.60};
FW.Default.OfflineColor =	 	{0.00,0.00,0.00};
FW.Default.DeadColor = 			{0.50,0.50,0.50};
FW.Default.DruidColor = 		{1.00,0.49,0.04};
FW.Default.PaladinColor = 		{0.96,0.55,0.73};
FW.Default.ShamanColor = 		{0.00,0.86,0.73};
FW.Default.SoulstoneBgColor = 	{0.31,0.00,0.62,0.75};
FW.Default.SoulstoneTextColor = {1.00,1.00,1.00};

FW.Default.SoulstoneFont = FW.Default.Font;
FW.Default.SoulstoneFontSize = FW.Default.FontSize;
FW.Default.SoulstoneTexture = FW.Default.Texture;
FW.Default.Details = true;
FW.Default.SoulstoneAuto = false;
FW.Default.SoulstoneDetailsAuto = false;
FW.Default.ShowReady = false;
FW.Default.ShowAll = true;
FW.Default.SoulstoneMax = 10;
FW.Default.SoulstoneWidth = 100;
FW.Default.SoulstoneHeight = 12
FW.Default.SoulstoneMsgColor = {1.00,0.00,1.00};
FW.Default.SoulstoneMsgEnable = true;
FW.Default.SoulstoneEnable = true;
FW.Default.SoulstoneExpand = false;
FW.Default.SoulstoneSpace = 1;

FW.Default.SoulstoneFadeSound = "Interface\\AddOns\\Forte_Core\\Sounds\\SoulstoneExpire.mp3";
FW.Default.SoulstoneFadeSoundEnable = true;
FW.Default.SoulstoneFadeSoundVolume = 1;
--FW.Default.SoulstoneUsedSound = "Sound\\Spells\\SoulstoneResurrection_Base.wav";
--FW.Default.SoulstoneUsedSoundEnable = true;
--FW.Default.SoulstoneUsedSoundVolume = 1;
FW.Default.SoulstoneReadySound = "Sound\\Spells\\SimonGame_Visual_GameTick.wav";
FW.Default.SoulstoneReadySoundVolume = 1;
FW.Default.SoulstoneReadySoundEnable = true;

BINDING_HEADER_SOULSTONE = FWL.SOULSTONE_TRACKER;
BINDING_NAME_SS_CREATESOULSTONE = FW:SpellName(693);
BINDING_NAME_SS_USESOULSTONE = FWL.USE_SOULSTONE;
--BINDING_NAME_SS_USESOULSTONESELF = "Use Soulstone on Self";
BINDING_NAME_SS_OPTIONS = FWL.TOGGLE_OPTIONS;
