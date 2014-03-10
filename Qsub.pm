#!/usr/bin/perl
# Author : Vishal N Koparde, Ph.D.
# Created : 120709
# Modified : 120709

package Qsub;

sub new
{
    my ($class, %hash) = @_;
    print "working directory not set for $self\n" if (!defined $hash{wd});
    exit if (!defined $hash{wd});
    print "name not set for $self\n" if (!defined $hash{name});
    exit if (!defined $hash{name});
    my $self = \%hash;
    bless $self, $class;
    return $self;
}


sub submit {
    my ($self) = @_;
    die "Job $self->{name} called with no command.\n" unless (defined $self->{cmd});
    my $qsub="/usr/global/sge/bin/lx24-amd64/qsub -N $self->{name} -wd $self->{wd}";
    $qsub .= " -l mem_free=$self->{memory}" if (defined $self->{memory});
    $qsub .= " -q $self->${queue}" if (defined $self->{queue});
    $qsub .= " -pe smp $self->{nproc}" if (defined $self->{nproc});
    $qsub .= " -o $self->{outfile}" if (defined $self->{outfile});
    $qsub .= " -e $self->{errfile}" if (defined $self->{errfile});
    $qsub .= " -hold_jid $self->{waitfor}" if (defined $self->{waitfor});
    my $qsubcmd = "$qsub /usr/global/blp/bin/qsub_GAP.sh \"$self->{cmd}\"";
    print $qsubcmd ."\n";
    my $qsuboutput = qx($qsub /usr/global/blp/bin/qsub_GAP.sh "$self->{cmd}");        
    my @tmp = split / /,$qsuboutput;
    $self->{jobid}=$tmp[2];
    return;
}

sub status {
    my ($self) = @_;
    my $status="Undetermined";
    if (`/usr/global/sge/bin/lx24-amd64/qstat|grep $self->{jobid}|wc -l` == 1) {
        my $tmp=`/usr/global/sge/bin/lx24-amd64/qstat|grep $self->{jobid}`;
        chomp $tmp;
        $tmp =~ s/^\s+|\s+$//g;
        my @tmp1 = split /\s+/,$tmp;
        $status = "Running" if ( $tmp1[4] eq "r") ;
        $status = "Queued" if ( $tmp1[4] eq "qw") ;
        $status = "Waiting" if ( $tmp1[4] eq "hqw") ;
    } else {
        $status="Completed";
    }
    return $status;
}

sub waitForCompletion {
    my ($self) = @_;
    while (`/usr/global/sge/bin/lx24-amd64/qstat|grep $self->{jobid}|wc -l` == 1) {
        sleep(10);
    }
    return;
}

1;
