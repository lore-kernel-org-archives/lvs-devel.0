From: Franchoze Eric <franchoze@yandex.ru>
Subject: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 07:51:20 +0400
Message-ID: <27901279770680@web67.yandex.ru>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex.ru; s=mail;
	t=1279770680; bh=5kQtMELCLJ1bGX2FmZdaMs47dfgEwXrlUSrKjUJkbIw=;
	h=From:To:Cc:Subject:MIME-Version:Message-Id:Date:
	 Content-Transfer-Encoding:Content-Type;
	b=iXsneZXhGYwuQD9vDYQ0D7iPH4fX+TKrpeSTugVBKz4JMRZAS0u7Z3mUxa040L6b3
	 WWH4u9+uxWx/Qe2rPUwx4Z/lxPDbrvsju22ICkH5yPpGEVVaqSAdH3jk+pd7H+RItk
	 i3djsMEC5vCHAjuorqop28T0+ljwQoEeB8cdo3sw=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: wensong@linux-vs.org
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Hello,

I'm trying to do load balancing of incoming traffic to my applications. This applications are not very  smp friendly, and I want try to run some instances according to number of cpus on single machine. And balance load of incoming traffic/connections to this applications.
Looks like is should be similar to http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.localnode.html

 linux kernel 2.6.32 with  or without hide interface patches.  Tried different configurations but could not see packets on application layer.

192.168.1.165 - eth0 - interface for external connections
195.0.0.1 - dummy0 - virtual interface, real application is binded to that address.

Configuration is:
-A -t 192.168.1.165:1234 -s wlc
-a -t 192.168.1.165:1234 -r 195.0.0.1:1234 -g -w

#ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.165:1234 wlc
  -> 195.0.0.1:1234               Local   1      0          0        
#

Log:
[ 2106.897409] IPVS: lookup/out TCP 192.168.1.165:44847->192.168.1.165:1234 not hit
[ 2106.897412] IPVS: lookup service: fwm 0 TCP 192.168.1.165:1234 hit
[ 2106.897414] IPVS: ip_vs_wlc_schedule(): Scheduling...
[ 2106.897416] IPVS: WLC: server 195.0.0.1:1234 activeconns 0 refcnt 2 weight 1 overhead 1
[ 2106.897418] IPVS: Enter: ip_vs_conn_new, net/netfilter/ipvs/ip_vs_conn.c line 693
[ 2106.897421] IPVS: Bind-dest TCP c:192.168.1.165:44847 v:192.168.1.165:1234 d:195.0.0.1:1234 fwd:L s:0 conn->flags:181 conn->refcnt:1 dest->refcnt:3
[ 2106.897425] IPVS: Schedule fwd:L c:192.168.1.165:44847 v:192.168.1.165:1234 d:195.0.0.1:1234 conn->flags:1C1 conn->refcnt:2
[ 2106.897429] IPVS: TCP input  [S...] 195.0.0.1:1234->192.168.1.165:44847 state: NONE->SYN_RECV conn->refcnt:2
[ 2106.897431] IPVS: Enter: ip_vs_null_xmit, net/netfilter/ipvs/ip_vs_xmit.c line 212
[ 2106.897439] IPVS: lookup/in TCP 192.168.1.165:1234->192.168.1.165:44847 not hit
[ 2106.897441] IPVS: lookup/out TCP 192.168.1.165:1234->192.168.1.165:44847 not hit
[ 2107.277535] IPVS: packet type=1 proto=17 daddr=255.255.255.255 ignored
[ 2108.542691] IPVS: packet type=1 proto=17 daddr=192.168.1.255 ignored

As the result, server application does receive anything on accept(). I tried to make dummy0 a hidden device and play with arp settings. But without result.

I will be happy to hear any idea how to do connection in this environment.


