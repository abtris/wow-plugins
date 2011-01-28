local RingKeeper = type(OneRingLib) == "table" and type(OneRingLib.RingKeeper) == "table" and OneRingLib.RingKeeper or false;
if not (RingKeeper and RingKeeper.AddRing) then return; end

RingKeeper:AddRing("DruidShift", {
	{c="cc66ff", id=24858}, -- Moonkin
	{c="4cff66", id=33891}, -- Tree
	{c="ff4c4c", id=5487}, -- Bear
	{c="33b2ff", rtype="macrotext", id="#rkrequire {{spell:40120/33943/1066/783}}\n/cancelform [noflyable]\n/cast [flyable,outdoors,nocombat,noswimming,nomod][flying] {{spell:40120/33943}}; [swimming] {{spell:1066}}; [outdoors] {{spell:783}}"}, -- Travel
	{c="ffff00", id=768}, -- Cat
	name="Druid Shapeshifting", hotkey="BUTTON4", class="DRUID", version=4
});
RingKeeper:AddRing("DruidUtility", {
	{c="117aed", id=29166}, -- innervate
	{c="dd002b", id="/cast [combat][mod] {{spell:20484}}; {{spell:50769}}"}, -- rebirth/revive
	{c="e8a50f", id=22812}, -- bark
	{c="9919e5", id=18960}, -- moonglade
	name="Utility", hotkey="BUTTON5", class="DRUID", version=3
});
RingKeeper:AddRing("DruidFeral", {
	{c="fe1200", id=50334}, -- berserk
	{c="fe9094", id="/cast [form:1] {{spell:5229}}; {{spell:5217}}"}, -- enrage / tiger's fury
	{c="fe650b", id="/cast [form:1] {{spell:77761}}; {{spell:77764}}"}, -- stampeding roar
	{c="fec200", id="/cast [form:1] {{spell:80964}}; {{spell:80965}}"}, -- skull bash
	{c="fe7b00", id=22812}, -- barkskin
	{c="7300fe", id=61336}, -- survival instincts
	{c="d0170a", id=22842}, -- frenzied regen
	{c="fe8644", id="/cast [form:1] {{spell:16979}}; {{spell:49376}}"}, -- feral charge
	name="Feral",class="DRUID"
});
RingKeeper:AddRing("HunterAspects", {
	{c="35b58e", id=13165}, -- hawk
	{c="ba6802", id=5118}, -- cheetah
	{c="ffb200", id=13159}, -- pack
	{c="96ff14", id=20043}, -- wild
	{c="d16a0d", id=82661}, -- fox
	{c="7dbffb", id=781}, -- disengage
	{c="3de4c6", id=5384}, -- feign
	{c="dab692", id="#rkrequire {{spell:883}}\n/cast [nomounted,@pet,noexists] {{spell:883}}; [@pet,dead] {{spell:982}}; [@pet,help,nomod] {{spell:136}}; [@pet,exists] {{spell:2641}}"},
	name="Aspects", hotkey="BUTTON4", class="HUNTER", version=4
});
RingKeeper:AddRing("HunterTraps", {
	{c="f37020", id=13813}, -- explosive
	{c="c83b10", id=13795}, -- immolation
	{c="6e65fc", id=1499}, -- freezing
	{c="61c0ff", id=13809}, -- ice
	{c="4ee854", id=34600}, -- snake
	{c="ca0902", id=77769}, -- launcher
	name="Traps", hotkey="ALT-BUTTON5", class="HUNTER"
});
RingKeeper:AddRing("HunterShots", {
	{c="d73240", id=53351}, -- kill
	{c="d0a3de", id=19801}, -- tranq
	{c="5c8ce6", id=20736}, -- distract
	{c="7ad424", id=77767}, -- cobra
	{c="bf41aa", id=2643}, -- multi
	{c="d81c1a", id=1130}, -- mark
	name="Shots", hotkey="BUTTON5", class="HUNTER"
});


