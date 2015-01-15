GestureDetector = require '../GestureDetector'

module.exports = class DragDetector extends GestureDetector

	constructor: (@_manager, @_nodeData) ->

		@_onStateCallback = null
		@_onStateNameCallback = {}

		@_startPageX = 0
		@_startPageY = 0

		@_lastPageX = 0
		@_lastPageY = 0

		@_mightBe = no

		super

		@_event.cancel = => @_cancel()

	_modifyEvent: ->

		super

		@_event.absX = @_event.pageX - @_startPageX
		@_event.absY = @_event.pageY - @_startPageY

		@_event.relX = @_event.pageX - @_lastPageX
		@_event.relY = @_event.pageY - @_lastPageY

		@_lastPageX = @_event.pageX
		@_lastPageY = @_event.pageY

		return

	onDown: (cb) ->

		@on 'down', cb

		@

	onUp: (cb) ->

		@on 'up', cb

		@

	onStart: (cb) ->

		@on 'start', cb

		@

	onStop: (cb) ->

		@on 'stop', cb

		@

	onEnd: (cb) ->

		@on 'end', cb

		@

	onCancel: (cb) ->

		@on 'cancel', cb

		@

	onDrag: (cb) ->

		@on 'drag', cb

		@

	onReleaseCombo: (cb) ->

		@on 'releaseCombo', cb

		@

	onState: ->

		if arguments.length is 2

			name = arguments[0]
			cb = arguments[1]

			if @_onStateNameCallback[name]?

				throw Error "State \'#{name}\' is defined currently"

			@_onStateNameCallback[name] = cb

		if arguments.length is 1

			cb = arguments[0]

			@_onStateCallback = cb

		@

	_stateIs: (name) ->

		@_onStateNameCallback[name]() if @_onStateNameCallback[name]?

		@_stateChanged()

	_stateChanged: ->

		@_onStateCallback @_activeStates if @_onStateCallback?

	_endCombo: ->

		@_cancel()

		return

	_releaseCombo: ->

		return unless @_mightBe

		@_emit 'releaseCombo', @_event

		return

	_cancel: ->

		return unless @_mightBe

		@_end()

		@_emit 'cancel', @_event

		return

	_handleMouseDown: (e) ->

		return unless @enabled

		@_lastReceivedMouseEvent = e

		return unless @_comboSatisfies

		@_mightBe = yes
		@_firstTime = yes

		@_manager._addDetectorToActiveDetectorsList @

		@_startPageX = e.pageX
		@_startPageY = e.pageY

		@_lastPageX  = e.pageX
		@_lastPageY  = e.pageY

		@_modifyEvent()

		@_emit 'down', @_event

		@_emit 'start', @_event

		return

	_handleMouseUp: (e) ->

		return unless @_mightBe and @enabled

		@_lastReceivedMouseEvent = e

		@_modifyEvent()

		if @_firstTime

			@_cancel()

			return

		else

			@_emit 'up', @_event

		@_end()

		return

	_handleMouseMove: (e) ->

		return unless @_mightBe and @enabled

		@_lastReceivedMouseEvent = e

		@_modifyEvent()

		if @_firstTime

			return if Math.abs(@_event.absX) < 4 and Math.abs(@_event.absY) < 4

			@_firstTime = no

			@_manager._cancelOthers @

			@_active = yes

			@_stateChanged()

			for name in @_activeStates

				@_onStateNameCallback[name]() if @_onStateNameCallback[name]?

		@_emit 'drag', @_event

		return


	detach: ->

		@_cancel()

		super

		return

	disable: ->

		super

		@_cancel()

		@

	_end: ->

		@_emit 'stop', @_event

		@_mightBe = no

		@_active = no

		@_emit 'end', @_event

		@_manager._removeDetectorFromActiveDetectorsList @

		return