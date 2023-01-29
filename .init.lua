print("Redbean nullboard agent.")
print("Redbean Version: " .. GetRedbeanVersion())

-- Write the embeded html file to disk.
local there = path.isfile("nullboard.html")
if not there then
    assert(Barf("nullboard.html", Slurp("/zip/nullboard.html")))
else
    print("nullboard.html exists.")
end
-- serve from disc rather than embeded asset. Same as -D
ProgramDirectory(".")

BDIR = "boards"
--unix.makedirs(BDIR)
unix.makedirs(BDIR .. "/DeletedBoards")

--inspect = require 'inspect'

function saveData(data, path)
    local file = io.open(path, "w")
    file:write(data)
    file:close()
end

function saveBoard(data, path)
    local file = io.open(path, "w")
    file:write(data)
    file:close()
end

function saveBoard2(params)
    print("saveBoard2()")
    writeTable(params, 0)
    print(params[2][2])
    print(type(params[2][2]))
    print(params[2][2]["id"])
    print(params[2][2].id)
    local b = DecodeJson(params[2][2])
    local id = b.id
    print("id: " .. id)
    unix.makedirs(BDIR .. "/" .. id)
    local rev = b.revision
    local fname = BDIR .. "/" .. id .. "/rev-" .. string.format("%08d", rev) .. ".nbx"
    print(fname)
    local file = io.open(fname, "w")
    file:write(params[2][2])
    file:close()
    local meta = BDIR .. "/" .. id .. "/meta.json"
    print(meta)
    local file = io.open(meta, "w")
    file:write(params[3][2])
    file:close()
end

function saveConfig(params)
    print("saveConfig")
    print(params)
    if params[2]~=nil then
        local file = io.open(BDIR .. "/" .. "app-config.json", "w")
        file:write(params[2][2])
        file:close()
    end
end

function deleteBoard(id)
    o = BDIR .. "/" .. id
    t = BDIR .. "/DeletedBoards/"..id
    print(o)
    print(t)
    print(os.rename(o, t))

end

function writeTable(table, indent) 
    for k, v in pairs(table) do
        io.write(string.rep("-", indent))
        io.write(k .. " = ")
        if (type(v) == "table") then
            print("(table)")
            writeTable(v, indent + 3)
        else
            print(v)
        end
    end
end



function OnHttpRequest()
    method = GetMethod()
    params = GetParams()
    path = GetPath()
    body = GetBody()
    headers = GetHeaders()
    print("\n\n")
    --saveData(EncodeJson(body), "body.txt")
    --saveData(EncodeJson(params), "params.json")
    --print("---")
    print("HEADERS:")
    writeTable(headers, 0)
    print("method: " .. method)
    print("params:")
    print("path: " .. GetPath())
    writeTable(params, 0)
    if method == "OPTIONS" then
        SetStatus(204, "No Content")
        SetHeader("Allow", "OPTIONS, GET, PUT, DELETE")
        SetHeader("Access-Control-Allow-Origin", "*")
        SetHeader("Access-Control-Allow-Headers", "*")
        SetHeader("Access-Control-Allow-Methods", "OPTIONS, GET, PUT, DELETE")
    elseif method == "PUT" then
        SetStatus(204, "No Content")
        SetHeader("Access-Control-Allow-Origin", "*")
        print("params table:")
        writeTable(params, 0)
        if (string.find(path, "board")) then
            print("doing saveBoard()")
            local _,_,id = string.find(path, "/(%d+)")
            --print("board id: " .. id)
            local board = params[2][2]
            --print("board is a: " .. type(board))
            --saveBoard(board, BDIR .. "/" .. tostring(id) .. ".json")
            saveBoard2(params)
            --saveBoard()
        elseif (string.find(path, "config")) then
            print("do saveConfig()")
            saveConfig(params)
        end
    elseif method == "DELETE" then
        SetStatus(204, "No Content")
        SetHeader("Access-Control-Allow-Origin", "*")
        print("do deleteBoard()")
        local _,_,id = string.find(path, "/(%d+)")
        deleteBoard(id)
    elseif method == "GET" then
        ServeAsset("nullboard.html")
    end
end

ProgramPort(10001)

--LaunchBrowser("nullboard.html")
