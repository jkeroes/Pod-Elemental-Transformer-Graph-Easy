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

note $doc->children->[2]->content;
like $doc->children->[2]->content, qr{Boots. Cats. Boots. Cats.:}m, "found cats' group title";
like $doc->children->[2]->content, qr{boots}m, "found cats' node 1";
like $doc->children->[2]->content, qr{Abyssinians}m, "found cats' node 2";
like $doc->children->[2]->content, qr{Bengals}m, "found cats' node 3";
like $doc->children->[2]->content, qr{--+>}m, "found cats' edge";
like $doc->children->[2]->content, qr{\+---+\+}m, "found cats' node wall";

note $doc->children->[4]->content;
like $doc->children->[4]->content, qr{Bees! Bees! Bees!:}m, "found bees' group title";
like $doc->children->[4]->content, qr{bumble}m, "found bees' node 1";
like $doc->children->[4]->content, qr{carpenter}m, "found bees' node 2";
like $doc->children->[4]->content, qr{honey}m, "found bees' node 3";
like $doc->children->[4]->content, qr{\+---+\+}m, "found bees' node wall";
like $doc->children->[4]->content, qr{<--+>}m, "found bees' edge";
like $doc->children->[4]->content, qr{buzz}m, "found bees' edge label";

note $doc->children->[5]->content;
like $doc->children->[5]->content, qr{and now}m, "found Pythons' node 1";
like $doc->children->[5]->content, qr{for something}m, "found Pythons' node 2";
like $doc->children->[5]->content, qr{completely}m, "found Pythons' node 3";
like $doc->children->[5]->content, qr{different}m, "found Pythons' node wall";
like $doc->children->[5]->content, qr{--+>}m, "found Pythons' edge";
like $doc->children->[5]->content, qr{\+---+\+}m, "found Pythons' node wall";

note $doc->as_pod_string;

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
