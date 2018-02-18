use_bpm 71

samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
define :crispysn do |i|
  return samples_base + "freesnd/" + (118283 + i).to_s + "__crispydinner__lr-sn-" + (sprintf '%04d', i) + ".flac"
end
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end

define :snare do
  sample crispysn(14), amp: 0.9
  sample masu("snare", 5), amp: 1.6
end
define :crash do
  sample masu("crash", [3, 4, 6, 7, 8].choose), rpitch: rrand(-0.2, 0.2), amp: 0.3
end

define :crash_2 do
  sample masu("crashtwo", (3..4).to_a.choose), rpitch: rrand(-0.2, 0.2), amp: 0.6
end

define :ride do
  sample masu("hatsmack", (4..6).to_a.choose), rpitch: rrand(-0.2, 0.2), amp: 0.9
end

define :hat do
  sample masu("hatclosed", (1..8).to_a.choose), rpitch: rrand(-0.1, 0.1), amp: 1.5
end

define :bdru do
  sample :bd_haus, amp: 0.7
end

define :guitar_s do |note|
  with_fx :krush, mix: 0.8, cutoff: 125, res: 0.6, amp: 0.8 do
    with_fx :hpf, cutoff: 35 do
      with_fx :pan, pan: -0.2 do
        sample samples_base + "/guitar/" + note + "_1.flac", amp: 5
      end
      with_fx :pan, pan: 0.2 do
        sample samples_base + "/guitar/" + note + "_2.flac", amp: 5
      end
    end
  end
end

define :guitar_verse do
  guitar_s("fgs_1")
  sleep 1
  guitar_s("fgs_2")
  sleep 1
  guitar_s("fgs_3")
  sleep 2
  guitar_s("fgs_1")
  sleep 1
  guitar_s("fgs_2")
  sleep 1
  guitar_s("fgs_4")
  sleep 2
end

chords = (ring chord(:E2, :minor),
          chord(:C2, :major, invert: 2),
          chord(:B2, :major),
          chord(:B2, :major),
          chord(:C2, :major, invert: 2),
          chord(:C2, :major, invert: 2),
          chord(:Fs2, :diminished7),
          chord(:Fs2, :diminished7))
synnotes = (ring :E, :C, :B, :B, :G, :C, :Fs, :Fs)

