local compostHeaps = {}
Buffalo3.GetCompost = function()
   table.insert(compostHeaps, setmetatable({}, {__mode='k'}))
   local compostNumber = #compostHeaps
   local thisCompost = compostHeaps[compostNumber]
   local get = function()
      local object = next(thisCompost)
      if object then
         thisCompost[object] = nil
      end
      return object
   end
   local deposit = function(object)
      assert(object, "Can't compost nil object")
      thisCompost[object] = true
   end
   return get, deposit
end
