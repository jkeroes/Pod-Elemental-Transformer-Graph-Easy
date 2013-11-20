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

    PASS: for (my $i = 0; $i < $children->length; $i++) {
        my $para = $children->[$i];

        next unless $para->isa('Pod::Elemental::Element::Pod5::Region')
            and    ! $para->is_pod
            and    $para->format_name eq $self->format_name;

        confess "grapheasy transformer expects grapheasy region to contain 1 Data para"
            unless $para->children->length == 1
            and    $para->children->[0]->isa('Pod::Elemental::Element::Pod5::Data');

        my $text        = $para->children->[0]->content;
        my $new_pod     = $self->convert_to_ascii($text);
        $children->[$i] = $new_pod;
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
