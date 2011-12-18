#= require ./wiki_syntax

window.application ||= {}

class Row extends Backbone.Model
  defaults:
    indent: 0
    text: ''
    page: null
    editing: false
    caretPos: 0

  isEditing: -> @get('editing')

  startEdit: ->
    @set({
      editing: true
      caretPos: @get('text').length
    })

  finishEdit: (text)->
    @set({
      text: text
      editing: false
    })

  split: (first, last) ->
    @finishEdit(first)
    @get('page').insertBelow(this, last)

  mergeWithBelow: (text) ->
    @finishEdit(text)
    @get('page').mergeWithBelow(this)

  mergeIntoAbove: (text) ->
    @finishEdit(text)
    @get('page').mergeIntoAbove(this)

  focusAbove: (text) ->
    @finishEdit(text)
    @get('page').focusAbove(this)

  focusBelow: (text) ->
    @finishEdit(text)
    @get('page').focusBelow(this)

  indent: (text) ->
    aboveRow = @get('page').getAboveRow(this, @get('indent'))
    return unless aboveRow
    return if @get('indent') > aboveRow.get('indent')
    i = @get('indent') + 1
    i = 5 if i > 5
    @set({
      indent: i
      text: text
    })

  unindent: (text) ->
    i = @get('indent') - 1
    i = 0 if i < 0
    @set({
      indent: i
      text: text
    })

  getHtml: ->
    (new application.WikiSyntax()).convert(@get('text'))

  getElementId: ->
    "item-#{@cid}"

class application.Page extends Backbone.Model
  defaults:
    title: ''
    body: []

  initialize: ->
    @fetch()

  getRows: ->
    unless @rows?
      @rows = @_getRows(@get('body'), 0)
    @rows

  _getRows: (tree, indent)->
    rows = []
    for node in tree
      switch typeof node
        when 'string'
          row = new Row({
            indent: indent
            text: node
            page: this
          })
          row.bind('change', @onRowChange)
          rows.push(row)
        when 'object'
          rows.push(r) for r in @_getRows(node, indent+1)
    rows

  onRowChange: () =>
    @save({
      body: @getTree()
    })

  getTree: () =>
    root = []
    for row in @rows
      if row.get('indent') == 0
        root.push row.get('text')
        children = @getChildren(row)
        if children.length > 0
          root.push children
    root

  getChildren: (parentRow) =>
    childIndent = parentRow.get('indent') + 1
    index = @getIndexOf(parentRow)
    array = []
    for i in [index+1...@rows.length]
      if @rows[i].get('indent') < childIndent
        return array
      if @rows[i].get('indent') == childIndent
        array.push @rows[i].get('text')
        children = @getChildren(@rows[i])
        if children.length > 0
          array.push children
    array

  getAboveRow: (row) ->
    return null if @rows.length <= 1
    isAbove = false
    index = @getIndexOf(row)
    if index > 0
      @rows[index-1]
    else
      null

  insertBelow: (row, text) ->
    newRow = new Row({
      indent: row.get('indent')
      text: text
      page: this
      editing: true
    })
    @rows.splice(@getIndexOf(row)+1, 0, newRow)
    @trigger('insert', row, newRow)

  mergeIntoAbove: (row) ->
    index = @getIndexOf(row)
    return unless @rows[index-1]
    above = @rows[index-1]
    # concat
    above.set({
      text: above.get('text') + row.get('text')
      editing: true
      caretPos: above.get('text').length
    })
    # remove
    @rows.splice(index, 1)
    @trigger('remove', row)

  mergeWithBelow: (row) ->
    index = @getIndexOf(row)
    return unless @rows[index+1]
    below = @rows[index+1]
    # concat
    row.set({
      text: row.get('text') + below.get('text')
      editing: true
      caretPos: row.get('text').length
    })
    # remove
    @rows.splice(index+1, 1)
    @trigger('remove', below)

  focusAbove: (row) ->
    index = @getIndexOf(row)
    if @rows[index-1]
      above = @rows[index-1]
      above.set({
        editing: true
        caretPos: above.get('text').length
      })
    else
      row.set({
        editing: true
        caretPos: 0
      })

  focusBelow: (row) ->
    index = @getIndexOf(row)
    if @rows[index+1]
      below = @rows[index+1]
      below.set({
        editing: true
        caretPos: 0
      })
    else
      row.set({
        editing: true
        caretPos: row.get('text').length
      })

  getIndexOf: (row) ->
    index = 0
    for r in @rows
      if r.cid == row.cid
        return index
      index += 1
    null

  url: ->
    "/page/api/#{ @get('title') }"
