#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8nhub.com
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

class Tr8n::Api::TranslationController < Tr8n::Api::BaseController

  def submit
    ensure_post
    ensure_translator

    if params[:key]
      tkey = Tr8n::TranslationKey.find_by_key(params[:key])
    elsif params[:id]
      tkey = Tr8n::TranslationKey.find_by_id(params[:id])
    end

    unless tkey
      raise Tr8n::Exception.new("Translation key not found")
    end

    if params[:locale]
      language = Tr8n::Language.for(params[:locale])
    end

    unless language
      raise Tr8n::Exception.new("Invalid or missing locale")
    end

    if params[:translation].blank?
      raise Tr8n::Exception.new("Translation must be provided")
    end
    
    translation = tkey.add_translation(params[:translation], nil, language, translator)
    render_response({:translation_key => tkey.key, :translation => translation.label})
  end

  def delete
    ensure_post 
    ensure_application_admin

    trn = Tr8n::Translation.find_by_id(params[:id]) if params[:id]
    trn.destroy if trn
 
    render_success
  end  
  
end