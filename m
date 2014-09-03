From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2 net-next] ipvs: reduce stack usage for sockopt data
Date: Wed, 3 Sep 2014 21:17:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409032055520.1750@ja.home.ssi.bg>
References: <1409691769-4413-1-git-send-email-ja@ssi.bg> <20140903091121.GA3735@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140903091121.GA3735@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, Andrey Utkin <andrey.krieger.utkin@gmail.com>, David Binderman <dcb314@hotmail.com>


	Hello,

On Wed, 3 Sep 2014, Pablo Neira Ayuso wrote:

> Hi Julian,
> 
> On Wed, Sep 03, 2014 at 12:02:49AM +0300, Julian Anastasov wrote:
> > Use union to reserve the required stack space for sockopt data
> > which is less than the currently hardcoded value of 128.
> > Now the tables for commands should be more readable.
> > The checks added for readability are optimized by compiler,
> > others warn at compile time if command uses too much
> > stack or exceeds the storage of set_arglen and get_arglen.
> > 
> > As Dan Carpenter points out, we can run for unprivileged user,
> > so we can silent some error messages.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > CC: Dan Carpenter <dan.carpenter@oracle.com>
> > CC: Andrey Utkin <andrey.krieger.utkin@gmail.com>
> > CC: David Binderman <dcb314@hotmail.com>
> > ---
> > 
> > This is 2nd version. I removed the macros and tried to
> > fit in 80 columns... Pablo, please check this version.
> > Also, let us know if you are going to apply the final
> > version directly or whether Simon should take it first.
> > Thanks!
> 
> Thanks for spinning a second version. I took it over and made some
> minor comestic changes. I noticed SET_CMDID() is equivalent to
> GET_CMDID() so, while at it, I have merged them. This allowed me to
> fit the structure in 80-chars per column by using spaces to pad the
> initialization area (I remeber to have seen this trick in other parts
> of the kernel code).

	Thanks, it looks better now.

> An another question, in do_ip_vs_get_ctl() I can see:
> 
> +       copylen = get_arglen[CMDID(cmd)];
> +       if (*len < (int) copylen || *len < 0) {
> 
> len is signed, the casting also enforces signed arithmetics. copylen
> can be 0 at worst case for unused options. Perhaps I'm overlooking
> something but I think *len < 0 is redundant.

	Yes, I added it for readability, it can be
removed, I checked that it does not generate code when
I added it. IIRC, Arjan van de Ven mentioned
about gcc reporting for missing range checks when
commit 04bcef2a83f40c6db24222b
("ipvs: Add boundary check on ioctl arguments") was
discussed. This is his posting:

http://marc.info/?l=linux-netdev&m=125443389131548&w=2

	But I don't know how to check for such warnings
and if they are still reported.

Regards

--
Julian Anastasov <ja@ssi.bg>
