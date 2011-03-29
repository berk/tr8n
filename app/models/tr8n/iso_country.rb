class Tr8n::IsoCountry < ActiveRecord::Base
  set_table_name :tr8n_iso_countries
  has_and_belongs_to_many :languages, :class_name => 'Tr8n::Language', :foreign_key => "tr8n_iso_country_id", :association_foreign_key=>"tr8n_language_id", :join_table=>"tr8n_iso_countries_tr8n_languages"

  def large_flag_image
    base_flag_url(64)
  end

  def medium_flag_image
    base_flag_url(32)
  end

  def small_flag_image
    base_flag_url(24)
  end

  def tiny_flag_image
    base_flag_url(16)
  end
  
  def base_flag_url(size)
    "/flags/#{size}/#{self.code.downcase}.png"
  end
end
