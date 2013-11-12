require 'rubygems'
require 'active_record'
require 'date'

ActiveRecord::Base.establish_connection(
    :adapter => 'yourdbtype',
    :host => 'yourhost',
    :encoding => 'utf8',
    :database => 'selenium_trending',
    :username => 'youruser',
    :password => 'youtpass'
)

class SeleniumTrend < ActiveRecord::Base
  ActiveRecord::Migration.class_eval do
    unless SeleniumTrend.table_exists?
      create_table :selenium_trends do |t|
        t.integer :hudson_build
        t.string :hudson_project
        t.string :hudson_url
        t.string :spec_line_failure
        t.string :spec_name
        t.string :nested_spec_name
        t.string :trace
        t.string :full_path
        t.date :failure_date
      end
    end
  end
end

def store_failure_data
  dir = Dir.pwd
  data = "#{dir}/tmp/parallel_log/trends.log"
  File.open("#{data}", 'r') do |f|
    f.each_line do |line|
      values = line.split("*").to_a

      if values != nil
        spec_line_failure = values[0]
        spec_name = values[1]
        nested_spec_name = values[2]
        trace = values[3]
        full_path = values[4]
        failure_date = values[5]
        hudson_build = values[6]
        hudson_project = values[7]
        hudson_url = values[8]

        SeleniumTrend.create!(:spec_line_failure => spec_line_failure, :spec_name => spec_name, :nested_spec_name => nested_spec_name, :trace => trace, :full_path => full_path, :failure_date => failure_date, :hudson_build => hudson_build, :hudson_project => hudson_project, :hudson_url => hudson_url)
      end
    end
  end
end

store_failure_data