lastnote = :C1
define :bassline do
  use_synth :pulse
  ch = chords.tick()
  8.times do
    note = ch.choose
    while note == lastnote do
        note = ch.choose
      end
      lastnote = note
      with_synth_defaults release: 0.15 do
        if rrand(0, 1) < 0.95 then
          play note
          play note - 12
          play note - 24
        end
      end
      sleep 0.125
    end
  end
  
  define :simple_bassline do
    use_synth :subpulse
    n = note(synnotes.tick(:SB), octave: 1)
    with_synth_defaults release: 0.5, amp: 1.3 do
      4.times do
        play n
        sleep 0.25
      end
    end
  end
  
  define :bass_ending do
    use_synth :subpulse
    n = :E2
    with_synth_defaults sustain: 2, release: 0, amp: 1.3 do
      play n
      sleep 32
    end
  end
  
  define :othersynths do
    notes = (ring :G, :E, :B, :B, :E, :C, :Fs, :A)
    use_synth :supersaw
    use_synth_defaults sustain: 1, release: 0, amp: 0.5
    with_fx :slicer do |sctl|
      n = notes.tick()
      with_fx :distortion do
        play note(n, octave: 3)
      end
      4.times do
        control sctl, phase: [0.25, 0.125, 0.125, 0.125*0.5].choose
        sleep 0.25
      end
    end
  end
  
  define :synth_ending do
    use_synth :dsaw
    with_fx :distortion do
      play :E3, sustain: 2, release: 0, amp: 0.5, cutoff: 115, detune: 0.07
    end
    sleep 32
  end
  
  ticker = 0
  define :synths do
    use_synth :saw
    use_synth_defaults amp: 0.5, sustain: 1, release: 0.1, note_slide: 0.05
    synnotes.each do |n|
      ticker = ticker + 1
      ctrl = play note(n, octave: 4)
      sleep 0.225
      control ctrl, note: note(n, octave: 5)
      sleep 0.25
      if ticker % 8 == 0 then
        control ctrl, note: note(n+1, octave: 5)
      else
        control ctrl, note: note(n, octave: 4)
      end
      sleep 0.25
      control ctrl, note: note(n, octave: 5)
      sleep 0.275
    end
  end
  
  define :drums do
    bdru
    sleep 0.25
    snare
    sleep 0.25
  end
  define :dbeat do
    bdru
    sleep 0.5
    snare
    sleep 0.25
    bdru
    sleep 0.5
    bdru
    sleep 0.25
    snare
    sleep 0.5
  end
  define :dbeatx2 do
    4.times do
      bdru
      sleep 0.25
      snare
      sleep 0.125
      bdru
      sleep 0.25
      bdru
      sleep 0.125
      snare
      sleep 0.25
    end
  end
  
  define :dbassdrums do
    bdru
    sleep 0.125
    bdru
    sleep 0.125
    snare
    bdru
    sleep 0.125
    bdru
    sleep 0.125
  end
  
  define :hihats do
    if rrand(0, 1) < 0.95 then hat end
    sleep 0.125
  end
  define :crashes do
    crash
    sleep 0.25
  end
  define :hcrashes do
    crash
    sleep 0.5
  end
  define :bassonly do
    bdru
    sleep 0.5
  end
  define :drumsfill do
    sleep 15
    2.times do
      snare
      sleep 0.25
      bdru
      sleep 0.25
    end
    crash
  end
  define :crashonce do
    crash
    sleep 32
  end
  
  
  melnotes = ring :E, :Fs, :G, :A, :B, :A, :Fs, :B, :A, :Fs,
    :E, :Fs, :G, :B, :A, :B, :A, :Fs, :D, :E
  
  melpauses = ring 1, 0.75, 0.25, 0.25, 1.75, 1, 0.75, 0.25, 0.25, 1.75,
    1, 0.75, 0.25, 0.25, 1.75, 0.5, 0.5, 0.5, 0.5, 2
  
  define :melody do
    use_synth :prophet
    duration = melpauses.tick(:mp)
    play note(melnotes.tick(:mn), octave: 4), sustain: 0.1
    sleep duration
  end
  
  mel2notes = ring :E, :Fs, :G, :A, :B, :A, :Fs, :A, :B, :C
  define :melody2 do
    n = note(mel2notes.tick(:m2n), octave: 5)
    with_synth :fm do
      play n, divisor: 1, amp: 0.7
    end
    sleep 0.5
  end
  
  melchords = ring chord(:E3, :minor, num_octaves: 2), # 5
    chord(:B3, :major, num_octaves: 2),                # 0
    chord(:A3, :minor, num_octaves: 2),                # 10
    chord(:Fs3, :diminished, num_octaves: 2),          # 7
    chord(:E3, :minor, num_octaves: 2),                # 5
    chord(:B3, :major, num_octaves: 2),                # 0
    chord(:D3, :major, num_octaves: 2),                # 3
    chord(:E3, :minor, num_octaves: 2)                 # 5
  
  define :play_melchords do
    use_synth :sine
    cur_chord = melchords.tick()
    with_fx :reverb do
      with_fx :tanh, krunch: 1 do
        16.times do
          play cur_chord.choose() + 12
          sleep 0.125
        end
      end
    end
  end
  
  define :guitar_bridge do
    guitar_s("fgsf_5")
    sleep 2
    guitar_s("fgsf_0")
    sleep 2
    guitar_s("fgsf_10")
    sleep 2
    guitar_s("fgsf_7")
    sleep 2
    guitar_s("fgsf_5")
    sleep 2
    guitar_s("fgsf_0")
    sleep 2
    guitar_s("fgsf_3")
    sleep 2
    guitar_s("fgsf_5")
    sleep 2
  end
  
  define :guitar_ending do
    guitar_s("ending")
    sleep 32
  end
  
  define :sweeper do
    use_synth :pulse
    use_synth_defaults attack: 0.1, note_slide: 0.1, sustain: 17.9, release: 0, amp: 0.5
    ctrl = play chords[0].choose() + 36
    sleep 0.2
    16.times do |i|
      cur_chord = chords.tick(:sweeper)
      (i == 0 ? 3 : 4).times do
        control ctrl, note: cur_chord.choose() + 36
        sleep 0.25
      end
    end
    control ctrl, note: :E3 + 36
    sleep 2.05
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
      with_transpose 3 do
        playall(16, [:bassline, :hihats])
        playall(16, [:bassline, :hihats, :bassonly, :drumsfill])
        playall(16, [:simple_bassline, :crashes, :dbeatx2, :synths, :guitar_verse])
        playall(8, [:simple_bassline, :crashes, :dbeatx2, :synths, :othersynths, :guitar_verse])
        playall(8, [:simple_bassline, :crashes, :dbassdrums, :synths, :othersynths, :guitar_verse])
        playall(8, [:dbeat, :play_melchords])
        playall(8, [:dbeat, :hcrashes, :play_melchords])
        playall(16, [:dbeat, :hcrashes, :melody, :play_melchords, :guitar_bridge])
        playall(16, [:dbeat, :hcrashes, :melody, :melody2, :play_melchords, :guitar_bridge])
        playall(16, [:simple_bassline, :crashes, :dbeatx2, :synths, :othersynths, :guitar_verse])
        playall(16, [:simple_bassline, :crashes, :dbassdrums, :synths, :othersynths, :guitar_verse, :sweeper])
        playall(16, [:bass_ending, :guitar_ending, :synth_ending, :crashonce])
      end
    end
    
    live_loop :mm do main end
    #live_loop :metro do
    #  sample :bd_haus, amp: 0.1
    #  sleep 0.5
    # with_fx :level, amp: 0.1 do
    #  dbeat
    #end
    #end
    
    