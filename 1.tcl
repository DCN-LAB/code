#Create Simulator
set ns [new Simulator]
#Open Trace file and NAM file
set ntrace [open prog1.tr w]
$ns trace-all $ntrace
set namfile [open prog1.nam w]
$ns namtrace-all $namfile
#Finish Procedure
proc Finish {} {
global ns ntrace namfile
#Dump all the trace data and close the files
$ns flush-trace
close $ntrace
close $namfile
#/Execute the nam animation file
exec nam prog1.nam &
exec echo "The number of packets dropped are:" &
exec grep -c "^d" prog1.tr &
exit 0
}
#Create 3 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
#Create Links between nodes
#You need to modify the bandwidth to observe the variation in packet drop
$ns duplex-link $n0 $n1 0.2Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
#Set Queue Size
#You can modify the queue length as well to observe the variation in packet drop
$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n2 10
#Set up a Transport layer connection.
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null [new Agent/Null]
$ns attach-agent $n2 $null
$ns connect $udp $null
#Set up an Application layer Traffic
set cbr0 [new Application/Traffic/CBR]
#$cbr0 set type_ CBR
#$cbr0 set packetSize_ 100
#$cbr0 set rate_ 1Mb
#$cbr0 set random_ false
$cbr0 attach-agent $udp
#Schedule Events
$ns at 0.0 "$cbr0 start"
$ns at 5.0 "Finish"
#Run the Simulation
$ns run