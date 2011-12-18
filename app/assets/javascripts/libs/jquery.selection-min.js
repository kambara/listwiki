/**
 * jQuery.selection - jQuery Plugin
 *
 * Under The MIT License
 * Copyright (c) 2010 Iwasaki. (http://d.hatena.ne.jp/ja9/)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Version: 1.0 beta
 * Revision: $Rev$
 * Date: $Date$
 */
(function(c){var b={getCaretData:function(j){var i={text:"",start:0,end:0};if(!j.value){return i}try{if(window.getSelection){i.start=j.selectionStart;i.end=j.selectionEnd;i.text=j.value.slice(i.start,i.end)}else{if(document.selection){j.focus();var g=document.selection.createRange(),f=document.body.createTextRange(),h;i.text=g.text;f.moveToElementText(j);f.setEndPoint("StartToStart",g);i.start=j.value.length-f.text.length;i.end=i.start+g.text.length}}}catch(k){}return i},getCaret:function(f){var e=this.getCaretData(f);return{start:e.start,end:e.end}},getText:function(e){return this.getCaretData(e).text},caretMode:function(e){e=e||"keep";if(e==false){e="end"}switch(e){case"keep":case"start":case"end":break;default:e="keep"}return e},replace:function(g,i,h){var f=this.getCaretData(g),k=g.value,j=c(g).scrollTop(),e={start:f.start,end:f.start+i.length};g.value=k.substr(0,f.start)+i+k.substr(f.end);c(g).scrollTop(j);this.setCaret(g,e,h)},insertBefore:function(g,i,h){var f=this.getCaretData(g),k=g.value,j=c(g).scrollTop(),e={start:f.start+i.length,end:f.end+i.length};g.value=k.substr(0,f.start)+i+k.substr(f.start);c(g).scrollTop(j);this.setCaret(g,e,h)},insertAfter:function(g,i,h){var f=this.getCaretData(g),k=g.value,j=c(g).scrollTop(),e={start:f.start,end:f.end};g.value=k.substr(0,f.end)+i+k.substr(f.end);c(g).scrollTop(j);this.setCaret(g,e,h)},setCaret:function(g,h,j){j=this.caretMode(j);if(j=="start"){h.end=h.start}else{if(j=="end"){h.start=h.end}}g.focus();try{if(g.createTextRange){var f=g.createTextRange();if(window.navigator.userAgent.toLowerCase().indexOf("msie")>=0){h.start=g.value.substr(0,h.start).replace(/\r/g,"").length;h.end=g.value.substr(0,h.end).replace(/\r/g,"").length}f.collapse(true);f.moveStart("character",h.start);f.moveEnd("character",h.end-h.start);f.select()}else{if(g.setSelectionRange){g.setSelectionRange(h.start,h.end)}}}catch(i){}}},d={getSelection:function(j){var g=((j||"text").toLowerCase()=="text");try{if(window.getSelection){if(g){return window.getSelection().toString()}else{var h=window.getSelection(),f;if(h.getRangeAt){f=h.getRangeAt(0)}else{f=document.createRange();f.setStart(h.anchorNode,h.anchorOffset);f.setEnd(h.focusNode,h.focusOffset)}return c("<div></div>").append(f.cloneContents()).html()}}else{if(document.selection){if(g){return document.selection.createRange().text}else{return document.selection.createRange().htmlText}}}}catch(i){}return""}},a={getSelection:function(){var e=[];this.each(function(){e.push(b.getText(this))});return(e.length<2)?e[0]:e},replaceSelection:function(f,e){return this.each(function(){b.replace(this,f,e)})},insertBeforeSelection:function(f,e){return this.each(function(){b.insertBefore(this,f,e)})},insertAfterSelection:function(f,e){return this.each(function(){b.insertAfter(this,f,e)})},getCaretPos:function(){var e=[];this.each(function(){e.push(b.getCaret(this))});return(e.length<2)?e[0]:e},setCaretPos:function(e){return this.each(function(){b.setCaret(this,e)})}};c.extend(d);c.fn.extend(a)})(jQuery);