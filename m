From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: Fix inappropriate output of procfs
Date: Mon, 6 Nov 2017 15:26:47 +0100
Message-ID: <20171106142647.GA8571@salvia>
References: <20171015115406.GA11429@nuc02.localdomain>
 <alpine.LFD.2.20.1710151709450.2100@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1710151709450.2100@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: KUWAZAWA Takuya <albatross0@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Sun, Oct 15, 2017 at 05:11:28PM +0300, Julian Anastasov wrote:
> On Sun, 15 Oct 2017, KUWAZAWA Takuya wrote:
> 
> > Information about ipvs in different network namespace can be seen via procfs.
> > 
> > How to reproduce:
> > 
> >   # ip netns add ns01
> >   # ip netns add ns02
> >   # ip netns exec ns01 ip a add dev lo 127.0.0.1/8
> >   # ip netns exec ns02 ip a add dev lo 127.0.0.1/8
> >   # ip netns exec ns01 ipvsadm -A -t 10.1.1.1:80
> >   # ip netns exec ns02 ipvsadm -A -t 10.1.1.2:80
> > 
> > The ipvsadm displays information about its own network namespace only.
> > 
> >   # ip netns exec ns01 ipvsadm -Ln
> >   IP Virtual Server version 1.2.1 (size=4096)
> >   Prot LocalAddress:Port Scheduler Flags
> >     -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
> >   TCP  10.1.1.1:80 wlc
> > 
> >   # ip netns exec ns02 ipvsadm -Ln
> >   IP Virtual Server version 1.2.1 (size=4096)
> >   Prot LocalAddress:Port Scheduler Flags
> >     -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
> >   TCP  10.1.1.2:80 wlc
> > 
> > But I can see information about other network namespace via procfs.
> > 
> >   # ip netns exec ns01 cat /proc/net/ip_vs
> >   IP Virtual Server version 1.2.1 (size=4096)
> >   Prot LocalAddress:Port Scheduler Flags
> >     -> RemoteAddress:Port Forward Weight ActiveConn InActConn
> >   TCP  0A010101:0050 wlc
> >   TCP  0A010102:0050 wlc
> > 
> >   # ip netns exec ns02 cat /proc/net/ip_vs
> >   IP Virtual Server version 1.2.1 (size=4096)
> >   Prot LocalAddress:Port Scheduler Flags
> >     -> RemoteAddress:Port Forward Weight ActiveConn InActConn
> >   TCP  0A010102:0050 wlc
> > 
> > Signed-off-by: KUWAZAWA Takuya <albatross0@gmail.com>
> 
> 	Looks good to me
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
