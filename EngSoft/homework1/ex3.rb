def combine_anagrams(words)
  anagram_groups = {}

  words.each do |word|

    # coloca em minusculo, separa as letras, ordena e junta no anagrama ordenado
    sorted_word = word.downcase.chars.sort.join

    # Adiciona a palvra limpa no grupo do anagrama
    if anagram_groups[sorted_word]
      anagram_groups[sorted_word] << word
    else # cria um grupo novo de anagraama e coloca a palavra
      anagram_groups[sorted_word] = [word]
    end
  end

  anagram_groups.values
end




print(combine_anagrams(['cars', 'for', 'potatoes', 'racs', 'four','scar', 'creams', 'scream']))

# input: ['cars', 'for', 'potatoes', 'racs', 'four','scar', 'creams', 'scream']
# => output: [["cars", "racs", "scar"], ["four"], ["for"], ["potatoes"],["creams", "scream"]]
# HINT: you can quickly tell if two words are anagrams by sorting their
# letters, keeping in mind that upper vs lowercase doesn't matter
