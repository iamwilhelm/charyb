#!/usr/bin/python

# imports a table into the db

import os, os.path, sys, traceback, csv, json
sys.path.append('redis')
import redis

VERSION = '0.1.0'

def _under(str):
    return str.replace(' ','_')

class Importer:
    def __init__(self, fn, dbNum):
        self.fname = fn
        self.fin = None
        self.hdr = {}
        self.data = None
        self.name = None
        self.searchDbNum = dbNum
        self.dataDbNum = dbNum+1
        self.db = redis.Redis(db=self.dataDbNum)

    def _openFile(self):
        # check that file exists, open it.  if not file, read from stdin
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
        self.hdr['otherDim'] = []

        for fields in self.csvIn:
            if len(fields) == 0:
                break
            key = fields[0].strip()
            if key == 'otherDim':
                self.hdr[key].append([ x.strip() for x in fields[1:] ])
            elif len(fields)>2:
                self.hdr[key] = [ x.strip() for x in fields[1:] ]
            else:
                self.hdr[key] = fields[1].strip()

        # some fields must always be lists
        for ff in ['cols', 'units']:
            if isinstance(self.hdr[ff], str):
                self.hdr[ff] = [ self.hdr[ff] ]

        # make sure required fields are present
        for ff in ['name', 'descr', 'source', 'url', 'units', 'default', 'colLabel', 'cols', 'license']:
            if not ff in self.hdr:
                raise Exception('header must contain an entry for ' + ff)

        self.name = _under(self.hdr['name'])

    def _remove(self):
        # remove the table whos header is loaded
        self.db.select(self.dataDbNum)
        if self.db.sismember('datasets', self.hdr['name']):
            print 'removing: ' + self.hdr['name']
            meta = json.loads(self.db.get(self.name))

            # remove meta
            self.db.srem('datasets', self.hdr['name'])
            self.db.delete(self.name)

            # remove data
            keys = self.db.keys(self.name+'*')
            for kk in keys:
                self.db.delete(kk)

            # remove search terms
            self.db.select(self.searchDbNum)
            for ss in self._getSearchTerms(meta['dims']):
                self.db.srem(_under(ss), self.hdr['name'])
                if self.db.scard(_under(ss))==0:
                    self.db.delete(_under(ss))

    def _readData(self):
        # read row labels and data
        self.hdr['rows'] = []
        self.data = []
        for fields in self.csvIn:
            self.hdr['rows'].append(fields[0])
            self.data.append(fields[1:])

    def _getSearchTerms(self, dims):
        # get a list of search terms given a list of dimensions or labels of a category
        ret = [ self.hdr['name'] ]
        for dd in dims:
            if dd['name'] == 'Category':
                ret += self._getSearchTerms(dd['labels'])
            elif dd['name'] not in ['State', 'Year', 'Country']:
                ret.append(dd['name'])
        return ret

    def _importData(self):
        # finish reading the input file, saving the row names and saving the data to the db
        # add header info to the db
        print 'importing: ' + self.hdr['name']
        try:
            self._readData()

            self.db.select(self.dataDbNum)
            self.db.sadd('datasets', self.hdr['name'])

            # load meta struct if it exists
            if self.db.exists(self.name):
                meta = json.loads(self.db.get(self.name))
            else:
                meta = {}
                meta['dims'] = []

            # pack metadata into struct
            meta['descr'] = self.hdr['descr']
            meta['default'] = self.hdr['default']

            # add or update row dimension
            dim = filter(lambda x: x['name'] == self.hdr['rowLabel'], meta['dims'])
            if len(dim) == 0:
                dim = {'name': self.hdr['rowLabel']}
                dim['labels'] = []
                meta['dims'].append(dim)
            else:
                dim = dim[0]
            labelNames = [ x['name'] for x in dim['labels'] ]
            for ll in set(self.hdr['rows']).difference(labelNames):
                dim['labels'].append({'name': ll})

            # add col dimension (one for each if categories)
            dim = filter(lambda x: x['name'] == self.hdr['colLabel'], meta['dims'])
            if len(dim) == 0:
                dim = {'name': self.hdr['colLabel']}
                dim['labels'] = []
                meta['dims'].append(dim)
            else:
                dim = dim[0]

            dim['url'] = self.hdr['url']
            dim['license'] = self.hdr['license']
            dim['source'] = self.hdr['source']
            dim['publishDate'] = self.hdr['publishDate']

            labelNames = [ x['name'] for x in dim['labels'] ]
            for ll in set(self.hdr['cols']).difference(labelNames):
                if (len(self.hdr['units'])==1):
                    dim['labels'] = [ {'name': x} for x in self.hdr['cols'] ]
                    dim['units'] = self.hdr['units'][0]
                else:
                    dim['labels'] = [ {'name': x, 'units': y} for x,y in zip(self.hdr['cols'],self.hdr['units']) ]

            # import other dimension names
            dims = []
            for name,value in self.hdr['otherDim']:
                dims.append([name,value])
                dim = filter(lambda x: x['name'] == name, meta['dims'])
                if len(dim) == 0:
                    meta['dims'].append({'name': name, 'labels': [value]})
                else:
                    dim[0]['labels'].append(value)

            # sort dimensions by name
            meta['dims'].sort(key=lambda x: x['name'])

            # store metadata as json string
            metaStr = json.dumps(meta)
            self.db.set(self.name, metaStr)

            # add the data to the db
            rowHdr = [self.hdr['rowLabel'], '']
            colHdr = [self.hdr['colLabel'], '']
            dims += [rowHdr, colHdr]
            dims.sort()
            for rh,rd in zip(self.hdr['rows'],self.data):
                rowHdr[1] = rh
                for ch,cd in zip(self.hdr['cols'],rd):
                    colHdr[1] = ch
                    key = self.name+'|'+'|'.join([ x[1] for x in dims ])
                    key = key.replace(' ','_')
                    self.db.set(key, cd.strip())

            # add lookup data
            self.db.select(self.dataDbNum)
            for ss in self._getSearchTerms(meta['dims']):
                self.db.sadd(_under(ss).lower(), self.hdr['name'])
                
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
        if len(self.hdr['otherDim'])==0:
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
        print traceback.print_exc()
