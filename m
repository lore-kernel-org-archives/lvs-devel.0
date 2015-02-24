From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH net-next 0/4] ipvs: check scheduler callback return
 values
Date: Tue, 24 Feb 2015 09:30:06 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502240914430.1755@ja.home.ssi.bg>
References: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Mon, 23 Feb 2015, Alex Gartrell wrote:

> We have a custom scheduler that is failing some atomic allocations

	You can use GFP_KERNEL from add_dest method.

> sometimes, and it was made pretty hard to discover by the fact that we more
> or less drop the return code on the floor.  This is especially nasty, as
> the ipvsadm -ln invocation shows the scheduler to be as we wish it were
> instead of as it is.
> 
> This is an RFC because I have no idea what the best way to proceed with the
> upd_dest invocation is.  I could clone all of the state and simply restore
> it, but I figured one of you might have a better idea.

	Can a new create_dest(svc, bool for_update) method
solve such problem? Such modifications are serialized, so
create_dest can attach new structure to sched_data just before
the add_dest/upd_dest call. IPVS does not clone dests on
update but scheduler may need this for RCU update.
create_dest should be called early in __ip_vs_update_dest.
Note that kfree(dest) is not enough, see ip_vs_dest_free(),
more fields may be allocated before __ip_vs_update_dest is
reached.

Patch 2:
	dest_p is not needed, this patch is ok

Patch 3:
	In the __ip_vs_update_dest change you are missing
	that ip_vs_rs_hash was called. In fact, I think we
	should call __ip_vs_unlink_dest(svc, dest, 0) and
	__ip_vs_del_dest(svc->net, dest, false)
	from ip_vs_add_dest() when both __ip_vs_update_dest(, 1)
	and ip_vs_new_dest() fail. This should work because
	add_dest call is the last thing we do on ADD, so
	the DEL operation but without calling del_dest should
	be ok. Such change invalidates Patch 1.

	Why above solution is preferred:

	At first look, scheduler that can return error from add_dest
	should not provide this dest to RCU readers via its schedule
	method and kfree(dest) looks ok.

	The problem is with the ip_vs_has_real_service() call
	and the ip_vs_rs_hash() call we do before add_dest,
	dest still can be accessed by RCU readers.
	For this reason we can not just kfree(dest).

Patch 1:
	Not needed if patch 3 is changed

Patch 4:
	As for del_dest result, failure should not happen,
we should be able to flush dests on module cleanup. I think, there
should not be any allocations in this case.

Regards

--
Julian Anastasov <ja@ssi.bg>
