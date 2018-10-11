require 'bundler'
require 'active_record'
require 'yaml'
require 'erb'

def import_active_record_tasks(default_rake_app)
  Rake.application = Rake::Application.new
  Rake.application.rake_require('active_record/railties/databases')

  # Customize AR database tasks
  include ActiveRecord::Tasks

  db_dir                               = File.expand_path('../../../db', __FILE__)
  db_config_path                       = File.expand_path('config/database.yml')
  migrations_path                      = "#{db_dir}/migrate"
  environment                          = ENV['RACK_ENV'] || 'development'

  # Must be a String not a Symbol
  DatabaseTasks.env                    = environment
  DatabaseTasks.db_dir                 = db_dir
  DatabaseTasks.database_configuration = YAML.load(ERB.new(File.read(db_config_path)).result)
  DatabaseTasks.migrations_paths       = [migrations_path]

  Rake::Task.define_task(:environment) do
    ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
    # Use Symbol or you'll get deprecation warning
    ActiveRecord::Base.establish_connection(DatabaseTasks.env.to_sym)
  end

  tasks_to_import = %w[db:create db:drop db:purge db:rollback db:migrate
                       db:migrate:up db:migrate:down db:migrate:status
                       db:version db:schema:load db:schema:dump]

  imported_tasks = Rake.application.tasks.select do |task|
    tasks_to_import.include?(task.name)
  end

  # Restore default rake app
  Rake.application = default_rake_app

  imported_tasks.each do |task|
    # import description
    Rake.application.last_description = task.comment
    # import task
    Rake::Task.define_task(task.name) { task.invoke }
  end
end

import_active_record_tasks(Rake.application)
