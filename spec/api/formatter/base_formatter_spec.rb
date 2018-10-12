require 'spec_helper'

module API
  module Formatter
    describe BaseFormatter do
      it 'calculates elapsed time' do
        start_time = Time.now
        end_time = start_time + 0.03456
        expect(BaseFormatter.time_taken(start_time, end_time)).to eq 34.56
      end
    end
  end
end

