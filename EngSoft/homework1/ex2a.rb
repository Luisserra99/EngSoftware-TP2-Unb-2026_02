class WrongNumberOfPlayersError < StandardError ; end
class NoSuchStrategyError < StandardError ; end




def rps_game_winner(game)
raise WrongNumberOfPlayersError unless game.length == 2
raise NoSuchStrategyError unless game.all? { |player| player[1] =~ /[RPS]/ }

if game[0][1] == game[1][1]
  return game[0]
elsif game[0][1] == "R" && game[1][1] == "S"
  return game[0]
elsif game[0][1] == "S" && game[1][1] == "P"
  return game[0]
elsif game[0][1] == "P" && game[1][1] == "R"
  return game[0]
else
  return game[1]
end
end



print(rps_game_winner([ [ "Kristen", "P" ], [ "Pam", "S" ] ]),"\n")
print(rps_game_winner([ [ "Kristen", "S" ], [ "Pam", "P" ] ]),"\n")
print(rps_game_winner([ [ "Kristen", "S" ], [ "Pam", "S" ] ]),"\n")

# print(rps_game_winner([ [ "Kristen", "P" ], [ "Pam", "S" ], [ "Pam", "S" ] ]),"\n")
#print(rps_game_winner([ [ "Kristen", "P" ], [ "Pam", "s" ] ]),"\n")


# => returns the list ["Pam", "S"] wins since S>P