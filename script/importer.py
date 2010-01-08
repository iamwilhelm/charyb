#!/usr/bin/python

# imports a table into the db

import os, os.path, sys, traceback, csv, json, operator
sys.path.append('redis')                # for running from local dir
sys.path.append('script/redis')         # for running from charyb dir
import redis, updatetotals

VERSION = '0.1.3'

def _tokey(str_in):
    ''' lowercase and underscore a string '''
    return str_in.replace(' ','_').lower()

def _getnumber(str_in):
    try:
        return str(float(str_in))
    except:
        return 'NaN'

class Importer:
    def __init__(self, fn, dbnum):
        self.fname = fn
        self.fin = None
        self.hdr = {}
        self.data = None
        self.name = None
        self.search_db_num = dbnum
        self.data_db_num = dbnum+1
        self.db = redis.Redis(db=self.data_db_num)

    def _openfile(self):
        # check that file exists, open it.  if not file, read from stdin
        if (self.fname == None):
            print 'reading from stdin'
            self.fin = sys.stdin
        else:
            if not os.path.exists(self.fname):
                raise Exception('input file not found: ' + os.path.abspath(self.fname))
            self.fin = open(self.fname, 'rb')
        self.csvIn = csv.reader(self.fin, skipinitialspace=True)

    def _readheader(self):
        # read header from file
        self.hdr['otherDims'] = []

        for fields in self.csvIn:
            if len(fields) == 0:
                break
            key = fields[0].strip()
            if key == 'otherDims':
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

        self.name = _tokey(self.hdr['name'])

    def _get_search_terms(self, dims):
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
        self.db.select(self.data_db_num)
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
            self.db.select(self.search_db_num)
            for ss in self._get_search_terms(meta['dims']):
                self.db.srem(_tokey(ss), self.hdr['name'])
                if self.db.scard(_tokey(ss))==0:
                    self.db.delete(_tokey(ss))

    def _readdata(self):
        # read row labels and data
        self.hdr['rows'] = []
        self.data = []
        for fields in self.csvIn:
            self.hdr['rows'].append(fields[0])
            self.data.append(fields[1:])

    def _update_dim_labels(self, meta, dimname, new_dim_labels):
        # create or expand dimension labels list
        if dimname in meta['dims']:
            dimlabels = meta['dims'][dimname]
        else:
            dimlabels = []
            meta['dims'][dimname] = dimlabels
        dimlabels += set(new_dim_labels).difference(dimlabels)

    def _importdata(self):
        # finish reading the input file, saving the row names and saving the data to the db
        # add header info to the db
        print 'importing: ' + self.hdr['name']
        try:
            self._readdata()

            # load meta struct if it exists
            self.db.select(self.data_db_num)
            if self.db.exists(self.name):
                meta = json.loads(self.db.get(self.name))
            else:
                meta = { 'dims': {}, 'otherDims': [], 'sources': {}, 'units': {} }

            # add or update row and col labels
            self._update_dim_labels(meta, self.hdr['rowLabel'], self.hdr['rows'])
            self._update_dim_labels(meta, self.hdr['colLabel'], self.hdr['cols'])

            # import other dimension names, populate otherDims list
            meta['otherDims'] = list(set(meta['otherDims']).union( map(operator.itemgetter(0), self.hdr['otherDims']) ))
            for name,value in self.hdr['otherDims']:
                if (name in meta['dims']):
                    meta['dims'][name] = list(set(meta['dims'][name]).union([value]))
                else:
                    meta['dims'][name] = [ value ]
            otherdims = sorted(self.hdr['otherDims'])

            # pack metadata into struct
            meta['descr'] = self.hdr['descr']
            meta['default'] = self.hdr['default']
            metaKey = 'default' if len(self.hdr['otherDims'])==0 else '|'.join( map(operator.itemgetter(1), otherdims) )
            meta['sources'][metaKey] = {'url': self.hdr['url'],
                                        'license': self.hdr['license'], 
                                        'source': self.hdr['source'], 
                                        'publishDate': self.hdr['publishDate']}
            if (len(self.hdr['units'])==1):
                meta['units']['default'] = self.hdr['units'][0]
            else:
                meta['units'].update(dict(zip([ _tokey(x) for x in self.hdr['cols'] ], self.hdr['units'])))

            # store metadata as json string
            meta_str = json.dumps(meta)
            self.db.set(self.name, meta_str)

            # add the data to the db
            dims = {self.hdr['rowLabel']: '', self.hdr['colLabel']: ''}
            dims.update(otherdims)

            for rh,rd in zip(self.hdr['rows'],self.data):
                dims[self.hdr['rowLabel']] = rh
                for ch,cd in zip(self.hdr['cols'],rd):
                    dims[self.hdr['colLabel']] = ch
                    key = _tokey(self.name+'|'+'|'.join( map(operator.itemgetter(1), sorted(dims.items())) ))
                    self.db.set(key, _getnumber(cd))

            # add dataset name
            self.db.sadd('datasets', self.hdr['name'])

            # add lookup data
            self.db.select(self.search_db_num)
            self.db.sadd(_tokey(self.hdr['name']), '_')
            for ss in self._get_search_terms(meta['dims']):
                self.db.sadd(_tokey(self.hdr['name']+'|'+ss), self.hdr['name'])
                
        except Exception, ex:
            print 'FAIL: ' + str(ex)
            print traceback.print_exc()
            print 'import failed, cleaning up'
            self._remove()

    def _postprocess(self):
        # make sure all dimensions have total columns
        # unless they have cols with differing units or hierarchies
        self.db.select(self.data_db_num)
        updatetotals.updateTotals(self.db, self.name)
                

    def removeTable(self):
        # import a new table into the db
        self._openfile()
        self._readheader()
        self.fin.close()
        self._remove()

    def importFile(self):
        # import a table into the db.  if its already there, remove it first
        self._openfile()
        self._readheader()
        if len(self.hdr['otherDims'])==0:
            self._remove()
        self._importdata()
        self._postprocess()
        self.fin.close()

def help():
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
        help()
        sys.exit(0)

    imp = False
    rem = False
    dbnum = 0

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
                dbnum = int(sys.argv[ii])
            ii+=1

        if imp:
            Importer(fname, dbnum).importFile()
        elif rem:
            Importer(fname, dbnum).removeTable()
        else: # import from stdin
            Importer(None, dbnum).importFile()

    except Exception,ex:
        print 'FAIL: ' + str(ex)
        print traceback.print_exc()
