
import tardis.tardis_portal.models.parameters as tardis_parameters
import tardis.tardis_portal.models.storage as tardis_storage
import tardis.tardis_portal.tasks as tasks
from tardis.tardis_portal.models.storage import StorageBox
from tardis.tardis_portal.models.storage import StorageBoxOption
from tardis.tardis_portal.models.storage import StorageBoxAttribute
from tardis.tardis_portal.models.datafile import DataFileObject
from tardis.tardis_portal.models.datafile import DataFile
import os
import re
from tardis.celery import tardis_app
from django.db import transaction
import shutil
import logging

logger = logging.getLogger(__name__)


def _get_default_storage_box(self):
    return StorageBox.get_default_storage()
DataFile.get_default_storage_box = _get_default_storage_box


def copy_file(dfo, dest_box=None, verify=True):
    if dest_box.name == 'store':
        uri = os.path.join(dfo.datafile.dataset.description + '-' + str(dfo.datafile.dataset.id), dfo.datafile.filename.strip())
    else:
        uri = os.path.join(dfo.datafile.dataset.description, dfo.datafile.filename.strip())
        if dfo.datafile.dataset.directory:
            uri = os.path.join(dfo.datafile.dataset.directory, uri)
    if not dfo.verified:
        logger.debug('DFO (id: %d) could not be copied.'
                        ' Source not verified' % dfo.id)
        return False
    print(dfo.storage_box.name + ':' + dfo.uri + ' -> ' + dest_box.name + ':' + uri)

    if dest_box is None:
        dest_box = StorageBox.get_default_storage()
    existing = dfo.datafile.file_objects.filter(storage_box=dest_box, uri=uri)
    if existing.count() > 0:
        if not existing[0].verified and verify:
            shadow = 'dfo_verify location:%s' % existing[0].storage_box.name
            tasks.dfo_verify.apply_async(
                args=[existing[0].id],
                priority=existing[0].priority,
                shadow=shadow)
        return existing[0]
    try:
        with transaction.atomic():
            copy = DataFileObject(
                datafile=dfo.datafile,
                storage_box=dest_box)
            copy.uri = uri
            copy.save()
            copy.file_object = dfo.file_object
    except Exception as e:
        print(
            'file copy failed for dfo id: %s, with error: %s' %
            (dfo.id, str(e)))
        return False
    if verify:
        shadow = 'dfo_verify location:%s' % copy.storage_box.name
        tasks.dfo_verify.apply_async(
            args=[copy.id],
            priority=copy.priority,
            shadow=shadow)
    return copy

def move_file(dfo, dest_box=None):
    copy = copy_file(dfo, dest_box=dest_box, verify=False)
    if copy and copy.id != dfo.id and (copy.verified or copy.verify()):
        dfo.delete()
    return copy

def safe_name(name):
    """Replaces unsafe filename characters with underscore
    Windows: <>:"/\|?*
    Linux: blanks
    """
    name = re.sub(r'[ =?()<>:^/"|*\\ ]', '_', str(name))
    return name



@tardis_app.task(name="move_to_uqrdm", ignore_result=True)
def move_to_uqrdm():
    rdm_schema = tardis_parameters.Schema.objects.filter(namespace='https://cai.imaging.org.au/schemas/experiment/uqrdm')[0]
    pn = tardis_parameters.ParameterName.objects.filter(name='UQRDM')[0]
    for ep in tardis_parameters.ExperimentParameter.objects.filter(name=pn):
        for df in ep.parameterset.experiment.get_datafiles().all():
            dfo = df.get_preferred_dfo()
            rdmname=safe_name(ep.string_value)
            rdmpath = os.path.join('/data',rdmname)
            if dfo and dfo.verified and dfo.storage_box.name != rdmname:
                if os.path.ismount(rdmpath):
                    dest_boxes = tardis_storage.StorageBox.objects.filter(name=rdmname)
                    if dest_boxes.count() == 0:
                        sb = StorageBox(name=rdmname,max_size=1000000000000,status='online')
                        sb.save() 
                        sbo = StorageBoxOption(storage_box=sb,key='location',value=os.path.join('/data',rdmname))
                        sbo.save()
                        sba = StorageBoxAttribute(storage_box=sb,key='can_delete',value=False)
                        sba.save()
                    dest_box = tardis_storage.StorageBox.objects.filter(name=rdmname)[0]
                    copy = move_file(dfo, dest_box)
                    # break


def fix_file_locations():
    rdm_schema = tardis_parameters.Schema.objects.filter(namespace='https://cai.imaging.org.au/schemas/experiment/uqrdm')[0]
    pn = tardis_parameters.ParameterName.objects.filter(name='UQRDM')[0]


    for ep in tardis_parameters.ExperimentParameter.objects.filter(name=pn):
        for df in ep.parameterset.experiment.get_datafiles().all():
            dfo = df.get_preferred_dfo()
            rdmname=safe_name(ep.string_value)
            rdmpath = os.path.join('/data',rdmname)
            if dfo and dfo.verified and rdmname == 'store':
                uri = os.path.join(dfo.datafile.dataset.description + '-' + str(dfo.datafile.dataset.id), dfo.datafile.filename.strip())
                if dfo.uri != uri:
                    oldfile = os.path.join('/store', dfo.uri)
                    newfile = os.path.join('/store', uri)
                    print(oldfile + ' -> ' + newfile)
                    shutil.move(oldfile, newfile)
                    dfo.uri = uri
                    dfo.save()

# fix_file_locations()








# def checksum(hasher, infile, blocksize=65536):
#     """Calculates checksum using supported hashing function
#     :param hasher: md5 & sha512 supported
#     :param infile: input file to be checksummed
#     :param blocksize: defaults to 65536
#     :return: hash as string
#     """
#     hashers = {'md5': hashlib.md5(), 'sha512': hashlib.sha512()}
#     with open(str(infile), 'rb') as datafile:
#         buf = datafile.read(blocksize)
#         while len(buf) > 0:
#             hashers[hasher].update(buf)
#             buf = datafile.read(blocksize)
#         return hashers[hasher].hexdigest()


# if __name__ == "__main__":
#     run()

# df = tardis_datafile.DataFile.objects.all()[0]
# dfo = df.get_preferred_dfo()
# dest_box = tardis_storage.StorageBox.objects.all()[0]
# old_box = tardis_storage.StorageBox.objects.all()[1]
# copy = DataFileObject(datafile=df, storage_box=dest_box)
# copy.uri = u'DS001/DICOM/0001_localizer.zip'
# copy.save()
# copy.file_object = dfo.file_object

# for mydatafile in tardis_datafile.DataFile.objects.all():
#     for myexperiment in mydatafile.dataset.experiments.all():
#         for myexperimentset in  myexperiment.getParameterSets():
#             for myexperimentparam in  myexperimentset.experimentparameter_set.all():
#                 if myexperimentparam.name.name == 'UQRDM':
#                     rdmname = myexperimentparam.string_value
#                     newpath = os.path.join('/data',rdmname)
#                     if os.path.ismount(newpath):
#                         newstorageboxname = 'local box at ' + newpath
#                         dest_boxes = tardis_storage.StorageBox.objects.filter(name=newstorageboxname)
#                         if dest_boxes.count() == 0:
#                             tardis_storage.StorageBox.create_local_box(newpath)
#                         dest_box = tardis_storage.StorageBox.objects.filter(name=newstorageboxname)[0]

#                         copy = move_file(mydatafile.get_preferred_dfo(), dest_box)


