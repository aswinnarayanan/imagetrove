import logging

from django.contrib.auth.models import User
from elasticsearch_dsl import analysis, analyzer
from django_elasticsearch_dsl import Document, fields
from django_elasticsearch_dsl.registries import registry

from tardis.tardis_portal.models import Dataset, Experiment, \
    DataFile, Instrument, ObjectACL


logger = logging.getLogger(__name__)


trigram = analysis.tokenizer('trigram', 'nGram', min_gram=3, max_gram=3)

analyzer = analyzer(
    "analyzer",
    tokenizer=trigram,
    filter='lowercase',
)


@registry.register_document
class ExperimentDocument(Document):
    class Index:
        name = 'experiments'
        settings = {'number_of_shards': 1,
                    'number_of_replicas': 0}

    id = fields.IntegerField()
    title = fields.TextField(
        fields={'raw': fields.KeywordField()},
        analyzer=analyzer
    )
    description = fields.TextField(
        fields={'raw': fields.KeywordField()},
        analyzer=analyzer
    )
    public_access = fields.IntegerField()
    created_time = fields.DateField()
    start_time = fields.DateField()
    end_time = fields.DateField()
    update_time = fields.DateField()
    institution_name = fields.StringField()
    created_by = fields.ObjectField(properties={
        'username': fields.StringField(
            fields={'raw': fields.KeywordField()},
        )
    })
    objectacls = fields.ObjectField(properties={
        'pluginId': fields.StringField(),
        'entityId': fields.StringField()
    }
    )

    class Django:
        model = Experiment
        related_models = [User, ObjectACL]

    def get_instances_from_related(self, related_instance):
        if isinstance(related_instance, User):
            return related_instance.experiment_set.all()
        if isinstance(related_instance, ObjectACL):
            return related_instance.content_object
        return None


@registry.register_document
class DatasetDocument(Document):
    class Index:
        name = 'dataset'
        settings = {'number_of_shards': 1,
                    'number_of_replicas': 0}

    id = fields.IntegerField()
    description = fields.TextField(
        fields={'raw': fields.KeywordField()},
        analyzer=analyzer
    )
    experiments = fields.NestedField(properties={
        'id': fields.IntegerField(),
        'title': fields.TextField(
            fields={'raw': fields.KeywordField()
                    }
        ),
        'objectacls': fields.ObjectField(properties={
            'pluginId': fields.StringField(),
            'entityId': fields.StringField()
        }
        ),
        'public_access': fields.IntegerField()
    }
    )
    instrument = fields.ObjectField(properties={
        'id': fields.IntegerField(),
        'name': fields.TextField(
            fields={'raw': fields.KeywordField()},
        )
    }
    )
    created_time = fields.DateField()
    modified_time = fields.DateField()

    class Django:
        model = Dataset
        related_models = [Experiment, Instrument]

    def get_instances_from_related(self, related_instance):
        if isinstance(related_instance, Experiment):
            return related_instance.datasets.all()
        if isinstance(related_instance, Instrument):
            return related_instance.dataset_set.all()
        return None


@registry.register_document
class DataFileDocument(Document):
    class Index:
        name = 'datafile'
        settings = {'number_of_shards': 1,
                    'number_of_replicas': 0}
    filename = fields.TextField(
        fields={'raw': fields.KeywordField()},
        analyzer=analyzer
    )
    created_time = fields.DateField()
    modification_time = fields.DateField()
    dataset = fields.NestedField(properties={
        'id': fields.IntegerField(),
        'experiments': fields.NestedField(properties={
            'id': fields.IntegerField(),
            'objectacls': fields.ObjectField(properties={
                'pluginId': fields.StringField(),
                'entityId': fields.StringField()
            }
            ),
            'public_access': fields.IntegerField()
        }
        ),
    }
    )

    class Django:
        model = DataFile
        related_models = [Dataset, Experiment]
        queryset_pagination = 100000

    def get_instances_from_related(self, related_instance):
        if isinstance(related_instance, Dataset):
            return related_instance.datafile_set.all()
        if isinstance(related_instance, Experiment):
            return DataFile.objects.filter(dataset__experiments=related_instance)
        return None
