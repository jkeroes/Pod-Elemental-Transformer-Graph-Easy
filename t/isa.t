use strict;
use warnings;

use Test::More;

use Pod::Elemental;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Graph::Easy;

my $str = do { local $/; <DATA> };

my $doc = Pod::Elemental->read_string($str);

Pod::Elemental::Transformer::Pod5->new->transform_node($doc);
Pod::Elemental::Transformer::Graph::Easy->new->transform_node($doc);

my @classes = (
    'Pod::Elemental::Element::Pod5::Command',
    'Pod::Elemental::Element::Pod5::Ordinary',
    'Pod::Elemental::Element::Generic::Text',
    'Pod::Elemental::Element::Pod5::Ordinary',
    'Pod::Elemental::Element::Generic::Text',
    'Pod::Elemental::Element::Generic::Text',
    'Pod::Elemental::Element::Pod5::Ordinary',
);

for my $i (0 .. $#{ $doc->children }) {
    my $expected_class = $classes[$i];
    isa_ok(
        $doc->children->[$i],
        $expected_class,
        "${i}th elem",
    );
}

done_testing;

__DATA__
=pod

=head1 I am the great POD.

I consume vast quantities.

=for grapheasy
( Boots. Cats. Boots. Cats.:
  [boots] --> [Abyssinians]
  [boots] --> [Bengals]
)

Untz. Untz. Untz. Untz.

=begin grapheasy

( Bees! Bees! Bees!:
  [bumble]    <- buzz -> [carpenter]
  [carpenter] <- buzz -> [honey]
  [honey]     <- buzz -> [bumble]
)

=end grapheasy

=for grapheasy
  [and now] --> [for something]
  [completely] --> [different]

Here end my thoughts.
