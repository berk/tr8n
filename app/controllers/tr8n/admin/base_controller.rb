class Tr8n::Admin::BaseController < Tr8n::BaseController
  
  before_filter :validate_admin
  
  layout Tr8n::Config.site_info[:admin_layout]
  
private

  def init_model_filter(class_name)
    return ModelFilter.new(class_name, tr8n_current_user).deserialize_from_params(params) if class_name.is_a?(String)
    class_name.new(tr8n_current_user).deserialize_from_params(params)
  end
  
  def tr8n_admin_tabs
    [
        {"title" => "Languages", "description" => "Admin tab", "controller" => "language"},
        {"title" => "Translation Keys", "description" => "Admin tab", "controller" => "translation_key"},
        {"title" => "Translations", "description" => "Admin tab", "controller" => "translation"},
        {"title" => "Translators", "description" => "Admin tab", "controller" => "translator"},
        {"title" => "Translator Logs", "description" => "Admin tab", "controller" => "translator_log"},
        {"title" => "Translation Key Sources", "description" => "Admin tab", "controller" => "translation_key_source"},
        {"title" => "Glossary", "description" => "Admin tab", "controller" => "glossary"},
        {"title" => "Forum", "description" => "Admin tab", "controller" => "forum"}
    ]
  end
  helper_method :tr8n_admin_tabs

  def validate_admin
    unless tr8n_current_user_is_admin?
      trfe("You must be an admin in order to view this section of the site")
      redirect_to_site_default_url
    end
  end
  
end