package MT::Plugin::FacebookGraph;
use strict;
use warnings;
use base qw( MT::Plugin );
use Readonly;
use FacebookGraph::Tags;
use Class::Inspector;
use String::CamelCase qw(camelize);
use utf8;

Readonly my $TAG_TYPE => +{
    co_ => 'block',
    ft_ => 'function',
    bt_ => 'block',
    mo_ => 'modifier',
};

our $PLUGIN_NAME = 'FacebookGraph';
our $VERSION = '0.1';

my $plugin = __PACKAGE__->new({
    name           => $PLUGIN_NAME,
    version        => $VERSION,
    key            => lc $PLUGIN_NAME,
    id             => lc $PLUGIN_NAME,
    author_name    => 'onagatani',
    author_link    => 'https://www.facebook.com/onagatani',
    description    => 'Facebook Graph API',
    l10n_class     => $PLUGIN_NAME. '::L10N',
    settings => MT::PluginSettings->new([
        ['page_id', +{
            Default => undef,
            Scope   => 'blog'
        }],
    ]),
    blog_config_template => \&_blog_config_template,
});

MT->add_plugin( $plugin );

sub init_registry {
    my $plugin = shift;

    my $subs = Class::Inspector->functions('FacebookGraph::Tags');

    my $tags;
    for my $subname (@$subs) {
        while(my($key, $value) = each %$TAG_TYPE){
            if($subname =~ m/^$key(.*?)$/){
                my $tag_name = camelize($1);
                $tag_name .= '?' if $key eq 'co_';
                $tags->{$value}->{'FBG' . $tag_name} = 'FacebookGraph::Tags::' . $subname;
            }
        }
    }
    $plugin->registry({
        tags => $tags, 
    });
}

sub _blog_config_template {
    return <<'__HTML__';
<mtapp:setting
    id="page_id"
    label="<__trans phrase="Facebook Page ID">">
<input type="text" name="page_id" value="<$mt:getvar name="page_id" escape="html"$>" />
</mtapp:setting>
__HTML__
}

1;
__END__

=head1 NAME

FacebookGraph

=head1 SYNOPSIS

<!--page_idとalbum_idがどちらも指定された場合はalbum_idが優先されます-->
<MTFBGPagePhotos page_id="skyarcsystem" album_id="160218764054405" limit="5" sort_order="desc">

<MTFBGPagePhotosHeader>
header<br />
</MTFBGPagePhotosHeader>

name:<$MTFBGPagePhoto key="name"$><$MTFBGPagePhoto key="created_time" format="%B %e, %Y %I:%M %p"$><br />
<img src="<$MTFBGPagePhoto key="720"$>">
<img src="<$MTFBGPagePhoto key="180"$>">
<img src="<$MTFBGPagePhoto key="130"$>">
<img src="<$MTFBGPagePhoto key="75"$>">

<MTFBGPagePhotosFooter>
footer<br />
</MTFBGPagePhotosFooter>

<MTElse>

FBページの写真を取得できませんでした。

</MTFBGPagePhotos>

<hr>

<!--wallのpage_idはゆーニークネームでは指定できません-->
<MTFBGPageWalls page_id="103237603085855" limit="5">

<MTFBGPageWallsHeader>
Wall header<br />
</MTFBGPageWallsHeader>

name:<$MTFBGPageWall key="name"$><$MTFBGPageWall key="published" format="%B %e, %Y %I:%M %p"$><br />
<a href="<$MTFBGPageWall key="alternate"$>">title:<$MTFBGPageWall key="title"$></a><br />
content:<$MTFBGPageWall key="content"$><br />

<MTFBGPageWallsFooter>
Wall footer<br />
</MTFBGPageWallsFooter>

<MTElse>

FBページのウォールを取得できませんでした。

</MTFBGPageWalls>

=cut
