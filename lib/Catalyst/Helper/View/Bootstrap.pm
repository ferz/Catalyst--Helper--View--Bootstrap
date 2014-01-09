package Catalyst::Helper::View::Bootstrap;

our $VERSION = '0.0005';
$VERSION = eval $VERSION;

use strict;
use File::Spec;
use Path::Class qw/dir file/;
use File::ShareDir qw/dist_dir/;

sub get_sharedir_file {
    my ($self, @filename) = @_;
    my $dist_dir;
    if (exists $ENV{CATALYST_DEVEL_SHAREDIR}) {
        $dist_dir = $ENV{CATALYST_DEVEL_SHAREDIR};
    }
    elsif (-d "inc/.author" && -f "lib/Catalyst/Helper/View/Bootstrap.pm"
            ) { # Can't use sharedir if we're in a checkout
                # this feels horrible, better ideas?
        $dist_dir = 'share';
    }
    else {
        $dist_dir = dist_dir('Catalyst-Helper-View-Bootstrap');
    }
    my $file = file( $dist_dir, @filename);
    Carp::confess("Cannot find $file") unless -r $file;
    my $contents = $file->slurp(iomode =>  "<:raw");
    return $contents;
}

sub mk_compclass {
    my ( $self, $helper, @args ) = @_;
    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
    $self->mk_templates( $helper, @args );
    $helper->{root} = dir( $helper->{base}, 'root' );
    $helper->mk_dir( $helper->{root} );
    $helper->{static} = dir( $helper->{root}, 'static' );
    $helper->mk_dir( $helper->{static} );
    $helper->{images} = dir( $helper->{static}, 'images' );
    $helper->mk_dir( $helper->{images} );
    $self->_mk_images($helper);
}

sub mk_templates {
    my ( $self, $helper ) = @_;
    my $base = $helper->{base},;
    my $ldir = File::Spec->catfile( $base, 'root', 'lib' );
    my $sdir = File::Spec->catfile( $base, 'root', 'src' );

    $helper->mk_dir($ldir);
    $helper->mk_dir($sdir);

    my $dir = File::Spec->catfile( $ldir, 'config' );
    $helper->mk_dir($dir);

    foreach my $file (qw( main url )) {
        $helper->render_file( "config_$file",
            File::Spec->catfile( $dir, $file ) );
    }

    $dir = File::Spec->catfile( $ldir, 'site' );
    $helper->mk_dir($dir);

    foreach my $file (qw( wrapper layout html header footer )) {
        $helper->render_file( "site_$file",
            File::Spec->catfile( $dir, $file ) );
    }

    foreach my $file (qw( welcome.tt2 message.tt2 error.tt2 ttsite.css )) {
        $helper->render_file( $file, File::Spec->catfile( $sdir, $file ) );
    }
}

sub _mk_images {
    my $self   = shift;
    my $helper = shift;
    my $images = $helper->{images};
    my @images =
      qw/catalyst_logo/;
    for my $name (@images) {
        my $image = $self->get_sharedir_file("root", "static", "images", "$name.png.bin");
	rename file( $images, "$name.png" ), file( $images, "$name.png" ).'.orig';
        $helper->mk_file( file( $images, "$name.png" ), $image );
    }
}


=head1 NAME

Catalyst::Helper::View::Bootstrap - Helper for Twitter Bootstrap and TT view which builds a skeleton web site

=head1 SYNOPSIS

# use the helper to create the view module and templates

    $ script/myapp_create.pl view HTML Bootstrap

# add something like the following to your main application module

    sub message : Global {
        my ( $self, $c ) = @_;
        $c->stash->{template} = 'message.tt2';
        $c->stash->{message}  ||= $c->req->param('message') || 'No message';
    }

    sub index : Path : Args(0) {
        my ( $self, $c ) = @_;
        $c->stash->{template} = 'welcome.tt2';
    }

    sub end : Private { # Or use Catalyst::Action::RenderView
        my ( $self, $c ) = @_;
        $c->forward( $c->view('HTML') );
    }

=head1 DESCRIPTION

This helper module creates a TT View module.  It goes further than
Catalyst::Helper::View::TT in that it additionally creates a simple
set of templates to get you started with your web site presentation
using Twitter Bootstrap3 from a CDN (Content Delivery Network).

