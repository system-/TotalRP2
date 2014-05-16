-------------------------------------------------------------------
--      Total RP 2 Module
--		Bookworm
--      Save readable items into Total RP 2
-- 		Created by Ellypse
--   	Licence : CC BY-NC-SA (http://creativecommons.org/licenses/)
-------------------------------------------------------------------

-- Creating a dummy frame to register an event
local frame = CreateFrame("FRAME", "TRP2_Bookworm");

-- Registering event for when a readable item is open
frame:RegisterEvent("ITEM_TEXT_BEGIN");
frame:RegisterEvent("ITEM_TEXT_CLOSED");

local function eventHandler(self, event, ...)

	-- If the item is open, show the button, else close it
	if event=="ITEM_TEXT_BEGIN" then
		if not documentAlreadyExists(ItemTextGetItem()) then
		 	TRP2_BookwormButton:Show();
		 else
		 	TRP2_BookwormButtonEmpty:Show();
		 end
	else
		 TRP2_BookwormButton:Hide();
		 TRP2_BookwormButtonEmpty:Hide();
	end
end

frame:SetScript("OnEvent", eventHandler);

function TRP2_Bookworm_createBook()

	local docId = TRP2_CreateNewEmpty("Document");
	local docTitle = ItemTextGetItem();

	-- Open the document creation interface for a new document
	TRP2_CreationPanel("Document",nil,docId);

	-- Set the name of the document to be the name of the readable object
	TRP2_CreationFrameDocumentFrameMenuTitre:SetText(docTitle);
	
	-- Using a book icon
	-- TODO : Use a plaque icon for plaques
	TRP2_CreationFrameDocumentFrameMenuIcone.icone = "INV_Misc_Book_03";

	-- Adding the first page
	TRP2_Bookworm_addPage();

	-- If there is a next page go to it and add it
	while ItemTextHasNextPage() do
		ItemTextNextPage();
		TRP2_Bookworm_addPage();
	end

	-- Go back to the first page of the document (comfortability for the player)
	while ItemTextGetPage()>1 do
		ItemTextPrevPage()
	end

	-- Save the document created
	TRP2_CreationFrameDocumentFrameMenuSave:Click("LeftButton");

	-- Close the creation interface (no longer needed)
	TRP2_CreationFrame:Hide();

	TRP2_Bookworm_createItem(docTitle,docId);

end

function TRP2_Bookworm_addPage()

	-- TODO use a different background based on the type of the readable item (plaques)

	-- Create a new empty page
	TRP2_CreaDocuChargerPage("Page"..TRP2_FoundFreePlace(TRP2_CreationFrameDocument.PageTab,"Page",3));

	-- Getting the text of the current page
	local text = ItemTextGetText();

	-- Books in WoW sometimes have an "unbreakable" space.
	-- As documents are rendered in HTML, those spaces are messing with the formating,
	-- So we are removing them to use a standard space.
	text = string.gsub(text," "," ");

	-- Set the text of the document to be that text
	TRP2_CreationFrameDocumentFramePageMainTexteScrollEditBox:SetText(text);

	-- Save dat page !
	TRP2_CreationFrameDocumentFramePageMainSave:Click("LeftButton");

end

function TRP2_Bookworm_createItem(itemTitle, documentId)

	local itemId = TRP2_CreateNewEmpty("Item");

	-- Open the creation frame
	TRP2_CreationPanel("Objet",nil,itemId);

	-- Set attributes
	TRP2_CreationFrameObjetFrameGeneralNom:SetText(itemTitle);

	-- This is really bad, but until I fully localized the addon, it will do the job :P
	local language = GetLocale();
	if(language == "frFR") then
		TRP2_CreationFrameObjetFrameGeneralCategorie:SetText("Livre");
	elseif (language == "esES") then
		TRP2_CreationFrameObjetFrameGeneralCategorie:SetText("Libro");
	else
		TRP2_CreationFrameObjetFrameGeneralCategorie:SetText("Book");
	end

	TRP2_CreationFrameObjetFrameGeneralQualite:SetValue(2);
	TRP2_CreationFrameObjetFrameGeneralIcone.icone = "INV_Misc_Book_03";
	TRP2_CreationFrameObjetFrameFlagsUsable:SetChecked("bUtilisable");
	if(language == "frFR") then
		TRP2_CreationFrameObjetFrameUtilisationTooltip:SetText("Lire le livre");
	elseif (language == "esES") then
		TRP2_CreationFrameObjetFrameUtilisationTooltip:SetText("Abrir el libro.");
	else
	TRP2_CreationFrameObjetFrameUtilisationTooltip:SetText("Read the book.");
	end
	TRP2_CreationFrameObjetFrameTriggerOnUseEnd.Effets = "docu$"..documentId..";son$Sound\\\\Interface\\\\Iabilitiesturnpagea.wav$1$0;";
	TRP2_CreationFrameObjetFrameTriggerOnReceive.Effets = "son$Sound\\\\Interface\\\\Pickup\\\\Putdownbook.wav$1$0;"

	-- Save and close
	TRP2_CreationFrameObjetFrameMenuSave:Click("LeftButton");
	TRP2_CreationFrame:Hide();

	-- Add to the bag
	TRP2_InvAddObjet(itemId);
	TRP2_ShowSac();

end

function  documentAlreadyExists(documentName)
	local documentFound = false;
	table.foreach(TRP2_Module_Documents,function(ID)
		if TRP2_GetWithDefaut(TRP2_Module_Documents[ID],"Nom","") == documentName then
			documentFound = true;
		end
	end);
	return documentFound;
end
