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

class Tr8n::Tools::TranslatorController < Tr8n::BaseController

  skip_before_filter :validate_guest_user
  skip_before_filter :validate_current_translator

  # for ssl access to the translator - using ssl_requirement plugin  
  ssl_allowed :translator, :select, :lists, :switch, :remove  if respond_to?(:ssl_allowed)

  layout 'tr8n/tools/translator'

  def splash_screen
    render(:layout => false)
  end

  def index
    unless translation_key
      trfe("Translation key must be specified")
      return redirect_to(:action => :error, :origin => params[:origin])
    end

    unless tr8n_current_user_is_translator?
      return redirect_to(:action => :login, :translation_key_id => translation_key.id, :origin => params[:origin])
    end

    translations = translation_key.inline_translations_for(tr8n_current_language)
    if translations.any?
      redirect_to(:action => :vote, :translation_key_id => translation_key.id, :origin => params[:origin])
    else
      redirect_to(:action => :submit, :translation_key_id => translation_key.id, :origin => params[:origin])
    end
  end

  def login
    @hide_header = true
  end

  def submit
    @translation = Tr8n::Translation.default_translation(translation_key, tr8n_current_language, tr8n_current_translator)
  end

  def dependencies
    @translation = Tr8n::Translation.default_translation(translation_key, tr8n_current_language, tr8n_current_translator)
  end

  def vote
    @translations = translation_key.inline_translations_for(tr8n_current_language)
  end

  def permutations
    translation_key
    @permutations = Tr8n::Translation.where("id in (?)", params[:ids].split(',')).all if params[:ids]
    @permutations ||= []
  end

  def done
    @translations = translation_key.translate(tr8n_current_language, {}, {:api => :translate})
    @translations = [@translations] unless @translations.is_a?(Array)
  end

private
  
  def translation_key
    @translation_key ||= Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
  end
  helper_method :translation_key

end

