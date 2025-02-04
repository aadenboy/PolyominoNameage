require "boiler"
require "keys"
require "vector"

local md5 = require("md5")
math.randomseed(1)

local polyomino = {
    Vector2.new(0, 0),
    Vector2.new(0, 1),
    Vector2.new(0, 2),
    Vector2.new(1, 1),
}
local color = "ffffff"
local last = ""
local name = ""
local codefinal = ""
local codescore = 0
local alls = ""

function findmino(mino, what, exempt) -- not very efficient but I don't care I REALLY don't want to deal with mappings
    exempt = exempt or {}
    if exempt[tostring(what)] then return nil end
    for i,v in pairs(mino) do
        if v == what then
            return i
        end
    end
end

local nprefix = {
    ["3"] = "ter",
    ["4"] = "ker",
    ["5"] = "pen",
    ["6"] = "ses",
    ["7"] = "hep",
    ["8"] = "og",
    ["9"] = "nen",
    ["10"] = "dec",
    ["11"] = "undec",
    ["12"] = "dodec",
    ["13"] = "tridec",
    ["14"] = "tetrakaidec",
    ["15"] = "pentadec",
    ["16"] = "sextadep",
    ["17"] = "heptadec",
    ["18"] = "octadec",
    ["19"] = "nonadec",
    ["20"] = "ic",
    ["+"] = "de",
    ["O"] = "cy",
    ["X"] = "chi"
}
local naffix = {
    ["4"] = "cer",
    ["+"] = "ako",
    ["-"] = "avo",
    ["O"] = "cy",
    ["X"] = "chi",
    ["Q"] = "dy",
    ["Z"] = "zet"
}
local nsuffix = {
    ["3"] = "to",
    ["4"] = "cer",
    ["+"] = "ie",
    ["-"] = "it",
    ["O"] = "cy",
    ["X"] = "ix",
    ["Q"] = "dy",
    ["Z"] = "zet"
}
local branchdeg = {
    [""]  = "ar",
    ["2"] = "ax",
    ["3"] = "ol",
    ["4"] = "ec",
    ["5"] = "us",
    ["6"] = "en",
    ["7"] = "ad",
    ["8"] = "ym",
    ["9"] = "ix",
    ["10"] = "ed",
    ["11"] = "edar",
    ["12"] = "edax",
    ["13"] = "edol",
    ["14"] = "edec",
    ["15"] = "edus",
    ["16"] = "eden",
    ["17"] = "edad",
    ["18"] = "edym",
    ["19"] = "edix",
    ["20"] = "el",
}
local terakoto = {
    ["V"]  = "lily",
    ["N"]  = "nau",
    ["X"]  = "chi",
    ["Z"]  = "zet",
    ["o"]  = "ky",
    ["x"]  = "xana",
    ["q"]  = "thy",
    ["z"]  = "sai",
    ["2"]  = "du",
    ["3"]  = "tri",
    ["4"]  = "tetra",
    ["5"]  = "penta",
    ["6"]  = "hexa",
    ["7"]  = "hepta",
    ["8"]  = "octa",
    ["9"]  = "nona",
    ["10"] = "deca",
    ["11"] = "undeca",
    ["12"] = "dodeca",
    ["13"] = "trideca",
    ["14"] = "tetrakaideca",
    ["15"] = "pentadeca",
    ["16"] = "hexadeca",
    ["17"] = "heptadeca",
    ["18"] = "octadeca",
    ["19"] = "nonadeca",
    ["20"] = "icosa",
}

