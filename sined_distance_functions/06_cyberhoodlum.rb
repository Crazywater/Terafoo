
sc = scale(:C3, :hirajoshi)
load_samples [:ambi_glass_rub, :ambi_piano]
chords = ring(chord(:C2, :minor, num_octaves: 3),
              chord(:C2, :minor, invert: 1, num_octaves: 3),
              chord(:C2, :minor, invert: 2, num_octaves: 3),
              chord(:C3, :minor, num_octaves: 3),
              chord(:C2, :minor, num_octaves: 3),
              chord(:C2, :minor, invert: 1, num_octaves: 3),
              chord(:C2, :minor, invert: 2, num_octaves: 3),
              chord(:C3, :minor, num_octaves: 3),
              chord(:Ab2, :major, num_octaves: 3),
              chord(:Ab2, :major, invert: 1, num_octaves: 3),
              chord(:Ab2, :major, invert: 2, num_octaves: 3),
              chord(:Ab3, :major, num_octaves: 3),
              chord(:G3, :major, num_octaves: 3),
              chord(:G3, :major, invert: 1, num_octaves: 3),
              chord(:G3, :major, invert: 2, num_octaves: 3),
              chord(:G4, :major, num_octaves: 3))

# does not actually reverse due to multiple octaves... meh
reverse_chords = []
chords.each() do |ch|
  reverse_chords.push(chord_invert(ch, 2))
end

chords_half = ring(chord(:C2, :minor, num_octaves: 3),
                   chord(:C2, :minor, invert: 1, num_octaves: 3),
                   chord(:C2, :minor, invert: 2, num_octaves: 3),
                   chord(:C3, :minor, num_octaves: 3),
                   chord(:C2, :minor, num_octaves: 3),
                   chord(:C2, :minor, invert: 1, num_octaves: 3),
                   chord(:C2, :minor, invert: 2, num_octaves: 3),
                   chord(:C3, :minor, num_octaves: 3))
chords_last = ring(chord(:G3, :major, num_octaves: 3),
                   chord(:G3, :major, invert: 1, num_octaves: 3),
                   chord(:G3, :major, invert: 2, num_octaves: 3),
                   chord(:G4, :major, num_octaves: 3))
bass_notes = ring(:F3, :Eb3, :C3, :Eb3, :F3, :G3)
bass_durations = ring(7, 1, 8)
define :get_cur_chord do
  return chords[beat().floor()]
end

define :joshi_intro do |timings|
  use_synth :chiplead
  ch = chords.tick().take(timings.choose)
  ch.each() do |note|
    play note + 12, release: 0.5
    sleep 1.0/ch.length + 0.000000001
  end
end

define :joshi_intro_6 do
  joshi_intro([6])
end

define :joshi_intro_68 do
  joshi_intro([6,8])
end

define :joshi_bridge do |chs, reverse|
  use_synth :chiplead
  ch = chs.tick().take(8)
  if reverse then
    ch = ch.reverse
  end
  
  ch.each() do |note|
    play note + 24, release: 0.25
    sleep 1.0/ch.length + 0.000000001
  end
end

define :joshi_bridge_half do
  joshi_bridge(chords_half, false)
end

define :joshi_bridge_full do
  joshi_bridge(chords, false)
end

define :joshi_bridge_full_reverse do
  joshi_bridge(reverse_chords, true)
end

define :joshi_intro_last do
  use_synth :chiplead
  ch = chords_last.tick().take(8)
  ch.each() do |note|
    play note + 12, release: 0.5
    sleep 1.0/ch.length + 0.000000001
  end
end

define :bass_note do |note, dur|
  use_synth :dsaw
  with_fx :hpf, cutoff: 40 do
    play note-12, amp: 0.7, sustain: dur, release: 0, detune: 0.05, cutoff: 110
    play note-5, amp: 0.3, sustain: dur, release: 0, detune: 0.05, cutoff: 110
    play note, amp: 0.3, sustain: dur, release: 0, detune: 0.05, cutoff: 110
    sleep dur
  end
end

