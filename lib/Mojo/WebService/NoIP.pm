package Mojo::WebService::NoIP;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

use Mojo::Base -base;

use Mojo::URL;
use Mojo::UserAgent;

has username => sub { die 'username is required' };
has password => sub { die 'password is required' };

has provider => 'http://dynupdate.no-ip.com/nic/update';
has secure   => 0;

has ua => sub {
  my $ua = Mojo::UserAgent->new->max_redirects(10);
  $ua->transactor->name("Mojo::WebService::NoIP/v${VERSION} joel.a.berger\@gmail.com");
  return $ua;
};

sub update {
  my $self = shift;
  my $cb = ref $_[-1] eq 'CODE' ? pop : undef;
  my $args = @_ == 1 ? shift : { @_ };

  my $url = Mojo::URL->new($self->provider);
  $url->scheme('https') if $self->secure;
  $url->userinfo($self->username . ':' . $self->password);

  if (exists $args->{offline}) {
    my $offline = 'NO';
    if ($args->{offline} and $args->{offline} !~ /n/i) { $offline = 'YES' };
    $url->query(offline => $offline);
  }

  $url->query(hostname => $args->{hostname}) if $args->{hostname};
  $url->query(myip     => $args->{myip})     if $args->{myip};

  say "Request: $url";

  $self->ua->get($url, $cb ? $cb : ());
}

1;

