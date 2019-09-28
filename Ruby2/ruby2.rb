require_relative 'concurrent_array'

test_data = Array.new(1_000_000) { |i| i }
concurrent_array = ConcurrentArray.new(test_data)

puts concurrent_array.map_concurrent(2) { |elem| elem * 2 }
                .select_concurrent(4) { |elem| elem > 1_000_000 }
                .any_concurrent?(8) { |elem| (elem % 2019).zero?  }


