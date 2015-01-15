array = require 'utila/lib/array'
WheelHandler = require './wheelManager/WheelHandler'

module.exports = class WheelManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

	onWheel: (nodeData, args) ->

		handler = nodeData.wheelHandler

		unless handler?

			handler = nodeData.wheelHandler = new WheelHandler @, nodeData, args

		handler

	handleMouseWheel: (e, ancestors) ->

		for nodeData in ancestors

			nodeData.wheelHandler?._handleMouseWheel e

		return