use_bpm 80
samples_base = "C:/Program Files (x86)/Sonic Pi/etc/samples/"
use_debug false

define :octaving do |note, octs, detune|
  (1..octs).each do |oct|
    play note - 12 * oct, amp: 1.0, detune: detune / oct
    play note + 12 * oct, amp: 1.0 / (oct * oct), detune: detune / oct
  end
  play note
end
define :masu do |name, i|
  return samples_base + "masu/mdk_" + name + (sprintf '%02d', i) + ".flac"
end
define :crash do
  sample masu("crash", [3, 4, 6, 7, 8].choose), rpitch: rrand(-0.2, 0.2)
end
define :snare do
  with_fx :reverb do
    sample masu("snare", 4), amp: 9.0, rpitch: rrand(-0.2, 0.2)
  end
end
define :bdru do
  sample :bd_haus
end
define :hat do
  sample masu("hatclosed", [1, 2].choose), rpitch: rrand(-0.1, 0.1), amp: 2.5
end
define :boomchak do
  bdru
  sleep 0.5
  snare
  sleep 0.5
end
define :sixteenths do
  16.times do
    hat
    sleep 0.125
  end
end
define :one_note_base do |note, octs|
  with_synth :dsaw do
    with_fx :reverb do
      with_fx :level, amp: 0.15 do
        with_fx :pan, pan: -0.7 do
          octaving(note, octs, 0.11)
        end
        with_fx :pan, pan: 0.7 do
          octaving(note, octs, 0.09)
        end
      end
    end
    
    with_fx :distortion, distort: 0.8, amp: 0.8 do
      with_fx :pan, pan: -0.8 do
        octaving(note - 12, 1, 0.07)
      end
      with_fx :pan, pan: 0.8 do
        octaving(note - 12, 1, 0.05)
      end
    end
  end
end
define :one_note do |note|
  one_note_base(note, 3)
end
define :one_note_prf_no_rev do |note|
  with_synth :dsaw do
    with_fx :level, amp: 0.15 do
      with_fx :pan, pan: -0.7 do
        play note, detune: 0.11
      end
      with_fx :pan, pan: 0.7 do
        play note, detune: 0.09
      end
    end
    
    with_fx :distortion, distort: 0.8, amp: 0.6 do
      with_fx :pan, pan: -0.8 do
        octaving(note - 12, 1, 0.07)
      end
      with_fx :pan, pan: 0.8 do
        octaving(note - 12, 1, 0.05)
      end
    end
  end
end

notes = ring 3, 0, 5, 7, 3, 0, 8, 7, 3, 0, 5, 7, 3, 2, 0, 0
sleeps = ring 0.75, 0.75, 0.25, 2.25,
  0.75, 0.75, 0.25, 2.25,
  0.75, 0.75, 0.25, 2.25,
  0.75, 0.75, 0.5, 2
define :saws do
  dur = sleeps.tick(:sl)
  note = notes.tick(:nt)
  with_synth_defaults sustain: dur, attack: 0.01, release: 0 do
    one_note(:D3 + note)
  end
  sleep dur
end

lead_notes = ring 0, 3, 7, 0, 8, 0, 7, 0, 5, 0, 7, 0, 5, 3, 2, 3,
  0, 3, 7, 0, 8, 0, 7, 0, 3, 5, 7, 8, 3, 2, 0, 0
define :organ do
  use_synth :chiplead
  play :D5 + lead_notes.tick(:ln), sustain: rrand(0, 0.5)
  sleep 0.5
end

trinotes = ring 0, 5, 8, 7, 8, 7, 3, 5, 0, 5, 8, 7, 3, 2, 0, 0
define :triloop do
  use_synth :tb303
  dur = sleeps.tick(:tris)
  play :D4 + trinotes.tick(:trin), attack: 0.01, amp: 0.7, release: 0, sustain: dur
  sleep dur
end

define :introcrash do
  crash
  bdru
  sleep sleeps.tick(:icrsh)
end
define :quartercrashes do
  crash
  sleep 2
end

