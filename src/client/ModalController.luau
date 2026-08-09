local GuiService = game:GetService("GuiService")

local ModalController = {}
ModalController.__index = ModalController

function ModalController.new()
	return setmetatable({ current = nil, previousSelection = nil }, ModalController)
end

function ModalController:open(frame: GuiObject, firstSelection: GuiObject?)
	if self.current and self.current ~= frame then
		self.current.Visible = false
	end
	self.previousSelection = GuiService.SelectedObject
	self.current = frame
	frame.Visible = true
	if firstSelection and firstSelection.Selectable then
		GuiService.SelectedObject = firstSelection
	end
end

function ModalController:close(frame: GuiObject?)
	if frame and self.current ~= frame then
		return
	end
	if self.current then
		self.current.Visible = false
	end
	self.current = nil
	if self.previousSelection and self.previousSelection.Parent then
		GuiService.SelectedObject = self.previousSelection
	else
		GuiService.SelectedObject = nil
	end
	self.previousSelection = nil
end

function ModalController:isOpen(): boolean
	return self.current ~= nil
end

return ModalController
