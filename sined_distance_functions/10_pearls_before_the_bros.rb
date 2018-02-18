use_bpm 85

samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end
define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end

define :snare do
  sample crispysn(14), amp: 0.7
  sample masu("snare", 5), amp: 2.5
end

define :bdru do
  sample :bd_haus
end

define :hat do
  sample masu("ride", (1..4).to_a.choose), pan: rrand(-0.2, 0.2)
end

define :crash do
  sample masu("crash", [3, 4, 6, 7, 8].choose), amp: 0.6, start: 0.01
end

define :guitar_c do |note|
  with_fx :hpf, cutoff: 35 do
    with_fx :compressor do
      with_fx :pan, pan: -0.2 do
        sample samples_base + "/guitar/" + note + "_1.flac", amp: 7
      end
      with_fx :pan, pan: 0.2 do
        sample samples_base + "/guitar/" + note + "_2.flac", amp: 7
      end
    end
  end
end

define :testchords do
  use_synth :blade
  use_synth_defaults release: 0, sustain: 1, amp: 3
  3.times do
    play_chord chord(:D3, :minor)
    sleep 1
    play_chord chord(:F3, :major), sustain: 0.75
    sleep 0.75
    play_chord chord(:Fs3, :augmented), sustain: 2.25
    sleep 2.25
  end
  play_chord chord(:D3, :minor)
  sleep 1
  play_chord chord(:F3, :major), sustain: 0.75
  sleep 0.75
  play_chord chord(:Gs3, :augmented), sustain: 2.25
  sleep 2.25
end

define :guitar_s do |note|
  with_fx :krush, mix: 0.9, cutoff: 125, res: 0.7, amp: 1.1 do
    with_fx :hpf, cutoff: 35 do
      with_fx :compressor do
        with_fx :pan, pan: -0.2 do
          sample samples_base + "/guitar/" + note + "_1.flac", amp: 7
        end
        with_fx :pan, pan: 0.2 do
          sample samples_base + "/guitar/" + note + "_2.flac", amp: 7
        end
      end
    end
  end
end

define :guitar_clean do
  guitar_c("blues1")
  sleep 8
  guitar_c("blues2")
  sleep 8
end

define :guitar_dist do
  guitar_s("blues3")
  sleep 8
  guitar_s("blues4")
  sleep 8
end

bl1 = ring 0, 3, 6, 5
sl1 = ring 1, 0.75, 1.25, 1
bl2 = ring 0, 3, 0
sl2 = ring 1, 0.75, 2.25

melchords = ring 10, 6, 3, 5,
  3, 6, 10, 5,
  10, 6, 3, 10,
  8, 6, 5, 3
to_deg = [10, 0, 1, 3, 5, 6, 8]
#1 2 2 1 2 2 2
#rotate
#2 1 2 2 1 2 2
#c minor
#ghghggg
#2/3 4/5

meltest = ring 10, 6, 3, 6, 5,
  5, 3, 3, 3, 6, 6, 6, 10, 10, 10, 5, 5, 5,
  10, 6, 3, 6, 10,
  10, 8, 8, 8, 6, 6, 8, 5, 5, 6, 3,
  10, 6, 3, 6, 5,
  5, 3, 3, 3, 6, 6, 6, 10, 10, 10, 5, 5, 5,
  10, 6, 3, 6, 10,
  #10, 8, 8, 10, 8, 6, 6, 8, 6, 5, 5, 6, 5, 3
  10, 8, 8, 10, 8, 6, 8, 5, 5, 6, 5, 3
melsleep = ring 1, 1, 0.5, 0.25, 1,
  0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25,
  1, 1, 0.5, 0.25, 1,
  0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 1,
  1, 1, 0.5, 0.25, 1,
  0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25,
  1, 1, 0.5, 0.25, 1,
  0.25, 0.25, 0.25, 0.25, 0.25, 0.75, 0.25, 0.25, 0.25, 0.25, 0.25, 1
define :testmel_base do |offset|
  use_synth :chiplead
  t = tick() + offset
  dur = melsleep[t]
  use_synth_defaults sustain: 0.125, release: dur
  play :D4 + meltest[t], amp: rrand(1.2, 1.6)
  sleep dur
end

define :testmel do
  testmel_base(0)
end

define :testmel_2ndhalf do
  testmel_base(34)
end

melchords_guitar = ring 10, 6, 35,
  3, 6, 10, 5,
  10, 6, 310,
  8, 6, 5, 3
meldurs_guitar = ring 1, 1, 2,
  1, 1, 1, 1,
  1, 1, 2,
  1, 1, 1, 1

define :guitar_bl do |note, dur|
  guitar_s("bl_" + note.to_s())
  sleep dur
end

define :guitar_mel do
  t = tick()
  guitar_bl(melchords_guitar[t], meldurs_guitar[t])
end

define :bass_mel do
  use_synth :sine
  use_synth_defaults sustain: 0.9, release: 0, attack: 0.1
  play :D1 + melchords.tick()
  sleep 1
end

define :bass do
  use_synth :sine
  use_synth_defaults sustain: 0.25, attack: 0.1
  3.times do
    bl1.length.times do
      t = tick(:s1)
      play :D1 + bl1[t], release: sl1[t] - 0.1
      sleep sl1[t]
    end
  end
  
  bl2.length.times do
    t = tick(:s2)
    play :D1 + bl2[t], release: sl2[t] - 0.1
    sleep sl2[t]
  end
end