define :bass_note do |note|
  use_synth :prophet
  play note + rrand(-0.05, 0.05), res: 0.9, release: 0.2
  play note + rrand(-0.05, 0.05), res: 0.9, release: 0.2
  use_synth :pluck
  play note - 12, amp: 0.8, release: 0.3, coef: 0.3
  play note, amp: 0.4, release: 0.3, coef: 0.3
  play note + 12, amp: 0.6, release: 0.3, coef: 0.3
  sleep 0.125
end

bassdurs = ring 32, 16, 8, 8,
  32, 16, 8, 4, 4,
  32, 16, 8, 8,
  32, 4, 4, 4, 4, 4, 4, 4,
  4, 4, 4, 4, 4, 32
bassnotes = ring :D3, :C3, :Bb2, :A2,
  :G2, :F2, :E2, :D2, :F2,
  :A2, :D3, :F2, :G2,
  :A2, :Bb2, :A2, :G2, :Bb2, :A2, :G2, :F2,
  :A2, :G2, :F2, :E2, :F2, :A2
bassnotes_end = ring :D3, :C3, :Bb2, :A2,
  :G2, :F2, :E2, :D2, :F2,
  :A2, :D3, :F2, :G2,
  :A2, :Bb2, :A2, :G2, :Bb2, :A2, :G2, :F2,
  :A2, :G2, :F2, :E2, :F2, :D2
define :bassline_base do |bassnotes|
  with_fx :ixi_techno, mix: 0.3, cutoff_min: 40, cutoff_max: 110 do
    27.times do
      times = bassdurs.tick(:bdd)
      note = bassnotes.tick(:bdn)
      times.times do
        bass_note(note)
      end
    end
  end
end
define :bassline do
  bassline_base(bassnotes)
end
define :bassline_end do
  bassline_base(bassnotes_end)
end

define :oversaw do
  duration = 0.125 * bassdurs.tick(:oversaw_d)
  note = bassnotes.tick(:oversaw) + 36
  use_synth :blade
  if duration > 1.0 then
    sus = 0.35 * duration - 0.1
  else
    sus = 0.25
  end
  with_synth_defaults attack: 0.1, release: duration, sustain: sus, vibrato_depth: 0.2, vibrato_delay: 0 do
    with_fx :level, amp: 1.5 do
      play note
      play note - 12
    end
  end
  with_synth_defaults attack: 0, release: 0, sustain: duration do
    with_fx :lpf, mix: 0.3, amp: 0.5 do
      one_note_prf_no_rev(note - 24)
    end
  end
  sleep duration
end

define :sps_base do |nts|
  duration = 0.125 * bassdurs.tick(:supportsaw_d)
  note = bassnotes.tick(:supportsaw)
  with_synth_defaults attack: 0, release: 0, sustain: duration do
    with_fx :level, amp: 0.8 do
      one_note_prf_no_rev(note)
    end
  end
  sleep duration
end
define :supportsaw do sps_base(bassnotes) end
define :supportsaw_end do sps_base(bassnotes_end) end

bridgenotes = ring 5, 7, 8, 5, 7, 8, 10, 12
define :bridge do
  with_synth_defaults release: 0, sustain: 0.25 do
    8.times do
      note = :D3 + bridgenotes.tick()
      one_note_prf_no_rev(note)
      sleep 0.25
    end
  end
end

define :bridge_full do
  with_fx :level, amp: 0.7 do
    bridge
    with_transpose 3 do
      bridge
    end
    with_transpose 4 do
      bridge
    end
    with_transpose 5 do
      bridge
    end
  end
end

longbassnotes = ring 5, 8, 9, 10
define :longbass do
  use_synth :prophet
  with_synth_defaults attack: 0.1, sustain: 2, release: 0 do
    4.times do
      play :D2 + longbassnotes.tick
      sleep 2
    end
  end
end

define :lb_rf_note do |note, sus, rel|
  play note
  with_synth_defaults sustain: sus, release: rel do
    one_note_prf_no_rev(note + 12)
  end
