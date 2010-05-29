class Tr8n::Admin::BaseController < Tr8n::BaseController
  
  CHART_COLORS = ['AFD8F8', 'F6BD0F', '8BBA00', 'FF8E46', '008E8E', 'D64646', '8E468E', '588526', 'B3AA00', '008ED6', '9D080D', 'A186BE']
  
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
  
  def generate_chart_xml(opts)
    limit = opts[:limit]
    total = total_set(opts[:sets]) 

    color_index = 0
    counter = 0
    
    limit_label = "(top #{limit})" if limit
    
    result = ""
    xml = Builder::XmlMarkup.new(:target=>result, :indent=>1)
    xml.instruct!
    xml.graph(:caption            =>  "#{opts[:subject].pluralize} by #{opts[:xAxisName]} #{limit_label}", 
              :subcaption         =>  "Total #{total} #{opts[:subject].pluralize}",
              :xAxisName          =>  opts[:xAxisName].pluralize, 
              :yAxisName          =>  opts[:yAxisName], 
              :showNames          =>  '1', 
              :decimalPrecision   =>  '0', 
              :rotateNames        =>  '1',
              :formatNumberScale  =>  '0') do
      if total > 0           
        opts[:sets].each do |set|
          break if limit and counter >= limit

          if set[1] and set[1].to_i > 0
            xml.set("", :name=>set[0], :value=>set[1], :color=>CHART_COLORS[color_index]) 
            counter += 1
          end
          
          color_index = next_color(color_index)
        end
      end
    end    
    
    result
  end
    
  def total_set(sets)
    total = 0 
    sets.each do |set| 
      total += set[1].to_i
    end   
    total
  end
    
  def next_color(index)
    index += 1
    index = 0 if index >= CHART_COLORS.size
    index
  end  
end