chords = ring(chord_degree(:i, :D3, :major),
              chord_degree(:v, :D2, :major),
              chord_degree(:vi, :D2, :major),
              chord_degree(:iv, :D2, :major),
              chord_degree(:i, :D3, :major),
              chord_degree(:iii, :D3, :major),
              chord_degree(:iv, :D3, :major),
              chord_degree(:v, :D3, :major),
              chord_degree(:vi, :D3, :major),
              chord_degree(:iv, :D3, :major),
              chord_degree(:i, :D3, :major),
              chord_degree(:v, :D2, :major),
              chord_degree(:vi, :D2, :major),
              chord_degree(:vii, :D2, :major),
              chord_degree(:i, :D3, :major),
              chord_degree(:ii, :D3, :major))
chords2 = ring(chord_degree(:i, :D3, :major),
               chord_degree(:i, :D3, :major),
               chord_degree(:vi, :D2, :minor),
               chord_degree(:vii, :D2, :major),
               chord_degree(:i, :D3, :major),
               chord_degree(:i, :D3, :major),
               chord_degree(:vi, :D2, :minor),
               chord_degree(:vii, :D2, :major))
chords3 = ring(chord_degree(:i, :D3, :major),
               chord_degree(:i, :D3, :major),
               chord_degree(:vi, :D2, :minor),
               chord_degree(:vii, :D2, :major),
               chord_degree(:iv, :D2, :major),
               chord_degree(:v, :D2, :major),
               chord_degree(:vi, :D2, :major),
               chord_degree(:vii, :D2, :major))

lens = [64, 16, 8, 16, 40, 36]
chs = [chords, chords2, chords3, chords, chords2, chords]

lens.each_with_index() do |len, i|
  if i > 0 then
    lens[i] = len + lens[i-1]
  end
end

define :get_cur_chord do
  bt = beat().floor
  lens.each_with_index() do |len, i|
    if (bt < len) then
      ch = chs[i]
      return ch[bt]
    end
  end
end

scales = ring(scale(:D3, :major_pentatonic, num_octaves: 4))

define :valuefn do |cur_note, is_ascending, note|
  cur_as_float = hz_to_midi(midi_to_hz(cur_note))
  note_as_float = hz_to_midi(midi_to_hz(note))
  absdist = (note - cur_as_float).abs
  epsilon = 0.00001
  if (absdist < 0.01) or (is_ascending != (note_as_float > cur_as_float)) then
    return epsilon
  else
    return 1.0/absdist**2
  end
end

define :normalize do |map|
  sum = 0
  map.each do |key, val|
    sum +=val
  end
  map.each do |key, val|
    map[key] = val/sum
  end
  return map.sort_by{|key, val| val}
end

define :pick_note do |map|
  map.sort
  search_value = rand(1)
  sum = 0
  map.each do |key, val|
    sum += val
    if (sum > search_value) then return key end
  end
end

current_sleeps = [0.25, 0.5]
define :gen_next_sleep do |index|
  if (rrand(0, 1) < 0.1)
    return 0.5
  else
    return 0.25
  end
end

current_notes = [:D3, :Gb5]
is_ascending = [true, false]
define :gen_next_note do |index|
  cur_scale = scales[beat().floor]
  note_to_value = Hash.new
  cur_scale.each do |x|
    note_to_value[x] = valuefn(current_notes[index], is_ascending[index], x)
  end
  note_to_value = normalize(note_to_value)
  current_notes[index] = pick_note(note_to_value)
  if (rrand(0, 1) < 0.1) then
    is_ascending[index] = !is_ascending[index]
  end
  
  return current_notes[index]
end

samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end

define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end

define :snare do
  sample crispysn(14), pitch_dis: 0.1
  sample crispysn(20), pitch_dis: 0.1
  sample masu("snare", 5), amp: 2.0, pitch_dis: 0.1
end

define :testbeat do
  sample :bd_haus, amp: 1.2, pitch_dis: 0.1
  sleep 0.5
  snare()
  sleep 0.75
  sample :bd_haus, amp: 1.2, pitch_dis: 0.1
  sleep 0.25
  snare()
  sleep 0.5
end

define :testbeat_db do
  2.times do
    sample :bd_haus, amp: 1.2, pitch_dis: 0.1
    sleep 0.25
  end
  snare()
  4.times do
    sample :bd_haus, amp: 1.2, pitch_dis: 0.1
    sleep 0.25
  end
  snare()
  2.times do
    sample :bd_haus, amp: 1.2, pitch_dis: 0.1
    sleep 0.25
  end
end

