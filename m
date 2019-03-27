From: Florian Westphal <fw@strlen.de>
Subject: Re: Inability to IPVS DR with nft dnat since 9971a514ed26
Date: Wed, 27 Mar 2019 10:30:27 +0100
Message-ID: <20190327093027.gmflo27icuhr326p@breakpoint.cc>
References: <20190327062650.GA10700@hostway.ca>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190327062650.GA10700@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Kirby <sim@hostway.ca>
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

Simon Kirby <sim@hostway.ca> wrote:
> We have been successfully using nft dnat and IPVS in DR mode on 4.9, 4.14
> kernels, but since upgrading to 4.19, such rules now appear to miss the
> IPVS input hook and instead appear to hit localhost (and "tcpdump -ni lo"
> shows the packets) instead of being forwarded to a real server.
> 
> I bisected this to 9971a514ed2697e542f3984a6162eac54bb1da98 ("netfilter:
> nf_nat: add nat type hooks to nat core").
> 
> It should be pretty easy to see this with a minimal setup:
> 
> /etc/nftables.conf:
> 
> table ip nat {
>         chain prerouting {
>                 type nat hook prerouting priority 0;
> 
> 		ip daddr $ext_ip dnat to $vip
> 	}
> 	chain postrouting {
> 		type nat hook postrouting priority 100;
> 
> 		# In theory this hook no longer needed since this commit,
> 		# but we also need to do some unrelated snatting.
> 	}
> }
> 
> /etc/sysctl.conf:
> 	
> net.ipv4.conf.all.accept_local = 1
> net.ipv4.vs.conntrack = 1
> 
> IPVS DR setup:
> 
> ipvsadm -A -t $vip:80 -s wrr
> ipvsadm -a -t $vip:80 -r $real_ip:80 -g -w 100

I have a hard time figuring out how to expand $ext_ip, $vip and $real_ip,
and where to place those addresses on the nft machine.