define :test_drums do
  bdru
  if rrand(0, 1) < 0.3 then
    with_fx :level, amp: 0.5 do
      snare
    end
  end
  2.times do
    hat
    sleep 0.125
  end
  snare
  2.times do
    hat
    sleep 0.125
  end
end

define :test_drums_pause do
  15.times do
    bdru
    if rrand(0, 1) < 0.3 then
      with_fx :level, amp: 0.5 do
        snare
      end
    end
    2.times do
      hat
      sleep 0.125
    end
    snare
    2.times do
      hat
      sleep 0.125
    end
  end
  bdru
  crash
  sleep 0.5
end

define :test_drums_2 do
  bdru
  crash
  sleep 0.125
  if rrand(0, 1) < 0.2 then
    with_fx :level, amp: 0.7 do
      bdru
    end
  end
  sleep 0.125
  snare
  sleep 0.125
  if rrand(0, 1) < 0.2 then
    with_fx :level, amp: 0.7 do
      bdru
    end
  end
  sleep 0.125
end

define :test_drums_2_dbass do
  bdru
  crash
  sleep 0.125
  with_fx :level, amp: 0.7 do
    bdru
  end
  sleep 0.125
  snare
  sleep 0.125
  with_fx :level, amp: 0.7 do
    bdru
    if rrand(0, 1) < 0.2 then
      snare
    end
  end
  sleep 0.125
end


define :crashqt do
  crash
  sleep 4
end

define :revcrash do
  sleep 11.5
  sample masu("crash_crescendo", 1)
  sleep 32
end

define :revcrash_half do
  sleep 6.5
  4.times do
    hat
    sleep 0.5
  end
  sleep 6.5
  hat
  sleep 0.5
  crash
  sleep 8
end

define :triads do
  16.times do |i|
    deg = to_deg.index(melchords.tick()) + 1
    nct = rrand(0, 1) < 0.25 ? 6 : 3
    inc = nct == 6 ? 1 : 2
    sc = chord_degree(deg, :C5, :minor, nct)
    use_synth :square
    with_fx :pan, pan: -1, pan_slide: 0.5, amp: 0.75 do |pctl|
      control pctl, pan: 0.8
      use_synth_defaults release: 1.0/nct, amp: 2
      nct.times do |i|
        play sc[inc*i]
        sleep 0.5/nct
      end
    end
  end
  sleep 0.0001 # rounding
end

define :blips do
  use_synth :sine
  noteslide = 0.05
  use_synth_defaults note_slide: noteslide, sustain: 16, amp: 0.8
  with_fx :tanh do
    ctl = play :D5
    16.times do |i|
      deg = to_deg.index(melchords.tick()) + 1
      sc = chord_degree(deg, :C4, :minor, 8)
      4.times do |j|
        subsleep = (i == 0 and j == 0) ? 0.5 * noteslide : 0.0
        if rrand(0, 1) < 0.3 then
          2.times do
            control ctl, note: sc.choose(), pan: rrand(-0.2, 0.2)
            sleep 0.125 - subsleep
          end
        else
          control ctl, note: sc.choose(), pan: rrand(-0.2, 0.2)
          sleep 0.25 - subsleep
        end
        control ctl, amp: 1
      end
    end
    sleep 0.5 * noteslide
  end
end

define :gdank do
  with_fx :level, amp: 1.3 do
    sleep 0.02
    guitar_s("gdank")
    sleep 8
  end
end

define :gdank_bass do
  use_synth :sine
  use_synth_defaults release: 0.125
  32.times do
    play :F1
    sleep 0.25
  end
end

define :random_drums do
  with_fx :level, amp: 0.5, amp_slide: 8 do |ctl|
    control ctl, amp: 1
    64.times do
      if rrand(0, 1) < 0.25 then
        bdru
      end
      if rrand(0, 1) < 0.5 then
        snare
      end
      if rrand(0, 1) < 0.5 then
        hat
      end
      if rrand(0, 1) < 0.5 then
        crash
      end
      sleep 0.125
    end
  end
end

endmel_mel = 10, 8, 8, 10, 8, 6, 6, 8, 6, 5, 5, 6, 8, 10
endmel_sleeps = 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 2
define :end_mel do
  use_synth :chiplead
  dur = endmel_sleeps.tick(:p2)
  use_synth_defaults sustain: 0.125, release: dur
  use_bpm current_bpm * 0.95
  play :D4 + endmel_mel.tick(:p1), amp: 1.4
  sleep dur
end

define :crashonce do
  crash
  sleep 32
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
  
  define :main do
    playall(16, [:guitar_clean, :bass, :revcrash_half])
    playall(16, [:crashonce, :revcrash, :test_drums, :guitar_dist, :bass])
    playall(32, [:test_drums_2, :testmel, :guitar_mel, :bass_mel])
    playall(16, [:test_drums_pause, :guitar_dist, :bass])
    playall(16, [:test_drums, :guitar_dist, :bass, :revcrash])
    playall(16, [:test_drums_2, :testmel, :guitar_mel, :bass_mel])
    playall(16, [:test_drums_2_dbass, :testmel_2ndhalf, :guitar_mel, :bass_mel, :triads])
    playall(8, [:gdank, :gdank_bass, :random_drums])
    playall(16, [:test_drums_2, :testmel, :guitar_mel, :bass_mel, :triads])
    playall(15.75, [:test_drums_2_dbass, :testmel_2ndhalf, :guitar_mel, :bass_mel, :triads, :blips])
    playall(4, [:end_mel])
  end
  
  main
  
  define :metro do
    sample :bd_haus, amp: 0.2
    sleep 0.5
  end
  