define :comparative_probability_drum_sequence do |patterns|
  total = { bd: Array.new(16, 0), sn: Array.new(16, 0), ch: Array.new(16, 0), oh: Array.new(16, 0) }
  puts total
  patterns.size.times do |i|
    %i[bd sn ch oh].each do |instrument|
      16.times do |j|
        if patterns[i][instrument][j] == 1
          total[instrument][j] += 1
        end
      end
    end
  end
  result = {}
  total.each do |instrument, sequence|
    result[instrument] = sequence.map do |beat_total|
      beat_total.to_f / patterns.size
    end
  end
  result
end
