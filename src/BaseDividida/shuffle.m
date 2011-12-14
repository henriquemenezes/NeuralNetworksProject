function retorno = shuffle(entrada, filename)

retorno = entrada(randperm(size(entrada, 1)),:);
csvwrite(filename, retorno);