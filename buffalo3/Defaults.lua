local L = LibStub("AceLocale-3.0"):GetLocale("Buffalo3")

local defaults = {
   profile = {
      disableBlizzardBuffs = true,
      containers = {
         ["**"] = {
            buttonScale = 1.0,
            xPadding = 5,
            yPadding = 10,
            columns = 8,
            growLeft = true,
            growUpwards = nil,
            showTimer = true,
            flashWarning = true,
            growHorizontalFirst = true,
            sortBy = "byTime",
            anchor = {
               point = "TOPRIGHT",
               relativePoint = "TOPRIGHT",
               relativeTo = "UIParent",
               xOffset = -200,
               yOffset = -200,
            },
            style = {
            },
         },
         playerBuffs = {
            name = L["Player Buffs"],
            unitIDs = {player = true},
            filter = {HELPFUL = true},
            color = {r = 0.2, g = 0.8, b = 0.2, a = 0.6},
            enabled = false,
         },
         weapons = {
            name = L["Weapon Buffs"],
            unitIDs = {mainhand = true, offhand = true},
            filter = {WEAPONS = true},
            color = {r = 0.8, g = 0.2, b = 0.8, a = 0.6},
            enabled = false,
         },
         playerBuffsAndWeapons = {
            name = L["Player Buffs and Weapon Buffs"],
            unitIDs = {player = true, mainhand = true, offhand = true},
            filter = {HELPFUL = true, WEAPONS = true},
            color = {r = 0.2, g = 0.8, b = 0.2, a = 0.6},
            enabled = true,
         },
         playerDebuffs = {
            name = L["Player Debuffs"],
            unitIDs = {player = true},
            filter = {HARMFUL = true},
            color = {r = 0.8, g = 0.2, b = 0.2, a = 0.6},
            enabled = true,
            locked = true,
            anchor = {
               point = "TOPRIGHT",
               relativeTo = "Buffalo3_Container_playerBuffsAndWeapons",
               relativePoint = "BOTTOMRIGHT",
               xOffset = 0,
               yOffset = -20,
            },
         },
      },
   },
}

Buffalo3.defaultOptions = defaults