define :testbeat_tb do
  4.times do
    sample :bd_haus, amp: 1.2, pitch_dis: 0.1
    sleep 0.125
  end
  snare()
  8.times do
    sample :bd_haus, amp: 1.2, pitch_dis: 0.1
    sleep 0.125
  end
  snare()
  4.times do
    sample :bd_haus, amp: 1.2, pitch_dis: 0.1
    sleep 0.125
  end
end

define :testbeat_tb_intro do
  testbeat_tb()
  4.times do
    sample masu("splash", 2)
    snare()
    4.times do
      sample :bd_haus, amp: 1.2, pitch_dis: 0.1
      sleep 0.125
    end
  end
end

define :half_intro do
  4.times do
    testbeat()
  end
  testbeat_intro()
end

define :testbeat_intro do
  3.times do
    sample :bd_haus, amp: 1.2
    sleep 0.5
    snare()
    sleep 0.75
    sample :bd_haus, amp: 1.2
    sleep 0.25
    snare()
    sleep 0.5
  end
  4.times do
    sample masu("splash", 2)
    snare()
    sleep 0.25
    sample :bd_haus, amp: 1.2, pitch_dis: 0.1
    sleep 0.25
  end
  sample masu("crash", 8)
end

define :hihat do
  if (rrand(0, 1) < 0.4) then
    sample masu("crash", (1..4).to_a.choose)
  end
  8.times do
    sample masu("hatopen", (10..13).to_a.choose)
    sleep 0.25
  end
end

define :ride do
  14.times do
    if (rrand(0, 1) < 0.4) then
      sample masu("ride", [6, 7, 8].choose)
    end
    4.times do
      sample masu("ride", [1, 2, 3, 4].choose)
      sleep 0.25
    end
  end
  4.times do |i|
    sample masu("crash", i)
    sleep 0.25
    sample masu("ride", [1, 2, 3, 4].choose)
    sleep 0.25
  end
end

