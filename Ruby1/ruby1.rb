def words_with_symbols(symbols_list, n)
  (1..n).reduce(['']) do |prev_list, _|
    symbols_list.map { |symbol|
      prev_list.reject { |prev_word| prev_word.end_with?(symbol) }
               .map { |prev_word| prev_word + symbol }
    }.flatten
  end
end

puts words_with_symbols(%w[a b c], 4)
