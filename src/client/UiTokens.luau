local UiTokens = {}

UiTokens.TouchTarget = 44
UiTokens.CornerRadius = 12
UiTokens.PanelPadding = 14
UiTokens.Gap = 10
UiTokens.ModalDisplayOrder = 100
UiTokens.ToastDisplayOrder = 50
UiTokens.HudDisplayOrder = 10

UiTokens.Colors = {
	Ink = Color3.fromRGB(35, 43, 54),
	InkSoft = Color3.fromRGB(75, 84, 96),
	Paper = Color3.fromRGB(250, 244, 226),
	PaperSoft = Color3.fromRGB(237, 229, 207),
	Meadow = Color3.fromRGB(104, 153, 93),
	Sky = Color3.fromRGB(90, 151, 191),
	Berry = Color3.fromRGB(184, 91, 119),
	Gold = Color3.fromRGB(232, 183, 73),
	Danger = Color3.fromRGB(183, 71, 65),
	Success = Color3.fromRGB(72, 139, 91),
	GhostValid = Color3.fromRGB(114, 194, 125),
	GhostInvalid = Color3.fromRGB(210, 89, 84),
}

UiTokens.Fonts = {
	Body = Enum.Font.Gotham,
	Strong = Enum.Font.GothamBold,
	Title = Enum.Font.GothamBlack,
}

return UiTokens
