use_bpm 85
samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"

define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end
define :snare do
  with_fx :reverb do
    sample masu("snare", 4), amp: 8.0
  end
end

define :guitar_s do |note|
  with_fx :hpf, cutoff: 35 do
    with_fx :hpf, cutoff: 50, mix: 0.5 do
      with_fx :lpf, cutoff: 80 do
        with_fx :pan, pan: -0.2 do
          sample samples_base + "/guitar/" + note + "_1.flac", amp: 5
        end
        with_fx :pan, pan: 0.2 do
          sample samples_base + "/guitar/" + note + "_2.flac", amp: 5
        end
      end
    end
  end
end

define :guitar_d do |note|
  with_fx :krush, mix: 0.8, cutoff: 130, res: 0.2, amp: 1.1 do
    with_fx :hpf, cutoff: 35 do
      with_fx :hpf, cutoff: 50, mix: 0.5 do
        with_fx :lpf, cutoff: 80 do
          with_fx :pan, pan: -0.2 do
            sample samples_base + "/guitar/" + note + "_1.flac", amp: 5
          end
          with_fx :pan, pan: 0.2 do
            sample samples_base + "/guitar/" + note + "_2.flac", amp: 5
          end
        end
      end
    end
  end
end

define :whoosh_intro do
  use_synth :dark_ambience
  play :D3, attack: 2, sustain: 8, release: 2, amp: 2
  sleep 8
end

define :randblip do
  use_arg_checks false
  with_fx :bitcrusher, bits: 7 do
    sample [:loop_breakbeat, :loop_compus].choose, start: rrand(0, 0.5), beat_stretch: rrand(0.3, 0.5), pitch: 50 + rrand(-50, 50), amp: rrand(0, 1)
  end
end

define :randblip_2 do
  use_arg_checks false
  with_fx :bitcrusher, bits: 4 do
    sample :ambi_piano, beat_stretch: rrand(0.3, 0.5), pitch: 50 + rrand(-50, 50), amp: rrand(0, 1)
  end
end

define :randblips_intro do
  sleep 56
  with_fx :level, amp: 0, amp_slide: 8 do |ctrl|
    control ctrl, amp: 5
    (8 * 8).times do
      randblip
      sleep 0.125
    end
  end
end

define :randblips_sustain do
  (8 * 8).times do
    randblip_2
    sleep 0.125
  end
end

define :randblips_fade do
  with_fx :level, amp: 1, amp_slide: 8 do |ctrl|
    control ctrl, amp: 0
    (8 * 8).times do
      randblip_2
      sleep 0.125
    end
  end
end

define :chipnoise_intro do
  sleep 48
  with_fx :level, amp: 0, amp_slide: 16 do |ctrl|
    control ctrl, amp: 0.4
    use_synth :chipnoise
    play :D4, sustain: 16, attack: 0, release: 0
    sleep 16
  end
end

define :guitar_intro do
  sleep 16
  cur_amp = 0.1
  with_fx :level, amp: 0, amp_slide: 32 do |ctrl|
    control ctrl, amp: 5
    6.times do
      guitar_s("guit_2_intro")
      sleep 8
    end
  end
end

define :toms_intro do
  sleep 56
  2.times do
    2.times do
      with_fx :reverb, room: 0.8, damp: 0.8 do
        sample :drum_tom_hi_hard, rpitch: -5
        sleep 0.25
        sample :drum_tom_hi_hard, rpitch: -10
        sleep 0.5
        sample :drum_tom_lo_hard, rpitch: -5
        sleep 0.25
        sample :drum_tom_lo_hard, rpitch: -10
        sleep 0.5
      end
    end
    sleep 1
  end
end

define :intro_crash_crescendo do
  sleep 59.5
  sample masu("crash_crescendo", 1)
  sleep 4.5
end

define :crash do
  sample masu("crash", (3..4).to_a.choose), rpitch: rrand(-0.5, 0.5)
end

define :bdru do
  sample :bd_haus
end

define :amen do
  bdru
  crash
  sleep 0.25
  bdru
  sleep 0.25
  crash
  snare
  sleep 0.25
  bdru
  sleep 0.25
  bdru
  crash
  sleep 0.25
  bdru
  sleep 0.25
  snare
  crash
  sleep 0.25
  bdru
  sleep 0.25
end

define :amen_remix do
  with_fx :flanger do
    bdru
    sleep 0.25
    sample masu("ride", 3), amp: 3, rpitch: rrand(-0.1, 0.1)
    sleep 0.25
    snare
    sleep 0.25
    sample masu("ride", 3), amp: 3, rpitch: rrand(-0.1, 0.1)
    sleep 0.25
  end
