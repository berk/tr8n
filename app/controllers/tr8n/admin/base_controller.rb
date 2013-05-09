#--
# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com
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

class Tr8n::Admin::BaseController < Tr8n::BaseController

  if Tr8n::Config.admin_helpers.any?
    helper *Tr8n::Config.admin_helpers
  end

  before_filter :validate_admin
  
  layout Tr8n::Config.site_info[:admin_layout]
  
  def delete
    params[:ids] ||= []
    params[:ids] = [params[:ids]] unless params[:ids].is_a?(Array)
    params[:ids].each do |id|
      case params[:type]
      when "domain"
        object = Tr8n::TranslationDomain.find_by_id(id)
      when "source"
        object = Tr8n::TranslationSource.find_by_id(id)
      when "application"
        object = Tr8n::Application.find_by_id(id)
      when "component"
        object = Tr8n::Component.find_by_id(id)
      when "key_source"
        object = Tr8n::TranslationKeySource.find_by_id(id)
      when "translation_key"
        object = Tr8n::TranslationKey.find_by_id(id)
      when "glossary"
        object = Tr8n::Glossary.find_by_id(id)
      when "topic"
        object = Tr8n::LanguageForumTopic.find_by_id(id)
      when "message"
        object = Tr8n::LanguageForumMessage.find_by_id(id)
      when "translation"
        object = Tr8n::Translation.find_by_id(id)
      when "application_language"
        object = Tr8n::ApplicationLanguage.find_by_id(id)
      when "component_language"
        object = Tr8n::ComponentLanguage.find_by_id(id)
      when "application_translator"
        object = Tr8n::ApplicationTranslator.find_by_id(id)
      when "component_translator"
        object = Tr8n::ComponentTranslator.find_by_id(id)
      when "component_source"
        object = Tr8n::ComponentSource.find_by_id(id)
      when "lock"
        object = Tr8n::TranslationKeyLock.find_by_id(id)
      when "comment"
        object = Tr8n::TranslationKeyComment.find_by_id(id)
      when "vote"
        object = Tr8n::TranslationVote.find_by_id(id)
      else 
        next  
      end
      object.destroy if object
    end  
    redirect_to_source
  end  

private

  def render_lightbox
    render(:layout => false)
  end

  def dismiss_lightbox
    redirect_to(:controller => "/tr8n/help", :action => "lb_done", :origin => params[:origin])
  end

  def validate_tr8n_enabled
    # don't do anything for admin pages
  end

  def validate_current_user
    # don't do anything for admin pages
  end
  
  def tr8n_admin_tabs
    [
        {"title" => "Applications", "description" => "Admin tab", "controller" => "applications"},
        {"title" => "Components", "description" => "Admin tab", "controller" => "components"},
        {"title" => "Sources", "description" => "Admin tab", "controller" => "sources"},
        {"title" => "Languages", "description" => "Admin tab", "controller" => "language"},
        {"title" => "Translation Keys", "description" => "Admin tab", "controller" => "translation_key"},
        {"title" => "Translations", "description" => "Admin tab", "controller" => "translation"},
        {"title" => "Translators", "description" => "Admin tab", "controller" => "translator"},
        {"title" => "Glossary", "description" => "Admin tab", "controller" => "glossary"},
        {"title" => "Forum", "description" => "Admin tab", "controller" => "forum"},
        {"title" => "Metrics", "description" => "Metrics tab", "controller" => "metrics"},
        {"title" => "Client SDK", "description" => "Admin tab", "controller" => "clientsdk"}
    ]
  end
  helper_method :tr8n_admin_tabs

  def validate_admin
    return if Tr8n::Config.env == 'development'

    unless tr8n_current_user_is_admin?
      trfe("You must be an admin in order to view this section of the site")
      redirect_to_site_default_url
    end
  end
  
end