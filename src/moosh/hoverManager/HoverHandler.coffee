GestureHandler = require '../GestureHandler'

module.exports = class HoverHandler extends GestureHandler

	constructor: (@_manager, @_nodeData) ->

		super

		@_mouseIsOverNode = no

		@_lastReceivedMouseEvent = null

	_startCombo: ->

		@_enter() if @_mouseIsOverNode

		return

	_endCombo: ->

		@_leave() if @_mouseIsOverNode

		return

	_enter: ->

		@_modifyEvent()

		@_emit 'enter', @_event

		return

	_move: ->

		@_modifyEvent()

		@_emit 'move', @_event

		return

	_leave: ->

		@_modifyEvent()

		@_emit 'leave', @_event

		return

	_checkIfShouldLeave: (e, ancestors) ->

		return unless @enabled

		@_lastReceivedMouseEvent = e

		unless @_mouseIsOverNode

			throw Error "called _checkIfShouldLeave() when listener is not active"

		# if the mousemove event is outside this listener
		if ancestors.indexOf(@_nodeData) is -1

			@_deactivate()

			@_leave() if @_comboSatisfies

		return

	_handleMouseMove: (e) ->

		return unless @enabled

		@_lastReceivedMouseEvent = e

		if @_mouseIsOverNode

			@_move() if @_comboSatisfies

		else

			@_activate()

			@_enter() if @_comboSatisfies

		return

	_activate: ->

		if @_mouseIsOverNode

			throw Error "Cannot call _activate when listener is already active"

		@_mouseIsOverNode = yes

		@_manager._addHandlerToActiveHandlersList @

		return

	_deactivate: ->

		unless @_mouseIsOverNode

			throw Error "Cannot call _deactivate when listener is not active"

		@_mouseIsOverNode = no

		@_manager._removeHandlerFromActiveHandlersList @

		return

	onEnter: (cb) ->

		@on 'enter', cb

		@

	onMove: (cb) ->

		@on 'move', cb

		@

	onLeave: (cb) ->

		@on 'leave', cb

		@

	detach: ->

		if @_mouseIsOverNode and @_comboSatisfies

			do @_leave

		super

		return

	disable: ->

		super

		if @_mouseIsOverNode and @_comboSatisfies

			do @_leave

		@