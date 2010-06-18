class Tr8n::LanguageForumAbuseReportFilter < Tr8n::BaseFilter

  def initialize(identity)
    super('Tr8n::LanguageForumAbuseReportFilter', identity)
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = super(profile, filter_name)
    filter.empty? ? nil : filter
  end

end
