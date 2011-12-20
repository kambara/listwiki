#= require ../libs/jquery.selection-min.js
#= require ../libs/jquery.autoresize-min.js

window.application ||= {}

class RowView extends Backbone.View
  tagName: 'div'
  className: 'item'

  initialize: ->
    $(@el).attr('id', @model.getElementId())
    $(window).mousedown @onBodyMousedown
    $(window).mouseup @onBodyMouseup
    @model.bind 'change', @render
    @container = $('<div/>').addClass('text-container').appendTo(@el)
    @container.mousedown @onMousedown
    @container.mouseup @onMouseup
    @render()

  render: =>
    @textarea.unbind() if @textarea
    minHeight = @html.height() if @html
    @container.empty()
    @container.css('margin-left', @model.get('indent') * 30)
    @container.removeClass('indent0 indent1 indent2 indent3 indent4 indent5')
    @container.addClass('indent' + @model.get('indent'))
    if @model.isEditing()
      @renderTextarea(minHeight)
    else
      @renderHtml()
    this

  renderHtml: ->
    @html = $('<div/>')
      .html(@model.getHtml())
      .addClass('text')
      .appendTo(@container)

  renderTextarea: (minHeight) ->
    @textarea = $('<textarea/>')
      .text(@model.get('text'))
      .addClass('text')
      .keydown(@onKeydown)
      .keyup(@onKeyup)
      .appendTo(@container)
    setTimeout(() =>
      @textarea.autoResize({
        animate: false
        extraSpace: 0
      }).trigger('change')
      if (minHeight? and @textarea.height() < minHeight)
        @textarea.height(minHeight)
      @textarea.focus()
      @textarea.setCaretPos({
        start: @model.get('caretPos')
        end:   @model.get('caretPos')
      })
    , 1)

  onKeydown: (event) =>
    #console.log(event.keyCode)
    @prevCaretPos = null
    switch event.keyCode
      when 13 ## Enter
        if event.shiftKey
          @textarea.height(
            @textarea.height() + 26)
        else
          setTimeout(@split, 10)
          false
      when 9 ## Tab
        if event.shiftKey
          @model.unindent(@textarea.val())
        else
          @model.indent(@textarea.val())
        false
      when 27 ## Esc
        if @model.get('editing')
          @model.finishEdit(@textarea.val())
          false
      when 8 ## Backspace
        caretPos = @textarea.getCaretPos()
        if caretPos.start is caretPos.end and caretPos.start is 0
          @model.mergeIntoAbove(@textarea.val())
          false
      when 46 ## Del
        if @textarea.getCaretPos().start == @textarea.val().length
          @model.mergeWithBelow(@textarea.val())
          false
      when 38 ## Up
        caretPos = @textarea.getCaretPos()
        if caretPos.start == 0
          @model.focusAbove(@textarea.val())
          false
        else
          @prevCaretPos = caretPos
      when 40 ## Down
        caretPos = @textarea.getCaretPos()
        if @textarea.getCaretPos().start == @textarea.val().length
          @model.focusBelow(@textarea.val())
          false
        else
          @prevCaretPos = caretPos

  onKeyup: (event) =>
    caretPos = @textarea.getCaretPos()
    switch event.keyCode
      when 38 # Up
        if @prevCaretPos? and caretPos.start is @prevCaretPos.start
          @textarea.setCaretPos({start:0, end:0})
      when 40 # Down
        if @prevCaretPos? and caretPos.start is @prevCaretPos.start
          last = @textarea.val().length
          @textarea.setCaretPos({start:last, end:last})

  split: () =>
    str = @textarea.val()
    pos = @textarea.getCaretPos().start
    @model.split(
      str.slice(0, pos),
      str.slice(pos))

  onMousedown: (event) =>
    if @model.isEditing()
      event.stopPropagation()
    else
      @dragStartX = event.pageX
      @dragStartY = event.pageY
      @dragging = true

  onBodyMousedown: (event) =>
    if @model.isEditing()
      @model.finishEdit(@textarea.val())

  onMouseup: (event) =>
    if @model.isEditing()
      event.stopPropagation()

  onBodyMouseup: (event) =>
    if @dragging and @isLikeClick(event)
      @model.startEdit()
    @dragging = false

  isLikeClick: (event) ->
    dx = event.pageX - @dragStartX
    dy = event.pageY - @dragStartY
    if Math.abs(dx) < 5 and Math.abs(dy) < 5
      true
    else
      false

class application.ListView extends Backbone.View
  el: '#list'

  initialize: ->
    @model.bind 'change', () => @render()
    @model.bind 'insert', @onInsert
    @model.bind 'remove', @onRemove

  render: ->
    @model.unbind 'change'
    for row in @model.getRows()
      rowView = new RowView({model: row})
      ## Focus when there is no text
      if (@model.getRows().length == 1 and
          row.get('text') is '')
        row.set({ editing: true })
      $(@el).append(rowView.el)
    this

  onInsert: (aboveRow, row) =>
    rowView = new RowView({model: row})
    $('#' + aboveRow.getElementId()).after(rowView.el)

  onRemove: (row) =>
    index = row.get('index')
    $('#' + row.getElementId()).remove()
