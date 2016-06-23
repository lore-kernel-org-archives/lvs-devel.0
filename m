From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 net] ipvs: fix bind to link-local mcast IPv6 address
 in backup
Date: Thu, 23 Jun 2016 10:27:58 +0900
Message-ID: <20160623012758.GC9412@verge.net.au>
References: <alpine.LFD.2.11.1606160912380.2490@ja.home.ssi.bg>
 <1466060414-12944-1-git-send-email-quentin@armitage.org.uk>
 <alpine.LFD.2.11.1606170935230.11309@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1466645282; bh=t2stcmuyU7U1J+d+lKAqOyWZDgB0zhl5mplmcGQ12LU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=PzFkCyC57gyzWZdKW0zv9126r13uMgmJxJVp6WKngCRoshnjF8GCIbM7pBJNQrUuu
	 akTKNZCqgzcpL5up6FYEtYKBFOt2tBrCYY+ObDLQtTnoxUHrh/ATviai9rRtQEPJTa
	 g25/olPH1n35YXnl15hRU8PDKkXEnfrjkgj0Nr1I=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1606170935230.11309@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Quentin Armitage <quentin@armitage.org.uk>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Fri, Jun 17, 2016 at 09:42:49AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 16 Jun 2016, Quentin Armitage wrote:
> 
> > When using HEAD from
> > https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/,
> > the command:
> > ipvsadm --start-daemon backup --mcast-interface eth0.60 \
> >     --mcast-group ff02::1:81
> > fails with the error message:
> > Argument list too long
> > 
> > whereas both:
> > ipvsadm --start-daemon master --mcast-interface eth0.60 \
> >     --mcast-group ff02::1:81
> > and:
> > ipvsadm --start-daemon backup --mcast-interface eth0.60 \
> >     --mcast-group 224.0.0.81
> > are successful.
> > 
> > The error message "Argument list too long" isn't helpful. The error occurs
> > because an IPv6 address is given in backup mode.
> > 
> > The error is in make_receive_sock() in net/netfilter/ipvs/ip_vs_sync.c,
> > since it fails to set the interface on the address or the socket before
> > calling inet6_bind() (via sock->ops->bind), where the test
> > 'if (!sk->sk_bound_dev_if)' failed.
> > 
> > Setting sock->sk->sk_bound_dev_if on the socket before calling
> > inet6_bind() resolves the issue.
> > 
> > Fixes: d33288172e72 ("ipvs: add more mcast parameters for the sync daemon")
> > Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply to ipvs tree. Patch compiles
> also on stable 4.4.13, 4.5.7 and 4.6.2, so no need for
> special versions. The ack is also for the other 3 patches
> from v4 (for ipvs-next) but they depend on this patch.

Thanks, done.
