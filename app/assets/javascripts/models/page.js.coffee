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
    prevText = @get('text')
    @set({
      text: text
      editing: false
    })
    if text isnt prevText
      @trigger('modify')

  split: (first, last) ->
    @finishEdit(first)
    @get('page').insertBelow(this, last)
    @trigger('modify')

  mergeWithBelow: (text) ->
    @finishEdit(text)
    @get('page').mergeWithBelow(this)
    @trigger('modify')

  mergeIntoAbove: (text) ->
    @finishEdit(text)
    @get('page').mergeIntoAbove(this)
    @trigger('modify')

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
    @trigger('modify')

  unindent: (text) ->
    i = @get('indent') - 1
    i = 0 if i < 0
    @set({
      indent: i
      text: text
    })
    @trigger('modify')

  getHtml: ->
    (new application.WikiSyntax()).convert(@get('text'))

  getElementId: ->
    "item-#{@cid}"

  getIndexOfLastLine: ->
    @get('text').lastIndexOf('\n') + 1

class Slide extends Backbone.Model
  defaults:
    title: null
    list: []

  getHtml: ->
    if @get('title')? == 0
      return ''
    
    if @get('list').length == 0
      if @get('title').match(/^(.+)\n\n(.+)/m)
        title = (new application.WikiSyntax()).convert RegExp.$1
        p = (new application.WikiSyntax()).convert RegExp.$2
        return "<h1>#{title}<p>#{p}</p></h1>"
      else
        title = (new application.WikiSyntax()).convert @get('title')
        return "<h1>#{title}</h1>"

    title = (new application.WikiSyntax()).convert @get('title')
    listHtml =  @getListHtml @get('list')
    "<h2>#{title}</h2>#{listHtml}"

  getListHtml: (list) ->
    htmlAry = []
    for item in list
      if typeof item is 'string'
        html = (new application.WikiSyntax()).convert(item)
        htmlAry.push "<li>#{html}</li>"
      else if typeof item is 'object'
        htmlAry.push @getListHtml(item)
    [
      '<ul>'
      htmlAry.join('')
      '</ul>'
    ].join('')

class application.Page extends Backbone.Model
  defaults:
    title: ''
    created_at: null
    updated_at: null
    body: []

  initialize: ->
    @fetch()

  getSlides: ->
    slides = []
    lastSlide = null
    for item in @get('body')
      if typeof item is 'string'
        slide = new Slide({
          title: item
        })
        slides.push(slide)
        lastSlide = slide
      else if typeof item is 'object' and lastSlide?
        lastSlide.set({
          list: item
        })
    slides

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
          row.bind('modify', @onRowModify)
          rows.push(row)
        when 'object'
          rows.push(r) for r in @_getRows(node, indent+1)
    rows

  validate: (attrs) ->
    if attrs.title? and attrs.title.length is 0
      'No title'
    else if attrs.body? and attrs.body.length is 0
      'No body'

  onRowModify: () =>
    $('#save-indicator').text('Save...').show()
    unless @get('created_at')
      @set({
        created_at: (new Date()).getTime()
      })
    @save({
      body: @getTree()
      updated_at: (new Date()).getTime()
    }, {
      success: ->
        $('#save-indicator').text('Saved').fadeOut(3000)
      error: (msg)->
        $('#save-indicator').text("Error")
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
    newRow.bind('modify', @onRowModify)
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
        caretPos: above.getIndexOfLastLine()
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
    t = (new Date()).getTime().toString()
    "/page/api/#{ @encodedTitle() }?nocache=#{t}"

  encodedTitle: ->
    encodeURIComponent @get('title')