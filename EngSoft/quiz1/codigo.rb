ARQUIVO     = File.join(__dir__, "engsoft.txt")
LINHA_ALUNO = /^\s*(\d{2}\/\d{7})\s+(\S.*?)\s*$/
# ^ começo da linha
# # \s*$            - zero ou mais espaços
# (\d{2}\/\d{7})  - captura a matrícula (dois dígitos, barra, sete dígitos)
# \s+             - um ou mais espaços em branco
# (\S.*?)         - captura o nome (uma sequência de caracteres não brancos, seguida de qualquer coisa)
# \s*$            - zero ou mais espaços

alunos       = []
coluna_nome  = nil

File.foreach(ARQUIVO) do |linha|
  linha = linha.chomp 
  # remove o identificador de final de linha (\n ou \r\n) do final da linha
  if (m = LINHA_ALUNO.match(linha)) # caso match seja diferente de nil, m recebe valor e entra no if
    alunos << [m[1], m[2]]
    coluna_nome = m.begin(2) # guarda em que posição da linha começa o nome do aluno, para caso ele continue na linha de baixo
  elsif coluna_nome && linha =~ /^ {#{coluna_nome}}(\S.*?)\s*$/
    # Nome que nao coube na coluna e continuou na linha de baixo.
    alunos.last[1] += " " + $1 # $1 armazena o valor do primeiro grupo de captura da regex, que é o nome do aluno
    coluna_nome = nil
  else
    coluna_nome = nil
  end
end
#retorna um array de arrays, cada sub-array contém a matrícula e o nome do aluno
alunos.each { |matricula, nome| puts "#{matricula}\t#{nome}" }
