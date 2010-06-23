class Tr8nMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template "migrate/create_tr8n_tables.rb", "db/migrate", :migration_file_name => "create_tr8n_tables"
      m.migration_template "migrate/register_independent_translators.rb", "db/migrate", :migration_file_name => "register_independent_translators"
    end
  end
end