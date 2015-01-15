array = require 'utila/lib/array'
DragDetector = require './buttonManager/DragDetector'
ClickDetector = require './buttonManager/ClickDetector'

module.exports = class ButtonManager

	constructor: (@clickManager, @keyName, @keyCode) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeDetectors = []

	_removeDetectorFromActiveDetectorsList: (detector) ->

		array.pluckOneItem @_activeDetectors, detector

		return

	_addDetectorToActiveDetectorsList: (detector) ->

		@_activeDetectors.push detector

		return

	_cancelOthers: (activeDetector) ->

		lastLength = @_activeDetectors.length
		i = 0

		while lastLength > 0

			detector = @_activeDetectors[i]

			return unless detector?

			if activeDetector isnt detector

				do detector._cancel

			newLength = @_activeDetectors.length

			i += newLength - lastLength + 1

			lastLength = newLength

		@_activeDetectors = [activeDetector]

	handleMouseDown: (e, ancestors) ->

		for nodeData in ancestors

			nodeData[@keyName].clickDetector?._handleMouseDown e

			nodeData[@keyName].dragDetector?._handleMouseDown e

		return

	handleMouseMove: (e, ancestors) ->

		lastLength = @_activeDetectors.length
		i = 0

		while lastLength > 0

			detector = @_activeDetectors[i]

			return unless detector?

			detector._handleMouseMove e

			newLength = @_activeDetectors.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	handleMouseUp: (e, ancestors) ->

		lastLength = @_activeDetectors.length
		i = 0

		while lastLength > 0

			detector = @_activeDetectors[i]

			return unless detector?

			detector._handleMouseUp e

			newLength = @_activeDetectors.length

			i += newLength - lastLength + 1

			lastLength = newLength

		return

	onClick: (nodeData, args) ->

		detector = nodeData.clickDetector

		unless detector?

			detector = nodeData[@keyName].clickDetector = new ClickDetector @, nodeData, args

		detector

	onDrag: (nodeData, args) ->

		detector = nodeData.dragDetector

		unless detector?

			detector = nodeData[@keyName].dragDetector = new DragDetector @, nodeData, args

		detector