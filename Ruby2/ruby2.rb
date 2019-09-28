require_relative 'concurrent_array'

a = ConcurrentArray.new([1, 2, 3, 4])
a.each_concurrent(1) do |partition|
  puts partition.map(&:to_s).join
end