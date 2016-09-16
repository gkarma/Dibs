script "_searchProfilesBV"
global gUserDataA

private command ____FUNNEL
end ____FUNNEL
on mouseUp
   switch the label of the target
      case "Search"
         searchUsers
         break
      case "List All"
         listAllUsers
         break
   end switch
end mouseUp

private command ____SEARCH
end ____SEARCH
command searchUsers
   local tKey, tInputA, tOutputA
   
   if fld "Search Field" is empty then exit "searchUsers"
   
   --put empty into all fields
   put empty into fld "Results"
   put empty into fld "recordIDs"
   
   --query for accounts whose key tKey matches the value being searched
   put "accounts" into tInputA["cdbTableName"]
   put "name" into tInputA["query"]["key"]
   put "~" into tInputA["query"]["operator"]
   put fld "Search Field" into tInputA["query"]["value"]
   put "recordData" into tInputA["resultFormat"]
   put cdb_QueryLocal(tInputA) into tOutputA
   if not cdb_result() then 
      put "Error:" && cdb_result("response")
      breakpoint--*****
   end if
   
   --iterate through the search results and printing them as results, but making sure "seeking" and gSeeking match
   repeat for each key xKey in tOutputA
      if gUserDataA["seeking"] is tOutputA[xKey]["gender"] and gUserDataA["cdbRecordID"] is not tOutputA[xKey]["cdb"]["cdbRecordID"] then
         put tOutputA[xKey]["name"] & lf after fld "Results"
         put xKey & lf after fld "recordIDs"
      end if
   end repeat
   
   delete the last char of fld "Results"
end searchUsers

private command ____LISTALL
end ____LISTALL
command listAllUsers
   local tInputA, tOutputA
   
   put empty into fld "Results"
   put empty into fld "recordIDs"
   
   --GET ALL RECORD'S DATA BY QUERYING FOR EMPTY != ANY KEY, SHOULD RETURN ALL RECORDS
   put "accounts" into tInputA["cdbTableName"]
   put "age" into tInputA["query"]["key"]
   put "!=" into tInputA["query"]["operator"]
   put empty into tInputA["query"]["value"]
   put "recordData" into tInputA["resultFormat"]
   put cdb_QueryLocal(tInputA) into tOutputA
   if not cdb_result() then 
      put "Error:" && cdb_result("response")
      breakpoint--*****
   end if
   
   --PUT THE LAST, FIRST NAME OF RETURNED RECORDS ONTO THE RESULTS FIELD
   repeat for each key xKey in tOutputA
      if gUserDataA["seeking"] is tOutputA[xKey]["gender"] and gUserDataA["cdbRecordID"] is not tOutputA[xKey]["cdb"]["cdbRecordID"] then
         put tOutputA[xKey]["name"] & lf after fld "Results"
         put xKey & lf after fld "recordIDs"
      end if
   end repeat
   
   delete the last char of fld "Results"
end listAllUsers
