define :playall do |duration, functions|
  start_beat = beat()
  end_beat = start_beat + duration
  functions.each do |fn|
    in_thread do send(fn)
      while beat() < end_beat do send(fn) end
      end
    end
    sleep duration
  end
  
  define :euda do
    vars=[:tabla_ke1, :tabla_ke2, :tabla_ke3, :tabla_dhec, :tabla_na_s, :tabla_re]
    sample vars.choose
    sleep [0.125, 0.25, 0.5, 1].choose
  end
  
  define :test do |notes|
    use_synth :chiplead
    duration = 0.5/3.0 + 0.0000001
    with_synth_defaults release: 0, sustain: duration do
      play_pattern_timed(notes, duration)
    end
  end
  
  volume = 1
  define :testfade do
    use_synth :chiplead
    duration = 0.5/3.0 + 0.0000001
    thering = (ring :e3, :g3, :b3)
    with_synth_defaults release: 0, sustain: duration do
      4.times do
        play thering.tick, amp: volume
        sleep duration
        volume *= 0.9
      end
    end
  end
  
  
  define :bass do |note, duration|
    with_synth :saw do
      play note, sustain: duration, attack: 0, release: 0
      sleep duration
    end
  end
  
  define :test1 do
    test [:e3, :g3, :b3]
  end
  define :bass1 do
    bass :e1, 4
  end
  
  define :triloop do
    times = 2
    with_synth :saw do
      s = play :e5, attack: 0.5, sustain: times*16, release: 4, note_slide: 0.1
      times.times do
        sleep 4
        control s, note: :d5
        sleep 2
        control s, note: :db5
        sleep 2
        control s, note: :b4
        sleep 4
        control s, note: :d5
        sleep 2
        control s, note: :db5
        sleep 2
        control s, note: :e5
      end
    end
  end
  
  define :test2 do
    test [:e3+7, :g3+7, :b3+7]
  end
  define :bass2 do
    bass :b1, 2
  end
  
  define :test3 do
    test [:e3+5, :g3+6, :b3+5]
  end
  define :bass3 do
    bass :a1, 2
  end
  
  define :main do
      playall(4, [:euda, :euda, :euda, :euda, :euda])
      2.times do
        playall(4, [:euda, :euda, :euda, :euda, :euda, :bass1])
        playall(2, [:euda, :euda, :euda, :euda, :euda, :bass2])
        playall(2, [:euda, :euda, :euda, :euda, :euda, :bass3])
      end
      2.times do
        playall(4, [:euda, :euda, :euda, :euda, :euda, :test1, :bass1])
        playall(2, [:euda, :euda, :euda, :euda, :euda, :test2, :bass2])
        playall(2, [:euda, :euda, :euda, :euda, :euda, :test3, :bass3])
      end
      in_thread do triloop end
      4.times do
        playall(4, [:euda, :euda, :euda, :euda, :euda, :test1, :bass1])
        playall(2, [:euda, :euda, :euda, :euda, :euda, :test2, :bass2])
        playall(2, [:euda, :euda, :euda, :euda, :euda, :test3, :bass3])
      end
    playall(4, [:euda, :euda, :euda, :euda, :euda, :testfade, :bass1])
    playall(2, [:euda, :euda, :euda, :euda, :euda, :bass2])
    playall(2, [:euda, :euda, :euda, :euda, :euda, :bass3])
    playall(4, [:euda, :euda, :euda, :euda, :euda, :bass1])
    playall(2, [:euda, :euda, :euda, :euda, :euda, :bass2])
    playall(2, [:euda, :euda, :euda, :euda, :euda, :bass3])
    playall(8, [:euda, :euda, :euda, :euda, :euda, :bass1])
  end
  
  main