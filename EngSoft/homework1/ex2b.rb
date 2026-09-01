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

def rps_tournament_winner(tournament)
  # É um jogo simples: [["Nome","P"], ["Nome","S"]]
  return rps_game_winner(tournament) if tournament[0][0].is_a?(String)

  # Caso contrário são dois sub-torneios: resolve cada lado e joga a final
  rps_game_winner([
    rps_tournament_winner(tournament[0]),
    rps_tournament_winner(tournament[1])
  ])
end



print(rps_tournament_winner(  
[
[
 [ ["Kristen", "P"], ["Dave", "S"] ],
 [ ["Richard", "R"], ["Michael", "S"] ],
 [ ["Allen", "S"], ["Omer", "P"] ],
 [ ["David E.", "R"], ["Richard X.", "P"] ]
],
[
 [ ["Allen", "S"], ["Omer", "P"] ],
 [ ["David E.", "R"], ["Richard X.", "P"] ],
 [ ["Kristen", "P"], ["Dave", "S"] ],
 [ ["Richard", "R"], ["Michael", "S"] ]
]
] 
)
)