script "_profileModificationsBV"
global gUserDataA

private command ____FUNNEL
end ____FUNNEL
on mouseUp   
   switch the label of the target
      case "Edit Profile"
         editProfile
         break
      case "Save"
         saveProfileChanges
         break
      case "Cancel"
         cancelProfileChanges
         break
      case "Upload a new photo"
         uploadNewPhoto
         break
      case "Remove photo"
         removePhoto
         break
   end switch
end mouseUp


private command ____EDIT_SAVE_CANCEL
end ____EDIT_SAVE_CANCEL
command editProfile --WHEN THE EDIT PROFILE BUTTON IS PRESSED
     lock screen
     --set labels to invisible and set field edit's to visible
     put word 1 of fld "Name-label" into fld "FirstName-input"
     put word 2 of fld "Name-label" into fld "LastName-input"
     put fld "Email-label" into fld "Email-input"
     put fld "Bio-label" into fld "Bio-input"
     set the visible of btn "Edit-button" to false
     set the visible of fld "Name-label" to false
     set the visible of fld "Email-label" to false
     set the visible of fld "Bio-label" to false
     set the visible of fld "FirstName-input" to true
     set the visible of fld "LastName-input" to true
     set the visible of fld "Bio-input" to true
     set the visible of fld "Email-input" to true
     set the visible of btn "Save-button" to true
     set the visible of btn "Cancel-button" to true
     unlock screen
end editProfile

command saveProfileChanges --WHEN THE SAVE BUTTON IS PRESSED
     local tInputA, tDataA
     lock screen
     
     --Query if the updated email already exists in another account
     put "accounts" into tInputA["cdbTableName"]
     put "=" into tInputA["query"]["operator"]
     put fld "Email-input" into tInputA["query"]["value"]
     put "email" into tInputA["query"]["key"]
     put cdb_QueryLocal(tInputA) into tDataA
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if
     
     --If an account already exists with this email, then exit
     if tDataA is not empty and gUserDataA["cdbRecordID"] is not line 1 of tDataA then
          answer "An account already exists with this email."
          exit "saveProfileChanges"
     end if
     
     put empty into tInputA
     
     --set the field edits to invisible and set the labels to visible
     set the visible of btn "Edit-button" to true
     set the visible of fld "FirstName-input" to false
     set the visible of fld "LastName-input" to false
     set the visible of fld "Email-input" to false
     set the visible of fld "Bio-input" to false
     set the visible of btn "Save-button" to false
     set the visible of btn "Cancel-button" to false
     set the visible of fld "Name-label" to true
     set the visible of fld "Email-label" to true
     set the visible of fld "Bio-label" to true
     
     --Update Local on new information
     put "accounts" into tInputA["cdbTableName"]
     put gUserDataA["cdbRecordID"] into tInputA["cdbRecordID"]
     if word 1 of fld "Name-label" <> fld "FirstName-input" or word 2 of fld "Name-label" <> fld "LastName-input" then
          put fld "FirstName-input" && fld "LastName-input" into tInputA["name"]
          put fld "FirstName-input" & " " & fld "LastName-input" into fld "Name-label"
     end if
     if fld "Email-label" <> fld "Email-input" then 
          put fld "Email-input" into tInputA["email"]
          put fld "Email-input" into fld "Email-label"
     end if
     if fld "Bio-label" <> fld "Bio-input" then 
          put fld "Bio-input" into tInputA["bio"]
          put fld "Bio-input" into fld "Bio-label"
     end if
     if the num of lines of keys of tInputA is 2 then exit "saveProfileChanges"
     cdb_updateLocal(tInputA)
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if   
     unlock screen
end saveProfileChanges


command cancelProfileChanges --WHEN THE CANCEL BUTTON IS PRESSED
   lock screen
     --set the field edits to invisible and set the labels to visible
     set the visible of btn "Edit-button" to true
     set the visible of fld "FirstName-input" to false
     set the visible of fld "LastName-input" to false
     set the visible of fld "Email-input" to false
     set the visible of fld "Bio-input" to false
     set the visible of btn "Save-button" to false
     set the visible of btn "Cancel-button" to false
     set the visible of fld "Name-label" to true
     set the visible of fld "Email-label" to true
     set the visible of fld "Bio-label" to true
     unlock screen
