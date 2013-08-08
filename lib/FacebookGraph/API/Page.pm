package FacebookGraph::API::Page;
use strict;
use warnings;
use Carp qw(croak);
use LWP::UserAgent;
use JSON;
use Class::Accessor::Lite (
    new => 0,
    rw  => [ qw(page_id album_id ua sort_order limit ) ],
);

sub end_point { 'https://graph.facebook.com/%s' }

sub new {
    my ($class, $opt) = @_;
    my $self = bless $opt, $class;
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->agent('MTCMS FacebookGraph plugin/' . $MT::Plugin::FacebookGraph::VERSION . '(http://mtcms.jp)');
    $self->ua($ua);
}

sub get {
    my ($self, $url) = @_;
    my $res = $self->ua->get($url);
    if ($res->is_success) {
        return $res->content;
    } else {
        croak($res->status_line);
    } 
}

sub parse {
    my ($self, $url) = @_;
    $url ||= sprintf $self->end_point, $self->page_id;
    my $content = $self->get($url);
    return decode_json( $content );
}

sub format_date {
    my ($self, $date) = @_;
    return unless $date;
    $date =~ s{[\-T\:]}{}img; 
    $date =~ s{^(.*?)\+.*?$}{$1};
    return $date;
}

1;
__END__

=head1 NAME

FacebookGraph::API::Page 

=head1 SYNOPSIS

=cut
