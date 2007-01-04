use strict;
use warnings;

package List::Search;

our $VERSION = '0.1';

use vars qw(@ISA @EXPORT_OK);
@ISA       = qw(Exporter);
@EXPORT_OK = qw( list_search nlist_search custom_list_search );

=head1 NAME

List::Search - fast searching of sorted lists

=head1 SYNOPSIS

    use List::Search qw( list_search nlist_search custom_list_search );

    # Create a list to search
    my @list = sort qw( bravo charlie delta );

    # Search for a value, returns the index of first m
    print list_search( 'charlie', \@list );    #  1
    print list_search( 'alpha',   \@list );    #  0
    print list_search( 'zebra',   \@list );    #  2

    # Search numerically
    my @numbers = sort { $a <=> $b } ( 10, 20, 100, 200, );
    print nlist_search ( 20, \@numbers );         #  2

    # Search using some other comparison
    my $cmp_code = sub { lc($_[0]) cmp lc($_[1]) };
    my @custom_list = sort { $cmp_code->($a, $b) } qw( FOO bar BAZ bundy );
    print list_search_generic( $cmp_code, 'foo', \@custom_list );

=head1 DESCRIPTION

This module lets you quickly search a sorted list. It will return the index of
the first entry that matches, or if there is no exact matches then the first
entry that is greater than the search key.

For example in the list C<my @list = qw( bob dave fred );> searching for
C<dave> will return C<1> as C<$list[1] eq 'dave'>. Searching for C<charles>
will also return C<1> as C<dave> is the first entry that is greater than
C<charles>.

If there are none of the entries match then C<-1> is returned. You can either
check for this or use it as an index to get the last values in the list.
Whichever approach you choose will depend on what you are trying to do.

The actual searching is done using a binary search which is very fast.

=head1 METHODS

=head2 list_search

  my $idx = list_search( $key, \@sorted_list );

Searches the list using C<cmp> as the comparison operator. Returns the index
of the first entry that is equal to or greater than C<$key>. If there is no
match then returns C<-1>.

=cut

sub list_search {
    my ( $key, $array_ref ) = @_;
    my $code = sub { $_[0] cmp $_[1] };

    return custom_list_search( $code, $key, $array_ref );
}

=head2 nlist_search

  my $idx = nlist_search( $key, \@sorted_list );

Searches the list using C<E<lt>=E<gt>> as the comparison operator. Returns the
index of the first entry that is equal to or greater than C<$key>. If there is
no match then returns C<-1>.

=cut

sub nlist_search {
    my ( $key, $array_ref ) = @_;
    my $code = sub { $_[0] <=> $_[1] };

    return custom_list_search( $code, $key, $array_ref );
}

=head2 custom_list_search

WARNING: I intend to change this method so that it accepts a block in the same
way that C<sort> does. This means that you will be able to use $a and $b as
expected. Until then take care with this one : )

  my $cmp_sub = sub { $_[0] cmp $_[1] };
  my $idx = custom_list_search( $cmp_sub, $key, \@sorted_list );

Searches the list using the subroutine to compare the values. Returns the
index of the first entry that is equal to or greater than C<$key>. If there is
no match then returns C<-1>.

NOTE - the list must have been sorted using the same comparison, ie:

  my @sorted_list = sort { $cmp_sub->( $a, $b ) } @list;

=cut

sub custom_list_search {
    my ( $cmp_code, $key, $array_ref ) = @_;

    my $max_index = scalar(@$array_ref) - 1;

    my $low  = 0;
    my $mid  = undef;
    my $high = $max_index;

    while ( $low <= $high ) {
        $mid = int( $low + ( ( $high - $low ) / 2 ) );
        my $mid_val = $array_ref->[$mid];

        my $cmp_result = $cmp_code->( $key, $mid_val );

        if ( $cmp_result >= 1 ) {
            $low = $mid + 1;
        }
        elsif ( $cmp_result <= -1 ) {
            $high = $mid - 1;
        }
        else {
            return $mid;    # key found
        }
    }

    # Look at the values here and work out what to return.

    # Perhaps there are no matches in the array
    return -1 if $cmp_code->( $key, $array_ref->[-1] ) eq 1;

    # Perhaps $mid is just before the best match
    return $mid + 1 if $cmp_code->( $key, $array_ref->[$mid] ) eq 1;

    # $mid is correct
    return $mid;
}

=head1 AUTHOR

Edmund von der Burg C<<evdb@ecclestoad.co.uk>>

L<http://www.ecclestoad.co.uk>

=head1 SEE ALSO

For fast sorting of lists try L<Sort::Key>

=head1 SVN ACCESS

You can access the latest (possibly unstable) code here:

L<http://dev.ecclestoad.co.uk/svn/cpan/List-Search>

=head1 COPYRIGHT

Copyright (C) 2007 Edmund von der Burg. All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If it breaks you get to keep both pieces.

THERE IS NO WARRANTY.

=cut

1;