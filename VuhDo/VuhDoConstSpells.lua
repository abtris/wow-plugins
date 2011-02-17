local GetSpellInfo = GetSpellInfo;


--------------------
-- Spells by SpellId
--------------------
VUHDO_SPELL_ID = { };
VUHDO_SPELL_ID.ACTIVATE_FIRST_TALENT = GetSpellInfo(63645);
VUHDO_SPELL_ID.ACTIVATE_SECOND_TALENT = GetSpellInfo(63644);
VUHDO_SPELL_ID.ANCESTRAL_HEALING = GetSpellInfo(16176);
VUHDO_SPELL_ID.ANCESTRAL_SPIRIT = GetSpellInfo(2008);
VUHDO_SPELL_ID.BINDING_HEAL = GetSpellInfo(32546);
VUHDO_SPELL_ID.BLESSED_HEALING = GetSpellInfo(70772);
VUHDO_SPELL_ID.BLOOD_PAKT = GetSpellInfo(6307);
VUHDO_SPELL_ID.CALL_OF_THE_ELEMENTS = GetSpellInfo(66842);
VUHDO_SPELL_ID.CHAIN_HEAL = GetSpellInfo(1064);
VUHDO_SPELL_ID.CIRCLE_OF_HEALING = GetSpellInfo(34861);
VUHDO_SPELL_ID.CLEANSE_SPIRIT = GetSpellInfo(51886);
VUHDO_SPELL_ID.CURE_DISEASE = GetSpellInfo(528);
VUHDO_SPELL_ID.DESPERATE_PRAYER = GetSpellInfo(19236);
VUHDO_SPELL_ID.DISPEL_MAGIC = GetSpellInfo(527);
VUHDO_SPELL_ID.DIVINE_AEGIS = GetSpellInfo(47509);
VUHDO_SPELL_ID.DIVINE_FAVOR = GetSpellInfo(31842);
VUHDO_SPELL_ID.DIVINE_ILLUMINATION = GetSpellInfo(71166);
VUHDO_SPELL_ID.ECHO_OF_LIGHT = GetSpellInfo(77485);
VUHDO_SPELL_ID.EARTHLIVING = GetSpellInfo(51945);
VUHDO_SPELL_ID.FLASH_HEAL = GetSpellInfo(2061);
VUHDO_SPELL_ID.FLASH_OF_LIGHT = GetSpellInfo(19750);
VUHDO_SPELL_ID.GIFT_OF_THE_NAARU = GetSpellInfo(59547);
VUHDO_SPELL_ID.GRACE = GetSpellInfo(47516);
VUHDO_SPELL_ID.GREATER_HEAL = GetSpellInfo(2060);
VUHDO_SPELL_ID.GUARDIAN_SPIRIT = GetSpellInfo(47788);
VUHDO_SPELL_ID.HEAL = GetSpellInfo(2050);
VUHDO_SPELL_ID.HEALING_TOUCH = GetSpellInfo(5185);
VUHDO_SPELL_ID.HEALING_WAVE = GetSpellInfo(331);
VUHDO_SPELL_ID.HOLY_LIGHT = GetSpellInfo(635);
VUHDO_SPELL_ID.HOLY_SHOCK = GetSpellInfo(20473);
VUHDO_SPELL_ID.HOLY_WORD_ASPIRE = GetSpellInfo(88682);
VUHDO_SPELL_ID.HOLY_WORD_CHASTISE = GetSpellInfo(88625);
VUHDO_SPELL_ID.HOLY_WORD_SANCTUARY = GetSpellInfo(88685);
VUHDO_SPELL_ID.HOLY_WORD_SERENITY = GetSpellInfo(88684);
VUHDO_SPELL_ID.ILLUMINATED_HEALING = GetSpellInfo(76669);
VUHDO_SPELL_ID.INNERVATE = GetSpellInfo(29166);
VUHDO_SPELL_ID.INSPIRATION = GetSpellInfo(14892);
VUHDO_SPELL_ID.LAY_ON_HANDS = GetSpellInfo(633);
VUHDO_SPELL_ID.LESSER_HEALING_WAVE = GetSpellInfo(27624);
VUHDO_SPELL_ID.LIFEBLOOM = GetSpellInfo(33763);
VUHDO_SPELL_ID.MEND_PET = GetSpellInfo(136);
VUHDO_SPELL_ID.MISDIRECTION = GetSpellInfo(34477);
VUHDO_SPELL_ID.MOONKIN_FORM = GetSpellInfo(24858);
VUHDO_SPELL_ID.NOURISH = GetSpellInfo(50464);
VUHDO_SPELL_ID.PAIN_SUPPRESSION = GetSpellInfo(33206);
VUHDO_SPELL_ID.PALA_CLEANSE = GetSpellInfo(4987);
VUHDO_SPELL_ID.POWERWORD_SHIELD = GetSpellInfo(17);
VUHDO_SPELL_ID.PRAYER_OF_HEALING = GetSpellInfo(596);
VUHDO_SPELL_ID.PRAYER_OF_MENDING = GetSpellInfo(33076);
VUHDO_SPELL_ID.PURGE = GetSpellInfo(370);
VUHDO_SPELL_ID.REBIRTH = GetSpellInfo(20484);
VUHDO_SPELL_ID.REDEMPTION = GetSpellInfo(7328);
VUHDO_SPELL_ID.REGROWTH = GetSpellInfo(8936);
VUHDO_SPELL_ID.REJUVENATION = GetSpellInfo(774);
VUHDO_SPELL_ID.REMOVE_CURSE = GetSpellInfo(475);
VUHDO_SPELL_ID.REMOVE_CORRUPTION = GetSpellInfo(2782);
VUHDO_SPELL_ID.RENEW = GetSpellInfo(139);
VUHDO_SPELL_ID.RENEWED_HOPE = GetSpellInfo(57470);
VUHDO_SPELL_ID.RESURRECTION = GetSpellInfo(2006);
VUHDO_SPELL_ID.REVIVE = GetSpellInfo(50769);
VUHDO_SPELL_ID.RIPTIDE = GetSpellInfo(22419);
VUHDO_SPELL_ID.SHADOWFORM = GetSpellInfo(15473);
VUHDO_SPELL_ID.SPELLSTEAL = GetSpellInfo(30449);
VUHDO_SPELL_ID.SWIFTMEND = GetSpellInfo(18562);
VUHDO_SPELL_ID.TRANQUILITY = GetSpellInfo(740);
VUHDO_SPELL_ID.TREE_OF_LIFE = GetSpellInfo(65139);
VUHDO_SPELL_ID.WILD_GROWTH = GetSpellInfo(48438);
VUHDO_SPELL_ID.CYCLONE = GetSpellInfo(33786);
VUHDO_SPELL_ID.POWER_WORD_BARRIER = GetSpellInfo(62618);


