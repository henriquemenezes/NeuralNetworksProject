function matrizConfusao = matrix_confusao( fileSaida )

numSaidas = 2;
inputname = strcat('res\', fileSaida, '.txt');
saida = load(inputname);
nodoVencedorRede = saida(:,1);
nodoVencedorDesejado = saida(:,2);
 
matrizConfusao = zeros(numSaidas,numSaidas); % Cria Matriz quadrática nula de Dimensão numSaida

numTeste = size(saida, 1);

for teste = 1 : numTeste;
   matrizConfusao(nodoVencedorDesejado(teste),nodoVencedorRede(teste)) = matrizConfusao(nodoVencedorDesejado(teste),nodoVencedorRede(teste))+ 1; % carrega matriz de confusão
end

transposta = matrizConfusao'; % operação efetuada para calcular a transposta

soma_das_linhas = sum(transposta); % operação efetuada para calcular um vetor de dimensão numSaida com a soma das colunas da transposta (que são as linhas da matriz de confusão)

for linha = 1 : numSaidas
    for    coluna = 1 : numSaidas
        matrizConfusao(linha,coluna) = matrizConfusao(linha,coluna)* 100/soma_das_linhas(linha); % cálculo de porcentagens: valor/soma da linha
    end
end

outputname = strcat( 'res\matriz\', fileSaida, '_matriz_confusao.xlsx');

xlswrite(outputname, matrizConfusao) % Cria uma planilha excel com a matriz de confusão no diretório do projeto

echo on
matrizConfusao; % Matriz de confusão no console
echo off

end

