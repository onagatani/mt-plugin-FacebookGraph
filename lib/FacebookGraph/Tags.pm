package FacebookGraph::Tags;
use strict;
use warnings;
use FacebookGraph::API::Page::Photo;
use FacebookGraph::API::Page::Wall;
use MT::Util qw/format_ts/;

sub ft_page_photo {
    my ($ctx, $args) = @_;
    my $key = $args->{key} or return;
    my $fb_photo = $ctx->stash('fb_photo') or return;

    if (defined $args->{format} && $key eq 'created_time'){
        return format_ts($args->{format}, $fb_photo->{$key});
    }

    return $fb_photo->{$key};
}

sub bt_page_photos {
    my ($ctx, $args, $cond) = @_; 

    my $blog = $ctx->stash('blog') or return;

    my $plugin = MT->component('FacebookGraph') or return;

    my $page_id = $args->{page_id} || $plugin->get_config_value('page_id', 'blog:'. $blog->id) || undef;

    my $fb = FacebookGraph::API::Page::Photo->new({
        page_id    => $page_id,
        limit      => $args->{limit} || undef,
        sort_order => $args->{sort_order} || undef,
    });
    my @photos = $args->{album_id} ? $fb->photo($args->{album_id}) : $fb->all_photo;

    return $ctx->_hdlr_pass_tokens_else($args, $cond) unless @photos;

    my $res  = ''; 
    my $i    = 0;
    my $vars = $ctx->{__stash}{vars} ||= {}; 

    for my $photo (@photos) {
        local $vars->{__first__}                = !$i;
        local $vars->{__last__}                 = !defined $photos[ $i + 1 ];
        local $vars->{__odd__}                  = ( $i % 2 ) == 0; # 0-based $i
        local $vars->{__even__}                 = ( $i % 2 ) == 1;
        local $vars->{__counter__}              = $i + 1;
        local $ctx->{__stash}{fb_photo}         = $photo;

        my $tok = $ctx->stash('tokens');
        my $builder = $ctx->stash('builder');

        my $out = $builder->build( $ctx, $tok, {
            %$cond,
            FBGPagePhotosHeader => $vars->{__first__},
            FBGPagePhotosFooter => $vars->{__last__},
        });
        return $ctx->error( $builder->errstr ) unless defined $out;
        $res .= $out;
        $i++;
    }
    return $res;
}

sub bt_page_photos_header {
    shift->slurp(@_);
}

sub bt_page_photos_footer {
    shift->slurp(@_);
}

sub ft_page_wall {
    my ($ctx, $args) = @_;
    my $key = $args->{key} or return;
    my $fb_wall = $ctx->stash('fb_wall') or return;

    if (defined $args->{format} && $key eq 'published'){
        return format_ts($args->{format}, $fb_wall->{$key});
    }
    return $fb_wall->{$key};
}

sub bt_page_walls {
    my ($ctx, $args, $cond) = @_; 

    my $blog = $ctx->stash('blog') or return;

    my $plugin = MT->component('FacebookGraph') or return;

    my $page_id = $args->{page_id} || $plugin->get_config_value('page_id', 'blog:'. $blog->id) or return;

    my $fb = FacebookGraph::API::Page::Wall->new({
        page_id    => $page_id,
        limit      => $args->{limit} || undef,
        sort_order => $args->{sort_order} || undef,
    });
    my @wall = $fb->wall;

    return $ctx->_hdlr_pass_tokens_else($args, $cond) unless @wall;

    my $res  = ''; 
    my $i    = 0;
    my $vars = $ctx->{__stash}{vars} ||= {};

    for my $wall (@wall) {
        local $vars->{__first__}                = !$i;
        local $vars->{__last__}                 = !defined $wall[ $i + 1 ];
        local $vars->{__odd__}                  = ( $i % 2 ) == 0; # 0-based $i
        local $vars->{__even__}                 = ( $i % 2 ) == 1;
        local $vars->{__counter__}              = $i + 1;
        local $ctx->{__stash}{fb_wall}          = $wall;

        my $tok = $ctx->stash('tokens');
        my $builder = $ctx->stash('builder');

        my $out = $builder->build( $ctx, $tok, {
            %$cond,
            FBGPageWallsHeader => $vars->{__first__},
            FBGPageWallsFooter => $vars->{__last__},
        });
        return $ctx->error( $builder->errstr ) unless defined $out;
        $res .= $out;
        $i++;
    }
    return $res;
}

sub bt_page_walls_header {
    shift->slurp(@_);
}

sub bt_page_walls_footer {
    shift->slurp(@_);
}

1;
__END__
