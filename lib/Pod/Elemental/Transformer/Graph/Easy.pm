package Pod::Elemental::Transformer::Graph::Easy;

use strict;
use warnings;

use Moose;
with 'Pod::Elemental::Transformer';

use namespace::autoclean;
use Moose::Autobox;
use Moose::Util::TypeConstraints;
use Pod::Elemental::Types qw(FormatName);
use Graph::Easy::Parser;

has format_name => (
    is      => 'ro',
    isa     => FormatName,
    default => 'grapheasy',
);

has parser => (
    is      => 'ro',
    isa     => duck_type( qw/from_text/ ),
    default => sub { Graph::Easy::Parser->new },
);

sub transform_node {
    my ($self, $node) = @_;
    my $children = $node->children;

    foreach (@{ $children }) {
        next unless  $_->isa('Pod::Elemental::Element::Pod5::Region')
            and    ! $_->is_pod
            and      $_->format_name eq $self->format_name;

        confess "grapheasy transformer expects grapheasy region to contain 1 Data para"
            unless $_->children->length == 1
            and    $_->children->[0]->isa('Pod::Elemental::Element::Pod5::Data');

        my $graph_in = $_->children->[0]->content;
        $_           = $self->convert_to_ascii($graph_in);
    }

    return $node;
}

sub convert_to_ascii {
    my ($self, $text) = @_;

    my $graph = $self->parser->from_text($text)->as_ascii;
    $graph =~ s/^/  /mg;  # indent
    $graph =~ s/\Z/\n/ms; # make paragraph

    return Pod::Elemental::Element::Generic::Text->new({
        content => $graph,
    });
}

1;
