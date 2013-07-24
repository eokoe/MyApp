package MyApp::TraitFor::Controller::DefaultCRUD;

use Moose::Role;

with 'MyApp::TraitFor::Controller::Search';
with 'MyApp::TraitFor::Controller::AutoBase';
with 'MyApp::TraitFor::Controller::AutoObject';
with 'MyApp::TraitFor::Controller::CheckRoleForPUT';
with 'MyApp::TraitFor::Controller::CheckRoleForPOST';

1;

