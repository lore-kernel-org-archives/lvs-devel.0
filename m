From: Simon Kirby <sim@hostway.ca>
Subject: Inability to IPVS DR with nft dnat since 9971a514ed26
Date: Tue, 26 Mar 2019 23:26:50 -0700
Message-ID: <20190327062650.GA10700@hostway.ca>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

Hello!

We have been successfully using nft dnat and IPVS in DR mode on 4.9, 4.14
kernels, but since upgrading to 4.19, such rules now appear to miss the
IPVS input hook and instead appear to hit localhost (and "tcpdump -ni lo"
shows the packets) instead of being forwarded to a real server.

I bisected this to 9971a514ed2697e542f3984a6162eac54bb1da98 ("netfilter:
nf_nat: add nat type hooks to nat core").

It should be pretty easy to see this with a minimal setup:

/etc/nftables.conf:

table ip nat {
        chain prerouting {
                type nat hook prerouting priority 0;

		ip daddr $ext_ip dnat to $vip
	}
	chain postrouting {
		type nat hook postrouting priority 100;

		# In theory this hook no longer needed since this commit,
		# but we also need to do some unrelated snatting.
	}
}

/etc/sysctl.conf:
	
net.ipv4.conf.all.accept_local = 1
net.ipv4.vs.conntrack = 1

IPVS DR setup:

ipvsadm -A -t $vip:80 -s wrr
ipvsadm -a -t $vip:80 -r $real_ip:80 -g -w 100

On the real server, the vip has to be bound to lo or similar and
net.ipv4.conf.all.arp_announce=2 and net.ipv4.conf.all.arp_ignore=1 as
usual for DR, with a symmetric gateway setup (with accept_local above).
Actually, a real server isn't needed to show the issue here, just another
neighbor to route at.

When it works, the inbound frame (TCP connectin to $ext_ip:80) should be
dnatted and then L2-routed (like a static route) to the MAC of $real_ip,
and sent out that interface. Since this commit, it hits lo instead.

Any ideas on what is going wrong here?

Note that we ended up using originally using nftables here because it let
us do one more thing: hairpin NAT _with_ IPVS all on the same host with
"type nat hook input priority -99" and applying snat there. The abillity
to specify hook priorities made this possible. I haven't checked if this
is still working or not, yet, though.

Simon-
