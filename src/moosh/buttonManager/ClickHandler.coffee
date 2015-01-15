GestureHandler = require '../GestureHandler'

module.exports = class ClickHandler extends GestureHandler

	constructor: (@_manager, @_nodeData, args) ->

		@_repeats = 1

		@_lastRepeatCheckTimeout = null

		@_startPageX = 0
		@_startPageY = 0

		super

		if args[0] instanceof Function

			@onDone args[0]

		@_event.cancel = => @_cancel()

	onDown: (cb) ->

		@on 'down', cb

		@

	onUp: (cb) ->

		@on 'up', cb

		@

	onCancel: (cb) ->

		@on 'cancel', cb

		@

	onDone: (cb) ->

		@on 'done', cb

		return

	repeatedBy: (n) ->

		if @_locked

			throw Error "Cannot call repeat when the listener is already set up"

		@_repeats = parseInt n

		unless Number.isFinite(@_repeats)

			throw Error "Invalid number for repeat"

		@

	_endCombo: ->

		@_cancel()

		return

	onReleaseCombo: (cb) ->

		@on 'releaseCombo', cb

		@

	_endCombo: ->

		@_cancel()

		return

	_releaseCombo: ->

		return unless @_active and @enabled

		@_emit 'releaseCombo', @_event

		return

	_handleMouseMove: (e) ->

		return unless @enabled

		unless @_active

			throw Error "called _handleMouseMove when inactive"

		if Math.abs(Math.abs(e.pageX) - Math.abs(@_startPageX)) > 5 or

		Math.abs(Math.abs(e.pageY) - Math.abs(@_startPageY)) > 5

			@_cancel()

		return

	_cancel: ->

		return unless @_active

		@_active = no

		@_manager._removeHandlerFromActiveHandlersList @

		@_emit 'cancel', @_event

		return

	_handleMouseDown: (e) ->

		return unless @enabled

		@_lastReceivedMouseEvent = e

		unless @_active

			return unless @_comboSatisfies

			@_active = yes

			@_manager._addHandlerToActiveHandlersList @

			@_startPageX = e.pageX
			@_startPageY = e.pageY

		@_modifyEvent()

		@_emit 'down', @_event

		if @_repeats > 1

			if @_lastRepeatCheckTimeout?

				clearTimeout @_lastRepeatCheckTimeout

			@_lastRepeatCheckTimeout = setTimeout =>

				@_cancel()

			, 300

		return

	_handleMouseUp: (e) ->

		return unless @_active and @enabled

		@_lastReceivedMouseEvent = e

		@_modifyEvent()

		@_event.repeats = e.detail

		@_emit 'up', @_event

		if e.detail >= @_repeats

			@_manager._cancelOthers @

			@_manager._removeHandlerFromActiveHandlersList @

			@_active = no

			@_emit 'done', @_event

			clearTimeout @_lastRepeatCheckTimeout

		return

	_modifyEvent: ->

		super

		# @_lastReceivedMouseEvent.preventDefault()

		return

	detach: ->

		@_cancel()

		super

		return

	disable: ->

		super

		@_cancel()

		@