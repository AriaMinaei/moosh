array = require 'utila/lib/array'
WheelListener = require './wheelManager/WheelListener'

module.exports = class WheelManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

	onWheel: (nodeData, args) ->

		l = new WheelListener @, nodeData, args

		nodeData.wheelListeners.push l

		l

	handleMouseWheel: (e, ancestors) ->

		for nodeData in ancestors

			# let's iterate through all of this node's wheel listeners
			for listener in nodeData.wheelListeners

				listener._handleMouseWheel e

		return