use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# ncol
{
  my $x1 = list(1, 2, 3);
  my $x2 = r->ncol($x1);
  ok($x2->is_null);
}

# nrow
{
  my $x1 = list(1, 2, 3);
  my $x2 = r->nrow($x1);
  ok($x2->is_null);
}

# set
{
  # set - NULL, dimnames
  {
    my $x1 = list(c(1, 2, 3), c(4, 5, 6), c(7, 8, 9));
    $x1->dimnames(list(c("r1", "r2", "r3"), c("c1", "c2", "c3")));
    $x1->at(2)->set(NULL);
    is_deeply($x1->getin(1)->values, [1, 2, 3]);
    is_deeply($x1->getin(2)->values, [7, 8, 9]);
    is_deeply($x1->dimnames->getin(1)->values, ["r1", "r2", "r3"]);
    is_deeply($x1->dimnames->getin(2)->values, ["c1", "c3"]);
  }
  
  # set - NULL, names
  {
    my $x1 = list(c(1, 2, 3), c(4, 5, 6), c(7, 8, 9));
    $x1->names(c("c1", "c2", "c3"));
    $x1->at(2)->set(NULL);
    is_deeply($x1->getin(1)->values, [1, 2, 3]);
    is_deeply($x1->getin(2)->values, [7, 8, 9]);
    is_deeply($x1->names->values, ["c1", "c3"]);
  }
  
  # set - basic
  {
    my $x1 = list(1, 2, 3);
    $x1->at(2)->set(5);
    is_deeply($x1->getin(1)->values, [1]);
    is_deeply($x1->getin(2)->values, [5]);
    is_deeply($x1->getin(3)->values, [3]);
  }

  # set - name
  {
    my $x1 = list(1, 2, 3);
    r->names($x1, c("n1", "n2", "n3"));
    $x1->at("n2")->set(5);
    is_deeply($x1->getin(1)->values, [1]);
    is_deeply($x1->getin(2)->values, [5]);
    is_deeply($x1->getin(3)->values, [3]);
  }
  
  # set - two index
  {
    my $x1 = list(1, list(2, 3));
    $x1->getin(2)->at(2)->set(5);
    is_deeply($x1->getin(1)->values, [1]);
    is_deeply($x1->getin(2)->getin(1)->values, [2]);
    is_deeply($x1->getin(2)->getin(2)->values, [5]);
  }

  # set - tree index
  {
    my $x1 = list(1, list(2, 3, list(4)));
    $x1->getin(2)->getin(3)->at(1)->set(5);
    is_deeply($x1->getin(2)->getin(3)->getin(1)->values, [5]);
  }
}

# list
{
  # list - basic
  {
    my $x1 = list(c(1, 2, 3), list("Hello", c(T, F, F)));
    is_deeply($x1->elements->[0]->values, [1, 2, 3]);
    is_deeply($x1->elements->[1]->elements->[0]->values, ["Hello"]);
    is_deeply(
      $x1->elements->[1]->elements->[1]->elements,
      [Rstats::ElementsFunc::TRUE, Rstats::ElementsFunc::FALSE, Rstats::ElementsFunc::FALSE]
    );
  }

  # list - argument is not array
  {
    my $x1 = list(1, 2, 3);
    is_deeply($x1->elements->[0]->values, [1]);
    is_deeply($x1->elements->[1]->values, [2]);
    is_deeply($x1->elements->[2]->values, [3]);
  }
    
  # list - to_string
  {
    my $x1 = list(c(1, 2, 3), list("Hello", c(T, F, F)));
    my $str = $x1->to_string;
    my $expected = <<"EOS";
[[1]]
[1] 1 2 3

[[2]]
[[2]][[1]]
[1] "Hello"

[[2]][[2]]
[1] TRUE FALSE FALSE

EOS
    is($str, $expected);
  }

  # list - length
  {
    my $x1 = list("a", "b");
    is_deeply(r->length($x1)->values, [2]);
  }

  # list - as_list, input is list
  {
    my $x1 = list("a", "b");
    my $l2 = r->as_list($x1);
    is($x1, $l2);
  }
  
  # list - as_list, input is array
  {
    my $x1 = c("a", "b");
    my $x2 = r->as_list($x1);
    ok(r->is_list($x2));
    is_deeply($x2->values, ["a", "b"]);
  }

  # list - getin
  {
    my $x1 = list("a", "b", list("c", "d", list("e")));
    my $x2 = $x1->getin(1);
    is_deeply($x2->values, ["a"]);
    
    my $x3 = $x1->getin(3)->getin(2);
    is_deeply($x3->values, ["d"]);

    my $x4 = $x1->getin(3)->getin(3)->getin(1);
    is_deeply($x4->values, ["e"]);
  }

  # list - getin,name
  {
    my $x1 = list("a", "b", list("c", "d", list("e")));
    r->names($x1, c("n1", "n2", "n3"));
    my $x2 = $x1->getin("n1");
    is_deeply($x2->values, ["a"]);

    my $x3 = $x1->getin("n3")->getin(3)->getin(1);
    is_deeply($x3->values, ["e"]);
  }
  
  # list - get
  {
    my $x1 = list(1, 2, 3);
    my $l2 = $x1->get(1);
    ok(r->is_list($l2));
    is_deeply($l2->getin(1)->values, [1]);
  }

  # list - get, multiple
  {
    my $x1 = list(1, 2, 3);
    my $l2 = $x1->get(c(1, 3));
    ok(r->is_list($l2));
    is_deeply($l2->getin(1)->values, [1]);
    is_deeply($l2->getin(2)->values, [3]);
  }

  # list - get, multiple, names
  {
    my $x1 = list(1, 2, 3);
    r->names($x1, c("n1", "n2", "n3"));
    my $l2 = $x1->get(c("n1", "n3"));
    ok(r->is_list($l2));
    is_deeply($l2->getin(1)->values, [1]);
    is_deeply($l2->getin(2)->values, [3]);
  }
}
