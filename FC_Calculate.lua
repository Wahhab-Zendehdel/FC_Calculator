local addonName, addonTable = ...
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("FC_Calculate", {
    type = "data source",
    text = "FC_Calculate",
    icon = "Interface\\Icons\\achievement_guild_level10",
    OnClick = function(_, button)
        if button == "LeftButton" then
            if FC_CalculateFrame:IsShown() then
                FC_CalculateFrame:Hide()
            else
                FC_CalculateFrame:Show()
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("FC_Calculate")
        tooltip:AddLine("Left-click to toggle the addon frame")
    end,
})

local icon = LibStub("LibDBIcon-1.0")

-- Saved variables for minimap icon position
addonTable.db = {
    profile = {
        minimap = {
            hide = false,
        },
    },
}

-- Register the minimap icon
icon:Register("FC_Calculate", LDB, addonTable.db.profile.minimap)

-- Frame definition
local frame = CreateFrame("Frame", "FC_CalculateFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(500, 300)  -- Increased frame size to fit elements comfortably
frame:SetPoint("CENTER", UIParent, "CENTER")

-- Enable frame dragging
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Add background texture
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(true)
frame.bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")

-- Title
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
frame.title:SetText("Raid Pot Calculator")

-- Labels on the left
local label1 = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
label1:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
label1:SetText("Members:")

local label2 = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
label2:SetPoint("TOPLEFT", label1, "BOTTOMLEFT", 0, -35)
label2:SetText("Total Pot:")

local label3 = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
label3:SetPoint("TOPLEFT", label2, "BOTTOMLEFT", 0, -35)
label3:SetText("Advertisers:")

local label4 = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
label4:SetPoint("TOPLEFT", label3, "BOTTOMLEFT", 0, -35)
label4:SetText("Adv Percent:")

-- Text boxes in the middle
local function createTextbox(name, point, relativeFrame, relativePoint, x, y)
    local textbox = CreateFrame("EditBox", name, frame, "InputBoxTemplate")
    textbox:SetSize(100, 30)
    textbox:SetPoint(point, relativeFrame, relativePoint, x, y)
    textbox:SetAutoFocus(false)
    textbox:SetMaxLetters(10)
    textbox:SetNumeric(true)
    return textbox
end

local membersTextbox = createTextbox("MembersTextbox", "LEFT", label1, "RIGHT", 52, 0)
local totalPotTextbox = createTextbox("TotalPotTextbox", "LEFT", label2, "RIGHT", 53, 0)
local advertisersTextbox = createTextbox("AdvertisersTextbox", "LEFT", label3, "RIGHT", 41, 0)
local advPercentTextbox = createTextbox("AdvPercentTextbox", "LEFT", label4, "RIGHT", 35, 0)

-- Button at the bottom
local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 35)
button:SetSize(140, 40)
button:SetText("Calculate")
button:SetNormalFontObject("GameFontNormalLarge")
button:SetHighlightFontObject("GameFontHighlightLarge")

-- Result display on the right side
local resultFrame = CreateFrame("Frame", nil, frame)
resultFrame:SetSize(280, 120)  -- Adjusted result frame size to fit within the larger frame
resultFrame:SetPoint("LEFT", membersTextbox, "RIGHT", -10, -130)

-- Result text
resultFrame.text = resultFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
resultFrame.text:SetPoint("TOPLEFT", resultFrame, "TOPLEFT", 10, -10)
resultFrame.text:SetWidth(260)  -- Adjusted width to fit text properly
resultFrame.text:SetText("")

-- Button click event
button:SetScript("OnClick", function()
    local members = tonumber(membersTextbox:GetText())
    local total_pot = tonumber(totalPotTextbox:GetText())
    local advertisers = tonumber(advertisersTextbox:GetText())
    local adv_percent = tonumber(advPercentTextbox:GetText()) / 100

    if not members or not total_pot or not advertisers or not adv_percent then
        resultFrame.text:SetText("Please fill in all fields.")
        return
    end

    local split = total_pot * adv_percent
    local normal_cut = (total_pot - split) / members
    local adv_cut = normal_cut + (split / advertisers)

    resultFrame.text:SetText(string.format("Member cut: %.2f\nAdvertiser cut: %.2f", normal_cut, adv_cut))
end)
