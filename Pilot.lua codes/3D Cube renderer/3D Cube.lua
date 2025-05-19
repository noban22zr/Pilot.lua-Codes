local screen = assert(GetPart("TouchScreen"))
local screenW, screenH = screen:GetDimensions().X, screen:GetDimensions().Y
local pixelSize = 2
local rotateSpeed = math.rad(5)
local moveSpeed = 0.3

local pixelFrames = {}

local function makeCubeVertices(size)
    local s = size / 2
    return {
        {-s, -s, -s}, {s, -s, -s}, {s, s, -s}, {-s, s, -s},
        {-s, -s, s}, {s, -s, s}, {s, s, s}, {-s, s, s}
    }
end

local cubeVertices = makeCubeVertices(1)
local cubeEdges = {
    {1,2},{2,3},{3,4},{4,1},
    {5,6},{6,7},{7,8},{8,5},
    {1,5},{2,6},{3,7},{4,8}
}

local cameraPos = {x = 0, y = 0, z = -4}
local cameraRot = {pitch = 0, yaw = 0}
local cubeColor = Color3.fromHSV(math.random(), 1, 1)

local function getRotationMatrix(pitch, yaw)
    local cosP, sinP = math.cos(pitch), math.sin(pitch)
    local cosY, sinY = math.cos(yaw), math.sin(yaw)
    return {
        {cosY, 0, -sinY},
        {sinY * sinP, cosP, cosY * sinP},
        {sinY * cosP, -sinP, cosP * cosY}
    }
end

local function transformVertex(v, camRot, camPos)
    local x, y, z = v[1] - camPos.x, v[2] - camPos.y, v[3] - camPos.z
    local rot = getRotationMatrix(camRot.pitch, camRot.yaw)
    local tx = rot[1][1]*x + rot[1][2]*y + rot[1][3]*z
    local ty = rot[2][1]*x + rot[2][2]*y + rot[2][3]*z
    local tz = rot[3][1]*x + rot[3][2]*y + rot[3][3]*z
    return tx, ty, tz
end

local function project3D(x, y, z)
    if z <= 0 then return nil end
    local scale = 80 / z
    return screenW / 2 + x * scale, screenH / 2 - y * scale
end

local function getLinePoints(x0, y0, x1, y1)
    local points = {}
    local dx, dy = math.abs(x1 - x0), math.abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    local err = dx - dy
    while true do
        table.insert(points, {x0, y0})
        if x0 == x1 and y0 == y1 then break end
        local e2 = 2 * err
        if e2 > -dy then err = err - dy; x0 = x0 + sx end
        if e2 < dx then err = err + dx; y0 = y0 + sy end
    end
    return points
end

local function clearPixels()
    for _, px in ipairs(pixelFrames) do
        px:Destroy()
    end
    pixelFrames = {}
end

local function drawLine(x0, y0, x1, y1)
    local points = getLinePoints(math.floor(x0), math.floor(y0), math.floor(x1), math.floor(y1))
    for _, pt in ipairs(points) do
        local px = screen:CreateElement("Frame", {
            Position = UDim2.new(0, pt[1], 0, pt[2]),
            Size = UDim2.new(0, pixelSize, 0, pixelSize),
            BackgroundColor3 = cubeColor,
            BorderSizePixel = 0,
        })
        table.insert(pixelFrames, px)
    end
end

local function renderCube()
    clearPixels()
    local projected = {}
    for _, v in ipairs(cubeVertices) do
        local x, y, z = transformVertex(v, cameraRot, cameraPos)
        local px, py = project3D(x, y, z)
        table.insert(projected, {px, py, z})
    end
    for _, edge in ipairs(cubeEdges) do
        local a, b = projected[edge[1]], projected[edge[2]]
        if a[1] and b[1] then
            drawLine(a[1], a[2], b[1], b[2])
        end
    end
end

local function createButton(label, posX, posY, callback)
    local btn = screen:CreateElement("TextButton", {
        Position = UDim2.new(0, posX, 0, posY),
        Size = UDim2.new(0, 60, 0, 30),
        Text = label,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        TextColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 0
    })
    btn.MouseButton1Click:Connect(callback)
end

createButton("Up", 60, screenH - 100, function()
    cameraRot.pitch = cameraRot.pitch - rotateSpeed
    renderCube()
end)

createButton("Down", 60, screenH - 60, function()
    cameraRot.pitch = cameraRot.pitch + rotateSpeed
    renderCube()
end)

createButton("Left", 0, screenH - 60, function()
    cameraRot.yaw = cameraRot.yaw - rotateSpeed
    renderCube()
end)

createButton("Right", 120, screenH - 60, function()
    cameraRot.yaw = cameraRot.yaw + rotateSpeed
    renderCube()
end)

createButton("Forward", screenW - 120, screenH - 100, function()
    cameraPos.x = cameraPos.x + math.sin(cameraRot.yaw) * moveSpeed
    cameraPos.z = cameraPos.z + math.cos(cameraRot.yaw) * moveSpeed
    renderCube()
end)

createButton("Back", screenW - 120, screenH - 60, function()
    cameraPos.x = cameraPos.x - math.sin(cameraRot.yaw) * moveSpeed
    cameraPos.z = cameraPos.z - math.cos(cameraRot.yaw) * moveSpeed
    renderCube()
end)

renderCube()
