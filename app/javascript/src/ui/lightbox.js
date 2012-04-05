Tr8n.Lightbox = function() {
  this.container                = document.createElement('div');
  this.container.className      = 'tr8n_lightbox';
  this.container.id             = 'tr8n_lightbox';
  this.container.style.display  = "none";

  this.overlay                  = document.createElement('div');
  this.overlay.className        = 'tr8n_lightbox_overlay';
  this.overlay.id               = 'tr8n_lightbox_overlay';
  this.overlay.style.display    = "none";

  document.body.appendChild(this.container);
  document.body.appendChild(this.overlay);
}


Tr8n.Lightbox.prototype = {

  hide: function() {
    this.container.style.display = "none";
    this.overlay.style.display = "none";
    Tr8n.Utils.showFlash();
  },

  show: function(url, opts) {
    var self = this;
    opts = opts || {};
    if(tr8nTranslator) tr8nTranslator.hide();
    if(tr8nLanguageSelector) tr8nLanguageSelector.hide();
    if(tr8nLanguageCaseManager) tr8nLanguageCaseManager.hide();
    Tr8n.Utils.hideFlash();

    this.container.innerHTML = "<div class='inner'><div class='bd'><img src='/assets/tr8n/spinner.gif' style='vertical-align:middle'> Loading...</div></div>";
    
    this.overlay.style.display  = "block";

    opts["width"] = opts["width"] || 700;
    opts["height"] = opts["height"] || 520;

    this.container.style.width  = opts["width"] + 'px';
    this.container.style.height = opts["height"] + 'px';
    this.container.style.marginLeft  = -opts["width"]/2 + 'px';
    this.container.style.marginTop  = -opts["height"]/2 + 'px';
    this.container.style.display  = "block";

    Tr8n.Utils.update('tr8n_lightbox', url, {
      evalScripts: true
    });
  }
}
