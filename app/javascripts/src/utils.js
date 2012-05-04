/****************************************************************************
  Copyright (c) 2010-2012 Michael Berkovich, Ian McDaniel, tr8n.net

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
****************************************************************************/

Tr8n.Utils = {

  element: function(element_id) {
    if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },

  value: function(element_id) {
    return Tr8n.element(element_id).value;
  },

  extend: function(destination, source) {
    for (var property in source) 
      destination[property] = source[property];
    return destination;
  },

  hideFlash: function() {
    // alert("Hiding");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'hidden';
    } 
  },

  showFlash: function() {
    // alert("Showing");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'visible';
    } 
  },

  isOpera: function() {
    return /Opera/.test(navigator.userAgent);
  },

  uuid: function() {
    return 'tr8n' + (((1+Math.random())*0x10000)|0).toString(16).substring(1);
  },

  addEvent: function(elm, evType, fn, useCapture) {
    useCapture = useCapture || false;
    if (elm.addEventListener) {
      elm.addEventListener(evType, fn, useCapture);
      return true;
    } else if (elm.attachEvent) {
      var r = elm.attachEvent('on' + evType, fn);
      return r;
    } else {
      elm['on' + evType] = fn;
    }
  },

  // Create a URL-encoded query string from an object
  encodeQueryString: function(obj,prefix) {
    var str = [];
    for(var p in obj) str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
    return str.join("&");
  },

  // Parses a query string and returns an object composed of key/value pairs
  decodeQueryString: function(qs) {
    var
      obj = {},
      segments = qs.split('&'),
      kv;
    for (var i=0; i<segments.length; i++) {
      kv = segments[i].split('=', 2);
      if (kv && kv[0]) {
        obj[decodeURIComponent(kv[0])] = decodeURIComponent(kv[1]);
      }
    }
    return obj;
  },

  toQueryParams: function (obj) {
    if (typeof obj == 'undefined' || obj == null) return "";
    if (typeof obj == 'string') return obj;

    var qs = [];
    for(p in obj) {
        qs.push(p + "=" + encodeURIComponent(obj[p]))
    }
    return qs.join("&")
  },

  toUrl: function(url, params) {
    params = params || {};
    params['origin'] = window.location;
    url = Tr8n.host + url + (url.indexOf('?') == -1 ? '?' : '&') + Tr8n.Utils.toQueryParams(params);
    return url
  },

  serializeForm: function(form) {
    var els = Tr8n.element(form).elements;
    var form_obj = {}
    for(i=0; i < els.length; i++) {
      if (els[i].type == 'checkbox' && !els[i].checked) continue;
      form_obj[els[i].name] = els[i].value;
    }
    return form_obj;
  },

  indexOf: function(array, item, i) {
    i || (i = 0);
    var length = array.length;
    if (i < 0) i = length + i;
    for (; i < length; i++)
      if (array[i] === item) return i;
    return -1;
  },

  replaceAll: function(label, key, value) {
    while (label.indexOf(key) != -1) {
      label = label.replace(key, value);
    }
    return label;
  },

  trim: function(string) {
    return string.replace(/^\s+|\s+$/g,"");
  },

  ltrim: function(string) {
    return string.replace(/^\s+/,"");
  },

  rtrim: function(string) {
    return string.replace(/\s+$/,"");
  },

  getRequest: function() {
    var factories = [
      function() { return new ActiveXObject("Msxml2.XMLHTTP"); },
      function() { return new XMLHttpRequest(); },
      function() { return new ActiveXObject("Microsoft.XMLHTTP"); }
    ];
    for(var i = 0; i < factories.length; i++) {
      try {
        var request = factories[i]();
        if (request != null)  return request;
      } catch(e) {continue;}
    }
  },

  getMetaAttributes: function() {
    var meta_hash = {};
    var meta = document.getElementsByTagName("meta");
    for (var i=0; i<meta.length; i++) {
      var name = meta[i].getAttribute('name'); 
      var content = meta[i].getAttribute('content'); 
      if (!name || !content) continue;
      meta_hash[name] = content;
    }
    return meta_hash;
  },

  ajax: function(url, options) {
    options = options || {};
    options.parameters = options.parameters || {};

    var meta = Tr8n.Utils.getMetaAttributes();
    if (meta['csrf-param'] && meta['csrf-token']) {
      options.parameters[meta['csrf-param']] = meta['csrf-token'];
    }
    options.parameters = Tr8n.Utils.toQueryParams(options.parameters);
    options.method = options.method || 'get';

    var self=this;
    if (options.method == 'get' && options.parameters != '') {
      url = url + (url.indexOf('?') == -1 ? '?' : '&') + options.parameters;
    }

    var request = this.getRequest();

    request.onreadystatechange = function() {
      if(request.readyState == 4) {
        if (request.status == 200) {
          if(options.onSuccess) options.onSuccess(request);
          if(options.onComplete) options.onComplete(request);
          if(options.evalScripts) self.evalScripts(request.responseText);
        } else {
          if(options.onFailure) options.onFailure(request)
          if(options.onComplete) options.onComplete(request)
        }
      }
    }

    request.open(options.method, url, true);
    request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  },

  update: function(element_id, url, options) {
    options.onSuccess = function(response) {
        Tr8n.element(element_id).innerHTML = response.responseText;
    };
    Tr8n.Utils.ajax(url, options);
  },

  evalScripts: function(html){
    var script_re = '<script[^>]*>([\\S\\s]*?)<\/script>';
    var matchAll = new RegExp(script_re, 'img');
    var matchOne = new RegExp(script_re, 'im');
    var matches = html.match(matchAll) || [];
    for(var i=0,l=matches.length;i<l;i++){
      var script = (matches[i].match(matchOne) || ['', ''])[1];
      // console.info(script)
      // alert(script);
      eval(script);
    }
  },

  hasClassName:function(el, cls){
    var exp = new RegExp("(^|\\s)"+cls+"($|\\s)");
    return (el.className && exp.test(el.className))?true:false;
  },

  findElement: function (e,selector,el) {
    var event = e || window.event;
    var target = el || event.target || event.srcElement;
    if(target == document.body) return null;
    var condition = (selector.match(/^\./)) ? this.hasClassName(target,selector.replace(/^\./,'')) : (target.tagName.toLowerCase() == selector.toLowerCase());
    if(condition) {
      return target;
    } else {
      return this.findElement(e,selector,target.parentNode);
    }
  },

  // deprecated
  cumulativeOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
    } while (element);
    return [valueL, valueT];
  },

  elementRect: function(element) {
    var valueT = 0, valueL = 0, el = element;
    do {
      valueT += el.offsetTop  || 0;
      valueL += el.offsetLeft || 0;
      el = el.offsetParent;
    } while (el);
    return {left: valueL, top: valueT, width: element.offsetWidth, height: element.offsetHeight};
  },

  wrapText: function (obj_id, beginTag, endTag) {
    var obj = document.getElementById(obj_id);

    if (typeof obj.selectionStart == 'number') {
        // Mozilla, Opera, and other browsers
        var start = obj.selectionStart;
        var end   = obj.selectionEnd;
        obj.value = obj.value.substring(0, start) + beginTag + obj.value.substring(start, end) + endTag + obj.value.substring(end, obj.value.length);

    } else if(document.selection) {
        // Internet Explorer
        obj.focus();
        var range = document.selection.createRange();
        if(range.parentElement() != obj)
          return false;

        if(typeof range.text == 'string')
          document.selection.createRange().text = beginTag + range.text + endTag;
    } else
        obj.value += beginTag + " " + endTag;

    return true;
  },

  insertAtCaret: function (areaId, text) {
    var txtarea = document.getElementById(areaId);
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? "ff" : (document.selection ? "ie" : false ) );

    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      strPos = range.text.length;
    } else if (br == "ff")
      strPos = txtarea.selectionStart;

    var front = (txtarea.value).substring(0, strPos);
    var back = (txtarea.value).substring(strPos, txtarea.value.length);
    txtarea.value=front+text+back;

    strPos = strPos + text.length;
    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      range.moveStart ('character', strPos);
      range.moveEnd ('character', 0); range.select();
    }  else if (br == "ff") {
      txtarea.selectionStart = strPos;
      txtarea.selectionEnd = strPos;
      txtarea.focus();
    }
    txtarea.scrollTop = scrollPos;
  },

  toggleKeyboards: function() {
    if(!VKI_attach) return;
    if (!this.keyboardMode) {
      this.keyboardMode = true;

      var elements = document.getElementsByTagName("input");
      for(i=0; i<elements.length; i++) {
        if (elements[i].type == "text") VKI_attach(elements[i]);
      }
      elements = document.getElementsByTagName("textarea");
      for(i=0; i<elements.length; i++) {
        VKI_attach(elements[i]);
      }
    } else {
      window.location.reload();
    }
  },

  displayShortcuts: function() {
      Tr8n.UI.Lightbox.show('/tr8n/help/lb_shortcuts', {width:400, height:480});
  },

  displayStatistics: function() {
      Tr8n.UI.Lightbox.show('/tr8n/help/lb_stats', {width:420, height:400});
  },

  isArray: function(obj) {
    if (obj == null) return false;
    return !(obj.constructor.toString().indexOf("Array") == -1);
  },

  isObject: function(obj) {
    if (obj == null) return false;
    return (typeof obj == 'object');
  },

  isString: function(obj) {
    return (typeof obj == 'string');
  },

  isURL: function(str) {
    str = "" + str;
    return (str.indexOf("http://") != -1) || (str.indexOf("https://") != -1);
  }

}
