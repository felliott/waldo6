package WebAPI::DBIC::Resource::Role::Item;

use Moo::Role;

requires 'render_item_as_plain';
requires 'render_item_as_hal';
requires 'encode_json';
requires 'decode_json';

has item => (
   is => 'ro',
   required => 1,
);

has writable => (
   is => 'ro',
);

sub content_types_provided { [
    {'application/hal+json' => 'to_json_as_hal'},
    {'application/json' => 'to_json_as_plain'},
] }
sub content_types_accepted { [ {'application/json' => 'from_json'} ] }

sub to_json_as_plain { $_[0]->encode_json($_[0]->render_item_as_plain($_[0]->item)) }
sub to_json_as_hal {   $_[0]->encode_json($_[0]->render_item_as_hal($_[0]->item)) }

sub from_json {
   $_[0]->update_resource(
      $_[0]->decode_json(
         $_[0]->request->content
      )
   )
}

sub resource_exists { !! $_[0]->item }

sub allowed_methods {
   [
      qw(GET HEAD),
      ( $_[0]->writable || 1 ) ? (qw(PUT DELETE)) : ()
   ]
}

sub delete_resource { $_[0]->item->delete }

sub update_resource { $_[0]->item->update($_[1]) }

1;
