script "addRemoveBV"
global gUserDataA, gAddLine

private command ____FUNNEL
end ____FUNNEL
on mouseUp
   switch the label of the target
      case "Add-button"
         addPerson
         break
      case "Remove-button"
         removePerson
         break
   end switch
end mouseUp

private command ____REMOVE
end ____REMOVE
command removePerson
     local tInputA, tDataA, tLine, tTableID, tMyMatches, tYourMatches
     local tMyID, tYourID, tLine1, tLine2
     lock screen
     
     --use variables for better code readability
     put the hilitedLine of fld "Name List" of cd "Dibs List" into tLine
     if tLine is empty then exit "removePerson"
     put gUserDataA["cdbRecordID"] into tMyID
     put line tLine of fld "RecordID List" of cd "Dibs List" of stack "Dibs" into tYourID
     put gUserDataA["matches"] into tMyMatches
     
     --DELETE LINES OF FIELDS AND gUserDataA's DIBS LIST
     delete line tLine of gUserDataA["dibs"]
     delete line tLine of fld "Name List" of cd "Dibs List" of stack "Dibs"
     delete line tLine of fld "RecordID List" of cd "Dibs List" 
     
     --Look up user being removed's matches
     put "accounts" into tInputA["cdbTableName"]
     put tYourID into tInputA["cdbRecordID"]
     put "matches" into tInputA["key"]
     put cdb_lookupLocalValue(tInputA) into tYourMatches
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if
     
     --The line where tYourID exists on tMyID's matches list and vice versa, if it exists
     put lineOffset(tMyID,tYourMatches) into tLine2
     put lineOffset(tYourID,tMyMatches) into tLine1
     
     --IF THE REMOVED PERSON WAS A MATCH, THEN REMOVE PERSON FROM MATCHES LIST AND DIBS LIST
     if tLine1 > 0 and tLine2 > 0 then
          delete line tLine1 of tMyMatches
          delete line tLine2 of tYourMatches
          delete line tLine1 of gUserDataA["matches"]
          
          --BATCH UPDATE
          put empty into tInputA
          put cdb_getTableID("accounts") into tTableID
          put tMyID into tInputA[tTableID][1]["cdbRecordID"]
          put tYourID into tInputA[tTableID][2]["cdbRecordID"]
          put tMyMatches into tInputA[tTableID][1]["matches"]
          put tYourMatches into tInputA[tTableID][2]["matches"]
          put gUserDataA["dibs"] into tInputA[tTableID][1]["dibs"]
          cdb_batchUpdateLocal(tInputA)
          if not cdb_result() then 
               put "Error:" && cdb_result("response")
               breakpoint--*****
          end if
          
     else --IF THE REMOVED PERSON IS ONLY ON THE DIBS LIST, THEN REMOVE PERSON FROM DIBS LIST ONLY
          put empty into tInputA
          put "accounts" into tInputA["cdbTableName"]
          put tMyID into tInputA["cdbRecordID"]
          put gUserDataA["dibs"] into tInputA["dibs"]
          cdb_updateLocal tInputA
          if not cdb_result() then 
               put "Error:" && cdb_result("response")
               breakpoint--*****
          end if
     end if
     
     unlock screen
end removePerson


private command ____ADD
end ____ADD
command addPerson
     local tInputA, tDataA, tTableID
     local tMyID, tYourID, tMyName, tYourName
     
     lock screen
     
     --User variables to better code readability
     put gUserDataA["cdbRecordID"] into tMyID
     put line gAddLine of fld "recordIDs" of cd "Search" into tYourID
     put gUserDataA["name"] into tMyName
     put line gAddLine of fld "Results" of cd "Search" into tYourName
     
     --Update gUserDataA's dibs list
     put tYourID && tYourName & lf after gUserDataA["dibs"]
     
     --Read tYourID's record to get their dibs/matches lists
     put empty into tInputA
     put "accounts" into tInputA["cdbTableName"]
     put tYourID into tInputA["cdbRecordID"]
     put cdb_readLocal(tInputA) into tDataA
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if
     
     --If I am already on tYourID's dibs list, then its a match!
     if tMyID is in tDataA["dibs"] then 
          answer "That's a match!"
          
          --Update gUserDataA's matches list
          put tYourID && tYourName & lf after gUserDataA["matches"]
          
          --BatchUpdate tMyID and tYourID's matches list and update tMyIDs dibs list
          put empty into tInputA
          put cdb_getTableID("accounts") into tTableID
          put tMyID into tInputA[tTableID][1]["cdbRecordID"]
          put tYourID into tInputA[tTableID][2]["cdbRecordID"]
          put tDataA["matches"] & tMyID && tMyName & lf after tInputA[tTableID][2]["matches"]
          put gUserDataA["matches"] after tInputA[tTableID][1]["matches"]
          put gUserDataA["dibs"] into tInputA[tTableID][1]["dibs"]
          cdb_batchUpdateLocal(tInputA)
          if not cdb_result() then 
               put "Error:" && cdb_result("response")
               breakpoint--*****
          end if
          
          --Display that you and tYourID are matched
          put "You and " & tDataA["name"] & " are matched!" into fld "Message" of cd "Friend Profile" of stack "Dibs" 
          set the visible of btn "Add-button" of cd "Friend Profile" of stack "Dibs" to false
          set the visible of fld "Message" of cd "Friend Profile" of stack "Dibs" to true
     else
          --Display message that tYourID is on your dibs list
          put tDataA["name"] & " is on your Dibs List!" into fld "Message" of cd "Friend Profile" of stack "Dibs" 
          set the vis of btn "Add-button" of cd "Friend Profile" of stack "Dibs" to false
          set the visible of fld "Message" of cd "Friend Profile" of stack "Dibs" to true
          
          --Since it was not a match, just update tMyID's dibs list
          put empty into tInputA
          put "accounts" into tInputA["cdbTableName"]
          put tMyID into tInputA["cdbRecordID"]
          put gUserDataA["dibs"] into tInputA["dibs"]
          cdb_updateLocal tInputA
          if not cdb_result() then 
               put "Error:" && cdb_result("response")
               breakpoint--*****
          end if
     end if
     unlock screen
end addPerson
