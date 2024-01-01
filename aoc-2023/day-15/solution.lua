
function hashof (s)
    hash = 0
    for ch in s:gmatch (".") do
         hash = (hash + ch:byte(1)) * 17 % 256
    end
    return hash
end

box = {}

function box:upsert (key, val)
    local new = BOX{}

    local found = false
    for i = 1, #self do
        if self[i].key == key then
            new[i] = {
                key=self[i].key,
                val=val,
            }
            found = true
        else
            new[i] = self[i]
        end
    end

    if not found then
        new[#new + 1] = {
            key=key,
            val=val,
        }
    end

    return new
end

-- ugh, I fear I may have fucked myself into a painted corner by attempting to
-- do this functional style-like; looks like table.remove would've done this
-- all in situ.
function box:without (key)
    local new = BOX{}
    local j = 1
    for i = 1, #self do
        if self[i].key ~= key then
            new[j] = self[i]
            j = j + 1
        end
    end
    return new
end

function BOX(arr)
    return setmetatable(arr, {__index = box})
end

--------ww--------
--              --
--  entrypoint  --
--              --
--------^^--------

local input = io.input ():read("*a")
local hashmap = {}

local sum1 = 0
for word in input:gmatch ("([^,\n]+)") do
    sum1 = sum1 + hashof(word)

    for label, op, val in word:gmatch ("(%w+)([-=])(%d*)") do
        idx = hashof (label) + 1
        box = hashmap[idx] or BOX{}

        if op == "-" then
            hashmap[idx] = box:without (label)
        elseif op == "=" then
            hashmap[idx] = box:upsert (label, val)
        end
    end
end

print ("Pt1:", sum1)

local sum2 = 0
for idx, box in pairs (hashmap) do
    for i = 1, #box do
        sum2 = sum2 + (idx * i * box[i].val)
    end
end

print ("Pt2:", sum2)
