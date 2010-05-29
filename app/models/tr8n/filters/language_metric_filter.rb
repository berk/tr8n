class Tr8n::LanguageMetricFilter < ModelFilter

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
    [
      ["Totals", "totals"],
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = self.name.constantize.new(profile)
    filter.key=filter_name
 
    if (filter_name=="totals")
      filter.add_condition(:metric_date, :is_not_provided)
      return filter
    end

    nil
  end

end
