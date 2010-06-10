module Tr8n::CommonMethods

  def self.included(base)
    if 'ApplicationController' == base.name
      base.append_before_filter :init_tr8n
    end
  end

  def init_tr8n
    tr8n_current_locale = nil
    begin
      tr8n_current_locale = eval(Tr8n::Config.current_locale_method)
    rescue Exception => ex
      # fallback to the default session based locale implementation
      session[:locale] = Tr8n::Config.default_locale unless session[:locale]
      session[:locale] = params[:locale] if params[:locale]
      tr8n_current_locale = session[:locale]
    end
    
    tr8n_current_user = nil
    begin
      tr8n_current_user = eval(Tr8n::Config.current_user_method)
    rescue Exception => ex
      raise Tr8n::Exception.new("Tr8n cannot be initialized because #{Tr8n::Config.current_user_method} failed with: #{ex.message}")
    end
    
    Tr8n::Config.init(tr8n_current_locale, tr8n_current_user)
  end

  # translation functions
  def tr(label, desc = "", tokens = {}, options = {})
    unless desc.nil? or desc.is_a?(String)
      raise Tr8n::Exception.new("The second parameter of the tr function must be a description")
    end
    
    if Tr8n::Config.enable_key_source_tracking?
      begin
        if self.respond_to?(:controller)
          source = "#{controller.controller_name}/#{controller.action_name}"
        else
          source = "#{controller_name}/#{action_name}"
        end
      rescue Exception => ex
        source = self.class.name
      end
      options.merge!(:source => source) unless options[:source]
    end
    
    unless Tr8n::Config.enabled?
      return Tr8n::TranslationKey.substitute_tokens(label, tokens, options)
    end
    
    Tr8n::Config.current_language.translate(label, desc, tokens, options)
  end

  # for translating labels
  def trl(label, desc = "", tokens = {}, options = {})
    tr(label, desc, tokens, options.merge(:skip_decorations => true))
  end

  # flash notice
  def trfn(label, desc = "", tokens = {}, options = {})
    flash[:trfn] = tr(label, desc, tokens, options)
  end

  # flash error
  def trfe(label, desc = "", tokens = {}, options = {})
    flash[:trfe] = tr(label, desc, tokens, options)
  end
  # end translation helper methods
  
end
