RuleSeparator = LibStub("AceAddon-3.0"):NewAddon("RuleSeparator", "AceConsole-3.0")
local RuleSeparator = _G.RuleSeparator

local AceGUI = LibStub("AceGUI-3.0")
local openWindow = false
local version = "v2.0"
local help = "RuleSeparator " .. version .. "\nSistema para gestion de bandas\n\n" 
help = help .. "Comandos rapidos:\n\n"
help = help .. "/icc\n"
help = help .. "/sr\n"
help = help .. "/generic\n"


local defaults = {
    profile = {
        version = "2",
        rules = {
            icc = "",
            sr = "",
            generic = ""
        },
        buffs = {
            section1 = "",
            section2 = ""
        },
        general = {
            discord = "",
            help = help,
            guildName = ""
        }
    }
}

function RuleSeparator:OnInitialize()

    RuleSeparator.db = LibStub("AceDB-3.0")

    if RuleSeparator.db.profile == nil then
        RuleSeparator.db = LibStub("AceDB-3.0"):New("rsDB",defaults, true)
    end

    -- update db to the version v2.0
    if type(RuleSeparator.db.profile.rules) ~= 'table' then 
        RuleSeparator.db = defaults
        chat("Se actualizo tu db a la version "..version)
    end

end


-- GENERAL FUNCTIONS ============================

local function chat(str_in)
    print("\124c00FF0000>> "..str_in.."\124r");
end

local function raidWarning(message)
    if IsRaidLeader() or IsRaidOfficer() then
        SendChatMessage(message, "RAID_WARNING", nil, GetUnitName("PLAYERTARGET"))
    else
        chat("Debes de ser lider de banda o ayudante para mandar alertas")
    end
end

-- ==============================================


local function General(container)

    -- NAME GUILD
    local guild_container = AceGUI:Create("InlineGroup")
    guild_container:SetTitle("Nombre de la hermandad:")
    guild_container:SetFullWidth(true) 
    guild_container:SetLayout("Flow")
    container:AddChild(guild_container)

    local guild = AceGUI:Create("EditBox")
    guild:SetLabel("Nombre:")
    guild:SetText(RuleSeparator.db.profile.general.guildName)
    guild:SetMaxLetters(30)
    guild:SetWidth(260)
    guild:SetCallback("OnEnterPressed", function() 
        RuleSeparator.db.profile.general.guildName = guild:GetText()
        chat("Guild " .. RuleSeparator.db.profile.general.guildName .. " guardada!");
    end)
    guild_container:AddChild(guild)

    -- HELP
    local info = AceGUI:Create("InlineGroup")
    info:SetTitle("Info")
    info:SetFullWidth(true) 
    info:SetLayout("Flow")
    container:AddChild(info)
    
    local help = AceGUI:Create("Label")
    help:SetText(RuleSeparator.db.profile.general.help)
    help:SetFullWidth(true)
    info:AddChild(help)
    
    -- SISTEMA DE COMUNICACION 
    local gp = AceGUI:Create("InlineGroup")
    gp:SetTitle("Sistema de comunicación")
    gp:SetFullWidth(true) 
    gp:SetLayout("Flow")
    container:AddChild(gp)

    local discord = AceGUI:Create("EditBox")
    discord:SetLabel("Link de Discord")
    discord:SetText(RuleSeparator.db.profile.general.discord)
    discord:SetMaxLetters(50)
    discord:SetWidth(260)
    discord:SetCallback("OnEnterPressed", function() 
        RuleSeparator.db.profile.general.discord = discord:GetText()
        chat("Discord " .. RuleSeparator.db.profile.general.discord .. " añadido!");
    end)
    gp:AddChild(discord)

    local discordbutton = AceGUI:Create("Button")
    discordbutton:SetText("Lanzar")
    discordbutton:SetWidth(80)
    discordbutton:SetCallback("OnClick", function()
        raidWarning("==CANAL DE DISCORD==")
        raidWarning(RuleSeparator.db.profile.general.discord)
    end)    
    gp:AddChild(discordbutton)

