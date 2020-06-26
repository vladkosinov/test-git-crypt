# https://github.com/hwdsl2/docker-ipsec-vpn-server/blob/master/run.sh

iptables -A FORWARD -p tcp -i eth0 -o ppp+ --dport 8082 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 8082 -j DNAT --to-destination 192.168.42.8

iptables -A FORWARD -p tcp -i eth0 -o ppp+ --dport 54557 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 54557 -j DNAT --to-destination 192.168.42.8

# iptables -A FORWARD -j DROP
