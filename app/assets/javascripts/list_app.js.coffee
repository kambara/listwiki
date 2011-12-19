#= require ./libs/jquery.js
#= require ./libs/underscore-min.js
#= require ./libs/backbone-min.js
#= require ./libs/json2.js
#= require ./models/page.js
#= require ./views/list_view.js

window.application ||= {}

class Router extends Backbone.Router
  initialize: (@pageTitle) ->

  routes:
    '': 'list'

  list: ->
    new application.ListView({
      model: new application.Page({
        title: @pageTitle
      })
    })

application.main = (pageTitle) ->
  $(->
    new Router(pageTitle)
    Backbone.history.start()
  )
