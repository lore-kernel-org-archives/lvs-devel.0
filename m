From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] IPVS: make failure of netns init more stable
Date: Mon, 23 Apr 2012 22:22:22 +0900
Message-ID: <20120423132222.GB13990@verge.net.au>
References: <3r6npeu.69e743752dad7d8eb6a19cbbbdfd1ed9@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3r6npeu.69e743752dad7d8eb6a19cbbbdfd1ed9@obelix.schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

On Wed, Apr 18, 2012 at 02:37:43PM +0200, Hans Schillstrom wrote:
> Hello 
> >
> >Hello,
> >
> >On Tue, 17 Apr 2012, Hans Schillstrom wrote:
> >
> >> I wonder if we are chasing ghosts...
> >> 
> >> With proper fault handling I can't even see a case when it (net->ipvs) can be used.
> >> Can you see a case when it could happen?
> >> Still we can set it to NULL on error exit and cleanup as you suggested, that doesn't harm I think.
> >> 
> >> A. If you add a netns and it fails the entire ns will be rolled back, 
> >>    and no access to that ns can occur.
> >>    That ns does not exist
> >
> >	Agreed
> >
> >> B. If you insert ip_vs.ko when having one or more name spaces and 
> >>    __ip_vs_init() returns an error the module will be unloaded.
> >>    All ready loaded ns will not be affected.
> >
> >	Yes, ip_vs_init fails.
> >
> >> C. insmod of ex. ip_vs_ftp only affects loaded name spaces
> >>    and if the load of ip_vs_ftp fails it will be unloaded without affecting ip_vs(.ko)
> >>    (If ip_vs.ko is not loaded then it has to be loaded first case B...)
> >> 
> >> With a "compiled in" ip_vs case B doesn't exist.
> >
> >	It is this case that can happen, we can only guess how
> >difficult is to get ENOMEM here. IIRC, we can generate only
> >ENOMEM error on IPVS core load.
> >
> >	I assume Simon has such setup and changes code to
> >trigger load error. When I generate ENOMEM on IPVS core init
> >for such case I get ENOENT from register_ip_vs_app when
> >patch 1 and 2 for apps are applied, i.e. net->ipvs is NULL.
> >You can check it with NF_CONNTRACK=y, IP_VS=y and
> >IP_VS_FTP=m. You only need to trigger ENOMEM in __ip_vs_init.
> 
> 
> I did test this with 4 netns loaded and modprobe ip_vs_ftp
> In the 4:th netns  (ipvs->gen >= 4) fire a -ENOMEM 
> The result was as expected, ip_vs_ftp was not loaded.
> 
> All patches below was loaded. (included the ipvs NULL check)
> 
> Just for "fun" I also added a printk in the ipvs NULL check
> but I can't trigger it. 
> 
> Simon:
>  do you have any possibility to test it or give me a hint how to do ?
> (Just to make sure that the patches below will be sufficient)

Hi,

Julian is correct. I made a hack to the code to force it to fail in
ip_vs_protocol_net_init() right after calling register_ip_vs_proto_netns()
for TCP.

With "netfilter: ipvs: Verify that IP_VS protocol has been registered"
applied I think that you could implement the same "test" by jumping to
cleanup after the first call to register_ip_vs_proto_netns() in the for
loop.

In my test all components of IPVS were compiled into the kernel,
no modules.
