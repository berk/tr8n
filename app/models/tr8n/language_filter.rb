class Tr8n::LanguageFilter < ModelFilter

  def initialize(identity)
    super('Tr8n::Language', identity)
  end

  def exportable?
    false
  end

  def default_order
    'completeness'
  end
  
  def default_order_type
    'desc'
  end

  def predefined_filters(profile)
    [
      ["Enabled Languages", "enabled"],
      ["Disabled Languages", "disabled"],
      ["Completed Languages", "completed"],
      ["Left-to-Right Languages", "left"],
      ["Right-to-Left Languages", "right"]
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = self.name.constantize.new(profile)
    filter.key=filter_name
 
    if (filter_name=="enabled")
      filter.add_condition(:enabled, :is, '1')
      return filter
    end

    if (filter_name=="disabled")
      filter.add_condition(:enabled, :is, '0')
      return filter
    end

    if (filter_name=="completed")
      filter.add_condition(:completeness, :is, 100)
      return filter
    end

    if (filter_name=="left")
      filter.add_condition(:right_to_left, :is, '0')
      return filter
    end

    if (filter_name=="right")
      filter.add_condition(:right_to_left, :is, '1')
      return filter
    end

    nil
  end

end