------------------
-- Buff categories
------------------


-- Priest
VUHDO_SPELL_ID.BUFFC_FORTITUDE         = "01" .. GetSpellInfo(13864);
VUHDO_SPELL_ID.BUFFC_SHADOW_PROTECTION = "02" .. GetSpellInfo(7235);

VUHDO_SPELL_ID.BUFFC_FEAR_WARD         = "03" .. GetSpellInfo(6346);
VUHDO_SPELL_ID.BUFFC_INNER_FIRE        = "04" .. GetSpellInfo(588);
VUHDO_SPELL_ID.BUFFC_SHADOW_FIEND      = "05" .. GetSpellInfo(34433);
VUHDO_SPELL_ID.BUFFC_POWER_INFUSION    = "06" .. GetSpellInfo(10060);
VUHDO_SPELL_ID.BUFFC_VAMPIRIC_EMBRACE  = "07" .. GetSpellInfo(15286);
VUHDO_SPELL_ID.BUFFC_LEVITATE          = "08" .. GetSpellInfo(1706);
VUHDO_SPELL_ID.BUFFC_PAIN_SUPPRESSION  = "09" .. GetSpellInfo(33206);

-- Shaman
VUHDO_SPELL_ID.BUFFC_HEROISM           = "05" .. GetSpellInfo(32182);
VUHDO_SPELL_ID.BUFFC_BLOODLUST         = "06" .. GetSpellInfo(2825)
VUHDO_SPELL_ID.BUFFC_EARTH_SHIELD      = "07" .. GetSpellInfo(974);
VUHDO_SPELL_ID.BUFFC_MANA_TIDE_TOTEM   = "10" .. GetSpellInfo(16190);
VUHDO_SPELL_ID.BUFFC_TIDAL_FORCE       = "11" .. GetSpellInfo(55198);
VUHDO_SPELL_ID.BUFFC_NATURES_SWIFTNESS = "12" .. GetSpellInfo(16188);

