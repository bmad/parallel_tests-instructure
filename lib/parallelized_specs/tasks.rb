namespace :parallel do
  def run_in_parallel(cmd, options)
    count = (options[:count] ? options[:count].to_i : nil)
    executable = File.join(File.dirname(__FILE__), '..', '..', 'bin', 'parallelized_spec')
    command = "#{executable} --exec '#{cmd}' -n #{count} #{'--non-parallel' if options[:non_parallel]}"
    abort unless system(command)
  end

  desc "create test databases via db:create --> parallel:create[num_cpus]"
  task :create, :count do |t, args|
    run_in_parallel('rake db:create RAILS_ENV=test', args)
  end

  desc "drop test databases via db:drop --> parallel:drop[num_cpus]"
  task :drop, :count do |t, args|
    run_in_parallel('rake db:drop RAILS_ENV=test', args)
  end

  desc "update test databases by dumping and loading --> parallel:prepare[num_cpus]"
  task(:prepare, [:count] => 'db:abort_if_pending_migrations') do |t, args|
    if defined?(ActiveRecord) && ActiveRecord::Base.schema_format == :ruby
      # dump then load in parallel
      Rake::Task['db:schema:dump'].invoke
      Rake::Task['parallel:load_schema'].invoke(args[:count])
    else
      # there is no separate dump / load for schema_format :sql -> do it safe and slow
      args = args.to_hash.merge(:non_parallel => true) # normal merge returns nil
      run_in_parallel('rake db:test:prepare --trace', args)
    end
  end

  # when dumping/resetting takes too long
  desc "update test databases via db:migrate --> parallel:migrate[num_cpus]"
  task :migrate, :count do |t, args|
    run_in_parallel('rake db:migrate RAILS_ENV=test', args)
  end

  # just load the schema (good for integration server <-> no development db)
  desc "load dumped schema for test databases via db:schema:load --> parallel:load_schema[num_cpus]"
  task :load_schema, :count do |t, args|
    run_in_parallel('rake db:test:load', args)
  end

  desc "run spec in parallel with parallel:spec[num_cpus]"
  task 'spec', :count, :pattern, :options, :arguments do |t, args|
    $LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..'))
    require "parallelized_specs"
    count, pattern, options = ParallelizedSpecs.parse_rake_args(args)
    executable = File.join(File.dirname(__FILE__), '..', '..', 'bin', 'parallelized_spec')
    command = "#{executable} --type 'spec' -n #{count} -p '#{pattern}' -r '#{Rails.root}' -o '#{options}' #{args[:arguments]}"
    abort unless system(command) # allow to chain tasks e.g. rake parallel:spec
  end
end

#backwards compatability
#spec:parallel:prepare
#spec:parallel
namespace :spec do
  namespace :parallel do
    task :prepare, :count do |t, args|
      $stderr.puts "WARNING -- Deprecated!  use parallel:prepare"
      Rake::Task['parallel:prepare'].invoke(args[:count])
    end
  end

  task :parallel, :count, :pattern do |t, args|
    $stderr.puts "WARNING -- Deprecated! use parallel:spec"
    Rake::Task['parallel:spec'].invoke(args[:count], args[:pattern])
  end
end