end cancelProfileChanges


private command ____UPLOAD_REMOVE_PHOTO
end ____UPLOAD_REMOVE_PHOTO
command uploadNewPhoto --WHEN THE UPLOAD A NEW PHOTO BUTTON IS PRESSED
     local tInputA, ina, tContent, tRatio
     answer file "Choose an image to upload..."
     if it is empty then
          exit "uploadNewPhoto"
     end if
     set the disabled of btn "Remove" to false
     set the visible of graphic "Rectangle" to false
     set the visible of img "camera.png" to false
     if exists(img "profPic") then
          delete img "profPic"
     end if
     put URL ("binfile://" & it) into tContent
     create img "profPic"
     put tContent into img "profPic"
     set the rect of img "profPic" to the rect of graphic "Rectangle"
     put the formattedWidth of img "profPic" / the formattedHeight of img "profPic" into tRatio
     set the width of img "profPic" to the width of graphic "Rectangle"
     set the height of img "profPic" to (the width of img "profPic" / (tRatio))     put "accounts" into tInputA["cdbTableName"]
     put gUserDataA["cdbRecordID"] into tInputA["cdbRecordID"]
     put tContent into tInputA["content"]
     cdb_updateLocal(tInputA)
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if
end uploadNewPhoto


command removePhoto --WHEN THE REMOVE PHOTO BUTTON IS PRESSED
     local tInputA
     delete img "profPic"      
     set the disabled of btn "Remove" to true
     set the visible of graphic "Rectangle" to true
     set the visible of img "camera.png" to true
     put "accounts" into tInputA["cdbTableName"]
     put gUserDataA["cdbRecordID"] into tInputA["cdbRecordID"]
     put empty into tInputA["content"]
     cdb_updateLocal tInputA
end removePhoto


private command ____INIT_PROFILE_PAGE
end ____INIT_PROFILE_PAGE
command initializeProfilePage -- GETS CALLED WHEN EITHER LOGGING IN OR CREATING AN ACCOUNT
     local tInputA
     
     --read the logging in user to display the account details on profiel page
     put "accounts" into tInputA["cdbTableName"]
     put gUserDataA["cdbRecordID"] into tInputA["cdbRecordID"]
     put cdb_readLocal(tInputA) into gUserDataA
     if not cdb_result() then 
          put "Error:" && cdb_result("response")
          breakpoint--*****
     end if
     
     --put the read data into the profile page's fields
     put gUserDataA["name"] into fld "Name-label" of cd "Profile Page" of stack "Dibs"
     put gUserDataA["email"] into fld "Email-label" of cd "Profile Page" of stack "Dibs"
     put gUserDataA["age"] into fld "Age-label" of cd "Profile Page" of stack "Dibs"
     if gUserDataA["bio"] is empty then --use default bio if none
          put "Click Edit Profile to create your Bio" into fld "Bio-label" of cd "Profile Page" of stack "Dibs"
     else
          put gUserDataA["bio"] into fld "Bio-label" of cd "Profile Page" of stack "Dibs"
     end if 
     if gUserDataA["content"] is not empty then --if they have a picture
          dispatch "dispalyImage" to btn "Upload-button" of cd "Profile Page" of stack "Dibs" with gUserDataA["content"]
     else --if they don't have a picture, then display the camera.png
          if exists(img "profPic") then delete img "profPic"
          set the disabled of btn "Remove-button" of cd "Profile Page" of stack "Dibs" to true
          set the visible of graphic "Rectangle" of cd "Profile Page" of stack "Dibs" to true
          set the visible of img "camera.png" of cd "Profile Page" of stack "Dibs" to true
     end if
     
     --empty out search fields
     put empty into fld "Search Field" of cd "Search" of stack "Dibs"
     put empty into fld "Results" of cd "Search" of stack "Dibs"
     
     set the hilitedItem of widget "Navigation Bar" of grp "nav group"  of cd "Profile Page" of stack "Dibs" to 1
end initializeProfilePage
