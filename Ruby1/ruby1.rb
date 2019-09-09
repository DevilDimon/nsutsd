require 'set'

def words_with_symbols(symbols_list, n)
  unique_symbols_list = symbols_list.to_set
  words_with_symbols_internal(unique_symbols_list, n)
    .sort
end

def words_with_symbols_internal(symbols_list, n)
  (1..n).reduce(['']) do |prev_list, _|
    symbols_list.map { |symbol|
      prev_list.reject { |prev_word| prev_word.end_with?(symbol) }
               .map { |prev_word| prev_word + symbol }
    }.flatten
  end
end

puts words_with_symbols(%w[a b c], 4)
