local screen = GetPart("Screen")
local Otime = 1000
local barframes = {}

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function BeepHeight(height)
    Beep(clamp(height * 3, 0, 2))
end

local function createBars(n)
    screen:ClearElements()
    barframes = {}
    for i = 1, n do
        local height = math.random()
        local frame = screen:CreateElement("Frame", {
            Size = UDim2.fromScale(1 / n, height),
            Position = UDim2.fromScale(i / n, 1),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0
        })
        table.insert(barframes, frame)
        BeepHeight(height)
        -- task.wait()
    end
end

local function swap(i, j)
    local a = barframes[i]
    local b = barframes[j]
    local sizeA = a.Size
    local sizeB = b.Size

    a.Size = sizeB
    b.Size = sizeA

    a.BackgroundColor3 = Color3.new(1, 0, 0)
    b.BackgroundColor3 = Color3.new(1, 0, 0)

    BeepHeight(sizeA.Y.Scale)
    BeepHeight(sizeB.Y.Scale)

    task.wait(0.005)

    a.BackgroundColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = Color3.new(1, 1, 1)
end

local function insertionSort()
    for i = 2, #barframes do
        local j = i
        while j > 1 and barframes[j].Size.Y.Scale < barframes[j - 1].Size.Y.Scale do
            swap(j, j - 1)
            j = j - 1
        end
    end
end

local function quickSort(low, high)
    if low < high then
        local pivot = barframes[high].Size.Y.Scale
        local i = low - 1
        for j = low, high - 1 do
            if barframes[j].Size.Y.Scale < pivot then
                i = i + 1
                swap(i, j)
            end
        end
        swap(i + 1, high)
        local pi = i + 1
        quickSort(low, pi - 1)
        quickSort(pi + 1, high)
    end
end

local function threeWayQuickSort(low, high)
    if high <= low then return end
    local lt = low
    local gt = high
    local v = barframes[low].Size.Y.Scale
    local i = low + 1
    while i <= gt do
        local val = barframes[i].Size.Y.Scale
        if val < v then
            swap(lt, i)
            lt = lt + 1
            i = i + 1
        elseif val > v then
            swap(i, gt)
            gt = gt - 1
        else
            i = i + 1
        end
    end
    threeWayQuickSort(low, lt - 1)
    threeWayQuickSort(gt + 1, high)
end

local function bubbleSort()
    local n = #barframes
    for i = 1, n do
        for j = 1, n - i do
            if barframes[j].Size.Y.Scale > barframes[j + 1].Size.Y.Scale then
                swap(j, j + 1)
            end
        end
    end
end

local function bozoSort()
    local function isSorted()
        for i = 1, #barframes - 1 do
            if barframes[i].Size.Y.Scale > barframes[i + 1].Size.Y.Scale then
                return false
            end
        end
        return true
    end

    while not isSorted() do
        local i = math.random(1, #barframes)
        local j = math.random(1, #barframes)
        swap(i, j)
    end
end

local function flashGreen()
    for i = 1, #barframes do
        barframes[i].BackgroundColor3 = Color3.new(0, 1, 0)
        Beep(i / (#barframes * 2))
        task.wait(0.002)
    end
end

createBars(Otime)

-- insertionSort()
quickSort(1, #barframes)
-- threeWayQuickSort(1, #barframes)
-- bubbleSort()
-- bozoSort()

flashGreen()
