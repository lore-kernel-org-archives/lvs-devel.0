From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipvs: changes related to service usecnt
Date: Tue, 21 Sep 2010 18:15:09 +0200
Message-ID: <4C98DA0D.2000804@trash.net>
References: <Pine.LNX.4.58.1009181704560.8786@u.domain.uli> <20100919114758.GA18134@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100919114758.GA18134@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Am 19.09.2010 13:48, schrieb Simon Horman:
> On Sat, Sep 18, 2010 at 05:18:46PM +0300, Julian Anastasov wrote:
>> > 
>> > 	Change the usage of svc usecnt during command execution:
>> > 
>> > - we check if svc is registered but we do not need to hold usecnt
>> > reference while under __ip_vs_mutex, only the packet handling needs
>> > it during scheduling
>> > 
>> > - change __ip_vs_service_get to __ip_vs_service_find and
>> > __ip_vs_svc_fwm_get to __ip_vs_svc_fwm_find because now caller
>> > will increase svc->usecnt
>> > 
>> > - put common code that calls update_service in __ip_vs_update_dest
>> > 
>> > - put common code in ip_vs_unlink_service() and use it to unregister
>> > the service
>> > 
>> > - add comment that svc should not be accessed after ip_vs_del_service 
>> > anymore
>> > 
>> > - all IP_VS_WAIT_WHILE calls are now unified: usecnt > 0
>> > 
>> > - Properly log the app ports
>> > 
>> > 	As result, some problems are fixed:
>> > 
>> > - possible use-after-free of svc in ip_vs_genl_set_cmd after
>> > ip_vs_del_service because our usecnt reference does not guarantee that
>> > svc is not freed on refcnt==0, eg. when no dests are moved to trash
>> > 
>> > - possible usecnt leak in do_ip_vs_set_ctl after ip_vs_del_service
>> > when the service is not freed now, for example, when some
>> > destionations are moved into trash and svc->refcnt remains above 0.
>> > It is harmless because svc is not in hash anymore.
>> > 
>> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Hi Julian,
> 
> thats a pretty big patch to review, but it looks good to me.

Indeed, I'd prefer slightly smaller patches too.
 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
