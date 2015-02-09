From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fix inability to remove a mixed-family RS
Date: Mon, 9 Feb 2015 14:25:26 +0900
Message-ID: <20150209052523.GA9021@verge.net.au>
References: <54D516C4.8080504@al-an.info>
 <alpine.LFD.2.11.1502062217360.4440@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1502062217360.4440@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alexey Andriyanov <alan@al-an.info>, lvs-devel@vger.kernel.org, Alex Gartrell <agartrell@fb.com>

On Fri, Feb 06, 2015 at 10:27:52PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 6 Feb 2015, Alexey Andriyanov wrote:
> 
> > The current code prevents any operation with a mixed-family dest
> > unless IP_VS_CONN_F_TUNNEL flag is set. The problem is that it's impossible
> > for the client to follow this rule, because ip_vs_genl_parse_dest does
> > not even read the destination conn_flags when cmd = IPVS_CMD_DEL_DEST
> > (need_full_dest = 0).
> > 
> > Also, not every client can pass this flag when removing a dest. ipvsadm,
> > for example, does not support the "-i" command line option together with
> > the "-d" option.
> > 
> > This change disables any checks for mixed-family on IPVS_CMD_DEL_DEST command.
> > 
> > Signed-off-by: Alexey Andriyanov <alan@al-an.info>
> 
> 	Good catch.
> 
> Fixes: bc18d37f676f ("ipvs: Allow heterogeneous pools now that we support them")
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply this bug fix.

Thanks, done.