end

define :tomroll_1 do
  with_fx :level, amp: 0.7 do
    sample :drum_tom_hi_hard
    sleep 0.125
    sample :drum_tom_hi_hard
    sleep 0.125
    sample :drum_tom_hi_hard, rpitch: -5
    sleep 0.125
    sample :drum_tom_hi_hard, rpitch: -5
    sleep 0.125
    sample :drum_tom_lo_hard
    sleep 0.125
    sample :drum_tom_lo_hard
    sleep 0.125
    sample :drum_tom_lo_hard, rpitch: -5
    sleep 0.125
    sample :drum_tom_lo_hard, rpitch: -5
    sleep 0.125
  end
end

define :tomroll_2 do
  with_fx :level, amp: 0.7 do
    sample :drum_tom_hi_hard
    sleep 0.125
    sample :drum_tom_hi_hard, rpitch: -5
    sleep 0.25
    sample :drum_tom_hi_hard, rpitch: -5
    sleep 0.125
    sample :drum_tom_lo_hard
    sleep 0.25
    sample :drum_tom_lo_hard, rpitch: -5
    sleep 0.25
  end
end

define :bash do
  with_fx :level, amp: 0.9 do
    4.times do
      crash
      bdru
      sleep 0.25
      crash
      bdru
      sleep 0.25
      snare
      sleep 0.25
    end
  end
end

define :full_on_bash do
  bash
  tomroll_2
  bash
  tomroll_1
end

define :half_on_bash do
  bash
  sleep 1
  bash
  sample masu("ride", 5), amp: 3
  sleep 0.5
  sample masu("ride", 3), amp: 3
  sleep 0.5
end

define :guitar_hard do
  guitar_d("guit_hard")
  sleep 8
end

define :guitar_outro do
  with_fx :level, amp: 5, amp_slide: 8 do |ctrl|
    control ctrl, amp: 0
    guitar_s("guit_2_intro")
    sleep 8
  end
end


define :guitar_hard_2 do
  3.times do
    guitar_d("guit_e12")
    sleep 2
    guitar_d("guit_e10")
    sleep 1
    guitar_d("guit_e8_7")
    sleep 1
  end
  sleep 0.03
  guitar_d("guit_e4_2")
  sleep 4 - 0.03
end

define :metro do
  sample :bd_haus, amp: 0.2
  sleep 0.5
end

pattern = (ring :d3, :f3, :d3, :f3, :d3, :e3, :d3, :e3,
           :d3, :g3, :d3, :g3, :d3, :f3, :d3, :f3)
times = (ring 0.25, 0.5, 0.25, 0.5, 0.25, 0.5, 0.25, 1.5,
         0.25, 0.5, 0.25, 0.5, 0.25, 0.5, 0.25, 1.5)
define :sawbass do
  8.times do
    use_synth :saw
    note = pattern.tick(:p)
    duration = times.tick(:t)
    play note - 12, release: 0, sustain: duration, amp: 0.5
    play note - 24, release: 0, sustain: duration, amp: 0.5
    sleep duration
  end
end
define :sawbass_2 do
  8.times do
    use_synth :dsaw
    playdur = 0.25
    use_synth_defaults release: playdur/2, sustain: playdur/2, amp: 0.5, res: 0.95
    note = pattern.tick(:p)
    duration = times.tick(:t)
    (duration/playdur).round.times do
      play note - 12
      play note - 24
      sleep playdur
    end
  end
end

define :eudatest do
  use_synth :chiplead
  sleep 6
  ctrl = play (:f4 + 5), sustain: 2, release: 0.03, amp: 0.8, note_slide: 2
  control ctrl, note: :f4 + 17
  sleep 2
end

bassline = ring 0, 0, 2, 0, 3, 0, 5, 7, -2, -2, 2, 3, -4, -4, 0, 2
bassline_2 = ring 5, 5, 5, 5, 5, 5, 3, 3, 5, 5, 5, 5, 5, 5, 5, 5
define :sawbass_3 do
  use_synth :saw
  use_synth_defaults sustain: 0.25/2, release: 0.25/2
  (16 * 3).times do
    note = :d2 + bassline.tick(:bl)
    play note
    play note - 12
    sleep 0.25
  end
  16.times do
    note = :d2 + bassline_2.tick(:bl2)
    play note
    play note - 12
    sleep 0.25
  end
end

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

current_notes = [:D6, :D6]
is_ascending = [true, true]
define :gen_next_note do |index, cur_scale|
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

