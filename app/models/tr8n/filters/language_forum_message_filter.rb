class Tr8n::LanguageForumMessageFilter < Tr8n::BaseFilter

  def initialize(identity)
    super('Tr8n::LanguageForumMessage', identity)
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = super(profile, filter_name)
    filter.empty? ? nil : filter
  end

end