RingKeeper:AddRing("MageArmor", {
	{c="f97200", id=30482}, -- molten
	{c="1966ff", id=168, id2=7302}, -- ice
	{c="7fe5e5", id=6117}, -- mage
	name="Armor spells", class="MAGE"
});
do -- MageTravel
	local m = "/cast [mod] {{spell:%s}}; {{spell:%s}}";
	RingKeeper:AddRing("MageTravel", {
		{c="64bbce", id=m:format(53142, 53140)}, -- Dalaran
		{c="77e0c4", id=m:format("35717/33691", 33690)}, -- Shattrath
		{c="8cb73d", id=m:format(10059, 3561)}, -- Stormwind
		{c="a826e0", id=m:format(11419, 3565)}, -- Darnassus
		{c="70a5b2", id=m:format(11420, 3566)}, -- Thunder Bluff
		{c="77e51e", id=m:format(11418, 3563)}, -- Undercity
		{c="68a8d1", id=m:format(11416, 3562)}, -- Ironforge
		{c="e87c21", id=m:format(11417, 3567)}, -- Orgrimmar
		{c="426ba5", id=m:format(49360, 49359)}, -- Theramore
		{c="72721e", id=m:format(49361, 49358)}, -- Stonard
		{c="7cc6f9", id=m:format(32267, 32272)}, -- Silvermoon
		{c="e89bd1", id=m:format(32266, 32271)}, -- Exodar
		{c="c33716", id=m:format("88346/88345", "88344/88342")}, -- Tol Barad
	  name="Mage Travel", hotkey="ALT-P", class="MAGE", version=5
	});
