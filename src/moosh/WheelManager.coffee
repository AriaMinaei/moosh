array = require 'utila/lib/array'
WheelDetector = require './wheelManager/WheelDetector'

module.exports = class WheelManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

	onWheel: (nodeData, args) ->

		detector = nodeData.wheelDetector

		unless detector?

			detector = nodeData.wheelDetector = new WheelDetector @, nodeData, args

		detector

	handleMouseWheel: (e, ancestors) ->

		for nodeData in ancestors

			nodeData.wheelDetector?._handleMouseWheel e

		return