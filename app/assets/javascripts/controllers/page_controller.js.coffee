#= require ../models/page.js
#= require ../views/page_view.js

window.application ||= {}

class Router extends Backbone.Router
  routes:
    '': 'index'

  index: ->
    new application.PageView({
      model: new application.Page({
        title: pageTitle
        body: []
        ary: []
      })
    })

$(->
  new Router()
  Backbone.history.start()
)
