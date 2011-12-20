window.application ||= {}

class application.WikiSyntax
  constructor: () ->
    @textLinkRe = /\[\[([^\n\]]+) *: *(https?:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%\#]+)\]\]/
    @wikiLinkRe = /\[\[([^\n\]]+)\]\]/
    @imageRe = /https?:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%\#]+\.(jpg|jpeg|png|gif)/i
    @httpLinkRe = /https?:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%\#]+/
    @youtubeRe = /https?:\/\/www\.youtube\.com\/watch\?([\w&=]+)/
    @youtubeShortRe = /http:\/\/youtu\.be\/(\w+)/
    @ltRe = /</
    @gtRe = />/
    @ampRe = /&/
    @quotRe = /\"/

  convert: (text) ->
    text = text.replace(/(\r\n|\r)/g, '\n')
    lines = []
    preLines = []
    for line in text.split('\n')
      if line.length > 0 and line.charAt(0) is ' '
        ## pre
        preLines.push line
      else
        if preLines.length > 0
          lines.push @pre(@escapeHtml(preLines.join('\n')))
          preLines = []
        ## convert line
        lines.push @convertLine(line)
        lines.push '<br />'
    lines.push @pre(preLines.join('\n')) if preLines.length > 0
    lines.join('')

  pre: (str) ->
    "<pre>#{str}</pre>"

  convertLine: (text) ->
    return '' if text.length == 0
    replaceingText =
      if @match(text, @textLinkRe)
        @textLink(RegExp.$2, RegExp.$1, true)
      else if @match(text, @wikiLinkRe)
        title = RegExp.$1
        @textLink("/page/#{encodeURIComponent(title)}", title)
      else if @match(text, @imageRe)
        @imgLink(RegExp.lastMatch)
      else if @match(text, @youtubeRe)
        videoId = @videoId(RegExp.$1)
        if videoId?
          @youtube(videoId)
        else
          null
      else if @match(text, @youtubeShortRe)
        @youtube(RegExp.$1)
      else if @match(text, @httpLinkRe)
        url = RegExp.lastMatch
        @textLink(url, url, true)
      else if @match(text, @ltRe) then '&lt;'
      else if @match(text, @gtRe) then '&gt;'
      else if @match(text, @ampRe) then '&amp;'
      else if @match(text, @quotRe) then '&quot;'
      else
        null
    
    if replaceingText?
      [
        @leftContext
        replaceingText
        @convertLine(@rightContext)
      ].join('')
    else
      text

  videoId: (params) ->
    for pairs in params.split('&')
      pair = pairs.split('=')
      if pair.length == 2 and pair[0] is 'v'
        return pair[1]
    null

  match: (text, re) ->
    if text.match(re)
      @leftContext = RegExp.leftContext
      @rightContext = RegExp.rightContext
      RegExp.lastMatch
    else
      null

  textLink: (url, text, targetBlank = false) ->
    @link(url, @escapeHtml(text), targetBlank)

  imgLink: (url) ->
    @link(url, @img(url), true)

  link: (url, innerHtml, targetBlank = false) ->
    onmousedown = "if (event.cancelBubble) {event.cancelBubble=true;} else {event.stopPropagation();}"
    target = ''
    target = 'target="_blank"' if targetBlank
    "<a href='#{url}'
      onmousedown='#{onmousedown}'
      #{target}
      >#{innerHtml}</a>"

  img: (url) ->
    "<img src='#{url}' />"

  youtube: (videoId) ->
    "<iframe width='560' height='315' src='http://www.youtube.com/embed/#{videoId}' frameborder='0' allowfullscreen></iframe>"

  escapeHtml: (str) ->
    str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\"/g, '&quot;')
