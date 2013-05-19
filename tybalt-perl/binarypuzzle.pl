
=head1 COPYRIGHT & LICENSE

Copyright 2012 Richard Klement.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

use strict;
use warnings;


my @puzzles = (<<END) =~ /(?:.+\n)+/g;

1--0--
--00-1
-00--1
------
00-1--
-1--00


----00
------
-1----
01-1--
0---0-
--1---


---1--
--0--1
0---0-
-11---
------
1---0-


-----1----
--11------
-0---00--0
1--------1
-------0--
1--------1
--------0-
-1---11---
-1-----0-0
---------0

11-0-0---0-0--
--00-00---1---
---------0--1-
0--01------01-
-1-----11----1
--------------
0-----0--0-0-0
---1--0-------
--1--1--11--1-
---0-1-1--0---
-1------0----0
-------0------
---11-1---0-0-
1-1--------11-


---------00-0-
-00----0------
1--00-1------0
-----1--1-0---
----0----00--1
-------------1
----1--1------
-0-0----0--1--
--------------
0--1----11--0-
-------0-1---0
1-00------0---
---0-------1--
0-0-00--1-----

------
------
------
------
------
------


------
--11--
0-1--0
------
----1-
----00

------11
--1-0---
--11----
-------0
1--1----
-------0
0--1---1
-1----0-

-0------
1-1---00
------0-
0-1--1--
--------
-0---1--
-------0
---0-11-

END

my ($half, $m1);

package BinaryPuzzle::Board;

use List::MoreUtils (qw( any ));
use List::Util (qw( first ));

use MooX qw/late/;

has 'str_ref' => (isa => 'ScalarRef[Str]', is => 'rw');
has 'prev' => (isa => 'Str', is => 'rw', default => sub { ''; });

sub transpose
{
    my ($self) = @_;

    my $str_ref = $self->str_ref;

    $self->prev($$str_ref);
    my $new = '';
    $new .= "\n" while $$str_ref =~ s/^(.)/ $new .= $1; ''/gem;
    $$str_ref = $new;

    return 0;
}

sub _replace
{
    my $s = shift;
    my ($d) = $s =~ /(\d)/g;
    return $s =~ s/ /1-$d/er;
}

sub tips
{
    my ($self) = @_;

    my $str_ref = $self->str_ref;

    return
    (
        $$str_ref =~ s/^(?=(?:.*1){$half}).*?\K /0/m or # max 1, needs 0
        $$str_ref =~ s/^(?=(?:.*0){$half}).*?\K /1/m or # max 0, needs 1
        (any {
                my $pat = $_;
                $$str_ref =~ s#($pat)#_replace($1)#e
            } (' 00', '0 0', '00 ', ' 11', '1 1', '11 ')
        ) or
        0
    );
}

sub _medium_helper
{
    my ($str_ref) = @_;

    my ($sum, $new) = 0;

    I_LOOP:
    for my $i ($$str_ref =~ /^\d* \d* \d*$/gm) # cet as opposite
    {
        my $p = $i =~ s/ /[01]/gr;
        if ($$str_ref !~ /($p)/)
        {
            next I_LOOP;
        }
        $new = $1 ^ $i =~ tr| 01|\1\0\0|r;
        $sum += ($$str_ref =~ s/$i/$new/);
    }

    return $sum;
}

sub medium
{
    my ($self) = @_;

    my $str_ref = $self->str_ref;

    return
    (
        # avoid 000/111
           ($$str_ref =~ s/^(?=(?:.*1){$m1}).*?\K (?=.*?[ 0]{3})/0/m)
        or ($$str_ref =~ s/^(?=(?:.*0){$m1}).*?\K (?=.*?[ 1]{3})/1/m)
        or ($$str_ref =~ s/^(?=(?:.*1){$m1}).*?[ 0]{3}.*?\K /0/m)
        or ($$str_ref =~ s/^(?=(?:.*0){$m1}).*?[ 1]{3}.*?\K /1/m)
        or _medium_helper($str_ref)
    );
}

