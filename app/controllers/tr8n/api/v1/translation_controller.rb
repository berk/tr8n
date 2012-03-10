#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Tr8n::Api::V1::TranslationController < Tr8n::Api::V1::BaseController
  unloadable

  def submit
    return sanitize_api_response({:error => "Api is disabled"}) unless Tr8n::Config.enable_api?
    return sanitize_api_response({:error => "Guest user cannot submit a translation"}) if tr8n_current_user_is_guest?

    if params[:translation_key]
      translation_key = Tr8n::TranslationKey.find_by_key(params[:translation_key])
    else
      translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    end
    
    unless request.post?
      return sanitize_api_response({:error => "Please use a translator window for submitting translations"})
    end

    if params[:translation_id].blank?
      translation = Tr8n::Translation.new(:translation_key => translation_key, :language => tr8n_current_language, :translator => tr8n_current_translator)
    else  
      translation = Tr8n::Translation.find(params[:translation_id])
    end
    
    translation.label = sanitize_label(params[:label])

    unless translation.can_be_edited_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to update translation which is locked or belongs to another translator")
      return sanitize_api_response({:error => "You are not authorized to edit this translation"})
    end  

    if translation.blank?
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an empty translation")
      return sanitize_api_response({:error => "Your translation was empty and was not accepted"})
    end
    
    unless translation.uniq?
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an identical translation")
      return sanitize_api_response({:error => "There already exists such translation for this phrase. Please vote on it instead or suggest an elternative translation."})
    end
    
    unless translation.clean?
      tr8n_current_translator.used_abusive_language!
      return sanitize_api_response({:error => "Your translation contains prohibited words and will not be accepted"})
    end

    translation.save_with_log!(tr8n_current_translator)
    translation.reset_votes!(tr8n_current_translator)

    sanitize_api_response({:translation_key => translation_key.key, :label => translation.label})
  end
  
end