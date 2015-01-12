HoverManager = require './moosh/HoverManager'
WheelManager = require './moosh/WheelManager'
ButtonManager = require './moosh/ButtonManager'
array = require 'utila/lib/array'

module.exports = class Moosh

	self = @

	@_instanceCounter = 0

	constructor: (@rootNode = document.body, @_kilidScope) ->

		if @rootNode.node? then @rootNode = @rootNode.node

		@id = ++self._instanceCounter

		@_nodesData = []

		@_openModals = []

		@_nodesToIgnore = []

		# We're gonna need a better name for this
		@_listOfNodesToMakeUsIgnoreAllEventsOriginatingInThem = []

		@current = {x: 0, y: 0}

		@_scrollingDisabled = no

		@_hovers = new HoverManager @

		@_wheels = new WheelManager @

		@_lefts = new ButtonManager @, 'left', 0
		@_middles = new ButtonManager @, 'middle', 1
		@_rights = new ButtonManager @, 'right', 2

		@_currentTouchId = null

		body = document.body

		body.addEventListener 'mousedown', (e) =>

			@_mousedown e

		body.addEventListener 'mouseup', (e) =>

			@_mouseup e

		body.addEventListener 'mousemove', (e) =>

			@_mousemove e

		body.addEventListener 'mousewheel', (e) =>

			@_mousewheel e

		, no

		body.addEventListener 'wheel', (e) =>

			@_mousewheel e

		, no

		body.addEventListener 'DOMMouseScroll', (e) =>

			@_domMouseScroll e

		, no

		body.addEventListener 'touchstart', (e) =>

			@_touchstart e

		body.addEventListener 'touchmove', (e) =>

			@_touchmove e

		body.addEventListener 'touchend', (e) =>

			@_touchend e

	_getHtmlNode: (node) ->

		if node.node? then node = node.node

		unless node instanceof Element

			throw Error "node must either be a Foxie instance or an element"

		node

	_assignIdToNode: (node) ->

		id = node.getAttribute "data-moosh-#{@id}-id"

		unless id?

			id = @_nodesData.length

			node.setAttribute "data-moosh-#{@id}-id", id

			@_nodesData.push

				id: id
				node: node

				hoverListeners: []
				wheelListeners: []

				left:

					clickListeners: []
					dragListeners: []

				right:

					clickListeners: []
					dragListeners: []

				middle:

					clickListeners: []
					dragListeners: []

				callbacksForClickOutside: []

		parseInt id

	forgetNode: (node) ->

		node = @_getHtmlNode node

		id = @_getNodeId node

		if id?

			data = @_nodesData[id]

			l.detach() for l in data.hoverListeners

			l.detach() for l in data.wheelListeners

			l.detach() for l in data.left.clickListeners
			l.detach() for l in data.left.dragListeners

			l.detach() for l in data.right.clickListeners
			l.detach() for l in data.right.dragListeners

			l.detach() for l in data.middle.clickListeners
			l.detach() for l in data.middle.dragListeners

			node.removeAttribute "data-moosh-#{@id}-id"

			@_nodesData[id] = null

		@

	_getNodeId: (node) ->

		id = node.getAttribute "data-moosh-#{@id}-id"

		return null unless id?

		parseInt id

	_getNodeAncestors: (node) ->

		ancestors = []

		loop

			break unless node?

			id = @_getNodeId node

			if id?

				ancestors.push @_nodesData[id]

			break if node is @rootNode

			node = node.parentNode

		ancestors

	_mousemove: (e) ->

		@current.x = e.screenX
		@current.y = e.screenY

		ancestors = @_getNodeAncestors e.target

		@_hovers.handleMouseMove e, ancestors
		@_lefts.handleMouseMove e, ancestors
		@_rights.handleMouseMove e, ancestors
		@_middles.handleMouseMove e, ancestors

		return

	_touchmove: (touchEvent) ->

		if @_scrollingDisabled

			touchEvent.preventDefault()

		for touch in touchEvent.changedTouches

			if touch.identifier is @_currentTouchId

				e = touch

				break

		unless e?

			touchEvent.preventDefault()

			return

		# let's use these hacks until we come up with
		# a better solution
		e.preventDefault = touchEvent.preventDefault.bind(touchEvent)
		e.button = 0
		e.detail = 1

		@_mousemove e

		return

	_mousedown: (e) ->

		return if e.target.tagName in ['INPUT', 'SELECT', 'TEXTAREA', 'OPTION']

		ancestors = @_getNodeAncestors e.target

		if ancestors[0] in @_nodesToIgnore

			ancestors.shift()

		for ancestor in ancestors

			return if ancestor in @_listOfNodesToMakeUsIgnoreAllEventsOriginatingInThem

		if e.button is 0

			@_closeModalsIfNecessary e, ancestors

			@_lefts.handleMouseDown e, ancestors

		else if e.button is 1

			e.preventDefault() if @_scrollingDisabled

			@_middles.handleMouseDown e, ancestors

		else if e.button is 2

			@_rights.handleMouseDown e, ancestors

		return

	_touchstart: (touchEvent) ->

		if @_currentTouchId?

			touchEvent.preventDefault()

			return

		e = touchEvent.changedTouches[0]

		@_fixMousePosition {screenX: e.screenX, screenY: e.screenY, target: e.target}

		@_currentTouchId = e.identifier

		e.preventDefault = touchEvent.preventDefault.bind(touchEvent)
		e.button = 0
		e.detail = 1

		@_mousedown e

		return

	_mouseup: (e) ->

		ancestors = @_getNodeAncestors e.target

		if e.button is 0

			@_lefts.handleMouseUp e, ancestors

		else if e.button is 1

			@_middles.handleMouseUp e, ancestors

		else if e.button is 2

			@_rights.handleMouseUp e, ancestors

		return

	_touchend: (touchEvent) ->

		touchEvent.preventDefault()

		for touch in touchEvent.changedTouches

			if touch.identifier is @_currentTouchId

				e = touch

				break

		unless e?

			touchEvent.preventDefault()

			return

		@_currentTouchId = null

		e.preventDefault = touchEvent.preventDefault.bind(touchEvent)
		e.button = 0
		e.detail = 1

		@_mouseup e

		setTimeout =>

			@_fixMousePosition()

		, 0

		return

	_fixMousePosition: (fakeEvent = {}) ->

		fakeEvent.screenX ?= -1000
		fakeEvent.screenY ?= -1000
		fakeEvent.target ?= document.body

		ancestors = @_getNodeAncestors fakeEvent.target

		@_hovers.handleMouseMove fakeEvent, ancestors
		@_lefts.handleMouseMove fakeEvent, ancestors
		@_rights.handleMouseMove fakeEvent, ancestors
		@_middles.handleMouseMove fakeEvent, ancestors

	_mousewheel: (e) ->

		e.preventDefault() if @_scrollingDisabled

		ancestors = @_getNodeAncestors e.target

		@_wheels.handleMouseWheel e, ancestors

	_domMouseScroll: (e) ->

		e.preventDefault() if @_scrollingDisabled

	_getNodeDataForListeners: (node) ->

		node = @_getHtmlNode node

		id = @_assignIdToNode node

		data = @_nodesData[id]

	_closeModalsIfNecessary: (e, ancestors) ->

		i = 0

		loop

			nodeData = @_openModals[i]

			return unless nodeData?

			if ancestors.indexOf(nodeData) is -1

				cb(e) for cb in nodeData.callbacksForClickOutside

				nodeData.callbacksForClickOutside.length = 0

				array.pluck @_openModals, i

			else

				i++

		return

	onClickOutside: (node, cb) ->

		nodeData = @_getNodeDataForListeners node

		if @_openModals.indexOf(nodeData) is -1

			@_openModals.push nodeData

		nodeData.callbacksForClickOutside.push cb

		return

	discardClickOutside: (node) ->

		nodeData = @_getNodeDataForListeners node

		if @_openModals.indexOf(nodeData) isnt -1

			array.pluckOneItem @_openModals, nodeData

			nodeData.callbacksForClickOutside.length = 0

		return

	onHover: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_hovers.onHover data, rest

	onWheel: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_wheels.onWheel data, rest

	onLeftClick: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_lefts.onClick data, rest

	onRightClick: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_rights.onClick data, rest

	onMiddleClick: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_middles.onClick data, rest

	onLeftDrag: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_lefts.onDrag data, rest

	onRightDrag: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_rights.onDrag data, rest

	onMiddleDrag: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_middles.onDrag data, rest

	ignore: (node) ->

		data = @_getNodeDataForListeners node

		return if data in @_nodesToIgnore

		@_nodesToIgnore.push data

		@

	unignore: (node) ->

		data = @_getNodeDataForListeners node

		return unless data in @_nodesToIgnore

		array.pluckOneItem @_nodesToIgnore, data

		@

	ignoreAllEventsOriginatingInThisNode: (node) ->

		data = @_getNodeDataForListeners node

		return if data in @_listOfNodesToMakeUsIgnoreAllEventsOriginatingInThem

		@_listOfNodesToMakeUsIgnoreAllEventsOriginatingInThem.push data

		@

	unignoreAllEventsOriginatingInThisNode: (node) ->

		data = @_getNodeDataForListeners node

		return unless data in @_listOfNodesToMakeUsIgnoreAllEventsOriginatingInThem

		array.pluckOneItem @_listOfNodesToMakeUsIgnoreAllEventsOriginatingInThem, data

		@

	disableScrolling: ->

		@_scrollingDisabled = yes

	enableScrolling: ->

		@_scrollingDisabled = no

Moosh::onDrag = Moosh::onLeftDrag
Moosh::onClick = Moosh::onLeftClick