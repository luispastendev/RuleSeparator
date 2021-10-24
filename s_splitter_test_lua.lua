-- DEBUG TOOLS
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] => ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- FUNCTIONS ================================
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
        output = "/ab "
    else
        output = " "
    end
    return output
end

function doMacro(paragraph)
    local limit = 20
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

-- MAIN=============================================

s = "How do I take the string and, split it 2 into a table of     strings? asdfasdff sdfsdf \n simon asdf \n space \n down"


blocks = generateParagraphs(s)
print(dump(buildMacros(blocks)))
