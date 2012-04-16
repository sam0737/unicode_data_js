#!/usr/bin/perl
#
# Copyright (C) 2012 Sam Wong. All rights reserved.
#
# This work is licensed under the # Creative Commons Attribution-NonCommercial 3.0 Hong Kong License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/hk/ or
# send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#

use strict;
use warnings;

use LWP::Simple;

my $json_callback = 'unicode_data_jsonp_callback';
my $mapping_comment = <<EOF;
// The data below is converted by unicode_data_js
// https://github.com/sam0737/unicode_data_js
//
// Original URL: %s
// ----------------------------------------------
//
// Copyright (c) 1991-2012 Unicode, Inc. All rights reserved. 
// Distributed under the Terms of Use in http://www.unicode.org/copyright.html.
// 
EOF

my $handlers = {
    mapping => sub {
        my ($url, $data, $filename, $type) = @_;
        my $output = '';
        foreach (split(/[\r\n]+/, $data)) {
            if (/^\s* (0x[0-9a-fA-F]+) \s+ (0x[0-9a-fA-F]+)/x) {
                $output .= "$1:$2,\n";
            } elsif (/^\s*#(.*)$/) {
                $output .= "//$1\n";
            }
        }
        $output = sprintf("$mapping_comment", $url) . "$json_callback({\n${output}'_':'_'});";
        writeOutput("mappings/$filename.txt", $output);
    }
};

while (my $r = <DATA>) {
    chomp $r;
    $r =~ s/#.*$//;
    next if $r =~ /^\s*$/;

    print "Processing $r...\n";

    my @params = split(/,/,$r);
    my $url = pop @params;
    my $type = shift @params;
    my $data = get($url);
    $handlers->{$type}->($url, $data, @params);
}

sub writeOutput
{
    my ($filename, $data) = @_;
    open(my $fh, '>:utf8', $filename);
    print $fh $data;
    close($fh);
}

__DATA__
# Mappings
mapping,cp1252,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1252.TXT
mapping,iso8859-1,n,http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-1.TXT
mapping,cp437,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP437.TXT
mapping,cp037,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/EBCDIC/CP037.TXT
# Thai
mapping,cp874,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP874.TXT
# Japanese (Shift JIS)
mapping,cp932,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP932.TXT
# Simplified Chinese (GBK)
mapping,cp936,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP936.TXT
# Korean
mapping,cp949,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP949.TXT
# Traditional Chinese (Big5)
mapping,cp950,n,http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP950.TXT
