_Listener = require '../_Listener'

module.exports = class DragListener extends _Listener

	constructor: (@_manager, @_nodeData) ->

		@_downCallback = null
		@_upCallback = null
		@_startCallback = null
		@_endCallback = null
		@_stopCallback = null
		@_cancelCallback = null
		@_dragCallback = null
		@_releaseComboCallback = null
		@_onStateCallback = null
		@_onStateNameCallback = {}

		@_startPageX = 0
		@_startPageY = 0

		@_lastPageX = 0
		@_lastPageY = 0

		@_mightBe = no

		super

		@_event.cancel = => do @_cancel

	_modifyEvent: ->

		super

		@_lastReceivedMouseEvent.preventDefault()

		@_event.absX = @_event.pageX - @_startPageX
		@_event.absY = @_event.pageY - @_startPageY

		@_event.relX = @_event.pageX - @_lastPageX
		@_event.relY = @_event.pageY - @_lastPageY

		@_lastPageX = @_event.pageX
		@_lastPageY = @_event.pageY

		return

	onDown: (cb) ->

		@_downCallback = cb

		@

	onUp: (cb) ->

		@_upCallback = cb

		@

	onStart: (cb) ->

		@_startCallback = cb

		@

	onStop: (cb) ->

		@_stopCallback = cb

		@

	onEnd: (cb) ->

		@_endCallback = cb

		@

	onCancel: (cb) ->

		@_cancelCallback = cb

		@

	onDrag: (cb) ->

		@_dragCallback = cb

		@

	onReleaseCombo: (cb) ->

		@_releaseComboCallback = cb

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

		do @_onStateNameCallback[name] if @_onStateNameCallback[name]?

		do @_stateChanged

	_stateChanged: ->

		@_onStateCallback @_activeStates if @_onStateCallback?

	_endCombo: ->

		do @_cancel

		return

	_releaseCombo: ->

		if @_mightBe

			if @_releaseComboCallback?

				@_releaseComboCallback @_event

		return

	_cancel: ->

		if @_mightBe

			do @_end

			if @_cancelCallback?

				@_cancelCallback @_event

		return

	_handleMouseDown: (e) ->

		return unless @enabled

		@_lastReceivedMouseEvent = e

		return unless @_comboSatisfies

		@_mightBe = yes
		@_firstTime = yes

		@_manager._addListenerToActiveListenersList @

		@_startPageX = e.pageX
		@_startPageY = e.pageY

		@_lastPageX  = e.pageX
		@_lastPageY  = e.pageY

		do @_modifyEvent

		if @_downCallback?

			@_downCallback @_event

		if @_startCallback?

			@_startCallback @_event

		return

	_handleMouseUp: (e) ->

		return unless @_mightBe and @enabled

		@_lastReceivedMouseEvent = e

		do @_modifyEvent

		if @_firstTime

			do @_cancel

			return

		else

			if @_upCallback?

				@_upCallback @_event

		do @_end

		return

	_handleMouseMove: (e) ->

		return unless @_mightBe and @enabled

		@_lastReceivedMouseEvent = e

		do @_modifyEvent

		if @_firstTime

			@_firstTime = no

			@_manager._cancelOthers @

			@_active = yes

			do @_stateChanged

			for name in @_activeStates

				do @_onStateNameCallback[name] if @_onStateNameCallback[name]?

		if @_dragCallback?

			@_dragCallback @_event

		return


	detach: ->

		do @_cancel

		super

		return

	disable: ->

		super

		do @_cancel

		@

	_end: ->

		if @_stopCallback?

			@_stopCallback @_event

		@_mightBe = no

		@_active = no

		if @_endCallback?

			@_endCallback @_event

		@_manager._removeListenerFromActiveListenersList @

		return