define :bass_intro do
  dur = bass_durations.tick(:duration)*0.5
  note = bass_notes.tick(:note)
  bass_note(note, dur)
end

define :bass_intro_last do
  bass_note(bass_notes[-1], 8)
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
  
  samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
  define :crispysn do |i|
    return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
  end
  define :masu do |name, i|
    return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
  end
  
  define :snare do
    sample crispysn(14), pitch: 0, pitch_dis: 0.01, time_dis: 0.01
    sample crispysn(20), pitch: 0, pitch_dis: 0.01, time_dis: 0.01
    sample masu("snare", 5), amp: 1.5, pitch: 0, pitch_dis: 0.01, time_dis: 0.01
  end
  
  define :snareloop do
    sleep 0.25
    snare
    sleep 0.5
    snare
    sleep 0.25
  end
  
  define :bassloop do
    sample :bd_haus
    sleep 0.5
  end
  
  define :guitar_s do |note|
    with_fx :krush, mix: 0.9, cutoff: 125, res: 0.7, amp: 1.1 do
      with_fx :hpf, cutoff: 35 do
        with_fx :hpf, cutoff: 50, mix: 0.5 do
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
  
  define :guitar_intro do
    guitar_s("guit_intro")
    sleep 4
  end
  
  define :guitar_bridge do
    guitar_s("guit_bridge_1")
    sleep 8
  end
  
  define :guitar_bridge_2 do
    guitar_s("guit_bridge_1")
    sleep 8
    guitar_s("guit_bridge_2")
    sleep 8
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
  
  define :crashes do
    8.times do
      sample masu("crash", (1..4).to_a.choose)
      sleep 0.25
    end
  end
  
  define :crush do |duration, smpl|
    use_arg_checks false
    with_fx :pan, pan: rrand(-0.4, 0.4) do
      with_fx :bitcrusher, bits: [2, 4, 7].choose do
        sample smpl, beat_stretch: duration
      end
    end
    
  end
  
  define :random_crushes do
    duration = [0.125, 0.25].choose
    crush(duration, :ambi_piano)
    sleep duration
  end
  
  ctr = 0
  define :screech do
    use_synth :prophet
    with_fx :tanh do
      with_fx :slicer, phase: 4 do |slicerctl|
        ctr = ctr + 1
        if ctr % 4 != 0 then
          source = :C5
          target = :C6
        else
          source = :C6
          target = :C5
        end
        ctrl = play source, sustain: 4, release: 0, note_slide: 1
        control ctrl, note: target
        nt = target
        sleep 1
        24.times do
          control slicerctl, phase: [0.125/2, 0.125].choose
          nt = nt + [-1, 1].choose
          control ctrl, note: nt
          sleep 0.125
        end
      end
    end
  end
  
  define :screech_variation do |synth|
    use_synth synth
    with_fx :tanh do
      with_fx :slicer, phase: 4 do |slicerctl|
        ctr = ctr + 1
        if ctr % 4 != 0 then
          source = [:C5, :G5, :C6].choose
          target = source + 12
        else
          source = [:G5, :C6, :G6].choose
          target = source - 12
        end
        ctrl = play source, sustain: 4, release: 0, note_slide: 0.5
        control ctrl, note: target
        nt = target
        sleep 0.5
        28.times do
          control slicerctl, phase: [0.125/2, 0.125, 0.25].choose
          nt = nt + [-1, -2, -3, 1, 2, 3].choose
          control ctrl, note: nt
          sleep 0.125
        end
      end
    end
  end
  
  define :screech_variation_1 do
    screech_variation(:chiplead)
  end
  
  define :screech_variation_2 do
    screech_variation(:tb303)
  end
  
  define :bass_verse do
    cur_idx = 3
    4.times do |verse|
      sleep 1
      6.times do |ni|
        cur_idx = cur_idx - 1
        if verse != 3 || ni < 3 then
          note = scale(:C3, :harmonic_minor, octaves: 2).take(6)[cur_idx]
        else
          note = :C3
        end
        bass_note(note, 0.5)
      end
    end
  end
  
  define :bass_bridge do
    4.times do
      bass_note(:F3, 0.75)
    end
    bass_note(:F3, 0.5)
    bass_note(:Eb3, 0.5)
    4.times do
      bass_note(:C3, 0.75)
    end
    bass_note(:C3, 0.5)
    bass_note(:Eb3, 0.5)
  end
  
  define :bass_bridge_2 do
    4.times do
      bass_note(:F3, 0.75)
    end
    bass_note(:F3, 0.5)
    bass_note(:Eb3, 0.5)
    4.times do
      bass_note(:C3, 0.75)
    end
    bass_note(:C3, 0.5)
    bass_note(:D3, 0.5)
    4.times do
      bass_note(:Eb3, 0.75)
    end
    bass_note(:Eb3, 0.5)
    bass_note(:F3, 0.5)
    4.times do
      bass_note(:G3, 0.75)
    end
    bass_note(:G3, 0.5)
    bass_note(:Ab3, 0.5)
  end
  
  define :drums_bridge do
    4.times do
      sample masu("crash", [3,4,6,7].choose)
      sample :bd_haus
      sleep 0.25
      sample masu("crashtwo", [4,5,7,8].choose)
      sample :bd_haus
      sleep 0.25
      snare()
      sleep 0.25
    end
    2.times do
      sample masu("crash", [3,4,6,7].choose)
      sample :bd_haus
      sleep 0.25
      snare()
      sleep 0.25
    end
  end
  
  define :drums_bridge_2 do
    4.times do
      sample masu("crashtwo", [2,3,4].choose)
      sample :bd_haus
      sleep 0.25
      sample masu("crashtwo", [2,3,4].choose)
      sample :bd_haus
      sleep 0.25
      snare()
      sleep 0.25
    end
    2.times do
      sample masu("crashtwo", [2,3,4].choose)
      sample :bd_haus
      sleep 0.25
      snare()
      sleep 0.25
    end
  end
  
  define :crashonce do
    sample masu("crash", [1, 2, 3, 4].choose)
    sleep 16
  end
  
  define :random_hardcore_crushes do
    duration = [0.125, 0.25].choose
    sleep duration
  end
  
  define :random_hardcore_crushes do
    start = beat()
    while beat() - start < 8 do
        duration = [0.125, 0.25].choose
        crush(duration/2, :ambi_piano)
        sleep duration
      end
      while beat() - start < 16 do
          duration = [0.125/2, 0.125].choose
          crush(duration, [:ambi_glass_rub, :ambi_piano].choose)
          sleep duration
        end
      end
      
      define :the_end do
        bass_note(:C2, 0.25)
        bass_note(:C2, 0.25)
        bass_note(:Db2, 0.25)
        bass_note(:C2, 0.25)
      end
      
      define :main do
        use_bpm 60
        playall(16, [:joshi_intro_6])
        playall(28, [:joshi_intro_68, :bass_intro])
        playall(8, [:joshi_intro_last, :bass_intro_last])
        use_bpm 80
        playall(32, [:random_crushes, :snareloop, :bassloop, :bass_verse, :guitar_intro, :hihat, :screech])
        playall(16, [:crashonce, :drums_bridge_2, :bass_bridge, :guitar_bridge, :joshi_bridge_half])
        playall(16, [:drums_bridge, :bass_bridge_2, :guitar_bridge_2, :joshi_bridge_full])
        playall(16, [:crashonce, :random_crushes, :snareloop, :bassloop, :bass_verse, :guitar_intro, :hihat, :screech])
        playall(16, [:random_hardcore_crushes, :drums_bridge, :bass_bridge_2, :guitar_bridge_2, :joshi_bridge_full_reverse])
        playall(4, [:joshi_bridge_full_reverse])
        playall(16, [:snareloop, :bassloop, :bass_verse, :guitar_intro, :hihat, :joshi_bridge_half, :screech_variation_1])
        playall(16, [:snareloop, :bassloop, :bass_verse, :guitar_intro, :crashes, :joshi_bridge_half, :screech_variation_1, :screech_variation_2])
        playall(1, [:the_end])
      end
      main()
      