class Tr8n::LanguageMetricFilter < Tr8n::BaseFilter

  def initialize(identity)
    super('Tr8n::LanguageMetric', identity)
  end

  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end

  def predefined_filters(profile)
    super(profile) + [
      ["Totals", "totals"],
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = super(profile, filter_name)
 
    case filter_name
      when "totals"
        filter.add_condition(:metric_date, :is_not_provided)
    end   

    filter.empty? ? nil : filter
  end

end
