local RuleSeparator = LibStub("AceAddon-3.0"):NewAddon("RuleSeparator", "AceConsole-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local openWindow = false


-- Constructor ===================================

local defaults = {
    profile = {
        rules = "",
    }
}

function RuleSeparator:OnInitialize()

    RuleSeparator.db = LibStub("AceDB-3.0")

    if RuleSeparator.db.profile == nil then
        RuleSeparator.db = LibStub("AceDB-3.0"):New("rsDB",defaults, true)
    end
    -- print(RuleSeparator.db.profile.rules)
end


-- FUNCTIONS LIB ================================
function filterParagraph(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end

    local s = ''
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do              
        if s == nil or s == '' then -- is first loop?
            s = str
        else
            s = s .. " " .. str
        end            
    end
    return s
end

function filterLineBreaks(input) 
    lines = {}
    for s in input:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    return lines
end

function splitText (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function newMacroOrSpace(block)
    local output = ""
    if block == "" or block == nil then
        output = "" -- add "/ab "
    else
        output = " "
    end
    return output
end

function doMacro(paragraph)
    local limit = 255
    local macros = {""}
    local block  = 1

    for k, v in pairs(paragraph) do
        if string.len(v) < limit then
            
            tmp = macros[block] .. newMacroOrSpace(macros[block]) .. v

            if string.len(tmp) <= limit then
                macros[block] = tmp    
            else 
                block = block + 1
                macros[block] = newMacroOrSpace(macros[block]) .. v
            end
        else 
            block = block + 1
            macros[block] = newMacroOrSpace(macros[block]) .. v
        end 
    end
    return macros
end

function appendMacros(original,new)
    for k,v in pairs(new) do
        table.insert(original, v)
    end
    return original
end

function generateParagraphs(input)
    blocks = {} 
    for k, v in pairs(filterLineBreaks(input)) do
        blocks[k] = filterParagraph(v)
    end
    return blocks
end

function buildMacros(blocks) 
    local macros = {}
    for k, block in pairs(blocks) do
        chunk = doMacro(splitText(blocks[k]))
        macros = appendMacros(macros, chunk) 
        --do return end
    end
    return macros
end



-- FUNCTIONS LIB ================================


local addon = {}

function addon.chat(str_in)
    print("\124c00FF0000"..str_in.."\124r");
end


function addon.makeWindow()

    if openWindow then
        return
    end

    openWindow = true
    
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose",function(widget)
        AceGUI:Release(widget) 
        openWindow = false
    end)
    f:SetTitle("RuleSeparator")
    f:SetStatusText("RuleSeparator | v1.1 | por Martex - Naerzone")
    f:SetLayout("Flow")

    -- -- -- INPUT
    local input = AceGUI:Create("MultiLineEditBox")
    input:SetLabel("Copia y pega las reglas aqui")
    input:SetNumLines(20)
    input:SetFullWidth("isFull") 
    input:SetText(RuleSeparator.db.profile.rules) -- load from db 
    input:DisableButton("disabled")
    
    -- -- -- SEND RULES BUTTON
    local btn_send = AceGUI:Create("Button")
    btn_send:SetFullWidth("isFull") 
    btn_send:SetText("Lanzar en Banda")
    btn_send:SetCallback("OnClick", function() 
        rules = input:GetText()
        blocks = generateParagraphs(rules)
        for k,v in pairs(buildMacros(blocks)) do
            -- addon.chat(v)
            SendChatMessage(v, "RAID_WARNING", nil, GetUnitName("PLAYERTARGET"))
        end
    end)

    -- clean input
    local btn_clean = AceGUI:Create("Button")
    btn_clean:SetFullWidth("isFull") 
    btn_clean:SetText("Borrar Todo")
    btn_clean:SetCallback("OnClick", 
        function() 
            input:SetText("")
        end
    )

    -- save in db
    local btn_save = AceGUI:Create("Button")
    btn_save:SetFullWidth("isFull") 
    btn_save:SetText("Guardar")
    btn_save:SetCallback("OnClick", 
        function() 
            RuleSeparator.db.profile.rules = input:GetText()
        end
    )

    -- -- Add the button to the container
    f:AddChild(input)
    f:AddChild(btn_send)
    f:AddChild(btn_clean)
    f:AddChild(btn_save)

    -- GET FROM DB CURRENT RULES

end

RuleSeparator:RegisterChatCommand("rs", "openWindow")

function RuleSeparator:openWindow(input)

    addon.makeWindow()
end
