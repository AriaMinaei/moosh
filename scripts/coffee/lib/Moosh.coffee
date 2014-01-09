HoverManager = require './moosh/HoverManager'
WheelManager = require './moosh/WheelManager'
ButtonManager = require './moosh/ButtonManager'
array = require 'utila/scripts/js/lib/array'

module.exports = class Moosh

	self = @

	@_instanceCounter = 0

	constructor: (@rootNode = document.body, @_kilidScope) ->

		if @rootNode.node? then @rootNode = @rootNode.node

		@id = ++self._instanceCounter

		@_nodesData = []

		@_openModals = []

		@_nodesToIgnore = []

		@_hovers = new HoverManager @

		@_wheels = new WheelManager @

		@_lefts = new ButtonManager @, 'left', 0
		@_middles = new ButtonManager @, 'middle', 1
		@_rights = new ButtonManager @, 'right', 2

		@rootNode.addEventListener 'mousedown', =>

			@_mousedown event

		@rootNode.addEventListener 'mouseup', =>

			@_mouseup event

		@rootNode.addEventListener 'mousemove', =>

			@_mousemove event

		@rootNode.addEventListener 'mousewheel', =>

			event.preventDefault()

			@_mousewheel event

		, no

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

		ancestors = @_getNodeAncestors e.target

		@_hovers.handleMouseMove e, ancestors

		if e.button is 0

			@_lefts.handleMouseMove e, ancestors

		else if e.button is 1

			@_middles.handleMouseMove e, ancestors

		else if e.button is 2

			@_rights.handleMouseMove e, ancestors

		return

	_mousedown: (e) ->

		ancestors = @_getNodeAncestors e.target

		if ancestors[0] in @_nodesToIgnore

			ancestors.shift()

		if e.button is 0

			@_closeModalsIfNecessary e, ancestors

			@_lefts.handleMouseDown e, ancestors

		else if e.button is 1

			@_middles.handleMouseDown e, ancestors

		else if e.button is 2

			@_rights.handleMouseDown e, ancestors

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

	_mousewheel: (e) ->

		ancestors = @_getNodeAncestors e.target

		@_wheels.handleMouseWheel e, ancestors

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

		@_right.onClick data, rest

	onMiddleClick: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_middles.onClick data, rest

	onLeftDrag: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_lefts.onDrag data, rest

	onRightDrag: (node, rest...) ->

		data = @_getNodeDataForListeners node

		@_right.onDrag data, rest

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

Moosh::onDrag = Moosh::onLeftDrag
Moosh::onClick = Moosh::onLeftClick