end
define :longbass_riff do
  use_synth :prophet
  use_synth_defaults sustain: 0.5, release: 0.25, amp: 1
  4.times do
    lb_rf_note(:D2, 0.125, 0.125)
    sleep 0.25
    lb_rf_note(:D2, 0.125, 0.125)
    sleep 0.5
  end
  lb_rf_note(:D2 - 2, 0.5, 0)
  sleep 0.5
  lb_rf_note(:D2 - 1, 0.5, 0)
  sleep 0.5
  4.times do
    lb_rf_note(:D2, 0.125, 0.125)
    sleep 0.25
    lb_rf_note(:D2, 0.125, 0.125)
    sleep 0.5
  end
  lb_rf_note(:D2 + 2, 0.5, 0)
  sleep 0.5
  lb_rf_note(:D2 + 3, 0.5, 0)
  sleep 0.5
end

def longbass_d
  use_synth_defaults res: 0.9, sustain: 8, release: 8
  one_note(:D3)
  sleep 16
end

def tom_hi
  sample :drum_tom_hi_hard, rpitch: 5 + rrand(-0.3, 0.3), amp: 2
end
def tom_mid
  sample :drum_tom_mid_hard, rpitch: 5 + rrand(-0.3, 0.3), amp: 2
end
def tom_lo
  sample :drum_tom_lo_hard, rpitch: 5 + rrand(-0.3, 0.3), amp: 2
end
def tom_sublo
  sample :drum_tom_lo_hard, rpitch: rrand(-0.3, 0.3), amp: 2
end

def tomroll_1
  tom_hi
  sleep 1.0 / 3.0 + 0.000001
  tom_mid
  sleep 1.0 / 3.0 + 0.000001
  tom_lo
  sleep 1.0 / 3.0 + 0.000001
  tom_sublo
end

def tomroll_3
  2.times do
    2.times do
      tom_hi
      sleep 0.125
    end
    2.times do
      tom_mid
      sleep 0.125
    end
  end
  tom_lo
end

def tomroll_4
  tr4 = [:tom_lo, :tom_mid, :tom_hi, :tom_hi, :tom_mid, :tom_hi]
  tr4s = [1, 2, 1, 2, 2, 0]
  6.times do |i|
    send(tr4[i])
    sleep tr4s[i] * 0.125
  end
end

def tomroll_2
  2.times do
    tom_hi
    sleep 0.125
    tom_mid
    sleep 0.25
    tom_mid
    sleep 0.25
    tom_lo
    sleep 0.25
    tom_sublo
  end
  sleep 0.125
  tom_hi
  sleep 0.125
  cmpr = [:tom_hi, :tom_mid, :tom_hi, :tom_hi, :tom_hi, :tom_mid, :tom_hi, :tom_mid]
  8.times do |i|
    send(cmpr[i])
    sleep 0.25
  end
  tom_hi
end

def tomroll_5(lastlow)
  2.times do
    2.times do
      tom_hi
      sleep 0.125
    end
    2.times do
      tom_mid
      sleep 0.125
    end
  end
  2.times do
    2.times do
      tom_lo
      sleep 0.125
    end
    2.times do
      tom_sublo
      sleep 0.125
    end
  end
  2.times do
    2.times do
      tom_lo
      sleep 0.125
      tom_mid
      sleep 0.25
      tom_mid
      sleep 0.125
      tom_hi
      sleep 0.25
      tom_hi
    end
  end
  2.times do
    2.times do
      tom_mid
      sleep 0.125
    end
    2.times do
      tom_hi
      sleep 0.125
    end
  end
  if lastlow then tom_lo else tom_hi end
end

def random_tomrolls
  with_fx :reverb, room: 1 do
    sleep 3
    tomroll_1
    sleep 3
    tomroll_4
    crash
    sleep 3
    tomroll_3
    sleep 4
  end
  with_fx :reverb, room: 0.7 do
    tomroll_2
    crash
    sleep 3
  end
  with_fx :reverb, room: 1 do
    tomroll_1
    sleep 4
  end
  with_fx :reverb, room: 0.7 do
    tomroll_5(false)
    crash
    sleep 8
  end
end
define :random_tomroll_once do
  8.times do
    send([:tom_lo, :tom_mid, :tom_hi].choose)
    sleep 0.125
  end
  tom_lo
end

define :randtoms_2 do
  with_fx :reverb, room: 0.7 do
    sleep 3
    tomroll_1
    sleep 3
    random_tomroll_once
    crash
    sleep 3
    random_tomroll_once
    sleep 4
    tomroll_2
    crash
    sleep 3
    random_tomroll_once
    sleep 4
    tomroll_5(true)
    crash
    sleep 8
  end
