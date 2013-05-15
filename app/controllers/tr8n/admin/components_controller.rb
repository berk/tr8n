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

class Tr8n::Admin::ComponentsController < Tr8n::Admin::BaseController

  def index
    @comps = Tr8n::Component.filter(:params => params, :filter => Tr8n::ComponentFilter)
  end

  def change_component_language_state
    component_language = Tr8n::ComponentLanguage.find_by_id(params[:component_language_id])
    component_language.state = params[:state]
    component_language.save
    redirect_to_source
  end

  def lb_update
    @comp = Tr8n::Component.find_by_id(params[:id]) unless params[:id].blank?
    @comp = Tr8n::Component.new unless @comp

    if request.post?
      if @comp.id
        @comp.update_attributes(params[:comp])
      else
        @comp = Tr8n::Component.create(params[:comp])
      end
      
      return dismiss_lightbox      
    end

    @apps = Tr8n::Application.options
    render_lightbox
  end

  def lb_add_objects
    @type = params[:type] || component_link_types.first
    @type = component_link_types.first unless component_link_types.include?(@type)

    @comp = Tr8n::Component.find_by_id(params[:id])
    @app = @comp.application

    if @type == "language"
      @languages = @app.languages
    elsif @type == "source"   
      @sources = @app.sources.order("source asc")
    elsif @type == "translator"   
      @translators = @app.translators
    end
    
    render :partial => "lb_add_#{@type.pluralize}"
  end

  def add_objects
    unless component_link_types.include?(params[:type])
      trfe("Invalid object type")
      return redirect_to_source
    end
    type = params[:type].capitalize
    model_class_name = (type == "Source" ? "TranslationSource" : type)

    comp = Tr8n::Component.find(params[:id])
    params[:ids].each do |id|
      next if id.blank?
      lang = "Tr8n::#{model_class_name}".constantize.find_by_id(id)
      "Tr8n::Component#{type}".constantize.find_or_create(comp, lang) if lang
    end

    dismiss_lightbox
  end

  def view
    @comp = Tr8n::Component.find_by_id(params[:id])
    @languages = Tr8n::ComponentLanguage.find(:all, :conditions=>["component_id = ?", @comp.id]).collect{|cl| cl.language}.compact
    @translators = Tr8n::ComponentTranslator.find(:all, :conditions=>["component_id = ?", @comp.id]).collect{|ct| ct.translator}.compact

    unless @comp
      trfe("Invalid component id")
      return redirect_to_source
    end

    if params[:mode] == "translation_keys"
      conditions = ["cs.component_id = ?", @comp.id]

      unless params[:q].blank?
        conditions[0] << " and (tr8n_translation_keys.label like ? or tr8n_translation_keys.description like ?)"
        conditions << "%#{params[:q]}%"
        conditions << "%#{params[:q]}%"
      end

      @results = Tr8n::TranslationKey.find(:all, 
          :select => "distinct tr8n_translation_keys.id, tr8n_translation_keys.created_at, label, description, locale, admin, level, translation_count",
          :order => "tr8n_translation_keys.created_at desc",
          :conditions => conditions,
          :joins => [
            "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id",
            "join tr8n_component_sources as cs on tks.translation_source_id = cs.translation_source_id"
          ]
      ).page(page).per(per_page)
    elsif params[:mode] == "translations"
      conditions = ["cs.component_id = ?", @comp.id]

      @language_options = @languages.collect{|l| [l.english_name, l.id.to_s]}
      @language_options.unshift(['All', 'all'])

      if @languages.any?
        conditions[0] << " and tr8n_translations.language_id in (?)"
        if params[:language] and params[:language] != 'all'
          conditions << [params[:language]]
        else
          conditions << @languages.collect{|l| l.id}
        end
      else
        conditions[0] << " and 1 = 2"
      end

      @translator_options = @translators.collect{|t| [t.name, t.id.to_s]}
      @translator_options.unshift(['Any', 'any'])
      if params[:translator] and params[:translator] != 'any'
        conditions[0] << " and tr8n_translations.translator_id in (?)"
        conditions << [params[:translator]]
      end

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
            "join tr8n_component_sources as cs on tks.translation_source_id = cs.translation_source_id"
          ]
      ).uniq.page(page).per(per_page)
    else
      klass = {
        :metrics => Tr8n::ComponentSource,
        :sources => Tr8n::ComponentSource,
        :charts => Tr8n::ComponentSource,
        :translators => Tr8n::ComponentTranslator,
        :languages => Tr8n::ComponentLanguage,
      }[params[:mode].to_sym] if params[:mode]
      klass ||= Tr8n::ComponentSource

      filter = {"wf_c0" => "component_id", "wf_o0" => "is", "wf_v0_0" => @comp.id}
      extra_params = {:id => @comp.id, :mode => params[:mode]}
      @results = klass.filter(:params => params.merge(filter))
      @results.wf_filter.extra_params.merge!(extra_params)      
    end
  end

private

  def component_link_types
    ["language", "source", "translator"]
  end

end