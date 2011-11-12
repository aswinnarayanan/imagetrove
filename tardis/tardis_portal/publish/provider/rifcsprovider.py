import re
from django.template import Context
from django.conf import settings

class RifCsProvider(object):
    
    def get_rifcs_context(self, experiment):
        c = Context({})
        c['experiment'] = experiment
        c['description'] = experiment.description
        return c
    
    def get_template(self, experiment):
        return settings.RIFCS_TEMPLATE_DIR + "default.xml"
    
    def can_publish(self, experiment):
        return experiment.public
    
    def _is_html_formatted(self, text):
        if re.search(r'<.*?>',text):
            return True
        return False