end

define :guitar_d do |note|
  with_fx :krush, mix: 0.8, cutoff: 130, res: 0.3, amp: 1.2 do
    with_fx :hpf, cutoff: 50 do
      with_fx :pan, pan: -0.4 do
        sample samples_base + "/guitar/" + note + "_1.flac", amp: 5
      end
      with_fx :pan, pan: 0.4 do
        sample samples_base + "/guitar/" + note + "_2.flac", amp: 5
      end
    end
  end
end

def riff
  guitar_d("riff")
  sleep 8
end

def long_d
  guitar_d("long_d")
  sleep 16
end

def riffcrash
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
  2.times do
    crash
    bdru
    sleep 0.25
    snare
    sleep 0.25
  end
  crash
end

define :valuefn do |cur_nt, is_ascending, nt|
  cur_as_float = note(cur_nt)
  note_as_float = note(nt)
  absdist = (nt - cur_as_float).abs
  epsilon = 0.00001
  if (absdist < 0.01) or (is_ascending != (note_as_float > cur_as_float)) then
    return epsilon
  else
    return 1.0/absdist
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

current_notes = [:A3, :A5]
is_ascending = [true, false]
define :pick_note do |map|
  map.sort
  search_value = rand(1)
  sum = 0
  map.each do |key, val|
    sum += val
    if (sum > search_value) then return key end
  end
end

the_scale = scale(:D2, :harmonic_minor, num_octaves: 2)
the_notes = scale(:D2, :harmonic_minor, num_octaves: 3).map{|x| note(x)}
define :gen_next_note do |index|
  cur_scale = the_scale
  note_to_value = Hash.new
  cur_scale.each do |x|
    note_to_value[x] = valuefn(current_notes[index], is_ascending[index], x)
  end
  note_to_value = normalize(note_to_value)
  current_notes[index] = pick_note(note_to_value)
  if (rrand(0, 1) < 0.2) then
    is_ascending[index] = !is_ascending[index]
  end
  return current_notes[index]
end

cur_chord = []
next_chord = []
define :generate_chord do
  base = gen_next_note(0)
  if the_notes.include?(base + 3) then
    second = base + 3
  else
    second = base + 4
  end
  if the_notes.include?(second + 3) then
    third = second + 3
  else
    third = second + 4
  end
  cur_chord = next_chord
  next_chord = [base, second, third]
end

def td1(nt, ps)
    play nt, vel: rrand(0.05, 0.1), release: 4
    sleep ps
end
define :triad do
  use_synth :piano
  with_fx :level, amp: 7 do
    ps = 1.0/3.0 + 0.0000001
    td1(cur_chord[0], ps)
    td1(cur_chord[1], ps)
    td1(cur_chord[2], ps)
  end
end

define :master do
  generate_chord
  triad
end

define :otherm do
  use_synth :dark_ambience
  if (rrand(0, 1) < 0.2) then
    3.times do
      note = cur_chord.choose
      play note + [24, 36].choose, amp: 5
      sleep 1.0 / 3.0 + 0.00000001
    end
  elsif rrand(0, 1) < 0.25 then
    note = cur_chord.choose
    play note + [24, 36].choose, amp: 5
    sleep 2.0/3.0 + 0.00001
    play note + [24, 36].choose, amp: 5
    sleep 1.0/3.0 + 0.00001
  else
    note = cur_chord.choose
    play note + [24, 36].choose, amp: 5
    sleep 1
  end
end

define :otherm_prophet do
  use_synth :prophet
  use_synth_defaults sustain: 1, release: 0.1, amp: 0.6
  note = cur_chord.choose
  play note
  play note - 12
  sleep 1
end

