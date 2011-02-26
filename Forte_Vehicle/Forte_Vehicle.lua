-- ForteXorcist v1.974.7 by Xus 22-02-2011 for 4.0.6

local FW = FW;
local CA = FW.Modules.Casting;
local ST = FW.Modules.Timer;
local CD = FW.Modules.Cooldown;
	
if ST then
	-- doesnt use the casting code, but who cares!!

	-- Wyrmrest Skytalon
	ST:RegisterSpell(57090,	1,000,0,ST.HEAL,00,0,5); -- revivify
		ST:RegisterTickSpeed(57090, 1); -- make this show ticks
		
	ST:RegisterSpell(56092,	1,000,0,ST.DEFAULT,00,0,5); -- engulf
		ST:RegisterTickSpeed(56092, 3); -- make this show ticks
		
	ST:RegisterSpell(57143,	1,000,0,ST.BUFF,00,0); -- life burst
		
	ST:RegisterSpell(57108,	1,000,0,ST.BUFF,00,0); -- flame shield

	ST:RegisterSpell(57092,	1,000,0,ST.PET,00,0); -- blazing speed
	
	-- Ulduar
	ST:RegisterSpell(62489,	1,000,0,ST.DEFAULT,00,0,5); -- Blue Pyrite
		ST:RegisterTickSpeed(62489, 1); -- make this show ticks
		
	-- Amber Drake (The Oculus)
	ST:RegisterSpell(49836, 1, 000, 0, ST.DEFAULT,00,0); -- Shock Charge

	-- Emerald Drake (The Oculus)
	ST:RegisterSpell(50341, 1, 000, 0, ST.DEFAULT,00,0); -- Touch the Nightmare
	ST:RegisterSpell(50328, 1, 000, 0, ST.DEFAULT,00,0); -- Leeching Poison
		ST:RegisterTickSpeed(50328, 2); -- change tick speed from 3 to 2

end