end

-- GENERIC RULE BOX
local function rulerBox(container, tag, selector)
    -- SEND RULES BUTTON
    local btn_send = AceGUI:Create("Button")
    btn_send:SetFullWidth(true) 
    -- btn_send:SetRelativeWidth(0.5)
    btn_send:SetText("Lanzar en Banda")
    btn_send:SetCallback("OnClick", function() 
        -- rules = input:GetText()
        rules = RuleSeparator.db.profile.rules[selector]
        blocks = RuleSeparator:generateParagraphs(rules)
        
        if selector == "generic" then
            raidWarning(">> " .. RuleSeparator.db.profile.general.guildName .. " Reglas de raid <<")
        else
            raidWarning(">> Reglas de " .. tag .. " " .. RuleSeparator.db.profile.general.guildName .. " <<")
        end

        for k,v in pairs(RuleSeparator:buildMacros(blocks)) do
            raidWarning(v)
        end
    end)
    container:AddChild(btn_send)
    
    -- INPUT
    local input = AceGUI:Create("MultiLineEditBox")
    input:SetLabel("Introduce las reglas aquí")
    input:SetNumLines(21)
    input:SetFullWidth("isFull") 
    input:SetText(RuleSeparator.db.profile.rules[selector]) -- load from db 
    -- input:DisableButton("disabled")
    input:SetCallback("OnEnterPressed",function()
        RuleSeparator.db.profile.rules[selector] = input:GetText()
        chat("Reglas de " .. tag .. " guardadas correctamente")
    end)
    container:AddChild(input)
end



local function Buffs(container, label, selector)

    local group = AceGUI:Create("InlineGroup")
    group:SetTitle(label) 
    group:SetFullWidth(true) 
    group:SetLayout("Flow")
    group:AddChild(group)
    container.AddChild(group)

    local input = AceGUI:Create("MultiLineEditBox")
    input:SetLabel("")
    input:SetNumLines(4)
    input:SetFullWidth("isFull") 
    -- input:SetText(RuleSeparator.db.profile.buffs[selector]) -- load from db 
    input:SetText("asdfasdf")

    input:SetCallback("OnEnterPressed",function()
        -- RuleSeparator.db.profile.buffs[selector] = input:GetText()
        -- chat("Reglas de " .. tag .. " guardadas correctamente")
    end)
    group:AddChild(input)


    local button = AceGUI:Create("Button")
    button:SetText("Lanzar")
    button:SetWidth(50)
    button:SetCallback("OnClick", function()
        -- raidWarning(RuleSeparator.db.profile.buffs[selector])
    end)    
    group:AddChild(button)

end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            General(container)
        elseif group == "icc" then
            rulerBox(container, "ICC", "icc")
            -- ICC(container)
        elseif group == "sr" then
            rulerBox(container, "SR", "sr")
            -- SR(container)
        elseif group == "generic" then
            rulerBox(container, "Otras Raids", "generic")
        elseif group == "buffs" then
            -- General(container)
            Buffs(container, "Buffos de Paladines: ", "section1")
            Buffs(container, "Buffos Variados: ", "section2")
    end
end




function makeWindow()

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
    f:SetStatusText("RuleSeparator | ".. version .." | por Martex - Naerzone")
    f:SetLayout("Fill")

    local tab =  AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    -- Setup which tabs to show
    tab:SetTabs({
        {text="General", value="general"}, 
        {text="ICC", value="icc"}, 
        {text="SR", value="sr"}, 
        {text="Otra Raid", value="generic"}, 
        {text="Buffs", value="buffs"}, 
    });
    -- Register callback
    tab:SetCallback("OnGroupSelected", SelectGroup)
    -- Set initial Tab (this will fire the OnGroupSelected callback)
    tab:SelectTab("general")

    -- -- Add the button to the container
    f:AddChild(tab)

end

RuleSeparator:RegisterChatCommand("rs", "openWindow")

function RuleSeparator:openWindow(input)

    makeWindow()
end

