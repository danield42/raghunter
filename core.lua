--
-- To do:
--    Implement SavedVariables for position data
--
--
--

local rh = RH_Globals
local banlist = rh.Banlist
local InfoAddonPlayerInfoFrame,events = CreateFrame("FRAME"),{}
local eventHandler = CreateFrame("FRAME")
eventHandler:RegisterEvent("ADDON_LOADED")
function eventHandler:OnEvent(event, arg1)
	print("Loading: " .. arg1)
	if (event == "ADDON_LOADED" and arg1 == rh.Name) then
		updatecontent()
	end
end

-- local functions
local function printtable(data)
	if (type(data) == "table") then
		for k, v in pairs(data) do
			print (k, v)
		end
	end
end

local function inlist(data)
	for k, v in pairs(banlist) do
		if (string.match(data:lower(),v:lower())) then
			return true;
		end
	end
	return false;
end

local function israg(v)
	for name, server in string.gmatch(v, "(%a+)-(.+)") do
		if inlist(server) then
			return true;
		end
		
	end
	return false;
end
local function getraglist(plist)
	if (plist == nil) then
		plist = GetHomePartyInfo()
	end
	if (type(plist) == "table") then
		if plist then
			local raglist = {}
			for k,v in pairs(plist) do
				if (israg(v)) then
					table.insert(raglist, v)
				end
			end
			return raglist
		end
	else
		return ""
	end
end
rh.getraglist = getraglist

local function getpartylist()
	return GetHomePartyInfo()
end

local function printme()
	print(GetUnitFullName("player"));
end

local function printplayerlist(plist)
	printme()
	if IsInGroup() or IsInRaid() then
		if (plist) then
			print(plist)
		end
	end
end


local function toggleui()
	if rh.MainFrame:IsShown() then
		rh.MainFrame:Hide()
	else
		rh.MainFrame:Show()
	end
end

--TO DO

local function reset()
	rh.resetposition();
end

local function updatecontent()
	rh.settext(getraglist(getpartylist()))
end

local function reallypurgeallplayers()
	updatecontent()
	local raglist = getraglist(getpartylist())
	if (type(raglist) == "table" and next(raglist) ~= nil) then
		for k=1,#raglist do
			UninviteUnit(raglist[k], "No jajaja");
		end
	else
		print ("No jajajas to purge")
	end
end
local function groupkick(name)
	if (rh.permission) then
		UninviteUnit(name, "No jajaja")
	end
end
rh.groupkick = groupkick
local function purgeallplayers()
	if (rh.permission) then
		StaticPopupDialogs["PURGE"] = {
			text = "Permission to wipe this scum from the group, O Captain! My Captain?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function(self)
				reallypurgeallplayers()
			end,
			OnCancel = function (_,reason)
				if reason == "timeout" or reason == "clicked" then
				  StaticPopup_Hide("PURGE")
				else
				  -- "override" ...?
				end
			end,
			timeout = 30,
			whileDead = true,
			hideOnEscape = true,
		}
		StaticPopup_Show("PURGE")
	else
		reallypurgeallplayers()
	end
end
rh.purgeallplayers = purgeallplayers

-- Event handlers
function events:GROUP_ROSTER_UPDATE(...)
	updatecontent();
end
for k,v in pairs(events) do
	InfoAddonPlayerInfoFrame:RegisterEvent(k);
end
-- Set Script
InfoAddonPlayerInfoFrame:SetScript("OnEvent", function (self, event, ...)
	events[event](self, ...);	
end);


SLASH_RH1, SLASH_RH2 = '/rh', '/raghunter'
local function handler(msg, editBox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    -- Any leading non-whitespace is captured into command
    -- the rest (minus leading whitespace) is captured into rest.
    if (command == "info" or command == "version") then
        print("Name: ", rh.Name)
		print("Version: ", rh.Version)
		print("Author: ", rh.Author)
    elseif command == "list" then
		updatecontent()
    elseif command == "purge" then
		purgeallplayers()
	
	elseif command == "reset" then
		reset()
	else
        -- If not handled above, display some sort of help message
        toggleui()
    end
end

SlashCmdList["RH"] = handler