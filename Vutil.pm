#!/usr/bin/perl
# Author : Vishal N Koparde, Ph.D.
# Created : 140114
# Modified : 140114

package Vutil;

sub fileCheck{
    my ($filename,$msg)=@_;
#    $msg=$msg?$msg:"";
    $msg="" unless defined $msg;
    if ( ! -f $filename ) {
        print "File ".$filename." does not exist!\n$msg\n";
        print "Exiting!!!\n";
        exit;
    } else {
	my $filesize;
	$filesize = -s $filename;
	if ( $filesize == 0 ) {
        print "File ".$filename." is empty!\n$msg\n";
        print "Exiting!!!\n";
        exit;
	}
    }
	
}

sub runInParallel{
    my ($filename,$ncpus)=@_;
    fileCheck($filename,"Cannot run this $filename in parallel!");
    $ncpus=$ncpus?$ncpus:4;
    $cmd="/home/vnkoparde/bin/parallel -j $ncpus < ".$filename;
    system($cmd);
}

sub getFileAbsolutePath{
	my ($file)=@_;
	use Cwd;
	use File::Basename;
	my ($filename,$path)=fileparse(Cwd::abs_path($file));
	return $path;
}

1;
