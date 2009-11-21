#!/usr/bin/python

# imports a table into the db

import os, os.path, sys, traceback, csv
import redis

VERSION = '0.0.4'

class Importer:
    def __init__(self, fn, dbnum):
        self.fname = fn
        self.fin = None
        self.hdr = {}
        self.data = None
        self.name = None
        self.db = redis.Redis(db=dbnum)

    def _openFile(self):
        # check that file exists
        if (self.fname == None):
            print 'reading from stdin'
            self.fin = sys.stdin
        else:
            if not os.path.exists(self.fname):
                raise Exception('input file not found: ' + os.path.abspath(self.fname))
            self.fin = open(self.fname, 'rb')
        self.csvIn = csv.reader(self.fin, skipinitialspace=True)

    def _readHeader(self):
        # read header from file
        self.hdr['otherdim'] = []

        for fields in self.csvIn:
            if len(fields) == 0:
                break
            key = fields[0].strip()
            if key == 'otherdim':
                self.hdr[key].append(map(lambda x: x.strip(), fields[1:]))
            elif len(fields)>2:
                self.hdr[key] = map(lambda x: x.strip(), fields[1:])
            else:
                self.hdr[key] = fields[1].strip()

        # cols must always be a list 
        # TODO units also
        for ff in ['cols']:
            if isinstance(self.hdr[ff], str):
                self.hdr[ff] = [ self.hdr[ff] ]

        if not 'name' in self.hdr:
            raise Exception('header must contain a name')
        if not 'descr' in self.hdr:
            raise Exception('header must contain a description')
        if not 'source' in self.hdr:
            raise Exception('header must contain a source')
        if not 'url' in self.hdr:
            raise Exception('header must contain a url')
        if not 'units' in self.hdr:
            raise Exception('header must contain units')
        if not 'default' in self.hdr:
            raise Exception('header must contain default')
        if not 'colLabel' in self.hdr or not 'rowLabel' in self.hdr:
            raise Exception('header must contain column and row headers')
        if not 'cols' in self.hdr:
            raise Exception('header must contain a list of cols')

        self.name = self.hdr['name'].replace(' ','_')

    def _remove(self):
        # remove the table whos header is loaded
        if self.db.sismember('datasets', self.hdr['name']):
            print 'removing: ' + self.hdr['name']
            self.db.srem('datasets', self.hdr['name'])

            keys = self.db.keys(self.name+'*')
            for kk in keys:
                self.db.delete(kk)

    def _importData(self):
        # finish reading the input file, saving the row names and saving the data to the db
        # add header info to the db
        print 'importing: ' + self.hdr['name']
        try:
            self.db.sadd('datasets', self.hdr['name'])

            self.db.sadd(self.name+'||meta', 'descr||' + self.hdr['descr'])
            self.db.sadd(self.name+'||meta', 'source||' + self.hdr['source'])
            self.db.sadd(self.name+'||meta', 'url||' + self.hdr['url'])
            self.db.sadd(self.name+'||meta', 'units||' + self.hdr['units']) # assumes one
            self.db.sadd(self.name+'||meta', 'default||' + self.hdr['default']) # assumes one

            self.db.sadd(self.name+'||dimensions', self.hdr['colLabel'])
            self.db.sadd(self.name+'||dimensions', self.hdr['rowLabel'])
            for cc in self.hdr['cols']:
                self.db.sadd(self.name+'||'+self.hdr['colLabel'].replace(' ','_'), cc)

            # import other dimension names
            dims = []
            for name,value in self.hdr['otherdim']:
                self.db.sadd(self.name+'||dimensions', name)
                dims.append([name,value])
                self.db.sadd(self.name+'||'+name.replace(' ','_'), value)

            # add the table's column names and data to the db
            self.hdr['rows'] = []
            rowHdr = [self.hdr['rowLabel'], '']
            colHdr = [self.hdr['colLabel'], '']
            dims += [rowHdr, colHdr]
            dims.sort()
            for fields in self.csvIn:
                self.hdr['rows'].append(fields[0])
                rowHdr[1] = fields[0]
                for ii in range(1,len(fields)):
                    colHdr[1] = self.hdr['cols'][ii-1]
                    key = self.name+'||'+'||'.join(map(lambda x: x[1], dims))
                    key = key.replace(' ','_')
                    self.db.set(key, fields[ii])

            # import list of row names
            for rr in self.hdr['rows']:
                self.db.sadd(self.name+'||'+self.hdr['rowLabel'].replace(' ','_'), rr)
                
        except Exception, ex:
            print 'FAIL: ' + str(ex)
            print traceback.print_exc()
            print 'import failed, cleaning up'
            self._remove()

    def removeTable(self):
        # import a new table into the db
        self._openFile()
        self._readHeader()
        self.fin.close()
        self._remove()

    def importFile(self):
        # import a table into the db.  if its already there, remove it first
        self._openFile()
        self._readHeader()
        if not 'otherdim' in self.hdr:
            self._remove()
        self._importData()
        self.fin.close()

def printHelp():
    print 'Usage importer.py [Options]'
    print ''
    print 'Options:'
    print ' -i file.csv     import file into db'
    print ' -r file.csv     remove table in file from db'
    print ' -n num          database number'
    print ' -v              print version and exit'
    print ' -h              show this and exit'
    print ' -t              run unit tests'

if __name__ == '__main__':
    print 'importer v' + VERSION
    
    # parse command line args
    if len(sys.argv) == 1 or sys.argv[1] == '-h':
        printHelp()
        sys.exit(0)

    imp = False
    rem = False
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
            elif sys.argv[ii] == '-i':
                if not len(sys.argv) > ii+1:
                    raise Exception('-i option requires file argument')
                ii+=1
                fname = sys.argv[ii]
                imp = True
            elif sys.argv[ii] == '-r':
                if not len(sys.argv) > ii+1:
                    raise Exception('-r option requires file argument')
                ii+=1
                fname = sys.argv[ii]
                rem = True
            elif sys.argv[ii] == '-n':
                if not len(sys.argv) > ii+1:
                    raise Exception('-n option requires number argument')
                ii+=1
                dbNum = int(sys.argv[ii])
            ii+=1

        if imp:
            Importer(fname, dbNum).importFile()
        elif rem:
            Importer(fname, dbNum).removeTable()
        else: # import from stdin
            Importer(None, dbNum).importFile()

    except Exception,ex:
        print 'FAIL: ' + str(ex)
