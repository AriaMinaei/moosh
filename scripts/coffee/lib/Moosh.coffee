HoverManager = require './moosh/HoverManager'
WheelManager = require './moosh/WheelManager'
ButtonManager = require './moosh/ButtonManager'

module.exports = class Moosh

	self = @

	@_instanceCounter = 0

	constructor: (@rootNode = document.body, @_keys) ->

		if @rootNode.node? then @rootNode = @rootNode.node

		@id = ++self._instanceCounter

		@_nodesData = []

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

		unless node instanceof HTMLElement

			throw Error "node must either be a Foxie instance or an html element"

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

		parseInt id

	forgetNode: (node) ->

		node = @_getHtmlNode node

		id = @_getNodeId node

		if id?

			data = @_nodesData[id]
			delete data.node
			delete data.hoverListeners
			delete data.wheelListeners

			delete data.left
			delete data.right
			delete data.middle

			node.removeAttribute "data-moosh-#{@id}-id"

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

				ancestors.unshift @_nodesData[id]

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

		if e.button is 0

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

	_getNodeDataForListener: (node) ->

		node = @_getHtmlNode node

		id = @_assignIdToNode node

		data = @_nodesData[id]

	onClickOutside: (node, cb) ->

		data = @_getNodeDataForListener node


	onHover: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_hovers.onHover data, rest

	onWheel: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_wheels.onWheel data, rest

	onLeftClick: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_lefts.onClick data, rest

	onRightClick: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_right.onClick data, rest

	onMiddleClick: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_middles.onClick data, rest

	onLeftDrag: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_lefts.onDrag data, rest

	onRightDrag: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_right.onDrag data, rest

	onMiddleDrag: (node, rest...) ->

		data = @_getNodeDataForListener node

		@_middles.onDrag data, rest

Moosh::onDrag = Moosh::onLeftDrag
Moosh::onClick = Moosh::onLeftClick