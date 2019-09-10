require 'set'

def words_with_characters(characters_list, word_length)
  unique_characters_list = characters_list.to_set
  words_with_characters_internal(unique_characters_list, word_length).sort
end

def words_with_characters_internal(characters_list, word_length)
  (1..word_length).reduce(['']) do |words, _|
    words_with_added_characters = characters_list.map do |character|
      words.reject { |word| word.end_with?(character) }.map { |word| "#{word}#{character}" }
    end

    words_with_added_characters.flatten
  end
end

puts words_with_characters(%w(a b c), 4)
