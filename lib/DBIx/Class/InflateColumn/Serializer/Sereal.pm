use 5.006;    # our
use strict;
use warnings;

package DBIx::Class::InflateColumn::Serializer::Sereal;

our $VERSION = '0.001001';

# ABSTRACT: Sereal based Serialization for DBIx Class Columns

# AUTHORITY

use Sereal::Encoder qw( sereal_encode_with_object );
use Sereal::Decoder qw( sereal_decode_with_object );
use Carp qw( croak );

sub get_freezer {
  my ( undef, undef, $col_info, undef ) = @_;
  my $encoder = Sereal::Encoder->new();
  if ( defined $col_info->{'size'} ) {
    return sub {
      my $v = sereal_encode_with_object( $encoder, $_[0] );
      croak('Value Serialization is too big')
        if length($v) > $col_info->{'size'};
      return $v;
    };
  }
  return sub {
    return sereal_encode_with_object( $encoder, $_[0] );
  };
}

sub get_unfreezer {
  my $decoder = Sereal::Decoder->new();
  return sub {
    return sereal_decode_with_object( $decoder, $_[0] );
  };
}

1;

=head1 SYNOPSIS

Standard DBIx::Class definition:


  package Some::Result::Item;
  use parent 'DBIx::Class::Core';

  # Add Inflate::Column::Serializer to component loading.
  __PACKAGE__->load_components( 'InflateColumn::Serializer', 'Core' );
  __PACKAGE__->table('item');
  __PACKAGE__->add_column( itemid => { data_type => 'integer' }, );
  __PACKAGE__->set_primary_key('itemid');
  __PACKAGE__->add_column(
    data => {
      data_type        => 'text',
      size             => 1024,
      serializer_class => 'Sereal', # This line tells InflateColumn::Serializer what class to use.
    }
  );
  __PACKAGE__->source_name('Item');

=method get_freezer

This is an implementation detail for the C<InflateColumn::Serializer> module.

   my $freezer = ::Sereal->get_freezer( $column, $info, $column_args );
   my $string = $freezer->( $object );
   # $data isa string

=method get_unfreezer

This is an implementation detail for the C<InflateColumn::Serializer> module.

    my $unfreezer = ::Sereal>get_unfreezer( $column, $info, $args );
    my $object = $unfreezer->( $string );

=cut
