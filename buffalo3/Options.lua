local L = LibStub("AceLocale-3.0"):GetLocale("Buffalo3")

Buffalo3.GetOptionsTable = function()
   local self = Buffalo3
   local options = self.options
   if not options then
      options = {
         type = "group",
         childGroups = "tree",
         args = {
            options = {
               name = L["Options"],
               desc = L["General settings"],
               type = "group",
               order = 10,
               args = {
                  reference = {
                     type = "execute",
                     name = L["Toggle Reference"],
                     desc = L["Toggle reference frames for all buff containers"],
                     order = 0,
                     func = function(info)
                        if not Buffalo3.showingReference then
                           Buffalo3:ShowReference()
                        else
                           Buffalo3:HideReference()
                        end
                     end,
                  },
                  blizzard = {
                     type = "toggle",
                     name = L["Hide Default Blizzard Buffs"],
                     order = 10,
                     get = function(info) return Buffalo3.db.profile.disableBlizzardBuffs end,
                     set = function(info, value)
                        if value then
                           Buffalo3:DisableBlizzardBuffs()
                        else
                           Buffalo3:EnableBlizzardBuffs()
                        end
                     end,
                  },
               },
            },
            containers = {
               type = "group",
               name = L["Containers"],
               desc = "",
               childGroups = "tree",
               args = {
               },
            },
         },
      }
      self.options = options
   end
   local containerOptions = options.args.containers.args
   for name, containerSV in pairs(self.db.profile.containers) do
      if containerSV.enabled then
         containerOptions[name] = Buffalo3.containers[name]:GetOptions()
         containerOptions[name].name = containerSV.name
         containerOptions[name].args.enable = {
            type = "toggle",
            name = L["Enable"],
            desc = L["Enable this container"],
            order = 0,
            set = function(info, value) 
               if value then
                  Buffalo3:EnableContainer(name)
               else
                  Buffalo3:DisableContainer(name)
               end
            end,
            get = function(info) 
               return containerSV.enabled
            end,
         }
      else
         containerOptions[name] = {
            type = "group",
            name = containerSV.name,
            args = {
               enable = {
                  type = "toggle",
                  name = L["Enable"],
                  desc = L["Enable this container"],
                  order = 0,
                  set = function(info, value) 
                     if value then
                        Buffalo3:EnableContainer(name)
                     else
                        Buffalo3:DisableContainer(name)
                     end
                  end,
                  get = function(info) 
                     return containerSV.enabled
                  end,
               },
            },
         }
      end
   end
   options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Buffalo3.db)
   return options
end
