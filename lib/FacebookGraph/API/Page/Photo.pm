package FacebookGraph::API::Page::Photo;
use strict;
use warnings;
use base qw/FacebookGraph::API::Page/;
use FacebookGraph::API::Page::Album;

sub end_point { 'https://graph.facebook.com/%s/photos/' }

sub all_photo {
    my $self = shift;
    my $fb_album = FacebookGraph::API::Page::Album->new({
        page_id => $self->page_id,
    });
    my @albums = $fb_album->all_album;

    my @photos; 

    for my $album (@albums) {
        push @photos, $self->photo($album);
    }
    return unless @photos;

    my @sorted_photos = $self->sort_order eq 'asc'
        ? sort { $a->{created_time} <=> $b->{created_time} } @photos
        : sort { $b->{created_time} <=> $a->{created_time} } @photos;

    return $self->limit ? @sorted_photos[ 0 .. $self->limit -1 ] : @sorted_photos;
}

sub photo {
    my ($self, $album) = @_;

    unless (ref $album eq 'HASH') {
        my $fb = FacebookGraph::API::Page::Album->new({
            album_id => $album,
        });
        $album = $fb->album;
    }

    my $url = sprintf $self->end_point, $album->{id};
    my $data = $self->parse($url);

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
    my @photos;

    for my $photo ( @{ $data->{data} } ) {
        my %format_photo = map { $_ => $photo->{$_} } qw/id link name/;
        $format_photo{album_name} = $album->{'name'};
        $format_photo{album_link} = $album->{'link'};
        $format_photo{album_description} = $album->{'description'};
        $format_photo{720} = $photo->{images}->[0]->{source};
        $format_photo{180} = $photo->{images}->[1]->{source};
        $format_photo{130} = $photo->{images}->[2]->{source};
        $format_photo{75}  = $photo->{images}->[3]->{source};
        $format_photo{created_time} = $self->format_date( $photo->{created_time} );

        push @photos, \%format_photo; 
    }

    return @photos;
}

1;
__END__
