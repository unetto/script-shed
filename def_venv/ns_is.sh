ip netns list | awk '{print $1}' | while read ns; do sudo ip netns exec $ns ifconfig; done
