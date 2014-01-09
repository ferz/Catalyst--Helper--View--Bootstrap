use strict;
use warnings;
use inc::Module::Install 0.91;


if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/Catalyst/Helper/View/Bootstrap.pm > README' );
}

perl_version '5.012001';

name 'Catalyst-Helper-View-Bootstrap';
all_from 'lib/Catalyst/Helper/View/Bootstrap.pm';
requires 'File::ShareDir';

requires 'Catalyst'        => '5.7';
requires 'Template'        => 0;
requires 'Catalyst::View::TT' => 0;

test_requires 'Test::More';
install_share 'share';

auto_install;
# resources repository => 'https://github.com/ferz/Catalyst--Helper--View--Bootstrap';

WriteAll;
