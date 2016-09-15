script "_navigationBV"
on hiliteChanged
   switch the hilitedItem of the target
      case 1
         go to cd "Profile Page"
         break
      case 2
         go to cd "Dibs List"
         break
      case 3
         go to cd "Search"
         break
      case 4
         go to cd "Matches"
         break
      case 5
         go to cd "Settings"
         break
   end switch
end hiliteChanged
