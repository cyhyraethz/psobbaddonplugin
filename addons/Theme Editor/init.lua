-- Start LIP
--[[
    Copyright (c) 2012 Carreras Nicolas

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the Software), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]
--- Lua INI Parser.
-- It has never been that simple to use INI files with Lua.
--@author Dynodzzo

local LIP = {};

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function LIP.load(fileName)
    assert(type(fileName) == 'string', 'Parameter fileName must be a string.');
    local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
    local data = {};
    local section;
    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]$');
        if(tempSection)then
            section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
            data[section] = data[section] or {};
        end
        local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
        if(param and value ~= nil)then
            if(tonumber(value))then
                value = tonumber(value);
            elseif(value == 'true')then
                value = true;
            elseif(value == 'false')then
                value = false;
            end
            if(tonumber(param))then
                param = tonumber(param);
            end
            data[section][param] = value;
        end
    end
    file:close();
    return data;
end

--- Saves all the data from a table to an INI file.
--@param fileName The name of the INI file to fill. [string]
--@param data The table containing all the data to store. [table]
function LIP.save(fileName, data)
    assert(type(fileName) == 'string', 'Parameter fileName must be a string.');
    assert(type(data) == 'table', 'Parameter data must be a table.');
    local file = assert(io.open(fileName, 'w+b'), 'Error loading file :' .. fileName);
    local contents = '';
    for section, param in pairs(data) do
        contents = contents .. ('[%s]\n'):format(section);
        for key, value in pairs(param) do
            contents = contents .. ('%s=%s\n'):format(key, tostring(value));
        end
        contents = contents .. '\n';
    end
    file:write(contents);
    file:close();
end
-- End LIP

local fontGlobalScale = 1.0
local colorList = {
    { name = "Text"                 , color = "FFFFFFFF" },
    { name = "TextDisabled"         , color = "7F7F7FFF" },
    { name = "WindowBg"             , color = "0F0F0FEF" },
    { name = "ChildBg"              , color = "00000000" },
    { name = "PopupBg"              , color = "141414EF" },
    { name = "Border"               , color = "6D6D7F7F" },
    { name = "BorderShadow"         , color = "00000000" },
    { name = "FrameBg"              , color = "28497A89" },
    { name = "FrameBgHovered"       , color = "4296F966" },
    { name = "FrameBgActive"        , color = "4296F9AA" },
    { name = "TitleBg"              , color = "0A0A0AFF" },
    { name = "TitleBgActive"        , color = "28497AFF" },
    { name = "TitleBgCollapsed"     , color = "00000082" },
    { name = "MenuBarBg"            , color = "232323FF" },
    { name = "ScrollbarBg"          , color = "05050587" },
    { name = "ScrollbarGrab"        , color = "4F4F4FFF" },
    { name = "ScrollbarGrabHovered" , color = "686868FF" },
    { name = "ScrollbarGrabActive"  , color = "828282FF" },
    { name = "CheckMark"            , color = "4296F9FF" },
    { name = "SliderGrab"           , color = "3D84E0FF" },
    { name = "SliderGrabActive"     , color = "4296F9FF" },
    { name = "Button"               , color = "4296F966" },
    { name = "ButtonHovered"        , color = "4296F9FF" },
    { name = "ButtonActive"         , color = "0F87F9FF" },
    { name = "Header"               , color = "4296F94F" },
    { name = "HeaderHovered"        , color = "4296F9CC" },
    { name = "HeaderActive"         , color = "4296F9FF" },
    { name = "Separator"            , color = "6D6D7F7F" },
    { name = "SeparatorHovered"     , color = "1966BFC6" },
    { name = "SeparatorActive"      , color = "1966BFFF" },
    { name = "ResizeGrip"           , color = "4296F93F" },
    { name = "ResizeGripHovered"    , color = "4296F9AA" },
    { name = "ResizeGripActive"     , color = "4296F9F2" },
    { name = "Tab"                  , color = "2D5993DB" },
    { name = "TabHovered"           , color = "4296F9CC" },
    { name = "TabActive"            , color = "3268ADFF" },
    { name = "TabUnfocused"         , color = "111A25F7" },
    { name = "TabUnfocusedActive"   , color = "22426CFF" },
    { name = "PlotLines"            , color = "9B9B9BFF" },
    { name = "PlotLinesHovered"     , color = "FF6D59FF" },
    { name = "PlotHistogram"        , color = "E5B200FF" },
    { name = "PlotHistogramHovered" , color = "FF9900FF" },
    { name = "TextSelectedBg"       , color = "4296F959" },
    { name = "DragDropTarget"       , color = "FFFF00E5" },
    { name = "NavHighlight"         , color = "4296F9FF" },
    { name = "NavWindowingHighlight", color = "FFFFFFB2" },
    { name = "NavWindowingDimBg"    , color = "CCCCCC33" },
    { name = "ModalWindowDimBg"     , color = "CCCCCC59" },
}

