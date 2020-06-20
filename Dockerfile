FROM hwdsl2/ipsec-vpn-server

ADD forwarding.sh /opt/src/forwarding.sh
RUN sed -i -r -e 's/(^\"\$VPN_USER\" l2tpd \"\$VPN_PASSWORD\" )\*/\1192.168.42.8/' /opt/src/run.sh && \
    sed -i -e '/iptables -A FORWARD -j DROP/r forwarding.sh' -e 's/iptables -A FORWARD -j DROP//' /opt/src/run.sh

CMD ["/opt/src/run.sh"]