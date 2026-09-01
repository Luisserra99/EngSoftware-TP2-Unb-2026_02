def count_words(string)
  string = string.downcase.gsub(/[^a-z]/, ' ')
  words = string.split()
  word_count = {}
  words.each do |word|
    if word_count.key?(word)
      word_count[word] += 1
    else
      word_count[word] = 1
    end
  end
  puts(word_count,"\n")
end


count_words("A man, a plan, a canal -- Panama")
# => {'a' => 3, 'man' => 1, 'canal' => 1, 'panama' => 1, 'plan' => 1}
count_words ("Doo bee doo bee doo") # => {'doo' => 3, 'bee' => 2}

