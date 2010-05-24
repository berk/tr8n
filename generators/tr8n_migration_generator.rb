class Tr8nMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template "migrate/create_tr8n_tables.rb", "db/migrate", :migration_file_name => "create_tr8n_tables"
    end
  end
end