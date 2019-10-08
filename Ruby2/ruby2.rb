require_relative 'concurrent_array'

test_data = Array.new(20_000_000) { |i| i }
concurrent_array = ConcurrentArray.new(test_data)

starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
test_data.map { |elem| elem * 2 }
    # .select { |elem| elem > 1_000_000 }
    # .any? { |elem| (elem % 2019).zero? }
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting

puts "Serial: #{elapsed}"


starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
concurrent_array.map_concurrent(8) { |elem| elem * 2 }
    # .select_concurrent(8) { |elem| elem > 1_000_000 }
    # .any_concurrent?(8) { |elem| (elem % 2019).zero? }
ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting

puts "Concurrent: #{elapsed}"
