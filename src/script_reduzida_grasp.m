echo on
clear
entradas = [35, 12, 13, 38, 43, 46, 31, 32, 11, 17];
numEntradas = 46;                             % Informacoes sobre a rede e os dados
numEscondidos = [5];                          % Numero de nodos escondidos
numSaidas = 2;                                % Numero de nodos de saida
numTr = 40000;                                % Numero de padroes de treinamento
numVal = 20000;                               % Numero de padroes de validacao
numTeste = 10175;                             % Numero de padroes de teste
algsTr = {'trainlm'};                         % Algoritmos de treinamento
funcsAtv = {'logsig'};                        % Funções de ativacao
taxaslr = [0.01];                             % Taxas de aprendizagem
epocas = [5000];                              % Número de iterações (épocas)

echo off

% Abrindo arquivos e carregando
dadosTreinamento = load('BaseDividida\reduced_train_embaralhada.csv');
dadosValidacao = load('BaseDividida\reduced_validation_embaralhada.csv');
dadosTeste = load('BaseDividida\saida_embaralhada_teste.csv');

% Armazenando dados em matrizes
dadosTreinamento = [dadosTreinamento ~dadosTreinamento(:,end)];
dadosTreinamento = dadosTreinamento';
entradasTreinamento = dadosTreinamento(entradas,:);
saidasTreinamento = dadosTreinamento((numEntradas + 1):(numEntradas + numSaidas),:);

dadosValidacao = [dadosValidacao ~dadosValidacao(:,end)];
dadosValidacao = dadosValidacao';
entradasValidacao = dadosValidacao(entradas,:);
saidasValidacao = dadosValidacao((numEntradas + 1):(numEntradas + numSaidas),:);

dadosTeste = dadosTeste(1:end, 2:end)';
entradasTeste = dadosTeste(entradas, 1:numTeste);
saidasTeste = dadosTeste((numEntradas + 1):(numEntradas + numSaidas), 1:numTeste);

