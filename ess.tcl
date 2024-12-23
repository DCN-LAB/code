# Create a NS simulator object
set ns [new Simulator]
#setup trace support by opening file p5.tr and call the procedure trace-all
set tf [open p5.tr w]
$ns trace-all $tf
#create a topology object that keeps track of movements of mobile nodes
#within the topological boundary.
set topo [new Topography]
$topo load_flatgrid 1000 1000
set nf [open p5.nam w]
$ns namtrace-all-wireless $nf 1000 1000
# creating a wireless node you MUST first select (configure) the node
#configuration parameters to "become" a wireless node.
#Destination-Sequenced Distance-Vector Routing (DSDV) -------------- DSDV or DSR or TORA
$ns node-config -adhocRouting DSDV \
-llType LL \
-macType Mac/802_11 \
-ifqType Queue/DropTail \
-ifqLen 50 \
-phyType Phy/WirelessPhy \
-channelType Channel/WirelessChannel \
-propType Propagation/TwoRayGround \
-antType Antenna/OmniAntenna \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON
# Create god object
create-god 3
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
$n0 label "tcp0"
$n1 label "sink1/tcp1"
$n2 label "sink2"
$n0 set X_ 50
$n0 set Y_ 50
$n0 set Z_ 0
$n1 set X_ 100
$n1 set Y_ 100
$n1 set Z_ 0
$n2 set X_ 600
$n2 set Y_ 600
$n2 set Z_ 0
$ns at 0.1 "$n0 setdest 50 50 15"
$ns at 0.1 "$n1 setdest 100 100 25"
$ns at 0.1 "$n2 setdest 600 600 25"
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$ns connect $tcp0 $sink1
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set sink2 [new Agent/TCPSink]
$ns attach-agent $n2 $sink2
$ns connect $tcp1 $sink2
$ns at 5 "$ftp0 start"
$ns at 5 "$ftp1 start"
$ns at 100 "$n1 setdest 550 550 15"
$ns at 190 "$n1 setdest 70 70 15"
proc finish { } {
global ns nf tf
$ns flush-trace
exec nam p5.nam &
exec awk -f p5.awk p5.tr &
close $tf
exit 0
}
$ns at 250 "finish"
$ns run
AWK Script
BEGIN{
count1=0
count2=0
pack1=0
pack2=0
time1=0
time2=0
}
{
if($1 == "r" && $3 == "_1_" && $4 == "AGT")
{
count1++
pack1=pack1+$8
time1=$2
}
if($1 == "r" && $3 == "_2_" && $4 =="AGT")
{
count2++
pack2=pack2+$8
time2=$2
}
}
END{
printf("\n The Throughput from n0 to n1: %f Mbps \n",
((count1*pack1*8)/(time1)));
printf("\n The Throughput from n1 to n2: %f Mbps \n",
((count2*pack2*8)/(time2)));
}