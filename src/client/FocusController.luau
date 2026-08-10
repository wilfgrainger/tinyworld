local FocusController = {}

function FocusController.chain(buttons: { GuiButton })
	for index, button in buttons do
		local previous = buttons[index - 1]
		local nextButton = buttons[index + 1]
		button.NextSelectionUp = previous
		button.NextSelectionDown = nextButton
		button.NextSelectionLeft = previous
		button.NextSelectionRight = nextButton
	end
end

function FocusController.grid(buttons: { GuiButton }, columns: number)
	for index, button in buttons do
		button.NextSelectionLeft = buttons[index - 1]
		button.NextSelectionRight = buttons[index + 1]
		button.NextSelectionUp = buttons[index - columns]
		button.NextSelectionDown = buttons[index + columns]
	end
end

return FocusController
