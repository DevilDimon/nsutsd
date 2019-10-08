base_path = "#{Dir.home}/Library/Logs/DiagnosticReports"

Dir.glob('*.crash', base: base_path).each do |filename|
  file = File.read("#{base_path}/#{filename}")
  rx = /^
       (\d+)\s+(\w|\.)+\s+0x\w+\s+ # Call position in dump - call address
       ( # Possible language groups
        ([a-zA-Z_](\w|\.)+) # C
        |
        ([-+]\[(\w|\(|\))+\ (\w|:)+\]) # Objective-C
        |
        (\w+::(\w|[<>,()*& :'$.])+) # C++
       )
       \s\+\s\d+ # Offset in a call
       $/mx


  match_count = 0
  mean_count_accum = 0

  max_depth = 0
  min_depth = 0

  c_count = 0
  objc_count = 0
  cpp_count = 0

  file.scan(rx) do |call_depth_s, _, _, c_func, _, objc_func, _, _, cpp_func|
    call_depth = call_depth_s.to_i
    match_count += 1
    mean_count_accum += call_depth
    max_depth = [max_depth, call_depth].max
    min_depth = [min_depth, call_depth].min

    c_count += 1 unless c_func.nil?
    objc_count += 1 unless objc_func.nil?
    cpp_count += 1 unless cpp_func.nil?
  end

  puts "#{filename}
Mean depth: \t#{mean_count_accum / match_count.to_f}
Max depth: \t#{max_depth + 1}
Min depth: \t#{min_depth + 1}
C function ratio: \t#{c_count / match_count.to_f}
Objective-C method ratio: \t#{objc_count / match_count.to_f}
C++ call ratio: \t#{cpp_count / match_count.to_f}\n\n"
end



