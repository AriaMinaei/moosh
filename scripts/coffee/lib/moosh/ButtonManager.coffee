array = require 'utila/scripts/js/lib/array'
DragListener = require './buttonManager/DragListener'
ClickListener = require './buttonManager/ClickListener'

module.exports = class ButtonManager

	constructor: (@clickManager, @keyName, @keyCode) ->

		@_keys = @clickManager._keys

		@_activeListeners = []

	_removeListenerFromActiveListenersList: (listener) ->

		array.pluckOneItem @_activeListeners, listener

		return

	_addListenerToActiveListenersList: (listener) ->

		@_activeListeners.push listener

		return

	handleMouseDown: (e, ancestors) ->

		for nodeData in ancestors

			for listener in nodeData[@keyName].clickListeners

				listener._handleMouseDown e

			for listener in nodeData[@keyName].dragListeners

				listener._handleMouseDown e

			return if @_activeListeners.length > 0

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