-- Paladin
VUHDO_SPELL_ID.BUFFC_BEACON_OF_LIGHT = "04" .. GetSpellInfo(53563);
VUHDO_SPELL_ID.BUFFC_RIGHTEOUS_FURY  = "05" .. GetSpellInfo(25780);

-- Druid
VUHDO_SPELL_ID.BUFFC_MARK_OF_THE_WILD = "01" .. GetSpellInfo(1126);
VUHDO_SPELL_ID.BUFFC_THORNS           = "02" .. GetSpellInfo(467);

-- Warlock
VUHDO_SPELL_ID.BUFFC_DARK_INTENT = "02" .. GetSpellInfo(85767);
VUHDO_SPELL_ID.BUFFC_SOUL_LINK = "03" .. GetSpellInfo(19028);

-- Mage
VUHDO_SPELL_ID.BUFFC_ARCANE_BRILLIANCE = "01" .. GetSpellInfo(23030);
VUHDO_SPELL_ID.BUFFC_ICE_BLOCK         = "02" .. GetSpellInfo(45438);
VUHDO_SPELL_ID.BUFFC_FOCUS_MAGIC       = "04" .. GetSpellInfo(54646);
VUHDO_SPELL_ID.BUFFC_COMBUSTION        = "05" .. GetSpellInfo(11129);
VUHDO_SPELL_ID.BUFFC_SLOW_FALL         = "06" .. GetSpellInfo(130);

-- Death Knights
VUHDO_SPELL_ID.BUFFC_HORN_OF_WINTER = "01" .. GetSpellInfo(57330);
VUHDO_SPELL_ID.BUFFC_BONE_SHIELD    = "02" .. GetSpellInfo(49222);

-- Warriors
VUHDO_SPELL_ID.BUFFC_VIGILANCE = "02" .. GetSpellInfo(50720);

-- Hunter
VUHDO_SPELL_ID.BUFFC_TRUESHOT_AURA = "01" .. GetSpellInfo(19506);



--------
-- Buffs
--------


-- Priest
VUHDO_SPELL_ID.BUFF_POWER_WORD_FORTITUDE = GetSpellInfo(13864);

VUHDO_SPELL_ID.BUFF_SHADOW_PROTECTION = GetSpellInfo(7235);

VUHDO_SPELL_ID.BUFF_FEAR_WARD        = GetSpellInfo(6346);
VUHDO_SPELL_ID.BUFF_INNER_FIRE       = GetSpellInfo(588);
VUHDO_SPELL_ID.BUFF_INNER_WILL       = GetSpellInfo(73413);
VUHDO_SPELL_ID.BUFF_SHADOWFIEND      = GetSpellInfo(34433);
VUHDO_SPELL_ID.BUFF_POWER_INFUSION   = GetSpellInfo(10060);
VUHDO_SPELL_ID.BUFF_VAMPIRIC_EMBRACE = GetSpellInfo(15286);
VUHDO_SPELL_ID.BUFF_LEVITATE         = GetSpellInfo(1706);


-- Shaman
VUHDO_SPELL_ID.BUFF_FLAMETONGUE_TOTEM      = GetSpellInfo(8227);
VUHDO_SPELL_ID.BUFF_SEARING_TOTEM          = GetSpellInfo(3599);
VUHDO_SPELL_ID.BUFF_FIRE_ELEMENTAL_TOTEM   = GetSpellInfo(2894);
VUHDO_SPELL_ID.BUFF_MAGMA_TOTEM            = GetSpellInfo(8190);
VUHDO_SPELL_ID.BUFF_TOTEM_OF_WRATH         = GetSpellInfo(57658);

