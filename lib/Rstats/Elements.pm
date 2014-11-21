package Rstats::Elements;
use Object::Simple -base;

use Carp 'croak', 'carp';
use Rstats::ElementsFunc;
use Rstats::Util;

use overload
  bool => \&bool,
  '+' => sub { Rstats::ElementsFunc::add(shift->_fix_position(@_)) },
  '-' => sub { Rstats::ElementsFunc::subtract(shift->_fix_position(@_)) },
  '*' => sub { Rstats::ElementsFunc::multiply(shift->_fix_position(@_)) },
  '/' => sub { Rstats::ElementsFunc::divide(shift->_fix_position(@_)) },
  '%' => sub { Rstats::ElementsFunc::remainder(shift->_fix_position(@_)) },
  'neg' => sub { Rstats::ElementsFunc::negation(@_) },
  '**' => sub { Rstats::ElementsFunc::raise(shift->_fix_position(@_)) },
  '<' => sub { Rstats::ElementsFunc::less_than(shift->_fix_position(@_)) },
  '<=' => sub { Rstats::ElementsFunc::less_than_or_equal(shift->_fix_position(@_)) },
  '>' => sub { Rstats::ElementsFunc::more_than(shift->_fix_position(@_)) },
  '>=' => sub { Rstats::ElementsFunc::more_than_or_equal(shift->_fix_position(@_)) },
  '==' => sub { Rstats::ElementsFunc::equal(shift->_fix_position(@_)) },
  '!=' => sub { Rstats::ElementsFunc::not_equal(shift->_fix_position(@_)) },
  '""' => \&to_string,
  fallback => 1;

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $e1;
  my $e2;
  if (ref $data eq 'Rstats::Elements') {
    $e1 = $self;
    $e2 = $data;
  }
  else {
    if ($reverse) {
      $e1 = Rstats::ElementsFunc::element($data);
      $e2 = $self;
    }
    else {
      $e1 = $self;
      $e2 = Rstats::ElementsFunc::element($data);
    }
  }
  
  return ($e1, $e2);
}

sub as_character {
  my $self = shift;
  
  my $e2 = Rstats::ElementsFunc::character("$self");
  
  return $e2;
}

sub as_complex {
  my $self = shift;

  if ($self->is_na) {
    return $self;
  }
  elsif ($self->is_character) {
    my $z = Rstats::Util::looks_like_complex($self->cv);
    if (defined $z) {
      return Rstats::ElementsFunc::complex($z->{re}, $z->{im});
    }
    else {
      carp 'NAs introduced by coercion';
      return Rstats::ElementsFunc::NA();
    }
  }
  elsif ($self->is_complex) {
    return $self;
  }
  elsif ($self->is_double) {
    if ($self->is_nan) {
      return Rstats::ElementsFunc::NA();
    }
    else {
      return Rstats::ElementsFunc::complex_double($self, Rstats::ElementsFunc::double(0));
    }
  }
  elsif ($self->is_integer) {
    return Rstats::ElementsFunc::complex($self->iv, 0);
  }
  elsif ($self->is_logical) {
    return Rstats::ElementsFunc::complex($self->iv ? 1 : 0, 0);
  }
  else {
    croak "unexpected type";
  }
}

sub as_numeric { as_double(@_) }

sub as_logical {
  my $self = shift;
  
  if ($self->is_na) {
    return $self;
  }
  elsif ($self->is_character) {
    my $value = $self->value;
    
    if (defined (my $e1 = Rstats::Util::looks_like_logical($value))) {
      return $e1;
    }
    else {
      return Rstats::ElementsFunc::NA();
    }
  }
  elsif ($self->is_complex) {
    carp "imaginary parts discarded in coercion";
    my $re = $self->re->value;
    my $im = $self->im->value;
    if (defined $re && $re == 0 && defined $im && $im == 0) {
      return Rstats::ElementsFunc::FALSE();
    }
    else {
      return Rstats::ElementsFunc::TRUE();
    }
  }
  elsif ($self->is_double) {
    if ($self->is_nan) {
      return Rstats::ElementsFunc::NA();
    }
    elsif ($self->is_infinite) {
      return Rstats::ElementsFunc::TRUE();
    }
    else {
      return $self->dv == 0 ? Rstats::ElementsFunc::FALSE() : Rstats::ElementsFunc::TRUE();
    }
  }
  elsif ($self->is_integer) {
    return $self->iv == 0 ? Rstats::ElementsFunc::FALSE() : Rstats::ElementsFunc::TRUE();
  }
  elsif ($self->is_logical) {
    return $self->iv == 0 ? Rstats::ElementsFunc::FALSE() : Rstats::ElementsFunc::TRUE();
  }
  else {
    croak "unexpected type";
  }
}

