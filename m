From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [RFC PATCH net-next 0/4] ipvs: check scheduler callback return
 values
Date: Mon, 23 Feb 2015 23:51:05 -0800
Message-ID: <54EC2D69.5070300@fb.com>
References: <1424754462-3253312-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1502240914430.1755@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=9zEdHh7tciVpnytEzXtqzFD+BoPNHXY3SZZVrZzJUI8=;
 b=YRZ8Wka3OzKb8GJRbSsQnm4liRfos2EIbGscVz4Sep0ZCSTPZsWpBDQaf6A6UnkI6gq8
 slVsXxfF2o79db+XM3OVGIgPAAJjbqkT77I9gnh1LxiMAZ/RY/rJbTaYA41s8IpDsAHn
 IDXIxeJ8t72pTmuYdss8UdC82Hp1v/zUe4g= 
In-Reply-To: <alpine.LFD.2.11.1502240914430.1755@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: wensong@linux-vs.org, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com

Hey Julian,

Thank you for your quick and thoughtful response :)

On 2/23/15 11:30 PM, Julian Anastasov wrote:
>> We have a custom scheduler that is failing some atomic allocations
>
> 	You can use GFP_KERNEL from add_dest method.
>

That should definitely improve things for us.

>
> 	Can a new create_dest(svc, bool for_update) method
> solve such problem? Such modifications are serialized, so
> create_dest can attach new structure to sched_data just before
> the add_dest/upd_dest call. IPVS does not clone dests on
> update but scheduler may need this for RCU update.
> create_dest should be called early in __ip_vs_update_dest.
> Note that kfree(dest) is not enough, see ip_vs_dest_free(),
> more fields may be allocated before __ip_vs_update_dest is
> reached.

More context on the custom scheduler:

It's a consistent hash ring algorithm which requires sorting all of the 
members and then inserting them one at a time (a entry per weight).  It 
requires a massive allocation to load balance to the number of machines 
we need to.

Right here I'm going to admit that this is not ideal.  This is somewhat 
"inherited," but I'm currently stuck solving this problem so I'll make 
the best of it :)

So now we're in this position where adds, deletes, and updates all can 
force us to recalculate this giant hash ring.  We can either simply lock 
the ring (but this actually takes long enough with a large number of 
real servers with large weights that it causes soft lock up detection!) 
or do RCU (a new allocation every time).  We're trying out the RCU thing 
now which is where this hurt us.

One aside, if it's safe to call synchronize_rcu in that path, then it 
may solve our most painful allocation problem in part.

tl;dr; it's an implementation in which you allocate on add, update, and 
delete.


> Patch 3:
> 	In the __ip_vs_update_dest change you are missing
> 	that ip_vs_rs_hash was called. In fact, I think we
> 	should call __ip_vs_unlink_dest(svc, dest, 0) and
> 	__ip_vs_del_dest(svc->net, dest, false)
> 	from ip_vs_add_dest() when both __ip_vs_update_dest(, 1)
> 	and ip_vs_new_dest() fail. This should work because
> 	add_dest call is the last thing we do on ADD, so
> 	the DEL operation but without calling del_dest should
> 	be ok. Such change invalidates Patch 1.
>
> 	Why above solution is preferred:
>
> 	At first look, scheduler that can return error from add_dest
> 	should not provide this dest to RCU readers via its schedule
> 	method and kfree(dest) looks ok.
>
> 	The problem is with the ip_vs_has_real_service() call
> 	and the ip_vs_rs_hash() call we do before add_dest,
> 	dest still can be accessed by RCU readers.
> 	For this reason we can not just kfree(dest).

Pending the rest of your reply I will reimplement it in this way.

>
> Patch 4:
> 	As for del_dest result, failure should not happen,
> we should be able to flush dests on module cleanup. I think, there
> should not be any allocations in this case.

As mentioned above, we may need to reallocate in this path.  But it does 
offend my sensibilities that this is the case, so I think it'd be fair 
to change the del_dest function to return void and we'd just find 
another way to do it.

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
