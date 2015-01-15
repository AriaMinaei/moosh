GestureHandler = require '../GestureHandler'

module.exports = class WheelHandler extends GestureHandler

	constructor: (@_manager, @_nodeData) ->

		super

		@_callback = null

		@_preventDefault = no

	preventDefault: ->

		@_preventDefault = yes

	allowDefault: ->

		@_preventDefault = no

	onWheel: (cb) ->

		@on 'wheel', cb

		@

	_modifyEvent: ->

		super

		e = @_lastReceivedMouseEvent

		@_event.delta = e.wheelDelta
		@_event.deltaX = e.wheelDeltaX
		@_event.deltaY = e.wheelDeltaY

	_handleMouseWheel: (e) ->

		return unless @enabled

		@_lastReceivedMouseEvent = e

		return unless @_comboSatisfies

		e.preventDefault() if @_preventDefault

		do @_modifyEvent

		@_emit 'wheel', @_event

		return