ARQUIVO     = File.join(__dir__, "engsoft.txt")
LINHA_ALUNO = /^(\d{2}\/\d{7})\s+(\S.*?)\s*$/

alunos       = []
coluna_nome  = nil

File.foreach(ARQUIVO) do |linha|
  linha = linha.chomp

  if (m = LINHA_ALUNO.match(linha))
    alunos << [m[1], m[2]]
    coluna_nome = m.begin(2)
  elsif coluna_nome && linha =~ /^ {#{coluna_nome}}(\S.*?)\s*$/
    # Nome que nao coube na coluna e continuou na linha de baixo.
    alunos.last[1] += " " + $1
    coluna_nome = nil
  else
    coluna_nome = nil
  end
end

alunos.each { |matricula, nome| puts "#{matricula}\t#{nome}" }
