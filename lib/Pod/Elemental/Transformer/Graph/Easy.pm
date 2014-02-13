package Pod::Elemental::Transformer::Graph::Easy;
# ABSTRACT: graphs in your docs

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
    isa     => duck_type( [qw/from_text/] ),
    default => sub { Graph::Easy::Parser->new },
);

sub transform_node {
    my ($self, $node) = @_;
    my $children = $node->children;

    foreach (@{ $children }) {
        next unless  $_->isa('Pod::Elemental::Element::Pod5::Region')
            and    ! $_->is_pod
            and      $_->format_name eq $self->format_name;

        confess "grapheasy transformer expects grapheasy region to contain 1 Data paragraph"
            unless $_->children->length == 1
            and    $_->children->[0]->isa('Pod::Elemental::Element::Pod5::Data');

        my $graph_in = $_->children->[0]->content;
        $_           = $self->convert_to_ascii($graph_in);
    }

    return $node;
}

sub convert_to_ascii {
    my ($self, $graph_in) = @_;

    my $graph_out = $self->parser->from_text($graph_in)->as_ascii;
    $graph_out =~ s/^/  /mg;  # indent
    $graph_out =~ s/\Z/\n/ms; # make paragraph

    return Pod::Elemental::Element::Generic::Text->new({
        content => $graph_out,
    });
}

1;

=head1 SYNOPSIS

    use Pod::Elemental;
    use Pod::Elemental::Transformer::Pod5;
    use Pod::Elemental::Transformer::Graph::Easy;

    my $pod = <<END;
    =head1 Play that funky music

    =for grapheasy
    ( Boots. Cats. Boots. Cats.:
      [boots] --> [Abyssinians]
      [boots] --> [Bengals]
    )

    =begin grapheasy

    ( Bees! Bees! Bees!:
      [bumble]    <- buzz -> [carpenter]
      [carpenter] <- buzz -> [honey]
      [honey]     <- buzz -> [bumble]
    )

    =end grapheasy
    END

    my $doc = Pod::Elemental->read_string($pod);
    Pod::Elemental::Transformer::Pod5->new->transform_node($doc);
    Pod::Elemental::Transformer::Graph::Easy->new->transform_node($doc);
    print $doc->as_pod_string;

=head1 DESCRIPTION

Processes C<grapheasy> POD regions with L<Graph::Easy> to generate ASCII graphs.
All Graph::Easy directives may be used.

The L<SYNOPSIS> generates this:

    =pod

    =head1 Play that funky music

      + - - - - - - - - - - - - - - - - - - - - - - - - - -+
      ' Boots. Cats. Boots. Cats.:                         '
      '                                                    '
      ' +--------------------------+       +-------------+ '
      ' |          boots           | ----> | Abyssinians | '
      ' +--------------------------+       +-------------+ '
      '   |                                                '
      '   |                           - - - - - - - - - - -+
      '   |                          '
      '   |                          '
      '   v                          '
      ' +--------------------------+ '
      ' |         Bengals          | '
      ' +--------------------------+ '
      '                              '
      + - - - - - - - - - - - - - - -+

      + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
      ' Bees! Bees! Bees!:                                             '
      '                                                                '
      '                      buzz                                      '
      '   +----------------------------------------------------+       '
      '   v                                                    v       '
      ' +------------------+  buzz    +-----------+  buzz    +-------+ '
      ' |      bumble      | <------> | carpenter | <------> | honey | '
      ' +------------------+          +-----------+          +-------+ '
      '                                                                '
      + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+

    =cut

=attr format_name [default: grapheasy]

In POD, this is the token after C<=begin>, C<=end>, and C<=for>.

=attr parser [default: a Graph::Easy::Parser instance]

Handles the graph conversion.

=method transform_node

Given a POD node, walks the tree of children looking for grapheasy nodes, and converts them.

=method convert_to_ascii

Given input text for graph-easy, returns its ASCII representation.

=head1 SEE ALSO

L<Graph::Easy>
L<Pod::Weaver>