sub hard
{
    my ($self) = @_;

    my $str_ref = $self->str_ref;

    my $sum = 0;
    my ($new, $mod);
    # find single of 3, set oppo
    SINGLE_3:
    for my $i ($$str_ref =~ /^\d* \d* \d* \d*$/gm)
    {
        my $p = $i =~ s/ /[01]/gr;
        if (my ($m) = $$str_ref =~ /($p)/)
        {
            $new = $m;
        }
        else
        {
            next SINGLE_3;
        }
        if( $i =~ tr/0// < $i =~ tr/1// ) # needs singleton 1
        {
            $mod = ($i =~ tr/ 01/1 /r & $new) =~ tr/01/ 0/r | $i;
        }
        else
        {
            $mod = ($i =~ tr/ 01/1 /r & $new) =~ tr/01/1 /r | $i;
        }
        $sum += ($$str_ref =~ s/$i/$mod/);
        print "i $i  mod $mod\n";
    }

    return $sum;
}

sub code_or_transpose
{
    my ($self, $meth) = @_;

    if ($self->$meth())
    {
        return 1;
    }
    else
    {
        $self->transpose();
        if ($self->$meth())
        {
            $self->transpose();
            return 1;
        }
        else
        {
            ${$self->str_ref} = $self->prev;
            return 0;
        }
    }
}

sub call_moves
{
    my ($self) = @_;

    return (first { $self->code_or_transpose($_) } qw(tips medium hard));
}

sub earlyvalidate
{
    my ($self) = @_;

    my $str_ref = $self->str_ref;

    $self->transpose();
    my $both = "\n" . $self->prev . "\n\n$$str_ref\n";

    my $verify = sub {
        my ($dim, $v) = @_;

        if (my ($match) = $v =~ /(([01])\2\2)/)
        {
            die "three $match in a $dim$both";
        }
        if (my @m = grep { tr/1// != tr/0// } ($v =~ /^\d+$/gm))
        {
            die "unequal $dim count @m$both";
        }
        if ($v =~ /^(\d+)\n\C*\1\n/m)
        {
            die "error: duplicate $dim <$1>\n$both";
        }

        return;
    };

    $verify->('column', $$str_ref);
    $verify->('row', $self->prev);

    $$str_ref = $self->prev;

    return;
}

package main;

for my $puz (@puzzles)
{
    $puz =~ tr/-/ /;
    $half = ($puz =~ tr/\n//) / 2;
    $m1 = $half - 1;

    my @stack;

    push @stack, $puz;

    my $count = 0;
    my $fork = 0;
    my $backup = -1;

    my $do_fork = sub {
        my $obj = shift;

        my $str_ref = $obj->str_ref;

        if ($$str_ref =~ / /)
        {
            print("fork\n");
            $fork++;
            push @stack, $$str_ref =~ s/^.*\K /1/rs;
        }

        return $$str_ref =~ s/^.*\K /0/s;
    };

    my $try_move = sub {
        my $obj = shift;

        my $str_ref = $obj->str_ref;

        print("\n$$str_ref\n");

        return $obj->call_moves() || $do_fork->($obj);
    };

    STACK:
    while (my $state = pop @stack)
    {
        my $obj = BinaryPuzzle::Board->new(
            {
                str_ref => \$state,
            }
        );
        $backup++;
        print "new\n";

        eval
        {
            while ($try_move->($obj))
            {
                $count++;
                $obj->earlyvalidate;
            };

            print "count: $count  fork: $fork  backup: $backup\n\n";

            if ($state =~ / /)
            {
                die "incomplete";
            }
            $obj->earlyvalidate;
        };
        if ($@)
        {
            print "failed $@";
        }
        else
        {
            last STACK;
        }
    }
}

__END__
