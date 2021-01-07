
import hashlib
import os

def checksum(hasher, infile, blocksize=65536):
    hashers = {'md5': hashlib.md5(), 'sha512': hashlib.sha512()}
    with open(str(infile), 'rb') as datafile:
        buf = datafile.read(blocksize)
        while len(buf) > 0:
            hashers[hasher].update(buf)
            buf = datafile.read(blocksize)
        return hashers[hasher].hexdigest()


from tardis.tardis_portal.models import Experiment
from tardis.tardis_portal.models import DataFileObject
from tardis.tardis_portal.models import DataFile
from tardis.tardis_portal.tasks import dfo_verify

store = '/store/'





# dfs = Experiment.objects.filter(id=1038)[0].get_datafiles()

# for df in dfs:
#     dfo = df.get_preferred_dfo()
#     dfo.verified = False
#     dfo.save()


dfos = DataFileObject.objects.filter(verified=False)
#for dfo in dfos:
#    dfo_verify(dfo.id)

for dfo in dfos:
    try:
        df = DataFile.objects.filter(id=dfo.datafile_id)[0]
        dfpath = store + dfo.uri
        print(dfpath)
        print(df.size)
        print(os.stat(dfpath).st_size)

        new_size = os.stat(dfpath).st_size
        df.size = new_size
        new_md5 = unicode(checksum('md5', dfpath), "utf-8")
        df.md5sum = new_md5
        new_sha512 = unicode(checksum('sha512', dfpath), "utf-8")
        df.sha512sum = new_sha512

        df.save()
        dfo_verify(dfo.id)
    except:
        pass

