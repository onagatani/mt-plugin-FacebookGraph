package FacebookGraph::API::Page::Album;
use strict;
use warnings;
use base qw/FacebookGraph::API::Page/;

sub end_point { 'https://graph.facebook.com/%s/albums/' }

sub all_album {
    my $self = shift;

    my $data = $self->parse;

    if (my $next_url = $data->{paging}->{'next'} ) {
        while (1) {    
            my $tmp = $self->parse($next_url);
            if (scalar @{$tmp->{data}}) {
                push @{$data->{data}}, @{$tmp->{data}};
                $next_url = $tmp->{paging}->{'next'} or last;
            }
            else {
                last;
            }
        }
    }

    my @albums;
    my $count;
    for my $album ( @{ $data->{data} } ) {
        last if $self->limit && $count >= $self->limit; 

        my %normalize_album = map { $_ => $album->{$_} } qw/id name description link /;
        $normalize_album{created_time} = $self->format_date($album->{created_time});

        push @albums, \%normalize_album;
        $count++;
    }
    
    return @albums;
}

sub album {
    my $self = shift;
    
    my $url = sprintf $self->SUPER::end_point, $self->album_id; 
    my $data = $self->parse($url);
    my %album = map { $_ => $data->{$_} } qw/id name description link /;
    $album{created_time} = $self->format_date($data->{created_time});

    return \%album;
}

1;
__END__
