From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 net] net: free ip_vs_dest structs when refcnt=0
Date: Fri, 27 Jan 2017 19:37:47 +0100
Message-ID: <20170127183746.GC13402@verge.net.au>
References: <1485228269-21758-1-git-send-email-dwindsor@gmail.com>
 <alpine.LFD.2.11.1701262241280.3892@ja.home.ssi.bg>
 <20170127080738.GD21195@verge.net.au>
 <20170127122111.GA2495@salvia>
Mime-Version: 1.0
Return-path: <kernel-hardening-return-6186-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-ID: <lvs-devel.vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1485542270; bh=dNxuB6lkUcAPARITJBtyGYc5jIncsee9wO4msnMibVs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=OY6m5SsRZOc44xiW4OvQ1xjT872kxDfhF9QfUVJWfcH2W+6lo5/54GijhKRHVR0/N
	 T5m0WHBZ0c0lXE9H1feXyj5FwEYAge5cm4JTV3U1X9jjJti87azjCdvKvfNDESfHRd
	 NkdSVJYb/L9IuZ9s2TaPcVNJsuevL4/E0nnuga7s=
Content-Disposition: inline
In-Reply-To: <20170127122111.GA2495@salvia>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, David Windsor <dwindsor@gmail.com>, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, keescook@chromium.org, elena.reshetova@intel.com, ishkamiel@gmail.com

On Fri, Jan 27, 2017 at 01:21:11PM +0100, Pablo Neira Ayuso wrote:
> On Fri, Jan 27, 2017 at 09:07:38AM +0100, Simon Horman wrote:
> > On Thu, Jan 26, 2017 at 10:49:10PM +0200, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Mon, 23 Jan 2017, David Windsor wrote:
> > > 
> > > > Currently, the ip_vs_dest cache frees ip_vs_dest objects when their
> > > > reference count becomes < 0.  Aside from not being semantically sound,
> > > > this is problematic for the new type refcount_t, which will be introduced
> > > > shortly in a separate patch. refcount_t is the new kernel type for
> > > > holding reference counts, and provides overflow protection and a
> > > > constrained interface relative to atomic_t (the type currently being
> > > > used for kernel reference counts).
> > > > 
> > > > Per Julian Anastasov: "The problem is that dest_trash currently holds
> > > > deleted dests (unlinked from RCU lists) with refcnt=0."  Changing
> > > > dest_trash to hold dest with refcnt=1 will allow us to free ip_vs_dest
> > > > structs when their refcnt=0, in ip_vs_dest_put_and_free().
> > > > 
> > > > Signed-off-by: David Windsor <dwindsor@gmail.com>
> > > 
> > > 	Thanks! I tested the first version and this one
> > > just adds the needed changes in comments, so
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > 
> > > 	Simon and Pablo, this is more appropriate for
> > > ipvs-next/nf-next. Please apply!
> > 
> > Pablo, would you mind taking this one directly into nf-next?
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Sure, no problem. I'll take it. Thanks!

Thanks!