for iter = 1 : 10
    
    for iAlgTr = 1 : size(algsTr, 2)
        algoritmoTreinamento = algsTr{iAlgTr};

        for iFuncAtv = 1 : size(funcsAtv, 2)
            funcaoAtivacao = funcsAtv{iFuncAtv};

            for iNumEsc = 1 : size(numEscondidos, 2)
                numEscondido = numEscondidos(iNumEsc);

                for iTaxalr = 1 : size(taxaslr, 2)
                    taxalr = taxaslr(iTaxalr);

                    for iEpoca = 1 : size(epocas, 2)
                        epoca = epocas(iEpoca);

                        resFilename = strcat(algoritmoTreinamento,'_',funcaoAtivacao,'_',num2str(numEscondido),'_',num2str(taxalr),'_',num2str(epoca),'_it',num2str(iter));
                        resFile = fopen(strcat('res\', resFilename, '.txt'), 'w');

                        fprintf(resFile, 'Configuracao:\n');
                        fprintf(resFile, strcat('Alg.Trein.: ', algoritmoTreinamento, '\n'));
                        fprintf(resFile, strcat('Func.Ativ.: ', funcaoAtivacao, '\n'));
                        fprintf(resFile, strcat('Nod.Esc.: ', num2str(numEscondido), '\n'));
                        fprintf(resFile, strcat('Tax.Apr.: ', num2str(taxalr), '\n'));
                        fprintf(resFile, strcat('Epc.Max.: ', num2str(epoca), '\n'));

                        % Criando a rede (para ajuda, digite 'help newff')
                        for entrada = 1 : size(entradas,2);  % Cria 'matrizFaixa', que possui 'numEntradas' linhas, cada uma sendo igual a [0 1].
                            matrizFaixa(entrada,:) = [0 1];
                        end

                        rede = newff(matrizFaixa,[numEscondido numSaidas],{funcaoAtivacao,funcaoAtivacao},algoritmoTreinamento,'learngdm','mse');
                        % matrizFaixa                    : indica que todas as entradas possuem valores na faixa entre 0 e 1
                        % [numEscondido numSaidas]       : indica a quantidade de nodos escondidos e de saida da rede
                        % {'logsig','logsig'}            : indica que os nodos das camadas escondida e de saida terao funcao de ativacao sigmoide logistica
                        % 'traingdm','learngdm'          : indica que o treinamento vai ser feito com gradiente descendente (backpropagation)
                        % 'sse'                          : indica que o erro a ser utilizado vai ser MSE

                        % Inicializa os pesos da rede criada (para ajuda, digite 'help init')
                        rede = init(rede);

                        % Parametros do treinamento (para ajuda, digite 'help traingd')
                        rede.trainParam.epochs   = epoca;  % Maximo numero de iteracoes
                        rede.trainParam.lr       = taxalr; % Taxa de aprendizado
                        rede.trainParam.goal     = 0;      % Criterio de minimo erro de treinamento
                        rede.trainParam.max_fail = 5;      % Criterio de quantidade maxima de falhas na validacao
                        rede.trainParam.min_grad = 0;      % Criterio de gradiente minimo
                        rede.trainParam.show     = 10;     % Iteracoes entre exibicoes na tela (preenchendo com 'NaN', nao exibe na tela)
                        rede.trainParam.time     = inf;    % Tempo maximo (em segundos) para o treinamento

                        fprintf('\nTreinando ...\n')

                        conjuntoValidacao.P = entradasValidacao; % Entradas da validacao
                        conjuntoValidacao.T = saidasValidacao;   % Saidas desejadas da validacao

                        %   Treinando a rede
                        [redeNova,desempenho,saidasRede,erros] = train(rede,entradasTreinamento,saidasTreinamento,[],[],conjuntoValidacao);
                        % redeNova   : rede apos treinamento
                        % desempenho : apresenta os seguintes resultados
                        %              desempenho.perf  - vetor com os erros de treinamento de todas as iteracoes (neste exemplo, escolheu-se erro SSE)
                        %              desempenho.vperf - vetor com os erros de validacao de todas as iteracoes (idem)
                        %              desempenho.epoch - vetor com as iteracoes efetuadas
                        % saidasRede : matriz contendo as saidas da rede para cada padrao de treinamento
                        % erros      : matriz contendo os erros para cada padrao de treinamento
                        %             (para cada padrao: erro = saida desejada - saida da rede)
                        % Obs.       : Os dois argumentos de 'train' preenchidos com [] apenas sao utilizados quando se usam delays
                        %             (para ajuda, digitar 'help train')

                        fprintf(resFile, strcat('Epc.Real.:', num2str(length(desempenho.epoch)), '\n'));
                        fprintf('\nTestando ...\n');

                        %    Testando a rede
                        [saidasRedeTeste,Pf,Af,errosTeste,desempenhoTeste] = sim(redeNova,entradasTeste,[],[],saidasTeste);
                        % saidasRedeTeste : matriz contendo as saidas da rede para cada padrao de teste
                        % Pf,Af           : matrizes nao usadas neste exemplo (apenas quando se usam delays)
                        % errosTeste      : matriz contendo os erros para cada padrao de teste
                        %                  (para cada padrao: erro = saida desejada - saida da rede)
                        % desempenhoTeste : erro de teste (neste exemplo, escolheu-se erro SSE)

                        fprintf('MSE para o conjunto de treinamento: %6.5f \n',desempenho.perf(length(desempenho.perf)));
                        fprintf('MSE para o conjunto de validacao: %6.5f \n',desempenho.vperf(length(desempenho.vperf)));
                        fprintf('MSE para o conjunto de teste: %6.5f \n',desempenhoTeste);

                        fprintf(resFile, strcat('MSE tr.:', num2str(desempenho.perf(length(desempenho.perf))), '\n'));
                        fprintf(resFile, strcat('MSE val.:', num2str(desempenho.vperf(length(desempenho.vperf))), '\n'));
                        fprintf(resFile, strcat('MSE tst.:', num2str(desempenhoTeste), '\n'));

                        % Calculando o erro de classificacao para o conjunto de teste
                        % (A regra de classificacao e' winner-takes-all, ou seja, o nodo de saida que gerar o maior valor de saida
                        % corresponde a classe do padrao).
                        % Obs.: Esse erro so' faz sentido se o problema for de classificacao. Para problemas que nao sao de classificacao,
                        % esse trecho do script deve ser eliminado.

                        [maiorSaidaRede, nodoVencedorRede] = max (saidasRedeTeste);
                        [maiorSaidaDesejada, nodoVencedorDesejado] = max (saidasTeste);

                        % Obs.: O comando 'max' aplicado a uma matriz gera dois vetores: um contendo os maiores elementos de cada coluna
                        % e outro contendo as linhas onde ocorreram os maiores elementos de cada coluna.

                        classificacoesErradas = 0;

                        for padrao = 1 : numTeste;
                            if nodoVencedorRede(padrao) ~= nodoVencedorDesejado(padrao),
                                classificacoesErradas = classificacoesErradas + 1;
                            end
                        end

                        erroClassifTeste = 100 * (classificacoesErradas/numTeste);

                        fprintf('Erro de classificacao para o conjunto de teste: %6.5f\n',erroClassifTeste);
                        fprintf(resFile, strcat('Erro classf. tst.:', num2str(erroClassifTeste), '\n'));

                        saidaFilename = strcat(algoritmoTreinamento,'_',funcaoAtivacao,'_',num2str(numEscondido),'_',num2str(taxalr),'_',num2str(epoca),'_it',num2str(iter));
                        saidaFile = fopen(strcat('res\', saidaFilename,'_saida.txt'), 'w');

                        for padrao = 1 : numTeste
                            fprintf(saidaFile, strcat(num2str(nodoVencedorRede(padrao)), '\t', num2str(nodoVencedorDesejado(padrao)), '\n'));
                        end;

                        %matriz confusao
                        matrizFilename = strcat(saidaFilename,'_saida');
                        matrix_confusao(matrizFilename);


                        %Curva ROC
                        T = [];
                        for padrao = 1 : numTeste;

                            if nodoVencedorDesejado(padrao) == 1,
                                T(padrao,1) = 1;
                            else
                                T(padrao,1) = 0;
                            end

                            T(padrao,2) = saidasRedeTeste(1,padrao);

                        end

                        [TP,FP] = roc(T(:,1),T(:,2));

                        plot(FP,TP);
                        xlabel('false positive rate');
                        ylabel('true positive rate');
                        title('ROC curve');

                        set(gcf, 'Position', [200 200 300 300]);
                        stringImagem = strcat('res\imagens\', resFilename,'.png');
                        saveas(gcf, stringImagem);
                        % var = algoritmoAtual + '.png';

                        %export_fig stringImagem -m2.5;

                        % compute the area under the ROC

                        fprintf('\n\nAUROC   = %f\n', auroc(TP,FP));
                        stringTextoArquivo = strcat(resFile,'\n\nAUROC   = ', num2str(auroc(TP,FP)), '\n');

                        fprintf(resFile, stringTextoArquivo);

                        fclose(resFile);
                        fclose(saidaFile);

                    end;
                end;
            end;
        end;
    end;
end;