It creates the templates in F<root/> directory underneath your
main project directory.  In here two further subdirectories are
created: F<root/src> which contains the main page templates, and F<root/lib>
containing a library of other template components (header, footer,
etc.) that the page templates use.

The view module that the helper creates is automatically configured
to locate these templates.

It sets character encoding to utf-8 and it delivers HTML5 pages.


=head2 Default Rendering

To render a template the following process is applied:

The configuration template F<root/lib/config/main> is rendered. This is
controlled by the C<PRE_PROCESS> configuration variable set in the controller
generated by Catalyst::Helper::View::Bootstrap. Additionally, templates referenced by
the C<PROCESS> directive will then be rendered.

Next, the template defined by the C<WRAPPER> config variable is called. The default
wrapper template is located in F<root/lib/site/wrapper>. The wrapper template
passes files with C<.css/.js/.txt> extensions through as text OR processes
the templates defined after the C<WRAPPER> directive: C<site/html> and C<site/layout>.

Based on the default value of the C<WRAPPER> directive in F<root/lib/site/wrapper>,
the following templates are processed in order:

=over 4

=item * F<root/src/your_template.tt2>

=item * F<root/lib/site/footer>

=item * F<root/lib/site/header>

=item * F<root/lib/site/sidemenu>

=item * F<root/lib/site/layout>

=item * F<root/lib/site/html>

=back

Finally, the rendered content is returned to the bowser.

=head1 METHODS

=head2 mk_compclass

Generates the component class.

=head2 mk_templates

Generates the templates.

=cut

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::View::TT>, L<Catalyst::Helper>,
L<Catalyst::Helper::View::TT>

=head1 AUTHOR

Ferruccio Zamuner <nonsolosoft@diff.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;

__DATA__

__compclass__
package [% class %];

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        [% app %]->path_to( 'root', 'src' ),
        [% app %]->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    render_die   => 1,
});

=head1 NAME

[% class %] - Catalyst TT Twitter Bootstrap View

=head1 SYNOPSIS

See L<[% app %]>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__config_main__
[% USE Date;
   year = Date.format(Date.now, '%Y');
-%]
[% TAGS star -%]
[% # config/main
   #
   # This is the main configuration template which is processed before
   # any other page, by virtue of it being defined as a PRE_PROCESS
   # template.  This is the place to define any extra template variables,
   # macros, load plugins, and perform any other template setup.

   IF Catalyst.debug;
     # define a debug() macro directed to Catalyst's log
     MACRO debug(message) CALL Catalyst.log.debug(message);
   END;

   # define a data structure to hold sitewide data
   site = {
     title     => 'Catalyst::View::Bootstrap Example Page',
     copyright => '[* year *] Your Name Here',
   };

   # load up any other configuration items
   PROCESS config/url;

   # set defaults for variables, etc.
   DEFAULT
     message = 'There is no message';

-%]
__config_url__
[% TAGS star -%]
[% base = Catalyst.req.base;

   site.url = {
     base    = base
     home    = "${base}welcome"
     message = "${base}message"
   }
-%]
__site_wrapper__
[% TAGS star -%]
[% IF template.name.match('\.(css|js|txt)');
     debug("Passing page through as text: $template.name");
     content;
   ELSE;
     debug("Applying HTML page layout wrappers to $template.name\n");
     content WRAPPER site/html + site/layout;
   END;
-%]
__site_html__
[% TAGS star -%]
<!DOCTYPE HTML>
<html>
 <head>
  <title>[% template.title or site.title %]</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css" rel="stylesheet">
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >

  <style type="text/css">
body {
padding-top: 60px;
padding-bottom: 40px;
}
.sidebar-nav {
padding: 9px 0;
}
[% PROCESS ttsite.css %]
  </style>
 </head>
 <body>
[% content %]
 <script type="text/javascript" src="https://code.jquery.com/jquery.js"></script>
 <script type="text/javascript" src="//netdna.bootstrapcdn.com/bootstrap/3.0.3/js/bootstrap.min.js"></script>
 </body>
</html>
__site_layout__
[% TAGS star -%]
[% PROCESS site/header %]

