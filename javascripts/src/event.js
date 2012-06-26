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

Tr8n.Event = {

  events: {},

  /////////////////////////////////////////////////////////////////////////////////////
  // Bind an event, specified by a string name, 'event', to a callback, 'cb', function.
  /////////////////////////////////////////////////////////////////////////////////////

  bind: function(event, cb) {
  	this.events[event] = this.events[event]	|| [];
  	this.events[event].push(cb);
  },

  /////////////////////////////////////////////////////////////////////////////////////
  // Remove one or many callbacks. If callback is null, all
  // callbacks for the event wil be removed.
  /////////////////////////////////////////////////////////////////////////////////////

  unbind: function(event, cb) {
  	if(event in this.events === false)	return;
  	this.events[event].splice(this.events[event].indexOf(cb), 1);
  	if(!cb) delete this.events[event];
  },

  /////////////////////////////////////////////////////////////////////////////////////
  // Trigger an event, firing all bound callbacks. Callbacks are passed the
  // same arguments as 'trigger' is, apart from the event name.
  /////////////////////////////////////////////////////////////////////////////////////

  trigger: function(event) {
  	if( event in this.events === false  )	return;
  	for(var i = 0; i < this.events[event].length; i++){
  		this.events[event][i].apply(this, Array.prototype.slice.call(arguments, 1))
  	}
  }

}
