package FacebookGraph::API::Page::Wall;
use strict;
use warnings;
use base qw/FacebookGraph::API::Page/;

sub end_point { 'http://www.facebook.com/feeds/page.php?id=%s&format=json' }

sub wall {
    my $self = shift;
    my $wall = $self->parse;
    
    my @entries;

    for my $entry ( @{ $wall->{entries} } ) {

        my %normalize_entry = map { $_ => $entry->{$_} } qw/title id alternate likes content/;
        $normalize_entry{published} = $self->format_date( $entry->{published} );
        $normalize_entry{name} = $entry->{author}->{name};

        push @entries, \%normalize_entry;
    }

    return $self->limit ? @entries[ 0 .. $self->limit -1 ] : @entries;
}


1;
__END__
