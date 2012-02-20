from tardis.apps.sync.fields import State, transition_on_success, FSMField
from transfer_service import TransferService, TransferClient


class FailPermanent(State):
    
    def get_next_state(self, experiment):
        return self

    def is_final_state(self):
        return True


class Complete(State):

    def get_next_state(self, experiment):
        return self

    def is_final_state(self):
        return True


class CheckingIntegrity(State):

    @transition_on_success(Complete)
    def _wait(self, experiment):
        return True

    def get_next_state(self, experiment):
        return self._wait(experiment)


class InProgress(State):

    # TODO: The return true bit is misleading
    @transition_on_success(CheckingIntegrity)
    def _complete(self, experiment):
        return True

    def get_next_state(self, experiment):
        return self._complete(experiment)


class Requested(State):

    def _check_transfer_started(self, experiment):
        status_dict = TransferClient().get_status(experiment)
        return status_dict['status'] == TransferService.TRANSFER_IN_PROGRESS

    @transition_on_success(InProgress)
    def _wait(self, experiment):
        return True

    def get_next_state(self, experiment):
        started = self._check_transfer_started(experiment)
        if started:
           return self._wait(experiment)
        return self


class Ingesting(State):

    def _ingestion_complete(self, experiment):
        return True

    @transition_on_success(Requested)
    def _request_files(self, exp):
        return TransferClient().request_file_transfer(exp)

    def get_next_state(self, experiment):
        if self._ingestion_complete(experiment):
            return self._request_files(experiment)
        return self


class ConsumerFSMField(FSMField):

    # TODO dynamically generate this list using metaclass
    states = {
    'Ingesting' : Ingesting, 
    'Requested' : Requested, 
    'InProgress' : InProgress, 
    'Complete' : Complete, 
    'CheckingIntegrity' : CheckingIntegrity, 
    'FailPermanent' : FailPermanent, 
    }

