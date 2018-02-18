use_bpm 80
use_debug false
set_sched_ahead_time! 1

lead = :prophet

define :joshi do
  16.times do
    note = choose(scale(:e3, :hirajoshi, num_octaves: 3))
    with_fx :distortion do
      use_synth :dark_ambience
      play note
    end
    use_synth :tb303
    play note, amp: 0.1
    sleep 0.25
  end
end

define :distorted do
  degrees = [:i, :iv, :v]
  use_synth :supersaw
  with_fx :slicer do |slicer|
    with_fx :panslicer, pan_min: -0.25, pan_max: 0.25 do
      play_chord (chord_degree degrees[tick % degrees.length], :e2, :hirajoshi), sustain: 4, release: 0.25
      16.times do
        control slicer, phase: choose([0.25, 0.125])
        sleep 0.25
      end
    end
  end
end

define :playbetween do
  with_fx :tanh, amp: 0.5, mix: 0.7 do
    use_synth lead
    release = 0.01
    play :e2, sustain: 3-release, release: release
    sleep 3
    s = synth lead, note: :e2, sustain: 1-release, release: release
    sleep 0.5
    control s, note: :gb2
    sleep 0.5
    play_pattern_timed [:g2, :b2, :gb2, :a2], [1], sustain: 1-release, release: release
  end
end

define :beats do
  2.times do
    with_fx :reverb, mix: 0.2 do
      sample :bd_fat
      sleep 0.5
      sample :elec_hi_snare, rpitch: rrand(0, 5)
      sleep 0.75
      sample :bd_fat
      sleep 0.25
      with_fx :wobble, mix: rrand(0, 0.25) do
        sample :elec_hi_snare, rpitch: rrand(0, 5)
      end
      sleep 0.5
    end
  end
end

define :intro do
  4.times do
    joshi
  end
  4.times do
    in_thread do beats end
    in_thread do distorted end
    joshi
  end
end

define :fullorch do
  in_thread do
    2.times do joshi end
  end
  in_thread do
    2.times do beats end
  end
  in_thread do
    2.times do distorted end
  end
  playbetween
end

define :main do
  intro
  2.times do
    playbetween
  end
  4.times do
    fullorch
  end
  with_transpose 3 do
    2.times do
      fullorch
    end
  end
  with_transpose 7 do
    2.times do
      fullorch
    end
  end
  with_fx :krush, mix: 0.2 do
    fullorch
  end
  with_fx :krush, mix: 0.4 do
    fullorch
  end
  with_transpose 7 do
    with_fx :krush, mix: 0.5 do
      fullorch
    end
    with_fx :krush, mix: 0.7 do
      fullorch
    end
  end
  with_fx :krush, mix: 1 do
    2.times do
      fullorch
    end
    use_synth lead
    with_fx :krush, mix: 1 do
      with_fx :slicer do |slicer|
        play :e3, sustain: 2, release: 0
        24.times do
          control slicer, phase: rrand(0, 0.25)
          sleep 0.25
        end
      end
    end
  end
end

main