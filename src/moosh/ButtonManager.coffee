array = require 'utila/lib/array'
DragListener = require './buttonManager/DragListener'
ClickListener = require './buttonManager/ClickListener'

module.exports = class ButtonManager

	constructor: (@clickManager, @keyName, @keyCode) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeListeners = []

		@_shouldCancelNextContextMenu = no

	_removeListenerFromActiveListenersList: (listener) ->

		array.pluckOneItem @_activeListeners, listener

		return

	_addListenerToActiveListenersList: (listener) ->

		@_activeListeners.push listener

		return

	_cancelOthers: (activeListener) ->

		lastLength = @_activeListeners.length
		i = 0

		while lastLength > 0

			listener = @_activeListeners[i]

			return unless listener?

			if activeListener isnt listener

				do listener._cancel

			newLength = @_activeListeners.length

			i += newLength - lastLength + 1

			lastLength = newLength

		@_activeListeners = [activeListener]

	handleMouseDown: (e, ancestors) ->

		for nodeData in ancestors

			for listener in nodeData[@keyName].clickListeners

				listener._handleMouseDown e

			for listener in nodeData[@keyName].dragListeners

				listener._handleMouseDown e

		return

	handleMouseMove: (e, ancestors) ->

		lastLength = @_activeListeners.length
		i = 0

		while lastLength > 0

			listener = @_activeListeners[i]

			return unless listener?

			listener._handleMouseMove e

			newLength = @_activeListeners.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	handleMouseUp: (e, ancestors) ->

		lastLength = @_activeListeners.length
		i = 0

		while lastLength > 0

			listener = @_activeListeners[i]

			return unless listener?

			listener._handleMouseUp e

			newLength = @_activeListeners.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	onClick: (nodeData, args) ->

		l = new ClickListener @, nodeData, args

		nodeData[@keyName].clickListeners.push l

		l

	onDrag: (nodeData, args) ->

		l = new DragListener @, nodeData, args

		nodeData[@keyName].dragListeners.push l

		l

	handleContextMenu: (e) ->

		if @_shouldCancelNextContextMenu
			e.stopPropagation()
			e.preventDefault()

		@_shouldCancelNextContextMenu = no

	cancelNextContextMenu: ->

		@_shouldCancelNextContextMenu = yes