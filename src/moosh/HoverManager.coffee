array = require 'utila/lib/array'
HoverListener = require './hoverManager/HoverListener'

module.exports = class HoverManager

	constructor: (@clickManager) ->

		@_kilidScope = @clickManager._kilidScope

		@_activeListeners = []

	onHover: (nodeData, args) ->

		l = new HoverListener @, nodeData, args

		nodeData.hoverListeners.push l

		l

	handleMouseMove: (e, ancestors) ->

		@_checkMouseLeaveForActiveListeners e, ancestors

		for nodeData in ancestors

			# let's iterate through all of this node's hover listeners
			for listener in nodeData.hoverListeners

				if listener._handleMouseMove(e) is yes

					@_cancelOthers listener

					return

		return

	_cancelOthers: (activeListener) ->

		lastLength = @_activeListeners.length
		i = 0

		loop

			listener = @_activeListeners.pop()

			break unless listener?

			continue if listener is activeListener

			listener._forceLeave()

		@_activeListeners = [activeListener]

		# while lastLength > 0

		# 	listener = @_activeListeners[i]

		# 	return unless listener?

		# 	if activeListener isnt listener

		# 		do listener._cancel

		# 	newLength = @_activeListeners.length

		# 	i += newLength - lastLength + 1

		# 	lastLength = newLength

		# @_activeListeners = [activeListener]

	# calls 'leave' on elements outside the pointer
	_checkMouseLeaveForActiveListeners: (e, ancestors) ->

		for listener in @_activeListeners.slice 0

			listener._checkIfShouldLeave e, ancestors

		return

	_removeListenerFromActiveListenersList: (listener) ->

		array.pluckOneItem @_activeListeners, listener

		return

	_addListenerToActiveListenersList: (listener) ->

		@_activeListeners.push listener

		return