package MyApp::TraitFor::Controller::SimpleCRUD;

use Moose::Role;

# keep in order!!
with 'MyApp::TraitFor::Controller::AutoBase';      # 1
with 'MyApp::TraitFor::Controller::AutoObject';    # 2
with 'MyApp::TraitFor::Controller::AutoResult';    # 3

with 'MyApp::TraitFor::Controller::CheckRoleForPUT';
with 'MyApp::TraitFor::Controller::CheckRoleForPOST';

with 'MyApp::TraitFor::Controller::AutoList';      # 1
with 'MyApp::TraitFor::Controller::Search';        # 2

1;