define :prophet_chord do
  use_synth :prophet
  use_synth_defaults sustain: 8, release: 0.1, amp: 0.6
  play :D3
  play :A3
  play :D4
  play :F4
  one_note(:D3)
  sleep 8
  play :A2
  play :E3
  play :A4
  play :Db4
  play :G4
  one_note(:A3)
  sleep 8
  with_synth_defaults sustain: 6, release: 0.1, amp: 0.6 do
    play :G2
    play :E3
    play :C4
    play :E4
    play :G4
    one_note(:C4)
  end
  sleep 4
  play :B4, sustain: 1
  play :B5, sustain: 1
  sleep 1
  play :A4, sustain: 1
  play :A5, sustain: 1
  sleep 1
  play :B2
  play :Eb3
  play :B4
  play :Eb4
  play :Gb4
  one_note(:B3)
  sleep 8
  with_synth_defaults sustain: 6.5, release: 0.1, amp: 0.6 do
    play :A2
    play :E3
    play :A4
    play :C4
    one_note(:A3)
  end
  sleep 7
  with_synth_defaults sustain: 1, release: 0.1, amp: 0.6 do
    play :G2
    play :B3
    play :G4
    play :D4
    one_note(:G3)
    sleep 1
  end
  play :G2
  play :B3
  play :G4
  play :E4
  one_note(:E3)
  sleep 8
  play :Gb2
  play :Bb3
  play :Gb4
  play :E4
  one_note(:E3)
  sleep 8
  with_synth_defaults sustain: 4, release: 0.1, amp: 0.6 do
    play :D4
    play :B2
    play :B4
    one_note(:Gb3)
    sleep 4
    play :Bb2
    play :Gb4
    one_note(:Bb3)
    sleep 4
  end
  sleep 8
end

define :reverse_crash do
  sleep 11.5
  sample masu("crash_crescendo", 1), amp: 2
  sleep 8
end
define :doublebass do
  bdru
  sleep 0.125
end
define :halfsnare do
  sleep 0.5
  snare
  sleep 0.5
end
define :halfcrash do
  crash
  sleep 0.5
end

define :random_toms do
  with_fx :reverb, room: 0.7 do
    (16 * 4).times do
      d = [1, 2].choose
      d.times do
	send([:tom_lo, :tom_hi, :tom_mid].choose)
	sleep 0.25 / d
      end
    end
  end
end

define :fadein_16 do |lam|
  start_beat = beat()
  end_beat = start_beat + 16
  with_fx :level, amp: 0, amp_slide: 8 do |ctrl|
    control ctrl, amp: 1
    while beat() < end_beat do
      lam.call()
    end
  end
end

define :otherm_fadein do
  fadein_16(lambda {otherm()})
end

define :otherm_prophet_fadein do
  fadein_16(lambda {otherm_prophet()})
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

define :guitar_scrab do
  27.times do |i|
    j = (i == 13 or i == 26) ? 10 : i+1
    guitar_d("scrab_"+j.to_s)
    sleep bassdurs.tick(:sc)*0.125
  end
end

define :guitar_scrab_end do
  27.times do |i|
    j = i == 13 ? 10 : i+1
    guitar_d("scrab_"+j.to_s)
    sleep bassdurs.tick(:sc)*0.125
  end
end

define :revcr do
  sleep 46
  reverse_crash
end

define :main do
  playall(16, [:organ])
  playall(16, [:organ, :saws, :introcrash])
  playall(16, [:organ, :triloop, :saws, :introcrash, :reverse_crash])
  playall(38, [:bassline, :oversaw, :boomchak, :sixteenths, :random_tomrolls])
  playall(16, [:longbass, :bridge_full, :boomchak, :quartercrashes, :random_toms])
  playall(8, [:longbass_riff, :riff, :riffcrash])
  playall(8, [:longbass_riff, :riff, :riffcrash, :sixteenths])
  playall(8, [:long_d, :longbass_d])
  playall(24, [:master])
  playall(16, [:master, :otherm_fadein])
  playall(16, [:master, :otherm, :otherm])
  playall(16, [:master, :otherm, :otherm, :otherm_prophet_fadein])
  playall(16, [:master, :otherm, :otherm, :otherm_prophet, :otherm_prophet])
  playall(62, [:prophet_chord, :revcr])
with_transpose 1 do
  playall(38, [:bassline, :supportsaw, :guitar_scrab, :boomchak, :sixteenths, :random_tomrolls])
  playall(38, [:bassline_end, :supportsaw_end, :guitar_scrab_end, :doublebass, :halfsnare, :sixteenths, :halfcrash, :randtoms_2])
end
end
main