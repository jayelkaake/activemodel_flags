module ActivemodelFlags
  class ColumnGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration
    desc "Generates the migration to add a flags column to a rails model."
    source_root File.expand_path('../templates', __FILE__)

    def manifest
      migration_template 'migration.rb', "db/migrate/add_flags_to_#{custom_file_name}.rb", {
          :assigns => flags_local_assigns,
          :migration_file_name => "add_flags_field_to_#{custom_file_name}"
      }
    end

    def self.next_migration_number(dir)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    private

    def custom_file_name
      custom_name = class_name.underscore.downcase
      custom_name = custom_name.pluralize if ActiveRecord::Base.pluralize_table_names
      custom_name
    end

    def flags_local_assigns
      {}.tap do |assigns|
        assigns[:migration_action] = "add"
        assigns[:class_name] = "add_flags_fields_to_#{custom_file_name}"
        assigns[:table_name] = custom_file_name
        assigns[:attributes] = [Rails::Generators::GeneratedAttribute.new("flags", "text")]
      end
    end
  end
end