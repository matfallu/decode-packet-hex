#!/usr/bin/perl 
package cmn;

use lib '/homes/sksodhi/perl5/lib/perl5';
use strict;
use warnings;
use CGI;
use CGI::Carp 'fatalsToBrowser';

use Exporter;

our @ISA= qw(Exporter);
our @EXPORT = qw(lu_capture);


#
# debug
#
my $cmn_debug             = 1;


my $cnt = 0;

sub debug_log 
{
    my $ctx             = $_[0];
    my $log_to_file     = $_[1];
    my $log_file_name   = $_[2];
    my $log_fh          = $_[3];

    #open($log_fh, ">>", $log_file_name) or die $!; select $log_fh; $| = 1; # No buffering
    open($log_fh, ">>", $log_file_name) or die $!;

    if($cmn_debug) {
        my $timestamp = localtime(time);
        if ($log_to_file) {
            printf $log_fh "[%04d] ", $cnt;
            shift; shift; shift; shift;
            print $log_fh "$timestamp:($ctx) @_",;
            #printf $log_fh "[%04d] %s:(%s) %s\n", $cnt, $timestamp, $ctx, @_;
            $log_fh->flush();

        } else {
            print "[$cnt] $timestamp:($ctx) @_";
        }

    }
    $cnt = $cnt + 1;
}

sub debug_log_printf 
{
    my $ctx             = $_[0];
    my $log_to_file     = $_[1];
    my $log_fh          = $_[2];

    my $timestamp = localtime(time);
    my ($format, @args) = @_;
    my $str = sprintf($format, @args);
    if ($log_to_file) {
        print $log_fh "lu log: $timestamp: $str";
    } else {
        print "lu log: $timestamp: $str";
    }
}

sub open_file 
{
    my ($fh, $log_fh);

    my $file      = $_[0];
    my $mode      = $_[1];
    my $log_file  = $_[2];

    # TODO : Use debug_log ?
    if ($log_file) {
        open $log_fh,'>>', $log_file or die "Can't open the $log_file file: $!";
        print $log_fh "Trying to open $file in $mode mode\n";
    }

    if ( $mode eq "read" ) {
        open $fh,'<', $file or die "Can't open the $file file: $!";
    } elsif ($mode eq "write") {
        open $fh,'>', $file or die "Can't open the $file file: $!";
    } elsif ($mode eq "readwrite") {
        print $log_fh "$file: File opne mode $mode not supported/wrong\n";
    } elsif ($mode eq "append") {
        open $fh,'>>', $file or die "Can't open the $file file: $!";
    } else {
        print $log_fh "$file: File opne mode $mode not supported/wrong\n";
    }

    return $fh;
}

sub close_file 
{
    my ($log_fh);

    my $fh        = $_[0];
    my $log_file  = $_[1];

    $fh->flush();
    close($fh);

    if ($log_file) {
        open $log_fh,'>>', $log_file or die "Can't open the $log_file file: $!";
        print $log_fh "Flushed and closed file\n";
    }
}

sub show_error 
{
    my ($ctx, $log_file_url, $format, @args);
    my ($err_file, $err_fh);

    my $str;
    my $timestamp = localtime(time);

    if (@_ > 4) {
        ($ctx, $log_file_url, $err_file, $format, @args) = @_;
        $str = sprintf($format, @args);
    } else {
        ($ctx, $log_file_url, $err_file, @args) = @_;
        $str = join(" " , @args);
    }

    print "1: $ctx, 2:$log_file_url, 3:$err_file, 4:@args";

    #open $err_fh,'>', $err_file or die "Can't open the $err_file file: $!";
    $err_fh = open_file($err_file, "write");

    #print $err_fh "Content-type: text/html\n\n";
    print $err_fh "<pre>\n";
    print $err_fh "[Error]:($ctx) $str";
    print $err_fh "\n\n\n<a href=\"$log_file_url\" target=\"_blank\">Debug log</a>\n";
    print $err_fh "</pre>\n";

    close_file($err_fh);
}


sub execute_command
{
    my $cmd             = $_[0];
    system("$cmd");
}

sub get_command_output
{
    my $cmd             = $_[0];
    my $cmd_output      = "_________TBD___________";
    return $cmd_output;
}

sub send_mail
{
    my $mail_content_file = $_[0];

    system("sendmail sksodhi\@gmail.com < $mail_content_file");
}



1;