function nameify(last)
    local new = ""
    local ending = true
    local setprefix = true
    local lastnumber = false
    while #last > 0 do
        local char, coeff = last:match("(.){(%d+)}$")
        char = char or last:sub(-1)
        if char:match("[0-9]") then
            char = last:match("%d+$")
        end
        last = last:sub(1, -1 - #char - #(coeff and (coeff.."{}") or ""))

        if not coeff and char:match("[3-9%+%-OXQZ]") or char:match("%d+") then
            if #last == 0 and not char:match("[%-QZ]") then
                local add = (nprefix[char])
                if char:match("[5-9]") and new:match("^[aeiouy]") then
                    add = add..add:sub(-1)
                elseif char:match("[%+%-]") and new:match("^[aeiouy]") then
                    add = add:sub(1, -2)
                elseif char == "O" and new:match("^[aeiouy]") then
                    add = "cycl"
                elseif char == "X" and new:match("^i") then
                    add = "cha"
                end
                if ending and add:sub(-1):match("[^aeiouy]") then 
                    add = add..add:sub(-1).."a"
                end
                new = add..new
            elseif ending then
                new = (nsuffix[char] or nprefix[char])..new
            else
                local add = (naffix[char] or nprefix[char] or nsuffix[char])
                if char:match("[5-9]") and new:match("^[aeiouy]") then
                    add = add..add:sub(-1)
                elseif char:match("[%+%-]") and new:match("^[aeiouy]") then
                    add = add:sub(1, -2)
                elseif char == "O" and new:match("^[aeiouy]") then
                    add = "cycl"
                elseif char == "X" and new:match("^i") then
                    add = "cha"
                elseif char == "Q" and new:match("^[aeiouy]") then
                    add = "dyr"
                elseif char == "Z" and not new:match("^[aeiouy]") then
                    add = "zeta"
                end
                new = add..new
            end
        elseif char == ")" then
            local from = (last..")"):match("()%b()$")
            local set = last:sub(from + 1)
            last = last:sub(1, from - 1)

            local add = (setprefix and "i" or "o")
            if set == "+" then
                add = add.."d"
            elseif set == "-" then
                add = add.."v"
            else
                add = add..nameify(set)
                if set:sub(-1) == "O" then
                    add = add.."cl"
                elseif set:sub(-1) == "X" and branchdeg[coeff or ""]:sub(1, 1) == "i" then
                    add = add.."cl"
                elseif set:sub(-1) == "Q" then
                    add = add.."r"
                end
            end
            new = add..branchdeg[coeff or ""]..new
            setprefix = not setprefix
        elseif coeff and char:match("[XZ]") then
            new = terakoto[coeff]..terakoto[char]..new
        elseif coeff and char:match("[oxqz]") then
            local add = #last > 0 and naffix[coeff] or nprefix[coeff]
            if new:match("^[aeiouy]") and not numberlast then add = add..add:sub(-1) end
            new = (numberlast and
                (add..terakoto[char]) or
                (terakoto[char]..add)
            )..new
        end
        lastnumber = char:match("[3-9]")
        ending = false
    end
    return new
end

function generate()
    if #polyomino == 0 then return "anti", "", 0 end
    for _,v in ipairs(polyomino) do
        if not (
            findmino(polyomino, v + Vector2.new( 0,  1)) or
            findmino(polyomino, v + Vector2.new( 0, -1)) or
            findmino(polyomino, v + Vector2.new( 1,  0)) or
            findmino(polyomino, v + Vector2.new(-1,  0))
        ) then
            return (#polyomino == 1 and "mino" or "INVALID POLYOMINO"), "", 0
        end
    end
    if #polyomino == 2 then return "domi", "", 0 end
    
    local minos = {}
    for i=0, 7 do
        local newmino = {}
        for _,v in ipairs(polyomino) do
            local pos = (v * Vector2.new(1, i > 3 and -1 or 1)):rotaround(Vector2.new(0, 0), 90 * i)
            table.insert(newmino, pos)
        end
        table.sort(newmino, function(a, b)
            return a.y < b.y or (a.y == b.y and a.x < b.x)
        end)

        function search(poly, from, sdir, handled, start)
            local branch = {}
            local total = 0
            local name = ""
            local score = 0
            local pos = from
            local dir = sdir
            local o = Vector2.new(0, 0)
            local highvert = 0
            local noturn = true
            if start == false then noturn = false end

            while true do
                handled[tostring(pos)] = pos
                local count = 1
                while findmino(newmino, pos + dir, handled) do
                    pos = pos + dir
                    count = count + 1
                    handled[tostring(pos)] = pos

                    if (findmino(newmino, pos + dir:rotaround(o, -90), handled)  or
                        findmino(newmino, pos + dir:rotaround(o,  90), handled)) and 
                        findmino(newmino, pos + dir, handled) then
                        table.insert(branch, {pos = pos, dir = dir, at = total + count})
                    end
                end
                total = total + count
                if count > 2 then
                    name = name..count
                    score = score + count
                    highvert = highvert + (noturn and count or 0)
                end
                
                local odir = dir
                if findmino(newmino, pos + dir:rotaround(o, -90), handled) then
                    dir = dir:rotaround(o, -90)
                    name = name.."+"
                    score = score + 1
                    handled[tostring(pos)] = pos
                    total = total - 1
                elseif findmino(newmino, pos + dir:rotaround(o, 90), handled) then
                    dir = dir:rotaround(o, 90)
                    name = name.."-"
                    score = score + 2
                    handled[tostring(pos)] = pos
                    total = total - 1
                    if noturn then return "INVALID", math.huge, handled end
                else
                    break
                end
                noturn = false
                if findmino(newmino, pos + dir:rotaround(o, 180), handled) then
                    score = score - 1 - (name:sub(-1) == "-" and 1 or 0)
                    name = name:sub(1, -2)
                    table.insert(branch, {pos = pos, dir = odir, at = total + 1, pair = true})
                    break
                end
            end
            if (findmino(newmino, from + sdir:rotaround(o, -90), handled)  or
                findmino(newmino, from + sdir:rotaround(o,  90), handled)) and
                findmino(newmino, from + sdir, {}) and false then
                return "INVALID", math.huge, handled
            end
            if #branch > 0 then
                for _,v in ipairs(branch) do
                    if v.pair then
                        local aname, ascore = search(poly, v.pos, v.dir:rotaround(o, -90), handled, false)
                        local bname, bscore = search(poly, v.pos, v.dir:rotaround(o,  90), handled, false)
                        aname,  bname  = "+"..aname, "-"..bname
                        ascore, bscore = ascore + 1, bscore + 2

                        local win = #aname >= #bname
                        name = name..(win and aname or bname)
                        
                        if (win and bname or aname) ~= "" then
                            name = name.."("..(win and bname or aname)..")"..(v.at > 2 and "{"..(v.at - 1).."}" or "")
                        end
                        score = score + ascore + bscore + 2*v.at + 1
                    else
                        local add, nscore = search(poly, v.pos, v.dir, handled, false)
                        if add ~= "" then
                            name = name.."("..add..")"..(v.at > 2 and "{"..(v.at - 1).."}" or "")
                            score = score + 2*v.at + nscore + 1
                        end
                    end
                    ::out::
                end
            end
            return name, score - highvert, handled
        end
        local name, score, handled = search(newmino, newmino[1], Vector2.new(0, 1), {})

        local unname = ""
        local i = 0
        repeat
            i = i + 1
            local str = name:sub(i)
            if str:match("^[%+%-][%+%-]") then
                unname = unname..(str:sub(1, 2)
                    :gsub("%+%+", function(a)
                        score = score + 0
                        return "O"
                    end)
                    :gsub("%+%-", function(a)
                        score = score + 1
                        return "X"
                    end)
                    :gsub("%-%-", function(a)
                        score = score + 3
                        return "Q"
                    end)
                    :gsub("%-%+", function(a)
                        score = score + 2
                        return "Z"
                    end)
                )
                i = i + 1
                noelse = true
            else
                unname = unname..str:sub(1, 1)
            end
        until i > #name

        name, unname = unname, ""
        i = 0
        repeat
            i = i + 1
            local str = name:sub(i)
            if str:match("^XX+") or str:match("^ZZ+") then
                local mult = str:match("^(XX+)") or str:match("^(ZZ+)")
                unname = unname..(mult
                    :gsub("(XX+)", function(a)
                        score = score - #a
                        return "X{"..#a.."}"
                    end)
                    :gsub("(ZZ+)", function(a)
                        score = score - #a
                        return "Z{"..#a.."}"
                    end)
                )
                i = i + #mult - 1
            elseif str:match("^(%d)[%+%-]%1[%+%-]") then
                local mult = str:match("^((%d)[%+%-]%2[%+%-])")
                unname = unname..(mult
                    :gsub("(%d+)%+%1%+", function(a)
                        score = score - a
                        return "o{"..a.."}"
                    end)
                    :gsub("(%d+)%+%1%-", function(a)
                        score = score - a
                        return "x{"..a.."}"
                    end)
                    :gsub("(%d+)%-%1%-", function(a)
                        score = score - a
                        return "q{"..a.."}"
                    end)
                    :gsub("(%d+)%-%1%+", function(a)
                        score = score - a
                        return "z{"..a.."}"
                    end)
                )
                i = i + #mult - 1
            else
                unname = unname..str:sub(1, 1)
            end
        until i > #name

        local add = 0
        for _,v in pairs(handled) do
            add = add + 1
        end
        if add < #newmino then score = math.huge end

        table.insert(minos, {unname, score})
    end
    
    local min, last = math.huge, nil
    local minodump = ""
    for _,v in ipairs(minos) do
        minodump = minodump..v[1].." ("..v[2]..")\n"
        if v[2] < min or (v[2] == min and v[1] and (v[1] or "") < (last or "")) then
            min  = v[2]
            last = v[1]
        end
    end
    
    if not last then return "NO VALID NAME FOUND", "?!", "?!", minodump:sub(1, -2) end
    
    local lsave = last
    local namefinal
    pcall(function() namefinal, presentable = nameify(last) end)
    
    return namefinal or "TOO COMPLICATED!", last, min, minodump:sub(1, -2)
end

local t, ldt, f = 0, 0, 0
function love.update(dt)
    keyboard:refresh()
    mouse:refresh()
    window:refresh()

    t = t + dt
    ldt = dt
    f = f + 1

    if last ~= dump(polyomino) then
        last = dump(polyomino)
        name, codefinal, codescore, alls = generate()
        color = md5.sumhexa(name):sub(1, 6)
    end

    if keyboard.c.clicked then
        love.system.setClipboardText(name.."\n"..codefinal.." (Score: "..codescore..")")
    end
end

local canvas = love.graphics.newCanvas()
local canvas2 = love.graphics.newCanvas()

function love.resize()
    canvas = love.graphics.newCanvas()
    canvas2 = love.graphics.newCanvas()
end

local cpos, czoom = Vector2.new(0, 0), 1
local text  = love.graphics.newText(love.graphics.newFont("arialbold.ttf", 64, "light", 2))
local text2 = love.graphics.newText(love.graphics.newFont("Times-Roman-01.ttf", 42, "light", 4))
function love.draw()
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    love.graphics.setLineWidth(2)

    local min, max = Vector2.new(0, 0), Vector2.new(0, 0)
    for _,v in ipairs(polyomino) do
        min = Vector2.new(math.min(min.x, v.x), math.min(min.y, v.y))
        max = Vector2.new(math.max(max.x, v.x), math.max(max.y, v.y))
    end

    local area = Vector2.new(math.max(math.abs(min.x), max.x), math.max(math.abs(min.y), max.y)) * 2
    local middle = (min + max) / 2
    --cpos = cpos + (middle - cpos) / 5

    local zx = (window.width  - 50) / (math.snap(area.x + 1, 5, "ceil") * 50)
    local zy = (window.height - 50) / (math.snap(area.y + 1, 5, "ceil") * 50)
    czoom = czoom + (math.min(zx, zy) - czoom) / 5

    for i,v in pairs(polyomino) do
        local pos = Vector2.new(window.width / 2, window.height / 2) + ((v - cpos - Vector2.new(0.5, 0.5)) * Vector2.new(50, -50) * czoom)
        love.graphics.setColor(fromHEX(color))
        love.graphics.rectangle("fill", pos.x, pos.y, 50 * czoom, 50 * czoom)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", pos.x, pos.y, 50 * czoom, 50 * czoom)

        if mouse.rmb.clicked and math.inside(mouse.x, pos.x, pos.x + 50 * czoom)
                             and math.inside(mouse.y, pos.y, pos.y + 50 * czoom) then
            table.remove(polyomino, i)
        end
    end

    local mpos = ((Vector2.new(mouse.x, mouse.y) - Vector2.new(window.width / 2, window.height / 2))
                 / (Vector2.new(50, -50) * czoom) + cpos + Vector2.new(0, 1)):round()
    if tostring(mpos.x) == "-0" then mpos.x = 0 end
    if tostring(mpos.y) == "-0" then mpos.y = 0 end

    local pos = Vector2.new(window.width / 2, window.height / 2) + ((mpos - cpos - Vector2.new(0.5, 0.5)) * Vector2.new(50, -50) * czoom)
    love.graphics.setColor(1, 1, 1, math.sin(t * 2) * 0.1 + 0.3)
    love.graphics.rectangle("fill", pos.x, pos.y, 50 * czoom, 50 * czoom)
    
    if mouse.lmb.clicked and not findmino(polyomino, mpos) then
        table.insert(polyomino, mpos)
    end
    love.graphics.setColor(1, 1, 1)
    text:set(name)
    local width = text:getWidth()
    love.graphics.draw(text, 15, 0, 0, (width < window.width - 30) and 1 or ((window.width - 30) / width), 1)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    local cfs = (codefinal or "?!"):gsub("[oxqz]", {
        ["o"] = "K",
        ["x"] = "Ξ",
        ["q"] = "Θ",
        ["z"] = "∑",
    }).." (Score: "..(codescore or "?!")..")"
    text2:set(")")
    local height = text2:getHeight()
    local i = 0
    local x = 0
    repeat
        i = i + 1
        for j=0, 2, 2 do
            local succ, err = pcall(function()
                local c = cfs:sub(i, i + j)
                if c == "{" then
                    c = cfs:sub(i):match("^{(%d-)}")
                    text2:set(c)
                    i = i + #c + 1
                    love.graphics.draw(text2, x, window.height - height/2, 0, 0.5, 0.5)
                    x = x + text2:getWidth() * 0.5
                else
                    text2:set(c)
                    love.graphics.draw(text2, x, window.height - height, 0, 1, 1)
                    x = x + text2:getWidth()
                end
            end)
            if succ then i = i + j break end
        end
    until i >= #cfs
    love.graphics.setCanvas()
    love.graphics.draw(canvas, 15, -15, 0,
    (x < window.width*0.5 - 15) and 1 or (((window.width*0.5 - 15) / x)), 1)

    local alls2 = (alls or "?!").."\n"
    local at = 0
    local _, total = alls2:gsub("\n", "\n")
    for str in alls2:gmatch(".-\n") do
        text2:set(str)
        local width = text2:getWidth()
        scale = 0.5 * ((width * 0.5 < window.width*0.5 - 30) and 1 or ((window.width*0.5 - 30) / (width * 0.5)))
        love.graphics.draw(
            text2,
            window.width - width * scale - 15,
            window.height - text2:getHeight() * (total - at) * 0.5 - 15,
            0,
            scale,
            0.5
        )
        at = at + 1
    end

    love.graphics.setCanvas()
    --text2:set(alls or "")
    --width = text2:getWidth() * 0.3
    --love.graphics.draw(text2, 15, 64 + 64*0.4, 0, (width < window.width / 2 - 30) and 0.3 or (0.3 * ((window.width / 2 - 30) / width)), 0.3)
end