end
RingKeeper:AddRing("PaladinAuras", {
	{c="b8a671", id=465}, -- devotion
	{c="493ad3", id=19746}, -- concentration
	{c="ffffa5", id=32223}, -- crusader
	{c="ecab05", id=19891}, -- resistance
	{c="9e5bc6", id=7294}, -- retribution
	{rtype="ring", id="PaladinSeal", onlyNonEmpty=true},
	{rtype="ring", id="PaladinBlessing", onlyNonEmpty=true},
	{c="eb8129", id=25780}, -- righteous fury
	name="Paladin Buffs", hotkey="BUTTON4", class="PALADIN", version=4
});
RingKeeper:AddRing("PaladinSeal", {
	{c="2aa5e8", id=20154}, -- righteousness
	{c="fff697", id=31801}, -- truth
	{c="860106", id=20164}, -- justice
	{c="d9b084", id=20165}, -- insight
	name="Seals", class="PALADIN"
});
RingKeeper:AddRing("PaladinBlessing", {
	{c="6E49E6", id=20217}, -- kings
	{c="dab13b", id=19740}, -- might
	name="Blessings", class="PALADIN"
});
RingKeeper:AddRing("PaladinTools", {
	{c="E67E9D", id=853}, -- hammer
	{c="fcdb70", id=85673}, -- glory
	{c="ed8f1b", id=498}, -- divine protection
	{c="ffea4e", id=54428}, -- divine plea
	{c="ff1c5c", id=31884}, -- avenging wrath
	{c="5A55F2", id=1022}, -- hand of protection
	{c="be2c13", id=1044}, -- hand of freedom
	{c="e9d68a", id=1038}, -- hand of salvation
	{c="E6CC7E", id=62124}, -- hand of reckoning
	{c="d47c12", id=26573}, -- consecration
	name="Utility", class="PALADIN", hotkey="BUTTON5"
});
RingKeeper:AddRing("ShamanWeapons", {
	{c="B8DEE6", id=8232}, -- windfury
	{c="D94141", id=8024}, -- flametongue
	{c="D9AC52", id=8017}, -- rockbiter
	{c="52ACD9", id=8033}, -- frostbrand
	{c="52D988", id=51730}, -- earthliving
	name="Weapon Buffs", hotkey="BUTTON5", class="SHAMAN", version=2
});
RingKeeper:AddRing("WarlockDemons", {
	{c="ec3923", id=30146}, -- felguard
	{c="771ed8", id=697}, -- void
	{c="f7380f", id=688}, -- imp
	{c="ff33b2", id=712}, -- succubus
	{c="1966cc", id=691}, -- felhunter
	name="Warlock Demons", class="WARLOCK", hotkey="BUTTON4"
});
RingKeeper:AddRing("WarlockStones", {
	{c="66ff0c", id=6201}, -- health
	{c="b20ce5", id=693}, -- soul
	{c="d872ff", id=29893}, -- ritual
	{c="ff7f00", id=6366}, -- fire
	{c="0033ff", id=2362}, -- spell
	name="Stones", hotkey="BUTTON5", class="WARLOCK"
});
RingKeeper:AddRing("WarriorStances", {
	{c="ff4c4c", id=2457},
	{c="4c4cff", id=71},
	{c="ffcc4c", id=2458},
	name="Warrior Stances", hotkey="BUTTON4", class="WARRIOR", version=2
});
RingKeeper:AddRing("DeathKnightPresence", {
	{c="52ff5a", id="/cast [help,dead] {{spell:61999}}; [nopet,nomounted][@pet,dead] {{spell:46584}}; [@pet,nodead,exists][nomod] {{spell:47541}}; [mod] {{spell:48743}}"}, -- ghoul
	{c="e54c19", id=48263}, -- blood
	{c="1999e5", id=48266}, -- frost
	{c="4ce519", id=48265}, -- unholy
	{c="a93ae8", id=50977}, -- gate
	{c="E8C682", id="/cast [flyable,outdoors][flying] {{spell:54729}}; {{spell:48778}}"},
	{c="63eaff", id=3714}, -- path of frost
	name="Death Knight Presence", hotkey="BUTTON4", class="DEATHKNIGHT",version=4
});
RingKeeper:AddRing("DKCombat", {
	{c="fff4b2", id=57330}, -- horn
	{c="5891ea", id=48792}, -- fortitude
	{c="bcf800", id=48707}, -- shell
	{c="3d63cc", id=51052}, -- Zone
	{c="b7d271", id=49222}, -- shield
	{c="b31500", id=55233}, -- blood
	{c="aef1ff", id=51271}, -- pillar of frost
	{c="d0d0d0", id=49039}, -- lich
	name="Death Knight Combat", hotkey="BUTTON5", class="DEATHKNIGHT",version=3
});
RingKeeper:AddRing("CommonTrades", {
	{c="d8d1ad", id="/cast {{spell:3908/51309}}"}, -- tailoring
	{c="b57f49", id="/cast {{spell:2108/51302}}"}, -- leatherworking
	{c="f4aa0f", id="/cast {{spell:2018/51300}}"}, -- blacksmithing
	{c="3319e5", id="/cast [mod] {{spell:31252}}; {{spell:25229/51311}};"}, -- jewelcrafting/prospecting
	{c="f4ef28", id="/cast [mod] {{spell:13262}}; {{spell:7411/51313}}"}, -- enchanting/disenchanting
	{c="11ba9b", id="/cast {{spell:2259/51304}}"}, -- alchemy
	{c="c13f0f", id="/cast [mod] {{spell:818}}; {{spell:2550/51296}}"}, -- cooking/campfire
	{c="85de60", id="/cast [mod] {{spell:51005}}; {{spell:45357/45363}}"}, -- inscription/milling
	{c="bf2626", id="/cast {{spell:3273/45542}}"}, -- first aid
	{c="e6b725", id="/cast {{spell:4036/51306}}"}, -- engineering
	{c="ffce4d", id="/cast [mod] {{spell:80451}}; {{spell:78670/89722}}"},
	{c="335dcb", id="/cast {{spell:53428}}"}, -- runeforging
	{c="ffac3d", id="/cast {{spell:2656}}"}, -- smelting
	name="Trade Skills", hotkey="ALT-T", version=7
});