[% content %]
__site_header__
[% TAGS star -%]
<!-- BEGIN site/header -->
<div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">[% template.title or site.title %]</a>
        </div>
        <div class="navbar-collapse collapse">
          <form class="navbar-form navbar-right" role="form">
            <div class="form-group">
              <input type="text" placeholder="Email" class="form-control">
            </div>
            <div class="form-group">
              <input type="password" placeholder="Password" class="form-control">
            </div>
            <button type="submit" class="btn btn-success">Sign in</button>
          </form>
        </div><!--/.navbar-collapse -->
      </div>
    </div>

<!-- END site/header -->
__site_footer__
[% TAGS star -%]
<!-- BEGIN site/footer -->
 <footer>
        <p id="copyright">&copy; [% site.copyright %]</p>
 </footer>
<!-- END site/footer -->
__welcome.tt2__
[% TAGS star -%]
[% META title = 'Catalyst/Boostrap TT View' %]
<div class="jumbotron">
      <div class="container"><img style="float: right;" src="/static/images/catalyst_logo.png">
        <h1>Welcome to Catalyst world!</h1>
          <p>Yay!  You're looking at a page generated by the Catalyst::View::TT 
  plugin module and <a href="http://getbootstrap.com/">Twitter Bootstrap</a> using a simple Helper to produce the schema that you can look in root/lib/site and root/src/welcome.tt2.<br>
You can use the power of <a href="http://www.template-toolkit.org/">Template Toolkit 2</a> and the look and features of Bootstrap CSS.</p>

        <p>This is a template for a simple marketing or informational website. It includes a large callout called a jumbotron and three supporting pieces of content. Use it as a starting point to create something more unique.</p>
        <p><a href="http://www.catalystframework.org/" class="btn btn-primary btn-lg" role="button">Learn more &raquo;</a></p>
      </div>
 </div>[%# end of jumbotron %]

    <div class="container">
      <!-- Example row of columns -->
      <div class="row">
        <div class="col-md-4">
          <h2>Template Toolkit</h2>
          <p>The Template Toolkit is a fast, flexible and highly extensible template processing system. It is Free (in both senses: free beer and free speech), Open Source software and runs on virtually every modern operating system known to man. It is mature, reliable and well documented, and is used to generate content for countless web sites ranging from the very small to the very large.</p>
          <p><a class="btn btn-default" href="http://www.template-toolkit.org/" role="button">View details &raquo;</a></p>
        </div>
        <div class="col-md-4">
          <h2>Bootstrap 3</h2>
          <p>Sleek, intuitive, and powerful mobile first front-end framework for faster and easier web development.<br>
             Global CSS settings, fundamental HTML elements styled and enhanced with extensible classes, and an advanced grid system. </p>
          <p><a class="btn btn-default" href="http://getbootstrap.com/" role="button">View details &raquo;</a></p>
       </div>
        <div class="col-md-4">
          <h2>jQuery or Dojo</h2>
          <p>jQuery is common, but DojoToolkit is powerful and clean, stable and asynchronous. I would like to substitute jQuery with Dojo 2.0 as soon as it'll be released in 2014.</p>
          <p><a class="btn btn-default" href="http://dojotoolkit.org/" role="button">View details &raquo;</a></p>
        </div>
      </div>
    <hr>

    [% PROCESS site/footer %]
</div>[%# end of jumbotron %]
<!-- END of welcome -->
__message.tt2__
[% TAGS star -%]
[% META title = 'Catalyst/TT View!' %]
<p>
  Yay!  You're looking at a page generated by the Catalyst::View::TT
  plugin module and Twitter Bootstrap.
</p>
<p>
  We have a message for you: <span class="message">[% message %]</span>.
</p>
<p>
  Why not try updating the message?  Go on, it's really exciting, honest!
</p>
<form action="[% site.url.message %]"
      method="POST" enctype="application/x-www-form-urlencoded">
 <input type="text" name="message" value="[% message %]" />
 <input type="submit" name="submit" value=" Update Message "/>
</form>
__error.tt2__
[% TAGS star -%]
[% META title = 'Catalyst/TT Error' %]
<p>
  An error has occurred.  We're terribly sorry about that, but it's
  one of those things that happens from time to time.  Let's just
  hope the developers test everything properly before release...
</p>
<p>
  Here's the error message, on the off-chance that it means something
  to you: <span class="error">[% error %]</span>
</p>
__ttsite.css__
[% TAGS star %]

.error {
    color: #F11;
}