define :randgen_notes do |idx, synth|
  use_synth synth
  (12 * 8).times do
    cur_scale = scale(:D5, :minor_pentatonic, num_octaves: 2)
    play gen_next_note(0, cur_scale), release: 0.125
    sleep 0.125
  end
  (4 * 8).times do
    cur_scale = chord(:G4, :sus4, num_octaves: 3)
    play gen_next_note(0, cur_scale), release: 0.125
    sleep 0.125
  end
end

define :randgen_notes_ixi do |idx, synth|
  use_synth synth
  (4 * 8).times do
    cur_scale = scale(:D5, :minor_pentatonic, num_octaves: 2)
    play gen_next_note(0, cur_scale), release: 0.125
    sleep 0.125
  end
end

define :randgen_notes_0 do
  with_fx :tanh, krunch: 10 do
    randgen_notes(0, :beep)
  end
end
define :randgen_notes_1 do
  randgen_notes(1, :chiplead)
end

define :ixi_crusher do
  with_fx :krush do
    with_fx :ixi_techno do
      randgen_notes_ixi(1, :chiplead)
    end
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
  
  blarpnotes = ring :D4, :F4, :G4, :A4, :G4, :F4, :G4, :F4, :D4, :F4
  blarpsleeps = ring 0.5, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.5, 0.5
  blarpsnotes2 = ring :D4, :F4, :G4, :A4, :D5, :D5, :C5, :D5
  blarpsleeps2 = ring 0.5
  define :blarp do
    use_synth :blade
    use_synth_defaults amp: 2, release: 1, vibrato_delay: 0, vibrato_rate: 6, vibrato_onset: 0.05, vibrato_depth: 0.2, cutoff: 110
    (10 * 3).times do
      play blarpnotes.tick(:blrp)
      sleep blarpsleeps.tick(:blrps)
    end
    8.times do
      play blarpsnotes2.tick(:blrp2)
      sleep blarpsleeps2.tick(:blrps2)
    end
  end
  
  define :blarp_transposed do
    with_transpose 7 do
      blarp
    end
  end
  
  define :blarp_sliced do
    with_fx :panslicer, phase: 1, pan_min: -0.4, pan_max: 0.4 do
      with_fx :gverb do
        with_fx :slicer, phase: 0.125/2 do
          blarp
        end
      end
    end
  end
  
  define :fiddle_control do |ctrl|
    control ctrl, phase: [0.25, 0.125].choose
    sleep 0.25
  end
  
  define :guitar_hard_2_remix do
    with_fx :slicer do |ctrl|
      3.times do
        guitar_d("guit_e12")
        8.times do fiddle_control(ctrl) end
        guitar_d("guit_e10")
        4.times do fiddle_control(ctrl) end
        guitar_d("guit_e8_7")
        4.times do fiddle_control(ctrl) end
      end
      guitar_d("guit_e4_2")
      16.times do fiddle_control(ctrl) end
    end
  end
  
  define :upwards do
    sleep 12
    ctrl = play :d3, sustain: 4, note_slide: 4
    control ctrl, note: :d5
    sleep 4
  end
  
  define :main do
    playall(64, [:whoosh_intro, :guitar_intro, :randblips_intro, :chipnoise_intro, :toms_intro, :intro_crash_crescendo])
    playall(8, [:sawbass, :guitar_hard, :randblips_sustain, :full_on_bash])
    playall(8, [:sawbass_2, :guitar_hard, :randblips_sustain, :eudatest, :full_on_bash])
    playall(16, [:sawbass_3, :guitar_hard_2, :amen, :randgen_notes_0])
    playall(16, [:sawbass_3, :guitar_hard_2, :amen, :randgen_notes_0, :randgen_notes_1])
    playall(8, [:sawbass, :guitar_hard, :half_on_bash])
    playall(8, [:sawbass_2, :guitar_hard, :full_on_bash])
    playall(16, [:sawbass_3, :guitar_hard_2, :amen, :randgen_notes_0, :blarp])
    playall(16, [:sawbass_3, :guitar_hard_2, :amen, :randgen_notes_0, :randgen_notes_1, :blarp, :blarp_transposed])
    playall(16, [:sawbass_3, :guitar_hard_2_remix, :amen_remix, :blarp_sliced, :randblips_sustain, :upwards])
    playall(16, [:sawbass_3, :guitar_hard_2, :amen, :randgen_notes_0, :randgen_notes_1, :blarp, :blarp_transposed])
    playall(4, [:ixi_crusher])
  end
  
  main
  
  define :metro do
    sample :bd_haus, amp: 0.2
    sleep 0.5
  end
  
  
