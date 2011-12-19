#= require ./libs/jquery.js
#= require ./libs/underscore-min.js
#= require ./libs/backbone-min.js
#= require ./libs/json2.js
#= require ./libs/modernizr.custom.js
#= require ./libs/deck.core.js
#= require ./models/page.js
#= require ./views/slides_view.js

window.application ||= {}

class Router extends Backbone.Router
  initialize: (@pageTitle) ->

  routes:
    '': 'slide'

  slide: ->
    new application.SlidesView({
      model: new application.Page({
        title: @pageTitle
      })
    })

application.main = (pageTitle)->
  $(->
    new Router(pageTitle)
    Backbone.history.start()
  )
