array = require 'utila/lib/array'
DragDetector = require './buttonManager/DragDetector'
ClickDetector = require './buttonManager/ClickDetector'

module.exports = class ButtonManager

	constructor: (@clickManager, @keyName, @keyCode) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeDetectors = []

	_removeDetectorFromActiveDetectorsList: (listener) ->

		array.pluckOneItem @_activeDetectors, listener

		return

	_addDetectorToActiveDetectorsList: (listener) ->

		@_activeDetectors.push listener

		return

	_cancelOthers: (activeDetector) ->

		lastLength = @_activeDetectors.length
		i = 0

		while lastLength > 0

			listener = @_activeDetectors[i]

			return unless listener?

			if activeDetector isnt listener

				do listener._cancel

			newLength = @_activeDetectors.length

			i += newLength - lastLength + 1

			lastLength = newLength

		@_activeDetectors = [activeDetector]

	handleMouseDown: (e, ancestors) ->

		for nodeData in ancestors

			for listener in nodeData[@keyName].clickDetectors

				listener._handleMouseDown e

			for listener in nodeData[@keyName].dragDetectors

				listener._handleMouseDown e

		return

	handleMouseMove: (e, ancestors) ->

		lastLength = @_activeDetectors.length
		i = 0

		while lastLength > 0

			listener = @_activeDetectors[i]

			return unless listener?

			listener._handleMouseMove e

			newLength = @_activeDetectors.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	handleMouseUp: (e, ancestors) ->

		lastLength = @_activeDetectors.length
		i = 0

		while lastLength > 0

			listener = @_activeDetectors[i]

			return unless listener?

			listener._handleMouseUp e

			newLength = @_activeDetectors.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	onClick: (nodeData, args) ->

		l = new ClickDetector @, nodeData, args

		nodeData[@keyName].clickDetectors.push l

		l

	onDrag: (nodeData, args) ->

		l = new DragDetector @, nodeData, args

		nodeData[@keyName].dragDetectors.push l

		l