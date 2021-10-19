local AceGUI = LibStub("AceGUI-3.0")
local Acedb = LibStub("AceDB-3.0")

-- declare defaults to be used in the DB
-- local defaults = {
--     profile = {
--         rules = "",
--     }
-- }

-- function MyAddon:OnInitialize()
--     self.db = LibStub("AceDB-3.0"):New("RSdb", defaults, true)
-- end


local addon = {}

function addon.chat(str_in)
    print("\124c00FF0000  "..str_in.."\124r");
end

function addon.makeWindow()
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
    f:SetTitle("RulesSeparator")
    -- f:SetStatusText("por Luis Pastén con amor pal pueblo")
    f:SetLayout("Flow")

    -- INPUT
    local input = AceGUI:Create("MultiLineEditBox")
    input:SetLabel("Ingresa las reglas aqui")
    input:SetNumLines(20)
    input:SetFullWidth("isFull") 
    input:DisableButton("disabled")

    -- SAVE BUTTON
    local btn = AceGUI:Create("Button")
    btn:SetFullWidth("isFull") 
    btn:SetText("Guardar")
    btn:SetCallback("OnClick", 
        function() 
            rules = input:GetText();
            -- defaults.profile.rules = rules
            addon.chat(rules)
        end
    )

    -- SEND RULES BUTTON
    local btn_send = AceGUI:Create("Button")
    btn_send:SetFullWidth("isFull") 
    btn_send:SetText("Lanzar en Banda")
    btn_send:SetCallback("OnClick", function() 
        addon.chat("Lanzando en banda")
        end
    )



    -- Add the button to the container
    f:AddChild(input)
    f:AddChild(btn)
    f:AddChild(btn_send)

end


function addon.showMsg(msg, editBox)
    if msg == 'bye' then
        print('Goodbye, World!')
    else
        addon.makeWindow()
    end
end

-- constructor
function Recount:OnInitialize()

end

-- StaticPopupDialogs["EXAMPLE_HELLOWORLD"] = {
-- 	text = "Do you want to greet the world today?",
-- 	button1 = "Yes",
-- 	button2 = "No",
--     OnShow = function (self, data)
--         self.editBox:SetText("Some text goes here")
--     end,
--     OnAccept = function (self, data, data2)
--         local text = self.editBox:GetText()
--         -- do whatever you want with it
--     end,
--     hasEditBox = true
-- 	timeout = 0,
-- 	whileDead = true,
-- 	hideOnEscape = true,
-- }



SlashCmdList['SLASHCMD'] = addon.showMsg;


SLASH_SLASHCMD1 = '/rs'



local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

function frame:OnEvent(event, arg1)
 if event == "ADDON_LOADED" and arg1 == "HaveWeMet" then
  -- Our saved variables are ready at this point. If there are none, both variables will set to nil.
  if HaveWeMetCount == nil then
   HaveWeMetCount = 0; -- This is the first time this addon is loaded; initialize the count to 0.
  end
  if HaveWeMetBool then
   print("Hello again, " .. UnitName("player") .. "!");
  else
   HaveWeMetCount = HaveWeMetCount + 1; -- It's a new character.
   print("Hi; what is your name?");
  end
 elseif event == "PLAYER_LOGOUT" then
   HaveWeMetBool = true; -- We've met; commit it to memory.
 end
end
frame:SetScript("OnEvent", frame.OnEvent);
SLASH_HAVEWEMET1 = "/hwm";
function SlashCmdList.HAVEWEMET(msg)
 print("HaveWeMet has met " .. HaveWeMetCount .. " characters.");
end