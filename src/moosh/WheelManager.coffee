array = require 'utila/lib/array'
WheelDetector = require './wheelManager/WheelDetector'

module.exports = class WheelManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

	onWheel: (nodeData, args) ->

		l = new WheelDetector @, nodeData, args

		nodeData.wheelDetectors.push l

		l

	handleMouseWheel: (e, ancestors) ->

		for nodeData in ancestors

			# let's iterate through all of this node's wheel listeners
			for listener in nodeData.wheelDetectors

				listener._handleMouseWheel e

		return