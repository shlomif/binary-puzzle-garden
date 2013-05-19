#!/usr/bin/perl

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

my ($half, $m1, $prev);

sub transpose
{
    my ($str_ref) = @_;

    $prev = $$str_ref;
    my $new = '';
    $new .= "\n" while $$str_ref =~ s/^(.)/ $new .= $1; ''/gem;
    $$str_ref = $new;

    return 0;
}

sub earlyvalidate
{
    my ($str_ref) = @_;

    transpose($str_ref);
    my $both = "\n$prev\n\n$$str_ref\n";

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
    };

    $verify->('column', $$str_ref);
    $verify->('row', $prev);

    $$str_ref = $prev;

    return;
}

sub tips
{
    my ($str_ref) = @_;
    local $_ = $$str_ref;

    my $ret =
    (
    s/^(?=(?:.*1){$half}).*?\K /0/m or # max 1, needs 0
    s/^(?=(?:.*0){$half}).*?\K /1/m or # max 0, needs 1

    s/ 00/100/ or # avoid 000
    s/0 0/010/ or
    s/00 /001/ or
    s/ 11/011/ or # avoid 111
    s/1 1/101/ or
    s/11 /110/ or
    0
    );

    $$str_ref = $_;

    return $ret;
}

sub medium
{
    my ($str_ref) = @_;
    local $_ = $$str_ref;

    my $ret = (
    s/^(?=(?:.*1){$m1}).*?\K (?=.*?[ 0]{3})/0/m or # avoid 000/111
    s/^(?=(?:.*0){$m1}).*?\K (?=.*?[ 1]{3})/1/m or
    s/^(?=(?:.*1){$m1}).*?[ 0]{3}.*?\K /0/m or
    s/^(?=(?:.*0){$m1}).*?[ 1]{3}.*?\K /1/m or

     do{
        my ($sum, $new) = 0;
        for my $i (/^\d* \d* \d*$/gm) # cet as opposite
        {
            my $p = $i =~ s/ /[01]/gr;
            /($p)/ or next;
            $new = $1 ^ $i =~ tr| 01|\1\0\0|r;
            $sum += s/$i/$new/;
        }
        $sum;
    } or
    0);

    $$str_ref = $_;

    return $ret;
}

sub hard
{
    my ($str_ref) = @_;

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
    my ($code_ref, $str_ref) = @_;

    if ($code_ref->($str_ref))
    {
        return 1;
    }
    else
    {
        transpose($str_ref);
        if ($code_ref->($str_ref))
        {
            transpose($str_ref);
            return 1;
        }
        else
        {
            $$str_ref = $prev;
            return 0;
        }
    }
}

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
        my ($str_ref) = @_;

        if ($$str_ref =~ / /)
        {
            print("fork\n");
            $fork++;
            push @stack, $$str_ref =~ s/^.*\K /1/rs;
        }

        return $$str_ref =~ s/^.*\K /0/s;
    };

    my $try_move = sub {
        my ($str_ref) = @_;

        print("\n$$str_ref\n");

        return code_or_transpose(\&tips, $str_ref)
        || code_or_transpose(\&medium, $str_ref)
        || code_or_transpose(\&hard, $str_ref)
        || $do_fork->($str_ref);
    };

    STACK:
    while (my $state = pop @stack)
    {
        $backup++;
        print "new\n";

        eval
        {
            while ($try_move->(\$state))
            {
                $count++;
                earlyvalidate(\$state);
            };

            print "count: $count  fork: $fork  backup: $backup\n\n";

            if ($state =~ / /)
            {
                die "incomplete";
            }
            earlyvalidate(\$state);
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
