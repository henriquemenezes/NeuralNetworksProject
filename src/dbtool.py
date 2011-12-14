# -*- enconding: utf-8 -*-

import random

from optparse import OptionParser


def read_data(filename):
    try:
        print 'reading ' + filename + ' ...'
        print ''

        f = open(filename)
		
        data = [row.split(',') for row in f.read().strip().split('\n')]
        total = len(data)
        
        f.close()

        return data, total
    except Exception, err:
        print err

def drop_column(filename, data, column):
    try:
        print 'writing ' + filename + ' ...'
        
        f = open(filename, 'w')

        for i in range(len(data)):
            data[i].pop(column)
            if i == len(data) - 1:
                f.write(';'.join(data[i]))
            else:
                f.write(';'.join(data[i]) + '\n')
        f.close()

        print '\ndone.'
    except Exception, err:
        print err    

def group_classes(data, ic):
    try:
        classes = {}
            
        for row in data:
            if not classes.has_key(row[ic]):
                classes[row[ic]] = []
            classes[row[ic]].append(row)

        return classes
    except Exception, err:
        print err

def show_information(classes, total):
    for c, v in classes.items():
        print str(c) + '\t' + str(len(v)) + '\t' \
              + ('%.2f' % (float(len(v)) * 100 / total)) + ' %'

def split_data(filename, classes, total, percent):
    print 'percent test data: %d%%' % percent
    print 'percent train data: %d%%\n' % (100 - percent)
    
    total_test = int(total * float(percent) / 100)
    
    total_by_class = [(c, int(float(len(v)) * total_test / total)) \
                      for c, v in classes.items()]
    
    total_test = sum([v for c,v in total_by_class])
    total_train = total - total_test

    print 'writing ' + filename + '.test ... %d' % total_test

    f_test = open(filename + '.test', 'w')
    
    for i, tc in enumerate(total_by_class):
        count = tc[1]
        while count > 0:
            if count == 1 and i == len(total_by_class) - 1:
                f_test.write(';'.join(classes[tc[0]].pop(
                    random.randint(0, len(classes[tc[0]]) - 1))))
            else:
                f_test.write(';'.join(classes[tc[0]].pop(
                    random.randint(0, len(classes[tc[0]]) - 1))) + '\n')
            count = count - 1
    
    f_test.close()

    print 'writing ' + filename + '.train ... %d' % total_train

    f_train = open(filename + '.train', 'w')
    
    for i, c in enumerate(classes):
        for j in range(len(classes[c])):
            if j == len(classes[c]) - 1 and i == len(classes) - 1:
                f_train.write(';'.join(classes[c][j]))
            else:
                f_train.write(';'.join(classes[c][j]) + '\n')
    
    f_train.close()

    print '\ndone.'

def balancing(filename, classes):
    classes_balanced = {}
    max_samples = 0

    for k,v in classes.items():
            if len(v) > max_samples:
                    max_samples = len(v)
    
    for k,v in classes.items():
            div = max_samples / len(v)        
            diff_div = max_samples - (div*len(v))
            v = v * div
            if diff_div > 0:
                v = v + v[0:diff_div]
            classes_balanced[k] = v
    
    print 'writing ' + filename + '.balanced ...'

    f_balanced = open(filename + '.balanced', 'w')

    total_classes = len(classes_balanced)
    
    for k, v in classes_balanced.items():
        total_classes = total_classes - 1
        
        while len(v) > 0:
            if len(v) > 1 or total_classes > 0:
                f_balanced.write(';'.join(v.pop()) + '\n')
            else:
                f_balanced.write(';'.join(v.pop()))
    
    f_balanced.close()
    
    print '\ndone.'

def main():
    parser = OptionParser(usage="usage: %prog [options] filename classes_index")

    parser.add_option("-s", "--split", action="store", type="int",
                      dest="percent",
                      help="splits the database with n percent "
                      "(by default use 25) to test data and (100-n) "
                      "percent to training data keeping proportionals "
                      "classes")

    parser.add_option("-v", "--view-information", action="store_true",
                      dest="view_information",
                      help="shows database classes information")

    parser.add_option("--drop-column", action="store",
                      type="int", dest="drop_column",
                      help="drop a column n")

    parser.add_option("-b", "--balancing", action="store_true",
                      dest="balancing",
                      help="class balancing")

    (options, args) = parser.parse_args()

    if len(args) != 2:
        parser.error("must take exactly 2 compositional arguments: "
                     "filename classes_index")
    elif options.percent and \
         options.view_information and \
         options.drop_column != None:        
        parser.error("options -s and -v and --drop-column are "
                     "mutually exclusive")        
    elif not options.percent and \
         not options.view_information and \
         not options.balancing and \
         options.drop_column == None:        
        parser.error("choose at least one option")        
    elif options.percent and options.drop_column != None:
        parser.error("options -s and --drop-column are mutually "
                     "exclusive")        
    elif options.percent and options.view_information:
        parser.error("options -s and -v are mutually exclusive")        
    elif options.view_information and options.drop_column != None:
        parser.error("options -v and --drop-column are mutually "
                     "exclusive")
    else:
        data, total = read_data(args[0])
        
        if options.drop_column != None:
            drop_column(args[0], data, options.drop_column)            
        else:
            try:
                classes = group_classes(data, int(args[1]))

                if options.view_information:
                    print 'total paremeters: ' + str(len(data[0]) - 1) + '\n'
                    show_information(classes, total)
                elif options.balancing:
                    print 'total paremeters: ' + str(len(data[0]) - 1) + '\n'
                    show_information(classes, total)
                    print 'balancing'
                    balancing(args[0], classes)
                else:
                    split_data(args[0], classes, total, options.percent)
                
            except Exception, err:
                print err
        
if __name__ == "__main__":
    main()

                      
    
