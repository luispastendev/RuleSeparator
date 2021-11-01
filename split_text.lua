local RuleSeparator = _G.RuleSeparator

function RuleSeparator:filterParagraph(inputstr, sep)
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

function RuleSeparator:filterLineBreaks(input) 
    lines = {}
    for s in input:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    return lines
end

function RuleSeparator:splitText (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function RuleSeparator:newMacroOrSpace(block)
    local output = ""
    if block == "" or block == nil then
        output = "" -- add "/ab "
    else
        output = " "
    end
    return output
end

function RuleSeparator:doMacro(paragraph)
    local limit = 255
    local macros = {""}
    local block  = 1

    for k, v in pairs(paragraph) do
        if string.len(v) < limit then
            
            tmp = macros[block] .. RuleSeparator:newMacroOrSpace(macros[block]) .. v

            if string.len(tmp) <= limit then
                macros[block] = tmp    
            else 
                block = block + 1
                macros[block] = RuleSeparator:newMacroOrSpace(macros[block]) .. v
            end
        else 
            block = block + 1
            macros[block] = RuleSeparator:newMacroOrSpace(macros[block]) .. v
        end 
    end
    return macros
end

function RuleSeparator:appendMacros(original,new)
    for k,v in pairs(new) do
        table.insert(original, v)
    end
    return original
end

function RuleSeparator:generateParagraphs(input)
    blocks = {} 
    for k, v in pairs(RuleSeparator:filterLineBreaks(input)) do
        blocks[k] = RuleSeparator:filterParagraph(v)
    end
    return blocks
end

function RuleSeparator:buildMacros(blocks) 
    local macros = {}
    for k, block in pairs(blocks) do
        chunk = RuleSeparator:doMacro(RuleSeparator:splitText(blocks[k]))
        macros = RuleSeparator:appendMacros(macros, chunk) 
        --do return end
    end
    return macros
end