local core_mainmenu = require("core_mainmenu")

local enable = false
local themFileName = "addons/theme.ini"
local theme =
{
    ImGuiIO = {
        FontGlobalScale = 1.0,
    },
    ImGuiStyle = {
        Alpha                 = 1.0,
        Text                  = "FFE5E5E5",
        Text                  = "FFFFFFFF",
        TextDisabled          = "7F7F7FFF",
        WindowBg              = "0F0F0FEF",
        ChildBg               = "00000000",
        PopupBg               = "141414EF",
        Border                = "6D6D7F7F",
        BorderShadow          = "00000000",
        FrameBg               = "28497A89",
        FrameBgHovered        = "4296F966",
        FrameBgActive         = "4296F9AA",
        TitleBg               = "0A0A0AFF",
        TitleBgActive         = "28497AFF",
        TitleBgCollapsed      = "00000082",
        MenuBarBg             = "232323FF",
        ScrollbarBg           = "05050587",
        ScrollbarGrab         = "4F4F4FFF",
        ScrollbarGrabHovered  = "686868FF",
        ScrollbarGrabActive   = "828282FF",
        CheckMark             = "4296F9FF",
        SliderGrab            = "3D84E0FF",
        SliderGrabActive      = "4296F9FF",
        Button                = "4296F966",
        ButtonHovered         = "4296F9FF",
        ButtonActive          = "0F87F9FF",
        Header                = "4296F94F",
        HeaderHovered         = "4296F9CC",
        HeaderActive          = "4296F9FF",
        Separator             = "6D6D7F7F",
        SeparatorHovered      = "1966BFC6",
        SeparatorActive       = "1966BFFF",
        ResizeGrip            = "4296F93F",
        ResizeGripHovered     = "4296F9AA",
        ResizeGripActive      = "4296F9F2",
        Tab                   = "2D5993DB",
        TabHovered            = "4296F9CC",
        TabActive             = "3268ADFF",
        TabUnfocused          = "111A25F7",
        TabUnfocusedActive    = "22426CFF",
        PlotLines             = "9B9B9BFF",
        PlotLinesHovered      = "FF6D59FF",
        PlotHistogram         = "E5B200FF",
        PlotHistogramHovered  = "FF9900FF",
        TextSelectedBg        = "4296F959",
        DragDropTarget        = "FFFF00E5",
        NavHighlight          = "4296F9FF",
        NavWindowingHighlight = "FFFFFFB2",
        NavWindowingDimBg     = "CCCCCC33",
        ModalWindowDimBg      = "CCCCCC59",
    }
}

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
 end

local function ParseTheme()
    if file_exists(themFileName) then
        local savedTheme = LIP.load(themFileName);

        if savedTheme.ImGuiStyle == nil or savedTheme.ImGuiIO == nil then
            return;
        end

        theme = savedTheme
    end
end

local function ExportTheme()
    LIP.save(themFileName, theme)
    pso.reload_custom_theme()
