function retorno = shuffle(entrada, filename)

retorno = entrada(randperm(size(entrada, 1)),:);
CSVWRITE(filename, retorno);