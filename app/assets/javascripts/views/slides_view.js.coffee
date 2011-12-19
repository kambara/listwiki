#= require ../libs/modernizr.custom.js
#= require ../libs/deck.core.js

window.application ||= {}

class SlideView extends Backbone.View
  tagName: 'section'

  className: 'slide'

  initialize: ->
    @render()

  render: ->
    $(@el).append @model.getHtml()

class application.SlidesView extends Backbone.View
  el: '#slide-view'

  initialize: ->
    @model.bind 'change', () => @render()

  render: ->
    @model.unbind 'change'
    console.log @model.getSlides()
    for slide in @model.getSlides()
      slideView = new SlideView({model: slide})
      $(@el).append(slideView.el)
    $.deck('.slide')
    this
