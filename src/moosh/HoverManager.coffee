array = require 'utila/lib/array'
HoverDetector = require './hoverManager/HoverDetector'

module.exports = class HoverManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeDetectors = []

	onHover: (nodeData, args) ->

		l = new HoverDetector @, nodeData, args

		nodeData.hoverDetectors.push l

		l

	handleMouseMove: (e, ancestors) ->

		@_checkMouseLeaveForActiveDetectors e, ancestors

		for nodeData in ancestors

			# let's iterate through all of this node's hover listeners
			for listener in nodeData.hoverDetectors

				listener._handleMouseMove e

		return

	# calls 'leave' on elements outside the pointer
	_checkMouseLeaveForActiveDetectors: (e, ancestors) ->

		for listener in @_activeDetectors.slice 0

			listener._checkIfShouldLeave e, ancestors

		return

	_removeDetectorFromActiveDetectorsList: (listener) ->

		array.pluckOneItem @_activeDetectors, listener

		return

	_addDetectorToActiveDetectorsList: (listener) ->

		@_activeDetectors.push listener

		return