VUHDO_SPELL_ID.BUFF_GROUNDING_TOTEM         = GetSpellInfo(8177);
VUHDO_SPELL_ID.BUFF_WINDFURY_TOTEM          = GetSpellInfo(8512);
VUHDO_SPELL_ID.BUFF_WRATH_OF_AIR_TOTEM      = GetSpellInfo(3738);

VUHDO_SPELL_ID.BUFF_EARTHBIND_TOTEM         = GetSpellInfo(2484);
VUHDO_SPELL_ID.BUFF_STRENGTH_OF_EARTH_TOTEM = GetSpellInfo(8075);
VUHDO_SPELL_ID.BUFF_STONESKIN_TOTEM         = GetSpellInfo(8071);
VUHDO_SPELL_ID.BUFF_STONECLAW_TOTEM         = GetSpellInfo(5730);
VUHDO_SPELL_ID.BUFF_EARTH_ELEMENTAL_TOTEM   = GetSpellInfo(2062);
VUHDO_SPELL_ID.BUFF_TREMOR_TOTEM            = GetSpellInfo(8143);

VUHDO_SPELL_ID.BUFF_MANA_SPRING_TOTEM     = GetSpellInfo(5675);
VUHDO_SPELL_ID.BUFF_HEALING_STREAM_TOTEM  = GetSpellInfo(5394);
VUHDO_SPELL_ID.BUFF_TOTEM_OF_TRANQUIL_MIND = GetSpellInfo(87718);
VUHDO_SPELL_ID.BUFF_ELEMENTAL_RESISTANCE_TOTEM = GetSpellInfo(8184);
VUHDO_SPELL_ID.BUFF_MANA_TIDE_TOTEM = GetSpellInfo(16190);

VUHDO_SPELL_ID.BUFF_HEROISM = GetSpellInfo(32182);

VUHDO_SPELL_ID.BUFF_BLOODLUST = GetSpellInfo(2825);

VUHDO_SPELL_ID.BUFF_EARTH_SHIELD = GetSpellInfo(974);

VUHDO_SPELL_ID.BUFF_FLAMETONGUE_WEAPON = GetSpellInfo(8024);
VUHDO_SPELL_ID.BUFF_ROCKBITER_WEAPON   = GetSpellInfo(8017);
VUHDO_SPELL_ID.BUFF_FROSTBRAND_WEAPON  = GetSpellInfo(8033);
VUHDO_SPELL_ID.BUFF_WINDFURY_WEAPON    = GetSpellInfo(8232);
VUHDO_SPELL_ID.BUFF_EARTHLIVING_WEAPON = GetSpellInfo(51730);

VUHDO_SPELL_ID.BUFF_LIGHTNING_SHIELD = GetSpellInfo(324);
VUHDO_SPELL_ID.BUFF_WATER_SHIELD     = GetSpellInfo(52127);

VUHDO_SPELL_ID.BUFF_TIDAL_FORCE = GetSpellInfo(55198);

VUHDO_SPELL_ID.BUFF_NATURES_SWIFTNESS = GetSpellInfo(16188);


-- Paladin
VUHDO_SPELL_ID.BUFF_BLESSING_OF_MIGHT             = GetSpellInfo(19740);
VUHDO_SPELL_ID.BUFF_BLESSING_OF_THE_KINGS         = GetSpellInfo(20217);

VUHDO_SPELL_ID.BUFF_RIGHTEOUS_FURY = GetSpellInfo(25780);

VUHDO_SPELL_ID.BUFF_DEVOTION_AURA          = GetSpellInfo(465);
VUHDO_SPELL_ID.BUFF_RETRIBUTION_AURA       = GetSpellInfo(7294);
VUHDO_SPELL_ID.BUFF_CONCENTRATION_AURA     = GetSpellInfo(19746);
VUHDO_SPELL_ID.RESISTANCE_AURA             = GetSpellInfo(19726);
VUHDO_SPELL_ID.BUFF_CRUSADER_AURA          = GetSpellInfo(32223);

