# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  s.delete 0 if s[0] == 10
  frames << s
end

# 10フレーム目の処理
case frames.length
when 11
  frames[9].concat frames[10]
  frames.delete_at 10
when 12
  frames[9].concat frames[10]
  frames[9].concat frames[11]
  2.times { frames.delete_at 10 }
end

point = 0
next_frame_num = 0
frames.each do |frame|
  next_frame_num += 1
  point += if frame[0] == 10 && next_frame_num != 10
             10 + frames[next_frame_num].sum
           elsif frame.sum == 10
             10 + frames[next_frame_num][0]
           else
             frame.sum
           end
end
puts point
