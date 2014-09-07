use strict;
use warnings;
use inc::Module::Install 0.91;
use Module::Install::Share;


if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/Catalyst/Helper/View/Bootstrap.pm > README' );
}

perl_version '5.012001';
version_from 'lib/Catalyst/Helper/View/Bootstrap.pm';

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

makemaker_args(
    META_MERGE        => {
	"meta-spec" => { version => 2 },
	resources => {
	    repository => {
		type => 'git',
		url => 'git@github.com:ferz/Catalyst--Helper--View--Bootstrap.git',
		web => 'https://github.com/ferz/Catalyst--Helper--View--Bootstrap',
	    },
	},
    },
    );

WriteAll;
