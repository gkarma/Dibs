script "goToPrevCardBV"
on mouseUp
   local tActionName
   put the mouseAction of me into tActionName
   if tActionName is "back" then
      go to the previous card
   end if
end mouseUp
