From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Don't protect ip_vs_addr_is_unicast with
 CONFIG_SYSCTL
Date: Tue, 29 Sep 2015 09:55:46 +0900
Message-ID: <20150929005545.GA22155@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
 <20150925000102.GA5634@salvia>
 <87612ueff4.fsf_-_@x220.int.ebiederm.org>
 <alpine.LFD.2.11.1509282144410.6497@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1509282144410.6497@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Mon, Sep 28, 2015 at 09:45:28PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 28 Sep 2015, Eric W. Biederman wrote:
> 
> > I arranged the code so that the compiler can remove the unecessary bits
> > in ip_vs_leave when CONFIG_SYSCTL is unset, and removed an explicit
> > CONFIG_SYSCTL.
> > 
> > Unfortunately when rebasing my work on top of that of Alex Gartrell I
> > missed the fact that the newly added function ip_vs_addr_is_unicast was
> > surrounded by CONFIG_SYSCTL.
> > 
> > So remove the now unnecessary CONFIG_SYSCTL guards around
> > ip_vs_addr_is_unicast.  It is causing build failures today when
> > CONFIG_SYSCTL is not selected and any self respecting compiler will
> > notice that sysctl_cache_bypass is always false without CONFIG_SYSCTL
> > and not include the logic from the function ip_vs_addr_is_unicast in
> > the compiled code.
> > 
> > Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply to ipvs-next

Thanks, applied.
