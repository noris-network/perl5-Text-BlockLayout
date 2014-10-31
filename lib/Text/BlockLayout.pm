package Text::BlockLayout;

use 5.010;
use strict;
use warnings;
use utf8;
use Text::Wrap ();

our $VERSION = '0.02';

use Moo;

has max_width => (
    is          => 'rw',
    required    => 1,
);

has line_continuation_threshold => (
    is          => 'rw',
    default     => sub { int(shift->max_width * 2 / 3 + 0.5) },
    lazy        => 1,
);
has separator => (
    is      => 'rw',
    default => sub { ' ' },
);

sub add_text {
    my ($self, @chunks) = @_;

    push @{$self->{chunks}}, map [0, $_], @chunks;
    $self;
}

sub add_line {
    my ($self, @chunks) = @_;

    push @{$self->{chunks}}, map [1, $_], @chunks;
    $self;
}

sub formatted {
    my $self = shift;

    my @lines;
    my $last_line_separate = 0;
    for my $chunk ( @{ $self->{chunks} }) {
        my ($separate_line, $text) = @$chunk;
        my $start_new_line   = $last_line_separate || $separate_line || !@lines;
           $start_new_line ||= length($lines[-1]) > $self->line_continuation_threshold;
           $start_new_line ||= (length($lines[-1]) + length($self->separator) + length $text) > $self->max_width;
        if ($start_new_line) {
            push @lines, $self->_wrap($text);
        }
        else {
            $lines[-1] .= $self->separator . $text;
        }
        $last_line_separate = $separate_line;
    }
    return join "\n", @lines, '';
}

sub _wrap {
    my ($self, $text) = @_;
    # it seems Text::Wrap includes the final newline, so +1
    local $Text::Wrap::columns = 1 + $self->max_width;
    return split /\n/, Text::Wrap::wrap('', '', $text);
}

1;

__END__

=head1 NAME

Text::BlockLayout - Generate text blocks from a mixture of wrappable and
protected lines

=head1 SYNOPSIS

    use 5.010;
    use strict; use warnings;

    use Text::BlockLayout;
    my $tb = Text::BlockLayout->new(
        max_width   => 30,
        separator   => '. ',
    );

    $tb->add_text('This text will be wrapped if longer than 30 characters,'
            . ' and potentially be joined with other lines, separted by ". "');
    $tb->add_text('Same here');
    $tb->add_line('This will also be wrapped, but never be joined with other lines');

    say $tb->formatted;

=head1 DESCRIPTION

Text::BlockLayout can wrap and format chunks of text for you. For each piece
of text you add, you can chose whether it remains on lines on its own (when
added with the C<add_line> method), or whether it might be joined with other
lines (when added with the C<add_text> method). If the latter is the case, the
pieces of text are joined by a customizable separator.

=head1 Attributes

Attributes can be passed as named arguments to the constructor, and later set
and get with methods of the same name as the attribute.

=head2 max_width

The maximal number of characters in a line (not counting the newline
character).

Required. Must be a positive integer.

=head2 separator

The separator with which two chunks of text are joined if they are put on the
same line.

Optional. Will be used as a string. Default: the empty string.

=head2 line_continuation_threshold

The number of characters after which a line is considered full, i.e. no extra
chunks of text will be added to this line.

Optional. Defaults to two thirds of C<max_width>, rounded to the nearest
integer.

=head1 Methods

=head2 formatted

Returns the formatted text.

=head1 AUTHOR

Moritz Lenz (moritz@faui2k3.org) for the noris network AG.

=head1 DEVELOPMENT

This module is under version control. You can find its repository at
L<https://github.com/noris-network/perl5-Text-BlockLayout>.

=head1 LICENSE

This module and its accompanying files may be used, distributed and modified under the same terms as perl itself.

=head1 WARRANTY

There is no warranty for this software, to the extend permitted by applicable
law. Use it at your own risk.

=cut
