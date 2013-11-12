require 'parallelized_specs/spec_logger_base'

class ParallelizedSpecs::TrendingExampleFailures < ParallelizedSpecs::SpecLoggerBase

  def example_failed(example, counter, failure)
    if RSPEC_1
      if example.location != nil
        @failed_examples ||= {}
        @failed_examples["#{example.location.match(/spec.*\d/).to_s}*"] = ["#{example.description}*", "#{failure.header}*", "#{failure.exception.to_s.gsub(/\n/,"")}*", "#{failure.exception.backtrace.to_s.gsub(/\n/,"")}*", "#{Date.today}*"]
      end
    end
  end

  def dump_summary(*args);end

  def dump_failures(*args);end

  def dump_failure(*args);end

  def dump_pending(*args);end

  def dump_summary(*args)

    if File.exists?("#{Rails.root}/spec/build_info.txt")
      @hudson_build_info = File.read("#{Rails.root}/spec/build_info.txt")
    else
      @hudson_build_info = "no*hudson build*info"
    end

    lock_output do
      (@failed_examples||{}).each_pair do |example, details|
        @output.puts "#{example}#{details}#{@hudson_build_info}"
      end
      @output.flush
    end
  end
end

