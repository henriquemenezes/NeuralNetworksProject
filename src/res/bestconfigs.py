import os
import re

def print_res(result):
    print '%s\t%s\t%s\t%s\t%s' % ('Filename'.center(34), 'MSE tr'.center(8),
                                    'MSE val'.center(8), 'MSE tst'.center(8),
                                    'AUROC'.center(8))
    for r in result:
        a1, a2, a3, a4, a5 = r
        print '%s\t%f\t%f\t%f\t%f' % (a1.ljust(34), a2, a3, a4, a5)

files = os.listdir('.')
test = re.compile("0.txt$", re.IGNORECASE)
files = filter(test.search, files)

res = []

for f in files:
    file = open(f)
    content = file.read()

    mse_tr = re.search('MSE tr.:(\d+?\.\d+?)\n', content)
    mse_tr = float(mse_tr.group(1))
    
    mse_val = re.search('MSE val.:(\d+?\.\d+?)\n', content)
    mse_val = float(mse_val.group(1))
    
    mse_tst = re.search('MSE tst.:(\d+?\.\d+?)\n', content)
    mse_tst = float(mse_tst.group(1))
    
    auroc = re.search('AUROC   =(\d+?\.\d+?)\n', content)
    auroc = float(auroc.group(1))

    res.append([f, mse_tr, mse_val, mse_tst, auroc])
    
res_sorted = sorted(res, key=lambda row:row[4], reverse=True)

print_res(res_sorted)

raw_input()
