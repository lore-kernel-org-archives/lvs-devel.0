From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] libipvs: fix some buffer sizes
Date: Fri, 25 May 2018 11:34:19 +0200
Message-ID: <20180525093414.hftwiqgunkpkvm6q@verge.net.au>
References: <20180524203745.25950-1-ja@ssi.bg>
	<20180525092935.39a68441@redhat.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1527240862; bh=PevVtQzrmT3nAJzSPAZz+1zkToFEXp945U7PYgB+dKg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=gvxLG0rF/C9QZGv4qj/3jYvpKRk2vQsnQS0GzyRfhQBQvFWoRkAkXh1QegZfNmZx5
	3SauXO9t8kukl9CCnL4xq/NboK0OhHUIEPgXEndDP3cx1EHffc+sOHMj1p0TNyVPYb
	DPHUiAV+ujkeIkgqp5NmlR+MbbdWBTIBgfG+fzLg=
Content-Disposition: inline
In-Reply-To: <20180525092935.39a68441@redhat.com>
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
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Julian Anastasov <ja@ssi.bg>

On Fri, May 25, 2018 at 09:29:35AM +0200, Jesper Dangaard Brouer wrote:
> 
> On Thu, 24 May 2018 23:37:45 +0300 Julian Anastasov <ja@ssi.bg> wrote:
> 
> > Size or length? Here is the answer:
> > 
> > - IP_VS_SCHEDNAME_MAXLEN and IP_VS_IFNAME_MAXLEN are sizes
> > because they are used in kernel structures exported to user
> > space for the old setsockopt interface. We can not change
> > these structures in the kernel.
> > 
> > - IP_VS_PENAME_MAXLEN and IP_VS_PEDATA_MAXLEN are max lengths
> > because they are not exported to the old interface.
> > 
> > As result:
> > - buffers should have space for NUL terminator
> > - strncpy should use sizeof(buffer) - 1 as max length
> > 
> > As we change the libipvs structures, their users should be
> > recompiled.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> This all looks fine to me.  I'll give other people a little time to
> review and ACK, before I apply this.
> 
> (To Julian) did you find this by manual review, or did you use some tool
> to find these?

Acked-by: Simon Horman <horms@verge.net.au>
