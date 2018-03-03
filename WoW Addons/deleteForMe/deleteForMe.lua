--[[Tutorial: https://www.youtube.com/watch?v=NdESDIs7Ty4]]

local f = CreateFrame("Frame")
f:RegisterEvent("DELETE_ITEM_CONFIRM")

f:SetScript("OnEvent", deleteIt())

function deleteIt(...)
	print("Holy Shit!")
end