end

local function Round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function F32ToInt8(value)
    return Round(value * 255)
end

local function FloatsToColor(color)
    local color =
        bit.lshift(bit.band(F32ToInt8(color.r), 0xFF), 24) +
        bit.lshift(bit.band(F32ToInt8(color.g), 0xFF), 16) +
        bit.lshift(bit.band(F32ToInt8(color.b), 0xFF), 8) +
        bit.lshift(bit.band(F32ToInt8(color.a), 0xFF), 0)
    return color
end

local function ColorAsFloats(color)
    color = color or 0xFFFFFFFF

    local r = bit.band(bit.rshift(color, 24), 0xFF) / 255;
    local g = bit.band(bit.rshift(color, 16), 0xFF) / 255;
    local b = bit.band(bit.rshift(color, 8), 0xFF) / 255;
    local a = bit.band(color, 0xFF) / 255;

    return { r = r, g = g, b = b, a = a }
end

-- UI stuff
local function PresentColorEditor(label, default, custom, index)
    custom = custom or 0xFFFFFFFF

    local changed = false
    local i_default = ColorAsFloats(default)
    local i_custom = ColorAsFloats(custom)
    
    imgui.BeginGroup()
    imgui.PushID(label)
    
    result, i_custom.r, i_custom.g, i_custom.b, i_custom.a = imgui.ColorEdit4(label, i_custom.r, i_custom.g, i_custom.b, i_custom.a)
    
    default = FloatsToColor(i_default)
    custom = FloatsToColor(i_custom)
    
    
    if index == 1 then
        print('Color')
        print(string.format("%08X", custom))
    end
    
    if custom ~= default then
        imgui.SameLine(0, 5)
        if imgui.Button("Revert") then
            custom = default
        end
    end

    imgui.PopID()
    imgui.EndGroup()

    return custom
end

local function PresentColorEditors()
    imgui.SetNextWindowSize(500, 400, 'FirstUseEver')
    if imgui.Begin("Theme Editor") then
        if imgui.Button("Save") then
            ExportTheme()
        end

        local success = false
        if theme.ImGuiIO['FontGlobalScale'] == nil then
            theme.ImGuiIO['FontGlobalScale'] = fontGlobalScale
        end

        imgui.PushItemWidth(150)
        success, theme.ImGuiIO['FontGlobalScale'] = imgui.DragFloat("Font Global Scale", theme.ImGuiIO['FontGlobalScale'], 0.01, 0.1, 10)
        imgui.PopItemWidth()

        if fontGlobalScale ~= theme.ImGuiIO['FontGlobalScale'] then
            imgui.SameLine(0, 5)
            if imgui.Button("Revert") then
                theme.ImGuiIO['FontGlobalScale'] = fontGlobalScale
            end
        end

        imgui.BeginChild("ColorList", 0)
        for i = 1, table.getn(colorList), 1 do
            if theme.ImGuiStyle[colorList[i].name] == nil then
                theme.ImGuiStyle[colorList[i].name] = colorList[i].color
            end
            
            local result = PresentColorEditor(colorList[i].name, tonumber("0x" .. colorList[i].color), tonumber("0x" .. theme.ImGuiStyle[colorList[i].name]), i)
            theme.ImGuiStyle[colorList[i].name] = string.format("%08X", result)
        end
        imgui.EndChild()
    end
    imgui.End()
end

local function present()
    if enable == false then
        return
    end

    PresentColorEditors()
end

local function init()
    local function mainMenuButtonHandler()
        -- Parse theme since we will enable the window
        if enable == false then
            ParseTheme()
        end
        enable = not enable
    end

    core_mainmenu.add_button("Theme Editor", mainMenuButtonHandler)

    return
    {
        name = "Theme Editor",
        version = "1.1.0",
        author = "Solybum",
        description = "Theme editor for framework global theme",
        present = present,
    }
end

return
{
    __addon =
    {
        init = init
    }
}
