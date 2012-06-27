function addTr8nCSS(doc, src) {
	var css = doc.createElement('link');
  css.setAttribute("type", "application/javascript");
	css.setAttribute("href", src);
	css.setAttribute("type", "text/css");
	css.setAttribute("rel", "stylesheet");
	css.setAttribute("media", "screen");
  // doc.body.appendChild(node); 
	// doc.getElementsByTagName('head')[0].appendChild(node);
  doc.getElementsByTagName('head')[0].appendChild(css);
}

function addTr8nScript(doc, id, src, onload) {
   var script = doc.createElement('script');
   script.setAttribute("id", id);
   script.setAttribute("type", "application/javascript");
   script.setAttribute("src", src);
   script.setAttribute("charset", "UTF-8");
   if (onload) script.onload = onload;
   doc.getElementsByTagName('head')[0].appendChild(script);
}

;(function(doc) {
	// Tr8n is already present on the page, do not add the scripts
	if (doc.getElementById('tr8n-jssdk')) {
		return;
	}

	addTr8nCSS(doc, "http://localhost:3000/assets/tr8n/tr8n.css");

	addTr8nScript(doc, "tr8n-jssdk", "http://localhost:3000/assets/tr8n/tr8n.js", function() {
		console.log("******************************************************* loaded jssdk.js");
		addTr8nScript(doc, "tr8n-proxy", "http://localhost:3000/tr8n/api/v1/proxy/init.js", function() {
			console.log("******************************************************* loaded proxy.js");
		});		
	});	

}(document));
