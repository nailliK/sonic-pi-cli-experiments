# Function to calculate frequency of beats
def calculate_frequency(beats)
  beats.map { |beat| beat == 1 ? 1 : 0 }.reduce(:+)
end

# Function to calculate total position
def calculate_positions(beats)
  beats.each_with_index.map { |beat, idx| beat == 1 ? (idx + 1) : 0 }.reduce(:+)
end

# Function to calculate average position
def calculate_avg_position(total, count)
  count.zero? ? 0 : (total / count.to_f).round(2)
end

def calculate_pattern_stats(patterns)
  instrument_stats = Hash.new { |h, k| h[k] = { frequency: [], total_positions: [], avg_position: [] } }

  patterns.each do |pattern|
    pattern.each do |key, beats|
      next unless [:bd, :sn, :ch, :oh].include?(key)

      instrument = key
      idx = 0
      beats.each do |beat|
        next unless beat == 1

        instrument_stats[instrument][:frequency][idx] ||= 0
        instrument_stats[instrument][:frequency][idx] += 1

        instrument_stats[instrument][:total_positions][idx] ||= 0
        instrument_stats[instrument][:total_positions][idx] += (idx + 1)

        idx += 1
      end
    end
  end

  instrument_stats.each_value do |stats|
    stats[:avg_position] = stats[:total_positions].zip(stats[:frequency]).map do |total, freq|
      calculate_avg_position(total, freq)
    end
  end

  instrument_stats
end