define :playall do |duration, functions|
  start_beat = beat()
  end_beat = start_beat + duration
  functions.each do |fn|
    in_thread do
      send(fn)
      while beat() < end_beat do
          send(fn)
        end
      end
    end
    sleep duration
  end
  
  define :crashonce do
    sample masu("crash", [1, 2, 3, 4].choose)
    sleep 16
  end
  
  
  define :guitar_d do |note|
    with_fx :distortion, clamp_time: 0, relax_time: 0, distort: 0.99, amp: 0.35 do
      sample samples_base + "/guitar/" + note + ".flac", amp: 5
    end
  end
  
  define :guitar_s do |note|
    with_fx :krush, cutoff: 120 do
      with_fx :hpf, cutoff: 30 do
        sample samples_base + "/guitar_single/" + note.to_s() + "_0.flac", amp: 5, start: 0.25, finish: 0.75
        sample samples_base + "/guitar_single/" + note.to_s() + "_0.flac", amp: 5, start: 0.5, finish: 1
        sample samples_base + "/guitar_single/" + note.to_s() + "_1.flac", amp: 5, start: 0.25, finish: 0.75
        sample samples_base + "/guitar_single/" + note.to_s() + "_1.flac", amp: 5, start: 0.5, finish: 1
      end
    end
  end
  
  define :guitar_slicered do |note|
    with_fx :slicer do
      guitar_s(note)
    end
  end
  
  define :get_guitar_chord do
    ch = get_cur_chord()[0]
    test = ch + current_transpose - 50
    if (test < 0) then
      test = test + 12
    end
    if (test >= 12) then
      test = test - 12
    end
    return test
  end
  
  define :guitar do
    guitar_s(get_guitar_chord())
    sleep 1
  end
  
  define :test_1 do
    use_synth :blade
    play gen_next_note(0)
    sleep gen_next_sleep(0)
  end
  
  define :test_2 do
    use_synth :pulse
    play gen_next_note(1), amp: 0.3
    sleep gen_next_sleep(1)
  end
  
  define :test_directional do |up, chidx|
    use_synth :chiplead
    with_fx :slicer, phase: 0.125 do |slicerctl|
      note = get_cur_chord()[chidx] + 36
      ctrl = play note, release: 0, sustain: 4, note_slide: 0.25
      4.times do
        if up then
          note = note+1
        else
          note = note-1
        end
        
        3.times do
          sleep 0.25
          control slicerctl, phase: [0.125, 0.125/2].choose
        end
        control ctrl, note: note
        control slicerctl, phase: [0.125, 0.125/2].choose
        sleep 0.25
      end
    end
  end
  
  define :slidedown do
    use_synth :chiplead
    note = get_cur_chord()[0] + 24
    ctrl = play note, sustain: 16, release: 4, note_slide: 1
    2.times do
      4.times do
        note = note - 1
        control ctrl, note: note, note_slide: 1
        sleep 1
      end
      4.times do
        note = get_cur_chord()[0] + 24
        control ctrl, note: note, note_slide: 0.1
        sleep 0.9
        control ctrl, note: note + 12, note_slide: 0.1
        sleep 0.1
      end
    end
  end
  
  define :slidedown_2 do
    use_synth :chiplead
    3.times do |i|
      note = get_cur_chord()[0] + 24 + 12*i
      ctrl = play note, sustain: 0, release: 8, note_slide: 4, amp: 0.5
      note = note - 12
      control ctrl, note: note
    end
    sleep 16
  end
  
  define :crazyslides do |octave|
    use_synth :chiplead
    with_fx :slicer, phase: 0.125 do |slicerctl|
      note = get_cur_chord()[0] + 24
      ctrl = play note, sustain: 4, release: 0
      32.times do
        control slicerctl, phase: [0.125, 0.125/2].choose
        control ctrl, note: get_cur_chord()[rrand_i(0, 5)] + 8 * octave, note_slide: rrand(0, 1)
        sleep 0.125
      end
    end
  end
  
  
  define :crazyslides_low do
    crazyslides(3)
  end
  
  define :crazyslides_high do
    crazyslides(4)
  end
  
  define :test_down do
    test_directional(false, 0)
  end
  
  define :test_up do
    test_directional(true, 0)
  end
  
  define :bass do
    use_synth :dsaw
    cur_scale = get_cur_chord()
    play_chord [cur_scale[0] - 12], sustain: 1, release: 0.1, amp: 0.5
    sleep 1
  end
  
  define :euclid_beat_full do
    tick
    sample [:tabla_tas1, :tabla_tas2, :tabla_tas3].choose if (spread 4, 11).look
    sample :drum_snare_hard, amp: 0.4 if (spread 2, 7).look
    sample :bd_haus, amp: 1.2 if (spread 1, 4).look
    sleep 0.125
  end
  define :euclid_beat do
    tick
    sample :drum_snare_hard, amp: 0.4 if (spread 1, 3).look
    sample [:tabla_tas1, :tabla_tas2, :tabla_tas3].choose if (spread 4, 11).look
    sleep 0.125
  end
  
  define :the_end do
    notes = [:D4, :Gb4, :A4, :D5]
    use_synth :chiplead
    play notes[3], sustain: 0, release: 4
    use_synth :blade
    play_chord notes, sustain: 0, release: 4
    use_synth :pulse
    play notes[2], sustain: 0, release: 4, amp: 0.3
    sleep 4
  end
  
  define :main do
    playall(8, [:test_1, :bass, :euclid_beat_full])
    playall(8, [:test_1, :test_2, :bass, :euclid_beat, :testbeat_intro])
    with_transpose 7 do
      playall(16, [:test_1, :test_2, :bass, :euclid_beat, :testbeat, :hihat, :guitar])
    end
    playall(16, [:test_1, :test_2, :bass, :euclid_beat, :half_intro, :hihat, :guitar])
    with_transpose 7 do
      playall(16, [:test_1, :test_2, :bass, :euclid_beat_full, :ride])
    end
    playall(8, [:bass, :testbeat, :hihat, :guitar])
    playall(12, [:bass, :testbeat, :hihat, :guitar, :test_down, :crashonce])
    playall(4, [:bass, :testbeat, :hihat, :guitar, :test_up])
    current_notes = [:D3, :Gb5]
    with_transpose 7 do
      playall(16, [:test_1, :test_2, :bass, :euclid_beat, :testbeat, :hihat, :guitar, :slidedown, :crashonce])
    end
    
    playall(8, [:bass, :euclid_beat, :testbeat, :hihat, :guitar, :test_down])
    playall(4, [:bass, :testbeat_db, :hihat, :guitar, :test_down])
    playall(4, [:bass, :testbeat_tb_intro, :hihat, :guitar, :test_down])
    playall(8, [:bass, :testbeat_tb, :hihat, :guitar, :crashonce, :crazyslides_low])
    playall(8, [:bass, :testbeat_tb, :hihat, :guitar, :crashonce, :crazyslides_low, :crazyslides_low])
    playall(8, [:bass, :testbeat_tb, :hihat, :guitar, :crashonce, :crazyslides_low, :crazyslides_low, :crazyslides_high])
    with_transpose 7 do
      playall(16, [:test_1, :test_2, :bass, :euclid_beat, :testbeat, :hihat, :guitar, :crashonce, :crashonce, :crashonce, :slidedown_2])
    end
    playall(16, [:test_1, :test_2, :bass, :euclid_beat, :testbeat, :hihat, :guitar, :crazyslides_low, :crashonce])
    playall(0.25, [:crashonce, :the_end])
  end
  
  main()
  
  define :metro do
    with_fx :pan, pan: -1 do
      sample :bd_haus
      sleep 0.5
    end
  end