var Wf = Wf || {};
Wf.Effects = {
  blindUp: function(element_id) {
		Effect.BlindUp(element_id, { duration: 0.25 });
  },
  blindDown: function(element_id) {
    Effect.BlindDown(element_id, { duration: 0.25 });
  },
  appear: function(element_id) {
    Effect.Appear(element_id, { duration: 0.25 });
  },
  fade: function(element_id) {
    Effect.Fade(element_id, { duration: 0.25 });
  }
}