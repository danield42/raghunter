local defaultpoint, defaultsizex, defaultsizey = "CENTER", 250, 120
local rh = RH_Globals
local BUTTONS = {}
local TEXTS = {}

local permission = false
local function getpermission() 
	return permission
end
local function setpermission(b)
	permission = b
	rh.permission = permission
end
setpermission(true)
--START FRAME CREATE
--
--
--parent frame 
local title = rh.Name
local frame = CreateFrame("Frame", "rhframe", UIParent)
rh.MainFrame = frame;
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetMinResize(250, 120)
frame:SetMaxResize(250, 400)
frame:EnableMouse(true)
frame:EnableMouseWheel(true)
frame:RegisterForDrag("LeftButton")

local function getdefaults()
	return defaultpoint, defaultsizex, defaultsizey;
end

local function getposition()
	return frame:GetPoint()
end


local texture = frame:CreateTexture()
texture:SetAllPoints() 
texture:SetColorTexture(0,0,0,0.5)
local frametitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frametitle:SetPoint("TOP", 0, -5)
frametitle:SetText(title)

--scrollframe 
local scrollframe = CreateFrame("ScrollFrame", nil, frame) 
scrollframe:SetPoint("TOPLEFT", 10, -20) 
scrollframe:SetPoint("BOTTOMRIGHT", -10, 10) 
local texture = scrollframe:CreateTexture() 
texture:SetAllPoints() 
texture:SetColorTexture(1,0,0,0) 
frame.scrollframe = scrollframe 


--content frame 
local content = CreateFrame("Frame", nil, scrollframe) 
content:SetSize(180, 400) 
local texture = content:CreateTexture() 
texture:SetAllPoints()
texture:SetColorTexture(0,1,0,0) 

scrollframe:SetScrollChild(content)
local function clearbuttonstext()
	for k = 1, #BUTTONS do
		BUTTONS[k]:Disable()
		BUTTONS[k]:Hide()
	end
	for k = 1, #TEXTS do
		TEXTS[k]:Hide()
	end
end
local function printtable(data)
	if (type(data) == "table") then
		for k, v in pairs(data) do
			print (k, v)
		end
	end
end

local function stringifytable(data)
	if data then
		local datastring = ""
		for k,v in pairs(data) do
			datastring = tostring(v .. "\n")
		end
		
		return datastring
	end
end

local function settext(data)
	local plist = ""
	clearbuttonstext()	
	if (type(data) ~= "string" and next(data) ~= nil) then
		for k,v in pairs(data) do
			plist = tostring(v .. "\n")
			if (TEXTS[k] == nil) then
				local contentText = content:CreateFontString(nil, "ARTWORK", GameFontWhite)
				TEXTS[k] = contentText;
				TEXTS[k]:SetPoint("TOPLEFT", 25, -12-((k-1)*20))
				TEXTS[k]:SetFont(rh.font, rh.fontsize)
				TEXTS[k]:SetJustifyH("LEFT")
				TEXTS[k]:SetJustifyV("TOP")
			end
			TEXTS[k]:SetText(v)
			TEXTS[k]:Show()
			
			if (BUTTONS[k] == nil) then
				local b = CreateFrame("BUTTON", nil, content);
				BUTTONS[k] = b
				BUTTONS[k]:RegisterForClicks("LeftButtonUp")
				BUTTONS[k]:SetNormalTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
				BUTTONS[k]:SetPushedTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Down")
				BUTTONS[k]:SetHighlightTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Highlight")
				BUTTONS[k]:SetSize(18,18)
				BUTTONS[k]:SetPoint("TOPLEFT", 5, -11-((k-1)*20))
			end
			BUTTONS[k]:SetText(v)
			BUTTONS[k]:Enable()
			BUTTONS[k]:Show()
			StaticPopupDialogs["KICK" .. k] = {
				text = "Do you really want to kick " .. BUTTONS[k]:GetText() .. "?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function(self)
					rh.groupkick(BUTTONS[k]:GetText());
				end,
				OnCancel = function (_,reason)
					if reason == "timeout" or reason == "clicked" then
					  StaticPopup_Hide("KICK" .. k)
					else
					  -- "override" ...?
					end
				end,
				timeout = 30,
				whileDead = true,
				hideOnEscape = true,
			}
			BUTTONS[k]:SetScript('OnClick', function() StaticPopup_Show("KICK" .. k) end)
		end
	else
		if (type(data) == "table") then
			plist = stringifytable(data)
		else
			plist = data
		end
		if (plist == "") then
			plist = "No jajajas to monitor."
		end
		local contentText = content:CreateFontString(nil, "ARTWORK", GameFontWhite)
		TEXTS[1] = contentText;
		TEXTS[1]:SetPoint("TOPLEFT", 40, -10)
		TEXTS[1]:SetFont(rh.font, rh.fontsize)
		TEXTS[1]:SetJustifyH("LEFT")
		TEXTS[1]:SetJustifyV("TOP")
		TEXTS[1]:SetText(plist)
		TEXTS[1]:Show()
	end
end
rh.settext = settext
local b = CreateFrame("BUTTON", nil, frame);
b:RegisterForClicks("LeftButtonUp")
b:SetNormalFontObject("GameFontNormalSmall")
b:SetNormalTexture("Interface\\BUTTONS\\UI-QuickslotRed")
b:SetPushedTexture("Interface\\BUTTONS\\UI-QuickslotRed")
b:SetHighlightTexture("Interface\\BUTTONS\\UI-QuickslotRed")
b:SetSize(60,20)
b:SetPoint("TOPLEFT", 10,-5)
b:SetText("PURGE")
b:Enable()
b:Show()
b:SetScript('OnClick', function() rh.purgeallplayers() end)

local cb = CreateFrame("CheckButton", nil, frame, "ChatConfigCheckButtonTemplate");
cb:SetPoint("TOPRIGHT", -10, -5);
cb:SetChecked(true)
cb.tooltip = "When checked, " .. rh.Name .. " will ask for permission to eradicate the infection."
cb:SetScript("OnClick", 
  function()
	local perm = getpermission()
    setpermission(not perm)
	cb:SetChecked(not perm)
  end
);


local function resetposition()
	frame:SetSize(defaultsizex, defaultsizey) 
	frame:SetPoint(defaultpoint)
	scrollframe:SetVerticalScroll(0)
end
rh.resetposition = resetposition

frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetScript("OnMouseWheel", 
	function(self, delta)
		local scrollsize = 10;
		if (delta > 0) then 
			scrollsize = scrollsize*-1;
		end
		local oldvert = scrollframe:GetVerticalScroll()
		local newvert = oldvert + scrollsize
		--Stop scrolling up past top
		if (delta >0 and newvert < 0) then
		 -- do nothing
		else
			scrollframe:SetVerticalScroll(newvert)
		end
	end
)
frame:SetScript("OnMouseDown",
	function(self, button)
		if button == "RightButton" then
			frame:StartSizing()
		end
	end
)
frame:SetScript("OnMouseUp",
	function(self, button)
		if button == "RightButton" then
			frame:StopMovingOrSizing()
		end
	end
)

--
--
--END FRAME CREATE