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
    ($prev, my $new) = $_;
    $new .= "\n" while s/^(.)/ $new .= $1; ''/gem;
    $_ = $new;
    return 0;
}

sub earlyvalidate
{
    transpose();
    my $both = "\n$prev\n\n$_\n";

    /(000)/ || /(111)/ and die "three $1 in a column$both";
    die "unequal column count @1$both" if @1 = grep tr/1// != tr/0//, /^\d+$/gm;
    /^(\d+)\n\C*\1\n/m and die "error: duplicate column <$1>\n$both";

    $_ = $prev;

    /(000)/ || /(111)/ and die "three $1 in a row$both";
    die "unequal row count @1$both" if @1 = grep tr/1// != tr/0//, /^\d+$/gm;
    /^(\d+)\n\C*\1\n/m and die "error: duplicate row <$1>\n$both";
}

sub tips ()
{
    s/^(?=(?:.*1){$half}).*?\K /0/m or # max 1, needs 0
    s/^(?=(?:.*0){$half}).*?\K /1/m or # max 0, needs 1

    s/ 00/100/ or # avoid 000
    s/0 0/010/ or
    s/00 /001/ or
    s/ 11/011/ or # avoid 111
    s/1 1/101/ or
    s/11 /110/ or
    0;
}

sub medium ()
{
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
    0;
}

sub hard ()
{
    do {  # 101010/101--- -> 101-0-
        my ($sum, $new, $mod) = 0;
        for my $i (/^\d* \d* \d* \d*$/gm) # find single of 3, set oppo
        {
            my $p = $i =~ s/ /[01]/gr;
            /($p)/ ? ($new = $1) : next;
            if( $i =~ tr/0// < $i =~ tr/1// ) # needs singleton 1
            {
                $mod = ($i =~ tr/ 01/1 /r & $new) =~ tr/01/ 0/r | $i;
            }
            else
            {
                $mod = ($i =~ tr/ 01/1 /r & $new) =~ tr/01/1 /r | $i;
            }
            $sum += s/$i/$mod/;
            print "i $i  mod $mod\n";
        }
        $sum;
    } or
    0;
}

for (@puzzles)
{
    tr/-/ /;
    $half = tr/\n// / 2;
    $m1 = $half - 1;

    my @stack = $_;

    my ($count, $fork, $backup) = (0, 0, -1);

    while($_ = pop @stack)
    {
        $backup++;
        print "new\n";
        eval
        {
            $count++, earlyvalidate() while print("\n$_\n"),
            tips ||
            (transpose() + tips ? 1 + transpose() : ($_ = $prev, 0)) ||
            medium ||
            (transpose() + medium ? 1 + transpose() : ($_ = $prev, 0)) ||
            hard ||
            (transpose() + hard ? 1 + transpose() : ($_ = $prev, 0)) ||
            do { / / && print("fork\n") + ++$fork + push @stack,
                s/^.*\K /1/sr; s/^.*\K /0/s };

            print "count: $count  fork: $fork  backup: $backup\n\n";

            / / and die "incomplete";  # validate
            earlyvalidate();
        };
        $@ ? print "failed $@" : last;
    }
}

__END__
