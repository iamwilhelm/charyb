#!/usr/bin/python

# imports a table into the db

import os, os.path, sys, traceback, csv, json
sys.path.append('redis')
import redis

VERSION = '0.1.0'

def _under(strIn):
    return strIn.replace(' ','_')

def _getNumber(strIn):
    try:
        return str(float(strIn))
    except:
        return 'NaN'

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

    def _getSearchTerms(self, dims):
        # get a list of search terms given a dict of 
        ret = []
        for kk in dims:
            if kk == 'Category':
                ret += dims[kk]
            elif kk not in ['State', 'Year', 'Country']:
                ret.append(kk)
        return ret

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

    def _updateDimLabels(self, meta, dimName, newDimLabels):
        # create or expand dimension labels list
        if dimName in meta['dims']:
            dimLabels = meta['dims'][dimName]
        else:
            dimLabels = []
            meta['dims'][dimName] = dimLabels
        dimLabels += set(newDimLabels).difference(dimLabels)

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
                meta = { 'dims': {}, 'sources': {}, 'units': {} }

            # add or update row and col labels
            self._updateDimLabels(meta, self.hdr['rowLabel'], self.hdr['rows'])
            self._updateDimLabels(meta, self.hdr['colLabel'], self.hdr['cols'])

            # import other dimension names
            dims = []
            for name,value in self.hdr['otherDim']:
                dims.append({'name': name, 'val': value})
                if name in meta['dims']:
                    if value not in meta['dims'][name]:
                        meta['dims'][name] += [value]
                else:
                    meta['dims'][name] = [value]

            # sort dimensions by name
            dims.sort(key=lambda x: x['name'])

            # pack metadata into struct
            meta['descr'] = self.hdr['descr']
            meta['default'] = self.hdr['default']
            metaKey = 'default' if len(self.hdr['otherDim'])==0 else '|'.join([ x['val'] for x in dims ])
            meta['sources'][metaKey] = {'url': self.hdr['url'],
                                        'license': self.hdr['license'], 
                                        'source': self.hdr['source'], 
                                        'publishDate': self.hdr['publishDate']}
            if (len(self.hdr['units'])==1):
                meta['units']['default'] = self.hdr['units'][0]
            else:
                meta['units'].update(dict(zip(self.hdr['cols'],self.hdr['units'])))

            # store metadata as json string
            metaStr = json.dumps(meta)
            self.db.set(self.name, metaStr)

            # add the data to the db
            rowHdr = {'name': self.hdr['rowLabel'], 'val': ''}
            colHdr = {'name': self.hdr['colLabel'], 'val': ''}
            dims += [rowHdr, colHdr]
            dims.sort(key=lambda x: x['name'])
            for rh,rd in zip(self.hdr['rows'],self.data):
                rowHdr['val'] = rh
                for ch,cd in zip(self.hdr['cols'],rd):
                    colHdr['val'] = ch
                    key = _under(self.name+'|'+'|'.join([ x['val'] for x in dims ]))
                    self.db.set(key, _getNumber(cd))

            # add lookup data
            self.db.select(self.searchDbNum)
            self.db.sadd(_under(self.hdr['name']).lower(), '_')
            for ss in self._getSearchTerms(meta['dims']):
                self.db.sadd(_under(self.hdr['name']+'|'+ss).lower(), self.hdr['name'])
                
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