VUHDO_SPELL_ID.BUFF_SEAL_OF_JUSTICE       = GetSpellInfo(20164);
VUHDO_SPELL_ID.BUFF_SEAL_OF_INSIGHT       = GetSpellInfo(20165);
VUHDO_SPELL_ID.BUFF_SEAL_OF_TRUTH = GetSpellInfo(31801);
VUHDO_SPELL_ID.BUFF_SEAL_OF_RIGHTEOUSNESS = GetSpellInfo(20154);

VUHDO_SPELL_ID.BUFF_BEACON_OF_LIGHT = GetSpellInfo(53563);


-- Druid
VUHDO_SPELL_ID.BUFF_MARK_OF_THE_WILD = GetSpellInfo(1126);
VUHDO_SPELL_ID.BUFF_THORNS           = GetSpellInfo(467);


-- Warlock
VUHDO_SPELL_ID.BUFF_DEMON_ARMOR = GetSpellInfo(687);
VUHDO_SPELL_ID.BUFF_FEL_ARMOR = GetSpellInfo(28176);
VUHDO_SPELL_ID.BUFF_DARK_INTENT = GetSpellInfo(85767);
VUHDO_SPELL_ID.BUFF_SOUL_LINK = GetSpellInfo(19028);


-- Mage
VUHDO_SPELL_ID.BUFF_ARCANE_BRILLIANCE  = GetSpellInfo(1459);
VUHDO_SPELL_ID.BUFF_ARCANE_INTELLECT   = GetSpellInfo(1472);
VUHDO_SPELL_ID.BUFF_DALARAN_BRILLIANCE = GetSpellInfo(61316);
VUHDO_SPELL_ID.BUFF_ICE_BLOCK          = GetSpellInfo(45438);
VUHDO_SPELL_ID.BUFF_MOLTEN_ARMOR       = GetSpellInfo(30482);
VUHDO_SPELL_ID.BUFF_FROST_ARMOR        = GetSpellInfo(7302);
VUHDO_SPELL_ID.BUFF_ICE_ARMOR          = GetSpellInfo(1214);
VUHDO_SPELL_ID.BUFF_MAGE_ARMOR         = GetSpellInfo(6117);
VUHDO_SPELL_ID.BUFF_FOCUS_MAGIC        = GetSpellInfo(54646);
VUHDO_SPELL_ID.BUFF_COMBUSTION         = GetSpellInfo(11129);
VUHDO_SPELL_ID.BUFF_AMPLIFY_MAGIC      = GetSpellInfo(1267);
VUHDO_SPELL_ID.BUFF_DAMPEN_MAGIC       = GetSpellInfo(1266);
VUHDO_SPELL_ID.BUFF_SLOW_FALL          = GetSpellInfo(130);


-- Death Knight
VUHDO_SPELL_ID.BUFF_HORN_OF_WINTER  = GetSpellInfo(57330);
VUHDO_SPELL_ID.BUFF_BONE_SHIELD     = GetSpellInfo(49222);
VUHDO_SPELL_ID.BUFF_BLOOD_PRESENCE  = GetSpellInfo(48263);
VUHDO_SPELL_ID.BUFF_FROST_PRESENCE  = GetSpellInfo(48266);
VUHDO_SPELL_ID.BUFF_UNHOLY_PRESENCE = GetSpellInfo(48265);


-- Warrior
VUHDO_SPELL_ID.BUFF_BATTLE_SHOUT     = GetSpellInfo(6673);
VUHDO_SPELL_ID.BUFF_COMMANDING_SHOUT = GetSpellInfo(469);

VUHDO_SPELL_ID.BUFF_VIGILANCE = GetSpellInfo(50720);

-- Hunter
VUHDO_SPELL_ID.BUFF_TRUESHOT_AURA = GetSpellInfo(19506);

