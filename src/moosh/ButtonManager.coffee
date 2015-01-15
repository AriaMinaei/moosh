array = require 'utila/lib/array'
DragHandler = require './buttonManager/DragHandler'
ClickHandler = require './buttonManager/ClickHandler'

module.exports = class ButtonManager

	constructor: (@clickManager, @keyName, @keyCode) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeHandlers = []

		@_lastReceivedEventTypeWas = null

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

				handler._cancel()

			newLength = @_activeHandlers.length

			i += newLength - lastLength + 1

			lastLength = newLength

		@_activeHandlers = [activeHandler]

	_cancelAllActiveHandlers: ->

		lastLength = @_activeHandlers.length
		i = 0

		while lastLength > 0

			handler = @_activeHandlers[i]

			return unless handler?

			handler._cancel()

			newLength = @_activeHandlers.length

			i += newLength - lastLength + 1

			lastLength = newLength

		@_activeHandlers = []

	handleMouseDown: (e, ancestors) ->

		if @_lastReceivedEventTypeWas is 'down'

			@_cancelAllActiveHandlers()

			@_lastReceivedEventTypeWas = 'down'

			return

		@_lastReceivedEventTypeWas = 'down'

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

		if @_lastReceivedEventTypeWas is 'up'

			@_cancelAllActiveHandlers()

			@_lastReceivedEventTypeWas = 'up'

			return

		@_lastReceivedEventTypeWas = 'up'

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

		handler = nodeData[@keyName].clickHandler

		unless handler?

			handler = nodeData[@keyName].clickHandler = new ClickHandler @, nodeData, args

		if args[0] instanceof Function

			handler.onDone args[0]

		handler

	onDrag: (nodeData, args) ->

		handler = nodeData[@keyName].dragHandler

		unless handler?

			handler = nodeData[@keyName].dragHandler = new DragHandler @, nodeData, args

		handler