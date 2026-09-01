
def palindrome?(string)
  string = string.downcase.gsub(/[^a-z]/, '')
  puts(string == string.reverse,"\n")
end


palindrome?("A man, a plan, a canal -- Panama") #=> true
palindrome?("Madam, I'm Adam!") # => true
palindrome?("Abracadabra") # => false (nil is also ok)