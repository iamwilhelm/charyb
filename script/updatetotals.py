#!/usr/bin/python

# updates totals dimensions for a given dataset

import sys, itertools, operator, json, traceback
if 'redis' not in sys.path:
    sys.path.append('redis')                # for running from local dir
if 'script/redis' not in sys.path:
    sys.path.append('script/redis')         # for running from charyb dir
import redis

VERSION = '0.0.1'

def _toKey(strIn):
    ''' lowercase and underscore a string '''
    return strIn.replace(' ','_').lower()

def _applyPattern(dimLabels, flag):
    ''' set dimension labels according to pattern flags '''
    if flag=='t':
            return ['Total']
    elif flag == 'a':
        return [dimLabels]
    else:
        return dimLabels

def _getSumParams(allDimLabels, pattern):
    '''
    get the params for a set of sum operations.  returns a list of
    tuples, where each tuple specifies which items in the
    datawarehouse to sum.
    '''
    params = map(_applyPattern, allDimLabels, pattern)
    return [ [ [x] if isinstance(x, str) else x for x in pp ] for pp in itertools.product(*params) ]

def _getPatterns(labels):
    '''
    figure out which "Total" dimensions must be calculated.  each
    pattern specifies the calculations that must be done to complete a
    dimension of totals. get all of the summing patterns for a given
    set of labels. summing patterns are expressed in tuples, with one
    item for each dimension (sorted).  each pattern calculates a level
    of a dimension.  possible values for each item in the tuples are:
    a=all (dimension to be summed over), e=every (iterate over each),
    t=total (use total column for this dim).
    '''
    ret = []
    n = len(labels)
    for dd in range(1,n+1):
        pattern = [ list(aa) for aa in set(itertools.permutations('e'*(n-dd)+'t'*dd)) ]
        # set first 't' to 'a' (sum over first non-'e')
        for ii in pattern:
            ii[ii.index('t')] = 'a'
        ret += pattern
    return ret

def _getDimLabels(dw, dataSet):
    ''' get the dimension labels for all dimensions, update the datasets metadata '''
    if not dw.exists(dataSet):
        raise Exception('dataset not found')
    meta = json.loads(dw.get(dataSet))
    allDimLabels = [ [ str(x) for x in dd[1] if x!='Total' ] for dd in sorted(meta['dims'].items()) ]
    for dd in meta['dims']:
        if 'Total' not in meta['dims'][dd]:
            meta['dims'][dd].append('Total')
    dw.set(dataSet, json.dumps(meta))
    return allDimLabels

def updateTotals(dw, dataSet):
    '''
    >>> dw = redis.Redis(db=3)
    >>> updateTotals(dw, 'Oil')
    >>> print str(dw.get('Oil|Total|Total|Total'))
    53822.6742548
    '''
    # update the totals for a given dataset
    # get dimension labels from dataset metadata.  convert from
    # unicode to strings, make sure they're ordered by dimension name,
    # ignore total cols
    allDimLabels = _getDimLabels(dw, dataSet)
    
    # figure out all of the "Total" dimensions that need to be calculated
    patterns = _getPatterns(allDimLabels)
    for pp in patterns:
        # expand a pattern into a set of summations, execute each one
        params = _getSumParams(allDimLabels, pp)
        for pr in params:
            # lhs is the name of the redis key being set
            lhs = [ ['Total'] if len(x)>1 else x for x in pr ]
            lhs = _toKey(dataSet+'|' + '|'.join([ x[0] for x in lhs ]))
            # rhs is a list of redis keys being summed
            rhs = [ dataSet+'|' + '|'.join(map(_toKey, pp)) for pp in itertools.product(*pr) ]
            try:
                total = reduce(operator.add, [ float(x) for x in dw.mget(*rhs) ] )
            except:
                total = 'NaN'
            #print lhs + ' = ' + str(total)
            dw.set(lhs, str(total))
 
def printHelp():
    print 'Usage: updatetotals.py [Options] [dataset]'
    print ''
    print 'Options:'
    print ' -n num          database number'
    print ' -v              print version and exit'
    print ' -h              show this and exit'
    print ' -t              run unit tests'


if __name__ == '__main__':

    print 'updatetotals v' + VERSION
    
    # parse command line args
    if len(sys.argv) == 1 or sys.argv[1] == '-h':
        printHelp()
        sys.exit(0)

    dataSet = None
    dbNum = 0
    try:
        ii = 1
        while ii<len(sys.argv):
            if sys.argv[ii] == '-t':
                import doctest
                doctest.testmod()
                sys.exit(0)
            elif sys.argv[ii] == '-v':
                sys.exit(0)
            elif sys.argv[ii] == '-n':
                if not len(sys.argv) > ii+1:
                    raise Exception('-n option requires number argument')
                ii+=1
                dbNum = int(sys.argv[ii])
            else:
                dataSet = sys.argv[ii]
            ii+=1

        # update totals for a specified dataset
        if dataSet==None:
            raise Exception('dataset not specified')
        dw = redis.Redis(db=dbNum)
        updateTotals(dw, dataSet)
        print 'done'

    except Exception,ex:
        print 'FAIL: ' + str(ex)
        print traceback.print_exc()
