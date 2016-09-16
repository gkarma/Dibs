script "_loginCreateBV"
global gUserDataA

private command ____FUNNEL
end ____FUNNEL
on mouseUp
     switch the label of the target
          case "Login" --if the user is trying to log in
               logMeIn
               break
          case "Next" --if the user is trying to create an account but still has next step
               letsGoNext
               break
          case "Create An Account" --if the user is trying to create an account
               createAnAccount
               break
     end switch
end mouseUp

private command ____LOGIN
end ____LOGIN
command logMeIn
     local tInputA, tTableID, tDataA
     
     --Check if an account already exists with the given email AND passoword
     put cdb_getTableID("accounts") into tTableID
     put "email" into tInputA["batchQuery"][tTableID][1]["key"]
     put fld "Email-input" into tInputA["batchQuery"][tTableID][1]["value"]
     put "=" into tInputA["batchQuery"][tTableID][1]["operator"]
     put "password" into tInputA["batchQuery"][tTableID][2]["key"]
     put fld "Password-input" into tInputA["batchQuery"][tTableID][2]["value"]
     put "=" into tInputA["batchQuery"][tTableID][2]["operator"]
     put "logicalAND" into tInputA["settings"]["mode"]
     put cdb_BatchQueryLocal(tInputA) into tDataA
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if
     
     --if there is no account that has that email AND password, then Incorrent email/password
     if tDataA[tTableID][1] is empty then
          set the visible of fld "Error Message" to true
     else  --if an account does exist, then that is the user trying to log in!
          set the visible of fld "Error Message" to false
          
          --if an account does exist then
          put tDataA[tTableID][1] into gUserDataA["cdbRecordID"]
          
          --initialize the profile page's fields
          dispatch "initializeProfilePage" to stack "_profileModificationsBV"
          go to cd "Profile Page"
     end if
end logMeIn


private command ____NEXT
end ____NEXT
command letsGoNext
   local tQueryA, tInputA
   
   --set the error messages to invisible
   set the visible of fld "Error Message" to false
   
   --If any fields are empty
   if fld "First Name-input" is empty or fld "Last Name-input" is empty or fld "Email-input" is empty or fld "Password-input" is empty then
      put "You did not provide all the requred information." into fld "Error Message"
      set the visible of fld "Error Message" to true
      exit "letsGoNext"
   end if
   
   --Query for the email that the user is trying to create an account with
   put "accounts" into tQueryA["cdbTableName"]
   put "email" into tQueryA["query"]["key"]
   put fld "Email-input" into tQueryA["query"]["value"]
   put "=" into tQueryA["query"]["operator"]
   get cdb_QueryLocal(tQueryA)
   
   --if an account already exists with that email, then nope
   if it is not empty then
      put "An account has already been created with this email." into fld "Error Message"
      set the visible of fld "Error Message" to true
   else --if that email doesnt already exist with an account, then good to go
        go to card "Create An Account Two"
   end if
end letsGoNext


private command ____CREATE_AN_ACCOUNT
end ____CREATE_AN_ACCOUNT
command createAnAccount
     local tInputA, tRecordID
     
     --Create user account based on their information
     put "accounts" into tInputA["cdbTableName"]
     put fld "First Name-input" of cd "Create An Account" && fld "Last Name-input" of cd "Create An Account" into tInputA["name"]
     put fld "Email-input" of cd "Create An Account" into tInputA["email"]
     put fld "Password-input" of cd "Create An Account" into tInputA["password"]
     put the label of btn "Age-button" into tInputA["age"]
     put the label of btn "Gender-button" into tInputA["gender"]
     put the label of btn "Seeking-button" into tInputA["seeking"]
     put cdb_createLocal(tInputA) into gUserDataA["cdbRecordID"]
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if
     
     --initialize the profile page's fields
     dispatch "initializeProfilePage" to stack "_profileModificationsBV"
     
     go to cd "Profile Page"
end createAnAccount
