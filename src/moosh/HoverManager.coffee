array = require 'utila/lib/array'
HoverHandler = require './hoverManager/HoverHandler'

module.exports = class HoverManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeHandlers = []

	onHover: (nodeData, args) ->

		handler = nodeData.hoverHandler

		unless handler?

			handler = nodeData.hoverHandler = new HoverHandler @, nodeData, args

		handler

	handleMouseMove: (e, ancestors) ->

		@_checkMouseLeaveForActiveHandlers e, ancestors

		for nodeData in ancestors

			# let's iterate through all of this node's hover listeners
			nodeData.hoverHandler?._handleMouseMove e

		return

	# calls 'leave' on elements outside the pointer
	_checkMouseLeaveForActiveHandlers: (e, ancestors) ->

		for handler in @_activeHandlers.slice 0

			handler._checkIfShouldLeave e, ancestors

		return

	_removeHandlerFromActiveHandlersList: (handler) ->

		array.pluckOneItem @_activeHandlers, handler

		return

	_addHandlerToActiveHandlersList: (handler) ->

		@_activeHandlers.push handler

		return