local ghostShark = require(game.ReplicatedStorage.Items["Ghost Shark"])

-- fungsi buat print isi table secara rekursif
local function deepPrint(tbl, indent)
    indent = indent or ""
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(indent .. tostring(k) .. " = {")
            deepPrint(v, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

deepPrint(ghostShark)
