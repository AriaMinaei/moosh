array = require 'utila/lib/array'
DragHandler = require './buttonManager/DragHandler'
ClickHandler = require './buttonManager/ClickHandler'

module.exports = class ButtonManager

	constructor: (@clickManager, @keyName, @keyCode) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeHandlers = []

	_removeHandlerFromActiveHandlersList: (handler) ->

		array.pluckOneItem @_activeHandlers, handler

		return

	_addHandlerToActiveHandlersList: (handler) ->

		@_activeHandlers.push handler

		return

	_cancelOthers: (activeHandler) ->

		lastLength = @_activeHandlers.length
		i = 0

		while lastLength > 0

			handler = @_activeHandlers[i]

			return unless handler?

			if activeHandler isnt handler

				do handler._cancel

			newLength = @_activeHandlers.length

			i += newLength - lastLength + 1

			lastLength = newLength

		@_activeHandlers = [activeHandler]

	handleMouseDown: (e, ancestors) ->

		for nodeData in ancestors

			nodeData[@keyName].clickHandler?._handleMouseDown e

			nodeData[@keyName].dragHandler?._handleMouseDown e

		return

	handleMouseMove: (e, ancestors) ->

		lastLength = @_activeHandlers.length
		i = 0

		while lastLength > 0

			handler = @_activeHandlers[i]

			return unless handler?

			handler._handleMouseMove e

			newLength = @_activeHandlers.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	handleMouseUp: (e, ancestors) ->

		lastLength = @_activeHandlers.length
		i = 0

		while lastLength > 0

			handler = @_activeHandlers[i]

			return unless handler?

			handler._handleMouseUp e

			newLength = @_activeHandlers.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	onClick: (nodeData, args) ->

		handler = nodeData.clickHandler

		unless handler?

			handler = nodeData[@keyName].clickHandler = new ClickHandler @, nodeData, args

		handler

	onDrag: (nodeData, args) ->

		handler = nodeData.dragHandler

		unless handler?

			handler = nodeData[@keyName].dragHandler = new DragHandler @, nodeData, args

		handler