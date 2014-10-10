#!/usr/bin/perl

use utf8;
use strict;
use warnings;

use Imager::Font;

use Carp;
use Imager;
use Imager::Graph::Pie;
use FindBin;

my $chart = Imager::Graph::Pie->new;
my $font = Imager::Font->new(
 file => '/usr/share/fonts/ja/TrueType/kochi-gothic-subst.ttf',
);

$chart->set_style('primary');
$chart->set_font($font);

my $img = $chart->draw(
    width => 500,
    height => 500,
    font => $font,
    bg => 'F0F0F0',
    fg => '333333',
    aa => 1,
    data => [30, 20, 35, 10, 1, 4],
    labels => ['諸葛孔明', '劉玄徳', '曹孟徳', '孫仲謀', '武安国', 'その他'],
    features => +{ dropshadow => 1, labels => 1, labelspc => 1, legend => 1,},
    title => {
        text => '三国志で好きな登場人物',
        color => '000000',
        size => 16,
        font => $font,
    },
    label => {
        font => $font,
        color => '333333',
    },
    legend => {
        font => $font,
        color => '333333',
    },
    callout => {
        leadaa => 1,
    },
    fills => [qw/BE1E2D EE8310 92D5EA 666699 009900 FF0000/],
    size => 300,
);

print STDERR $chart->error if ($chart->error);

$img->write(file => "$FindBin::Bin/pie.png");