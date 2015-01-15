array = require 'utila/lib/array'
HoverDetector = require './hoverManager/HoverDetector'

module.exports = class HoverManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeDetectors = []

	onHover: (nodeData, args) ->

		detector = nodeData.hoverDetector

		unless detector?

			detector = nodeData.hoverDetector = new HoverDetector @, nodeData, args

		detector

	handleMouseMove: (e, ancestors) ->

		@_checkMouseLeaveForActiveDetectors e, ancestors

		for nodeData in ancestors

			# let's iterate through all of this node's hover listeners
			nodeData.hoverDetector?._handleMouseMove e

		return

	# calls 'leave' on elements outside the pointer
	_checkMouseLeaveForActiveDetectors: (e, ancestors) ->

		for detector in @_activeDetectors.slice 0

			detector._checkIfShouldLeave e, ancestors

		return

	_removeDetectorFromActiveDetectorsList: (detector) ->

		array.pluckOneItem @_activeDetectors, detector

		return

	_addDetectorToActiveDetectorsList: (detector) ->

		@_activeDetectors.push detector

		return