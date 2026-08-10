local AnalyticsEvents = {}

AnalyticsEvents.Joined = "TW_Joined"
AnalyticsEvents.JoinedNew = "TW_JoinedNew"
AnalyticsEvents.JoinedReturning = "TW_JoinedReturning"
AnalyticsEvents.OnboardingStarted = "TW_OnboardingStarted"
AnalyticsEvents.OnboardingCompleted = "TW_OnboardingCompleted"
AnalyticsEvents.HomeEntered = "TW_HomeEntered"
AnalyticsEvents.FirstHomeInteraction = "TW_FirstHomeInteraction"
AnalyticsEvents.CurrencyEarned = "TW_CurrencyEarned"
AnalyticsEvents.HomePurchase = "TW_HomePurchase"
AnalyticsEvents.FurniturePlaced = "TW_FurniturePlaced"
AnalyticsEvents.CareerCompleted = "TW_CareerCompleted"
AnalyticsEvents.PortalEntered = "TW_PortalEntered"
AnalyticsEvents.PortalCompleted = "TW_PortalCompleted"
AnalyticsEvents.HomeVisit = "TW_HomeVisit"
AnalyticsEvents.TradeCompleted = "TW_TradeCompleted"
AnalyticsEvents.SessionDuration = "TW_SessionDuration"

local ALLOWED = {}
for _, eventName in AnalyticsEvents do
	if type(eventName) == "string" then
		ALLOWED[eventName] = true
	end
end

function AnalyticsEvents.isAllowed(eventName: string): boolean
	return ALLOWED[eventName] == true
end

return AnalyticsEvents
