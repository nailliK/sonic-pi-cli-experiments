# define :acid_chords do |port, channel, root, key, inversion, repeats, division| 
# 	repeats.times do
# 		if one_in(3)
# 			midi (chord root, key, num_octaves: 3).choose, port: port, channel: channel, sustain: rrand(division / 2, division * 2)
# 		end

# 		sleep division

# 		midi_note_off port: port, channel: channel
# 	end
# end

# define :drum_trigger do |port, channel, note|
# 	midi note, port: port, channel: channel, sustain: 0.0125
# end




