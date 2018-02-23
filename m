From: Vincent Li <vincent.mc.li@gmail.com>
Subject: IPVS trouble shooting tips in Kubernetes kube-proxy
	ipvs mode
Date: Fri, 23 Feb 2018 15:43:40 -0800
Message-ID: <CAK3+h2yaFw-TtA-UQ6CxSeTYXDcO0v0CJ-u8z+94=ond2xAj2g@mail.gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
	h=mime-version:from:date:message-id:subject:to;
	bh=RuRik8PKo3/jywoizpjS+wGyhwCm3SYgxIBGdd2YoO4=;
	b=FJwkMonFDC1nr9nlCc3R4FMSqzZn8Db1OwOVWhXpcO5QtAmTys/IOZP7EDEmhhjWnM
	cdpxzDJ0mQ2Mm9wte4nQmGXLTm3wZE4hJqXfbAyekejnjtUHDDRzuvKVmHQMx0sdTunS
	OQab8mgfBUm1OLOq4J52Df73kP3m+KvrgOtLcb+0dKxPqYdlW4G5JyCAkzJSqlDCOEN7
	+zEVS5ul/3ND9gNWfLOhhqjaitKGU71a3NsxwR1cyFlWt76RlXXXShrRcihQCh4ORODC
	n13VVkB1jtCJ7gvuXbGQ8hfH2Nw/fWA8CzeR7Tg1z4c3dXCCbmA3ciz2vfTMQWMV1wMk
	Fe1A==
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>, lvs-devel@vger.kernel.org

Hi

I am experimenting Kubernetes kube-proxy ipvs mode in my lab and
kube-proxy end up with ipvs service as below on both k8s master node
and worker node:

k8s master node:

[root@centos-k8s kubernetes]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.0.0.1:443 rr persistent 10800
  -> 192.168.1.168:6443           Masq    1      1          0
TCP  10.0.0.10:53 rr
  -> 10.244.0.28:53               Masq    1      0          0
UDP  10.0.0.10:53 rr
  -> 10.244.0.28:53               Masq    1      0          0



k8s worker node:

[root@centos-k8s-node1 kubernetes]# ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.0.0.1:443 rr persistent 10800
  -> 192.168.1.168:6443           Masq    1      0          0
TCP  10.0.0.10:53 rr
  -> 10.244.0.28:53               Masq    1      0          0
UDP  10.0.0.10:53 rr
  -> 10.244.0.28:53               Masq    1      0          0

the problem is on k8s worker node, telnet can't reach to 10.0.0.1:443.

[root@centos-k8s-node1 kubernetes]# telnet 10.0.0.1 443
Trying 10.0.0.1...
^C

on k8s master node, I can telnet to ipvs service 10.0.0.1:443 fine,

[root@centos-k8s kubernetes]# telnet 10.0.0.1 443
Trying 10.0.0.1...
Connected to 10.0.0.1.
Escape character is '^]'.
^]
telnet>


the real ip:port 192.168.1.168:6443 is k8s api services running on k8s
master node

[root@centos-k8s kubernetes]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc pfifo_fast
state UP qlen 1000
    link/ether 52:54:00:cf:91:8e brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.168/24 brd 192.168.1.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::fdfd:fb1f:204f:e03f/64 scope link
       valid_lft forever preferred_lft forever

both k8s master and worker node has dummy interface kube-ipvs0 with ip
10.0.0.1 automatically setup by kube-proxy ipvs

[root@centos-k8s kubernetes]# ip addr show dev kube-ipvs0
6: kube-ipvs0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
    link/ether 06:a9:58:8e:c6:a5 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.1/32 brd 10.0.0.1 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.0.0.10/32 brd 10.0.0.10 scope global kube-ipvs0
       valid_lft forever preferred_lft forever

on worker node, when I telnet 10.0.0.1, ideally, 10.0.0.1 should be
DNAT to 192.168.1.168...but when run tcpdump on interface lo or
kube-ipvs0 or real interface eth1, I see nothing, no SYN, arp...
packet.


 this leads me to think would this ipvs rule actually work with a
dummy interface with a dummy virtual ip, and real ip on a separate
machine?

I thought there might be some iptables rule configured by kube-proxy
dropping the packet, here is iptables rule setup by Kubernetes
kube-proxy on the worker node:

filter table

[root@centos-k8s-node1 kubernetes]# iptables -n -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
KUBE-FIREWALL  all  --  0.0.0.0/0            0.0.0.0/0

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
DOCKER-ISOLATION  all  --  0.0.0.0/0            0.0.0.0/0
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            ctstate
RELATED,ESTABLISHED
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
KUBE-FIREWALL  all  --  0.0.0.0/0            0.0.0.0/0

Chain DOCKER (1 references)
target     prot opt source               destination

Chain DOCKER-ISOLATION (1 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0

Chain KUBE-FIREWALL (2 references)
target     prot opt source               destination
DROP       all  --  0.0.0.0/0            0.0.0.0/0            /*
kubernetes firewall for dropping marked packets */ mark match
0x8000/0x8000

nat table:

[root@centos-k8s-node1 kubernetes]# iptables -t nat -n -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
KUBE-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            /*
kubernetes service portals */
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE
match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
KUBE-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            /*
kubernetes service portals */
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE
match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
KUBE-POSTROUTING  all  --  0.0.0.0/0            0.0.0.0/0
/* kubernetes postrouting rules */
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0

Chain KUBE-FIRE-WALL (0 references)
target     prot opt source               destination

Chain KUBE-MARK-DROP (0 references)
target     prot opt source               destination
MARK       all  --  0.0.0.0/0            0.0.0.0/0            MARK or 0x8000

Chain KUBE-MARK-MASQ (0 references)
target     prot opt source               destination
MARK       all  --  0.0.0.0/0            0.0.0.0/0            MARK or 0x4000

Chain KUBE-POSTROUTING (1 references)
target     prot opt source               destination
MASQUERADE  all  --  0.0.0.0/0            0.0.0.0/0            /*
kubernetes service traffic requiring SNAT */ mark match 0x4000/0x4000
MASQUERADE  all  --  0.0.0.0/0            0.0.0.0/0
match-set KUBE-LOOP-BACK dst,dst,src

Chain KUBE-SERVICES (2 references)
target     prot opt source               destination


Do you suspect any iptables rule will be dropping the packet quietly ?

is there anything else in ipvs I could  to trace to the origin of the problem?

FYI, I have full detail lab information in
https://github.com/kubernetes/kubernetes/issues/60161

I also have same problems with kube-proxy iptables mode, but i am
hoping tracing through ipvs ( I am more comfortable trouble shooting
ipvs than trouble shooting iptables :)) I maybe  able to find what
configured wrong or what potential bugs I hit in kubernetes kube-proxy
network

Regards,

Vincent