VUHDO_SPELL_ID.BUFF_ASPECT_OF_THE_HAWK = GetSpellInfo(13165);
VUHDO_SPELL_ID.BUFF_ASPECT_OF_THE_PACK = GetSpellInfo(13159);
VUHDO_SPELL_ID.BUFF_ASPECT_OF_THE_WILD = GetSpellInfo(20043);

----------
-- Debuffs
----------


VUHDO_SPELL_ID.DEBUFF_WEAKENED_SOUL = GetSpellInfo(6788);
VUHDO_SPELL_ID.DEBUFF_FROST_BLAST = GetSpellInfo(27808);
VUHDO_SPELL_ID.DEBUFF_ANCIENT_HYSTERIA = GetSpellInfo(19372);
VUHDO_SPELL_ID.DEBUFF_IGNITE_MANA = GetSpellInfo(19659);
VUHDO_SPELL_ID.DEBUFF_TAINTED_MIND = GetSpellInfo(16567);
VUHDO_SPELL_ID.DEBUFF_VIPER_STING = GetSpellInfo(67991);
VUHDO_SPELL_ID.DEBUFF_SILENCE = GetSpellInfo(30225);
VUHDO_SPELL_ID.DEBUFF_MAGMA_SHACKLES = GetSpellInfo(19496);
VUHDO_SPELL_ID.DEBUFF_FROSTBOLT = GetSpellInfo(116);
VUHDO_SPELL_ID.DEBUFF_PSYCHIC_HORROR = GetSpellInfo(64044);
VUHDO_SPELL_ID.DEBUFF_HUNTERS_MARK = GetSpellInfo(1130);
VUHDO_SPELL_ID.DEBUFF_SLOW = GetSpellInfo(31589);
VUHDO_SPELL_ID.DEBUFF_ARCANE_BLAST = GetSpellInfo(30451);
VUHDO_SPELL_ID.DEBUFF_IMPOTENCE = GetSpellInfo(51340);
VUHDO_SPELL_ID.DEBUFF_DECAYED_STR = GetSpellInfo(35760);
VUHDO_SPELL_ID.DEBUFF_DECAYED_INT = GetSpellInfo(31555);
VUHDO_SPELL_ID.DEBUFF_CRIPPLE = GetSpellInfo(18381);
VUHDO_SPELL_ID.DEBUFF_CHILLED = GetSpellInfo(12484);
VUHDO_SPELL_ID.DEBUFF_CONEOFCOLD = GetSpellInfo(120);
VUHDO_SPELL_ID.DEBUFF_CONCUSSIVESHOT = GetSpellInfo(5116);
VUHDO_SPELL_ID.DEBUFF_THUNDERCLAP = GetSpellInfo(8147);
VUHDO_SPELL_ID.DEBUFF_DAZED = GetSpellInfo(1604);
VUHDO_SPELL_ID.DEBUFF_FALTER = GetSpellInfo(32859);
VUHDO_SPELL_ID.DEBUFF_UNSTABLE_AFFL = GetSpellInfo(30108);
VUHDO_SPELL_ID.DEBUFF_DREAMLESS_SLEEP = GetSpellInfo(15822);
VUHDO_SPELL_ID.DEBUFF_GREATER_DREAMLESS = GetSpellInfo(24360);
VUHDO_SPELL_ID.DEBUFF_MAJOR_DREAMLESS = GetSpellInfo(28504);
VUHDO_SPELL_ID.DEBUFF_FROST_SHOCK = GetSpellInfo(46180);
VUHDO_SPELL_ID.DEBUFF_DELUSIONS_OF_JINDO = GetSpellInfo(24306);
VUHDO_SPELL_ID.DEBUFF_MIND_VISION = GetSpellInfo(2096);
VUHDO_SPELL_ID.DEBUFF_MUTATING_INJECTION = GetSpellInfo(28169);
VUHDO_SPELL_ID.DEBUFF_BANISH = GetSpellInfo(8994);
VUHDO_SPELL_ID.DEBUFF_PHASE_SHIFT = GetSpellInfo(8611);
