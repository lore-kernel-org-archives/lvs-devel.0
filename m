From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next 0/4] ipvs: check scheduler callback return values
Date: Mon, 23 Feb 2015 21:07:38 -0800
Message-ID: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=e6aLrg/CzsW0FpBASlwXC1W3eysxVwq+NdIMD5qls9E=;
 b=Haxe8gM9CdsoUGpcBonxTwTxnePjKlAF9zuK8k5llXsAGUGxotzw8+66j+m0Fhomif/J
 8Jg/og6B34UikCdFpetim713vIusRMufFH6EinaebtFMl6B5vDUSv+HkO+pNjgEKslKJ
 1aJVmksThfUWDZPmPjxzJ5WXGbNnEaTjEy4= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

We have a custom scheduler that is failing some atomic allocations
sometimes, and it was made pretty hard to discover by the fact that we more
or less drop the return code on the floor.  This is especially nasty, as
the ipvsadm -ln invocation shows the scheduler to be as we wish it were
instead of as it is.

This is an RFC because I have no idea what the best way to proceed with the
upd_dest invocation is.  I could clone all of the state and simply restore
it, but I figured one of you might have a better idea.

Alex Gartrell (4):
  ipvs: move ip_vs_trash_put_dest into its own function
  ipvs: drop dest_p from ip_vs_new_dest
  ipvs: check return value of add_dest
  ipvs: check return value of del_dest

 net/netfilter/ipvs/ip_vs_ctl.c | 106 +++++++++++++++++++++++++----------------
 1 file changed, 66 insertions(+), 40 deletions(-)

-- 
Alex Gartrell <agartrell@fb.com>

