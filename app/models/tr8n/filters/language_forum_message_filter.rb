class Tr8n::LanguageForumMessageFilter < ModelFilter

  def initialize(identity)
    super('Tr8n::LanguageForumMessage', identity)
  end

  def predefined_filters(profile)
    [
      ["Forum Messages Created Today", "created_today"],
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = self.name.constantize.new(profile)
    filter.key=filter_name
 
    if (filter_name=="created_today")
      filter.add_condition(:created_at, :is_on, Date.today)
      return filter
    end

    nil
  end  
end
