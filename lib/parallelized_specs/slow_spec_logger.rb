require 'parallelized_specs'

module RSpec


  class ParallelizedSpecs::SlowestSpecLogger < ParallelizedSpecs::SpecLoggerBase

    def example_started(example)
      @spec_start_time = Time.now
    end

    def example_passed(example)
      total_time = determine_spec_duration(@spec_start_time)
      write_total_spec_time(total_time, example)
    end

    def example_failed(example, count, failure)
      total_time = determine_spec_duration(@spec_start_time)
      write_total_spec_time(total_time, example)
    end

    def determine_spec_duration(spec_start_time)
      total_time = Time.now - spec_start_time
      total_time
    end

    def write_total_spec_time(total_time, example)
      lock_output do
        @output.puts "#{total_time}*#{example.description}*#{example_group.location}"
      end
      @output.flush
    end
  end
end
