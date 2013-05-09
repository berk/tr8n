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

class Tr8n::Admin::ApplicationsController < Tr8n::Admin::BaseController

  def index
    @apps = Tr8n::Application.filter(:params => params, :filter => Tr8n::ApplicationFilter)
  end
  
  def lb_update
    @app = Tr8n::Application.find_by_id(params[:id]) unless params[:id].blank?
    @app = Tr8n::Application.new unless @app

    if request.post?
      if @app.id
        @app.update_attributes(params[:app])
      else
        @app = Tr8n::Application.create(params[:app])
      end
      return dismiss_lightbox
    end

    render_lightbox
  end

  def view
    @app = Tr8n::Application.find_by_id(params[:id])

    unless @app
      trfe("Invalid application id")
      return redirect_to_source
    end

    params[:mode] ||= "metrics"

    if params[:mode] == "metrics"
      @results = @app.components
    elsif params[:mode] == "translation_keys"
      conditions = ["ts.application_id = ?", @app.id]
      unless params[:q].blank?
        conditions[0] << " and (tr8n_translation_keys.label like ? or tr8n_translation_keys.description like ?)"
        conditions << "%#{params[:q]}%"
        conditions << "%#{params[:q]}%"
      end
      @results = Tr8n::TranslationKey.find(:all, 
          :select => "distinct tr8n_translation_keys.id, tr8n_translation_keys.created_at, tr8n_translation_keys.label, tr8n_translation_keys.description, tr8n_translation_keys.locale, tr8n_translation_keys.admin, tr8n_translation_keys.level, tr8n_translation_keys.translation_count",
          :order => "tr8n_translation_keys.created_at desc",
          :conditions => conditions,
          :joins => [
            "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id",
            "join tr8n_translation_sources as ts on tks.translation_source_id = ts.id"
          ]
      ).page(page).per(per_page)
    elsif params[:mode] == "translations"
      conditions = ["ts.application_id = ?", @app.id]
      unless params[:q].blank?
        conditions[0] << " and (tr8n_translations.label like ?)"
        conditions << "%#{params[:q]}%"
      end
      @results = Tr8n::Translation.find(:all, 
          :order => "tr8n_translations.created_at desc",
          :conditions => conditions,
          :joins => [
            "join tr8n_translation_keys as tk on tr8n_translations.translation_key_id = tk.id",
            "join tr8n_translation_key_sources as tks on tk.id = tks.translation_key_id",
            "join tr8n_translation_sources as ts on tks.translation_source_id = ts.id"
          ]
      ).uniq.page(page).per(per_page)
    else
      klass = {
        :components => Tr8n::Component,
        :languages => Tr8n::ApplicationLanguage,
        :translators => Tr8n::ApplicationTranslator,
        :domains => Tr8n::TranslationDomain,
        :sources => Tr8n::TranslationSource,
      }[params[:mode].to_sym] if params[:mode]
      klass ||= Tr8n::Component

      filter = {"wf_c0" => "application_id", "wf_o0" => "is", "wf_v0_0" => @app.id}
      extra_params = {:id => @app.id, :mode => params[:mode]}
      @results = klass.filter(:params => params.merge(filter))
      @results.wf_filter.extra_params.merge!(extra_params)      
    end
  end

  def lb_update_domain
    @app = Tr8n::Application.find_by_id(params[:id])
    @domain = Tr8n::TranslationDomain.find_by_id(params[:domain_id]) unless params[:domain_id].blank?
    @domain = Tr8n::TranslationDomain.new unless @domain
    @domain.application = @app

    if request.post?
      @domain.update_attributes(params[:domain])
      return dismiss_lightbox
    end

    render_lightbox
  end

  def lb_add_objects
    @type = params[:type] || linked_types.first
    @type = linked_types.first unless linked_types.include?(@type)

    @app = Tr8n::Application.find_by_id(params[:id])
    if @type == "language"
      @languages = Tr8n::Language.enabled_languages
    elsif @type == "source"   
      @sources = Tr8n::TranslationSource.find(:all, :order => "source asc")
    elsif @type == "translator"   
    end
    
    render :partial => "lb_add_#{@type.pluralize}"
  end

  def add_objects
    unless linked_types.include?(params[:type])
      trfe("Invalid object type")
      return redirect_to_source
    end
    type = params[:type].capitalize
    model_class_name = (type == "Source" ? "TranslationSource" : type)

    app = Tr8n::Application.find(params[:id])
    params[:ids].each do |id|
      next if id.blank?
      lang = "Tr8n::#{model_class_name}".constantize.find_by_id(id)
      "Tr8n::Application#{type}".constantize.find_or_create(app, lang) if lang
    end

    dismiss_lightbox
  end

private

  def linked_types
    ["language", "source", "translator"]
  end

end