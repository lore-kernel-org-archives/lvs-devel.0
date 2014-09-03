From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCHv2 net-next] ipvs: reduce stack usage for sockopt data
Date: Wed, 3 Sep 2014 22:03:00 +0300
Message-ID: <20140903190300.GN6549@mwanda>
References: <1409691769-4413-1-git-send-email-ja@ssi.bg>
 <20140903091121.GA3735@salvia>
 <alpine.LFD.2.11.1409032055520.1750@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1409032055520.1750@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Andrey Utkin <andrey.krieger.utkin@gmail.com>, David Binderman <dcb314@hotmail.com>

On Wed, Sep 03, 2014 at 09:17:38PM +0300, Julian Anastasov wrote:
> > An another question, in do_ip_vs_get_ctl() I can see:
> > 
> > +       copylen = get_arglen[CMDID(cmd)];
> > +       if (*len < (int) copylen || *len < 0) {
> > 
> > len is signed, the casting also enforces signed arithmetics. copylen
> > can be 0 at worst case for unused options. Perhaps I'm overlooking
> > something but I think *len < 0 is redundant.
> 
> 	Yes, I added it for readability, it can be
> removed, I checked that it does not generate code when
> I added it. IIRC, Arjan van de Ven mentioned
> about gcc reporting for missing range checks when
> commit 04bcef2a83f40c6db24222b
> ("ipvs: Add boundary check on ioctl arguments") was
> discussed. This is his posting:
> 
> http://marc.info/?l=linux-netdev&m=125443389131548&w=2
> 
> 	But I don't know how to check for such warnings
> and if they are still reported.
> 

I think you mean CONFIG_DEBUG_STRICT_USER_COPY_CHECKS.  Unfortunately
it's been turned off on recent versions of GCC since 2fb0815c9ee6
('gcc4: disable __compiletime_object_size for GCC 4.6+')

regards,
dan carpenter


