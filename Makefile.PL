use inc::Module::Install 0.87;

if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/Catalyst/Helper/View/Bootstrap.pm > README' );
}

perl_version '5.008001';

name 'Catalyst-Helper-View-Bootstrap';
all_from 'lib/Catalyst/Helper/View/Bootstrap.pm';

requires 'Catalyst'        => '5.7';
requires 'Template'        => 0;
requires 'Catalyst::View::TT' => 0;

test_requires 'Test::More';

auto_install;
# resources repository => 'git://git.shadowcat.co.uk/catagits/Catalyst-View-TT.git';

WriteAll;
