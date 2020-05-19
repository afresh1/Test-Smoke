package Test::Smoke::Poster::HTTP_Tiny;
use warnings;
use strict;

our $VERSION = '0.001';

use base 'Test::Smoke::Poster::Base';

use CGI::Util;                   # escape() for HTML

=head1 NAME

Test::Smoke::Poster::HTTP_Tiny - Poster subclass using HTTP::Tiny.

=head1 DESCRIPTION

This is a subclass of L<Test::Smoke::Poster::Base>.

=head2 Test::Smoke::Poster::HTTP_Tiny->new(%arguments)

=head3 Extra Arguments

None.

=cut

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    require HTTP::Tiny;
    $self->{_ua} = HTTP::Tiny->new(
        agent => $self->agent_string()
    );

    return $self;
}

=head2 $poster->_post_data()

Post the json to CoreSmokeDB using HTTP::Tiny.

=cut

sub _post_data {
    my $self = shift;

    $self->log_info("Posting to %s via %s.", $self->smokedb_url, $self->poster);
    $self->log_debug("Report data: %s", my $json = $self->get_json);

    my $form_data = sprintf("json=%s", CGI::Util::escape($json));
    my $response = $self->ua->request(
        POST => $self->smokedb_url,
        {
            headers => {
                'Content-Type'   => 'application/x-www-form-urlencoded',
                'Content-Length' => length($form_data),
            },
            content => $form_data,
        },
    );

    if (!$response->{success}) {
        $self->log_warn(
            "POST failed: %s %s",
            $response->{status},
            $response->{reason}
        );
        die sprintf(
            "POST to '%s' failed: %s %s\n",
            $self->smokedb_url,
            $response->{status}, $response->{reason}
        );
    }

    $self->log_debug("[CoreSmokeDB] %s", $response->{content});

    return $response->{content};
}

1;

=head1 COPYRIGHT

(c) 2002-2013, Abe Timmerman <abeltje@cpan.org> All rights reserved.

With contributions from Jarkko Hietaniemi, Merijn Brand, Campo
Weijerman, Alan Burlison, Allen Smith, Alain Barbet, Dominic Dunlop,
Rich Rauenzahn, David Cantrell.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See:

=over 4

=item * L<http://www.perl.com/perl/misc/Artistic.html>

=item * L<http://www.gnu.org/copyleft/gpl.html>

=back

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