sub as {
  my ($self, $type) = @_;
  
  if ($type eq 'character') {
    return $self->as_character;
  }
  elsif ($type eq 'complex') {
    return $self->as_complex;
  }
  elsif ($type eq 'double') {
    return $self->as_double;
  }
  elsif ($type eq 'numeric') {
    return $self->as_numeric;
  }
  elsif ($type eq 'integer') {
    return $self->as_integer;
  }
  elsif ($type eq 'logical') {
    return $self->as_logical;
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub to_string {
  my $self = shift;
  
  my $str;
  if ($self->is_character) {
    $str = $self->cv . "";
  }
  elsif ($self->is_complex) {
    my $re = $self->re;
    my $im = $self->im;
    
    $str = "$re";
    $str .= '+' if $im >= 0;
    $str .= $im . 'i';
  }
  elsif ($self->is_double) {
  
    if ($self->is_positive_infinite) {
      $str = 'Inf';
    }
    elsif ($self->is_negative_infinite) {
      $str = '-Inf';
    }
    elsif ($self->is_nan) {
      $str = 'NaN';
    }
    else {
      $str = $self->dv . "";
    }
  }
  elsif ($self->is_integer) {
    $str = $self->iv . "";
  }
  elsif ($self->is_logical) {
    $str = $self->iv ? 'TRUE' : 'FALSE'
  }
  else {
    croak "Invalid type";
  }
  
  my $is_na = $self->is_na->iv;
  if ($is_na) {
    $str = 'NA';
  }
  
  return $str;
}

sub bool {
  my $self = shift;
  
  my $is;
  if ($self->is_character || $self->is_complex) {
    croak 'Error in -a : invalid argument to unary operator ';
  }
  elsif ($self->is_double) {
    if ($self->is_infinite) {
      $is = 1;
    }
    elsif ($self->is_nan) {
      croak 'argument is not interpretable as logical';
    }
    else {
      $is = $self->dv;
    }
  }
  elsif ($self->is_integer || $self->is_logical) {
    $is = $self->iv;
  }
  else {
    croak "Invalid type";
  }
  
  my $is_na = $self->is_na->iv;
  if ($is_na) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }
  
  return $is;
}

sub value {
  my $self = shift;
  
  my $value;
  if ($self->is_double) {
    if ($self->is_positive_infinite) {
      $value = 'Inf';
    }
    elsif ($self->is_negative_infinite) {
      $value = '-Inf';
    }
    elsif ($self->is_nan) {
      $value = 'NaN';
    }
    else {
      $value = $self->dv;
    }
  }
  elsif ($self->is_logical) {
    if ($self->iv) {
      $value = 1;
    }
    else {
      $value = 0;
    }
  }
  elsif ($self->is_complex) {
    $value = {
      re => $self->re->value,
      im => $self->im->value
    };
  }
  elsif ($self->is_character) {
    $value = $self->cv;
  }
  elsif ($self->is_integer) {
    $value = $self->iv;
  }
  else {
    croak "Invalid type(Rstats::Elements::value())";
  }
  
  my $is_na = $self->is_na->iv;
  if ($is_na) {
    $value = undef;
  }
  
  return $value;
}

sub typeof { shift->type }

sub is_character { shift->type eq 'character' }
sub is_complex { shift->type eq 'complex' }
sub is_numeric {
  my $self = shift;
  return $self->is_double || $self->is_integer;
}
sub is_double { shift->type eq 'double' }
sub is_integer { shift->type eq 'integer' }
sub is_logical { shift->type eq 'logical' }

sub is_positive_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->dv > 0;
}

sub is_negative_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->dv < 0;
}


1;

=head1 NAME

Rstats::Elements - Elements

=heaa1 METHODS

=head2 as_double

=head2 type

=head2 iv

=head2 dv

=head2 cv

=head2 re

=head2 im

=head2 flag

=head2  XS

=head2  is_nan

=head2  is_infinite

=head2  is_finite
