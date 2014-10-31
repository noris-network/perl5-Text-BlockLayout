use Test::More tests => 1;
use Text::BlockLayout;

my $tb = Text::BlockLayout->new(
    max_width   => 20,
    separator   => '; ',
);

$tb->add_text('This is longer than 20 chars');
$tb->add_text('short');
$tb->add_line('Short.');
$tb->add_line('Another.');

is $tb->formatted, <<EXPECTED, 'Basic formatting';
This is longer than
20 chars; short
Short.
Another.
EXPECTED
