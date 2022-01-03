RuleSeparator = LibStub("AceAddon-3.0"):NewAddon("RuleSeparator", "AceConsole-3.0")
local RuleSeparator = _G.RuleSeparator

local AceGUI = LibStub("AceGUI-3.0")
local openWindow = false
local version = "v2.0"
local help = "RuleSeparator " .. version .. "\nSistema para gestion de bandas\n\n" 
help = help .. "Comandos rapidos:\n\n"
help = help .. "\124c00FF0000/rs dc\124r - Lanzar canal de discord\n"
help = help .. "\124c00FF0000/rs icc\124r - Lanzar reglas de icc\n"
help = help .. "\124c00FF0000/rs sr\124r - Lanzar reglas de sr\n"
help = help .. "\124c00FF0000/rs raid\124r - Lanzar reglas de raid generica\n"
help = help .. "\124c00FF0000/rs buffs\124r - Lanzar buffos\n"
help = help .. "\124c00FF0000/rs help\124r - Ayuda\n"

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

    if type(RuleSeparator.db.profile.rules) ~= 'table' then
        RuleSeparator.db:ResetDB('Default')
        print("Se actualizó tu db a a la versión " .. version)
    end
end


-- GENERAL FUNCTIONS ============================

local function chat(str_in)
    print(">> "..str_in);
end

local function raidWarning(message)
    if IsRaidLeader() or IsRaidOfficer() then
        SendChatMessage(message, "RAID_WARNING", nil, GetUnitName("PLAYERTARGET"))
    else
        chat("Debes de ser lider de banda o ayudante para mandar alertas")
    end
end

local function warnMacros(text, mode)

    if not mode or mode:trim() == "" then
        mode = "warning"
    end 

    blocks = RuleSeparator:generateParagraphs(text)

    for k,v in pairs(RuleSeparator:buildMacros(blocks)) do
        if mode == "warning" then
            raidWarning(v)
        elseif mode == "chat" then
            chat(v)
        else
            chat(v)
        end
    end
end

-- ==============================================


-- ALERTS 

local function warnDC()
    raidWarning(">> CANAL DE DISCORD <<")
    warnMacros(RuleSeparator.db.profile.general.discord)
end

local function warnRaids(selector, tag)
    if selector == "generic" then
        raidWarning(">> " .. RuleSeparator.db.profile.general.guildName .. " REGLAS DE RAID <<")
    else
        raidWarning(">> REGLAS DE " .. tag .. " " .. RuleSeparator.db.profile.general.guildName .. " <<")
    end
    warnMacros(RuleSeparator.db.profile.rules[selector])
end

local function warnBuffs()
    warnMacros(">> BUFFOS <<")
    warnMacros(RuleSeparator.db.profile.buffs.section1)
    warnMacros(RuleSeparator.db.profile.buffs.section2)
end

local function warnInfo()
    warnMacros(RuleSeparator.db.profile.general.help, "chat")
end

-- ================


local function General(container)

    -- NAME GUILD
    local guild_container = AceGUI:Create("InlineGroup")
    -- guild_container:SetTitle("Nombre de la hermandad:")
    guild_container:SetFullWidth(true) 
    guild_container:SetLayout("Flow")
    container:AddChild(guild_container)

    local guild = AceGUI:Create("EditBox")
    guild:SetLabel("Nombre de la hermandad:")
    guild:SetText(RuleSeparator.db.profile.general.guildName)
    guild:SetMaxLetters(30)
    guild:SetWidth(260)
    guild:SetCallback("OnEnterPressed", function() 
        RuleSeparator.db.profile.general.guildName = guild:GetText()
        chat("Guild " .. RuleSeparator.db.profile.general.guildName .. " guardada!");
    end)
    guild_container:AddChild(guild)

    -- SISTEMA DE COMUNICACION 
    local gp = AceGUI:Create("InlineGroup")
    -- gp:SetTitle("Sistema de comunicación")
    gp:SetFullWidth(true) 
    gp:SetLayout("Flow")
    container:AddChild(gp)

    local discord = AceGUI:Create("EditBox")
    discord:SetLabel("Sistema de comunicación (Link de Discord):")
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
        warnDC()
    end)    
    gp:AddChild(discordbutton)

    -- HELP
    local info = AceGUI:Create("InlineGroup")
    info:SetFullWidth(true) 
    info:SetLayout("Flow")
    container:AddChild(info)
    
    local help = AceGUI:Create("Label")
    help:SetText(RuleSeparator.db.profile.general.help)
    help:SetFullWidth(true)
    info:AddChild(help)

end

local function rulerBox(container, tag, selector)
    -- SEND RULES BUTTON
    local btn_send = AceGUI:Create("Button")
    btn_send:SetFullWidth(true) 
    -- btn_send:SetRelativeWidth(0.5)
    btn_send:SetText("Lanzar en Banda")
    btn_send:SetCallback("OnClick", function() 
        warnRaids(selector, tag)
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
        chat("Reglas de " .. tag .. " guardadas correctamente.")
    end)
    container:AddChild(input)
end

local function Buffs(container, label, selector)

    local buffs = AceGUI:Create("MultiLineEditBox")
    buffs:SetLabel(label)
    buffs:SetText(RuleSeparator.db.profile.buffs[selector])
    buffs:SetFullWidth(true)
    buffs:SetMaxLetters(255)
    buffs:SetCallback("OnEnterPressed", function()
        RuleSeparator.db.profile.buffs[selector] = buffs:GetText()
        chat("Buffos guardados correctamente.")
    end) 
    container:AddChild(buffs)

end

local function SelectGroup(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            General(container)
        elseif group == "icc" then
            rulerBox(container, "ICC", "icc")
        elseif group == "sr" then
            rulerBox(container, "SR", "sr")
        elseif group == "generic" then
            rulerBox(container, "Otras Raids", "generic")
        elseif group == "buffs" then
            -- BUTTON LANZAR
            local section1 = "section1"
            local section2 = "section2"

            local btn_send = AceGUI:Create("Button")
            btn_send:SetFullWidth(true) 
            btn_send:SetText("Lanzar en Banda")
            btn_send:SetCallback("OnClick", function() 
                warnBuffs()
            end)
            container:AddChild(btn_send)
            Buffs(container, "Buffos de paladines: ", section1)
            Buffs(container, "Buffos Variados: ", section2)
    end
end

local function makeWindow()

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
    tab:SetTabs({
        {text="General", value="general"}, 
        {text="ICC", value="icc"}, 
        {text="SR", value="sr"}, 
        {text="Otra Raid", value="generic"}, 
        {text="Buffs", value="buffs"}, 
    });
    tab:SetCallback("OnGroupSelected", SelectGroup)
    tab:SelectTab("general")
    f:AddChild(tab)
end



-- CHAT COMMANDS

RuleSeparator:RegisterChatCommand("rs", "shell")

function RuleSeparator:shell(input)

    if not input or input:trim() == "" then
        makeWindow()
    elseif input == "icc" then
        warnRaids("icc", "ICC")
    elseif input == "sr" then
        warnRaids("sr", "SR")
    elseif input == "raid" then
        warnRaids("generic", "Otras Raids")
    elseif input == "dc" then
        warnDC()
    elseif input == "buffs" then
        warnBuffs()
    else 
        warnInfo()
    end

end


-- universidad la gabriel escuela de dallas  // ANDREUS