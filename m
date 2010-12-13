From: Tinggong Wang <wangtinggong@gmail.com>
Subject: Re: [PATCH 2/3] ipvs: check data validation before local_bh_disable
Date: Tue, 14 Dec 2010 02:06:41 +0800
Message-ID: <20101213180641.GA8731@wangtg>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
 <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
 <20101212214806.GF7914@verge.net.au>
 <20101213034438.GA3814@wangtg>
 <20101213062921.GE4748@verge.net.au>
 <1292230381.4983.31.camel@seasc0214>
 <20101213104911.GB6558@wangtg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:references:mime-version:content-type:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=8P7dQPlFy7aJ0Y097VJHGSvzcb65nP2hnvCDiV1K/Cg=;
        b=KzEj9VkTcxe8o/WkI6xjSugPu7cVebtNCf7IZSxKpBIx0oXZp2/I4ArjB5U29+hNKV
         dvkj9AXo5z7Rl49ExLe82zxhyaay2yHBmeKCoKi4msUozOvzGMhoHzfm0LEJnKgHtk/j
         P4Sn4/LnmbF6rtLIrvfJdR61yTvBQuhFLI7Sc=
Content-Disposition: inline
In-Reply-To: <20101213104911.GB6558@wangtg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

on Mon, 13 Dec 2010 06:49:11PM +0800 Tinggong Wang (wangtinggong@gmail.com) wrote:
> on Mon, 13 Dec 2010 09:53:01AM +0100 Hans Schillstrom (hans.schillstrom@ericsson.com) wrote:
> > On Mon, 2010-12-13 at 07:29 +0100, Simon Horman wrote:
> > > On Mon, Dec 13, 2010 at 11:44:38AM +0800, Tinggong Wang wrote:
> > > > on Mon, 13 Dec 2010 06:48:06AM +0900 Simon Horman (horms@verge.net.au) wrote:
> > > > > [ CCed Hans Schillstrom and Julian Anastasov ]
> > > > > 
> > > > > On Sun, Dec 12, 2010 at 07:42:29PM +0800, Tinggong Wang wrote:
> > > > > > Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> > > > > > ---
> > > > > >  net/netfilter/ipvs/ip_vs_sync.c |   13 ++++++++-----
> > > > > >  1 files changed, 8 insertions(+), 5 deletions(-)
> > > > > > 
> > > > > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > > > > > index 7632a17..2b6b0cb 100644
> > > > > > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > > > > > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > > > > > @@ -315,11 +315,6 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> > > > > >  	char *p;
> > > > > >  	int i;
> > > > > >  
> > > > > > -	if (buflen < SYNC_MESG_HEADER_LEN) {
> > > > > > -		IP_VS_ERR_RL("sync message header too short\n");
> > > > > > -		return;
> > > > > > -	}
> > > > > > -
> > > > > >  	/* Convert size back to host byte order */
> > > > > >  	m->size = ntohs(m->size);
> > > > > >  
> > > > > > @@ -823,6 +818,14 @@ static int sync_thread_backup(void *data)
> > > > > >  				break;
> > > > > >  			}
> > > > > >  
> > > > > > +			/* throw invalid data before local_bh_disable,
> > > > > > +			 * so performance won't be downgraded by it
> > > > > > +			 */
> > > > > > +			if (len < SYNC_MESG_HEADER_LEN) {
> > > > > > +				IP_VS_ERR_RL("sync message header too short\n");
> > > > > > +				continue;
> > > > > > +			}
> > > > > > +
> > > > > >  			/* disable bottom half, because it accesses the data
> > > > > >  			   shared by softirq while getting/creating conns */
> > > > > >  			local_bh_disable();
> > > > > > -- 
> > > > > > 1.7.2.3
> > > > > > 
> > > > > 
> > > > > Could you explain the motivation for this change?
> > > > 
> > > > in my opinion, before local_bh_disable, should ensure packets are look
> > > > like more resonable.
> > > > 
> > > > local_bh_disable will disable all bottom-half processing on local cpu,
> > > > if the multicast group flood of packets containing bad sync message,
> > > > local cpu will be busy doing local_bh_disable and local_bh_enable. 
> > > > 
> > > > if the backup pc has only one cpu, all other tasks will be pending until
> > > > the flood finished.
> > > 
> > > Ok, that does sound reasonable to some extent. But realistically
> > > this should only occur if bogus packets are being sent. And in
> > > that case it would be possible for bogus packets to be more carefully
> > > crafted such that we need to enter ip_vs_process_message() anyway.
> > > So I'm not sure if there really is a gain here.
> > > 
> > I do agree, first of all It's a multicast and they are never opened in
> > firewall so who should flood us? 
> > (If IPVS addr and port is open close it)
> > I don't think the extra rows actually adds anything as you say.
> > 
> Yes, it has small possibility to occur. and this patch only make sense
> when the bogus packets length less than SYNC_MESG_HEADER_LEN.
> 
> but if it occurs, for example, someone write a program, join the
> multicast group cursorily, and floods bogus packets accidentally.
> backup's performace will be downgraded.
> 
> is this scenario should be included? if so, i'll try to improve this
> patch. 
> 
> Thanks!

this patch disable bottom half after sanity check.
it will slightly improve backup's performance when bogus packets not
using the sync message format.

From 19c9d8bd38d3d4694ff5d0f6e16d02fcc13b7f1e Mon Sep 17 00:00:00 2001
From: Tinggong Wang <wangtinggong@gmail.com>
Date: Tue, 14 Dec 2010 01:42:18 +0800
Subject: [PATCH] ipvs: check data validation before local_bh_disable

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index c1c167a..077fcdf 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1105,6 +1105,11 @@ static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 		IP_VS_DBG(7, "BACKUP, Ignoring syncid = %d\n", m2->syncid);
 		return;
 	}
+
+	/* disable bottom half, because it accesses the data
+	   shared by softirq while getting/creating conns */
+	local_bh_disable();
+
 	/* Handle version 1  message */
 	if ((m2->version == SYNC_PROTO_VER) && (m2->reserved == 0)
 	    && (m2->spare == 0)) {
@@ -1120,7 +1125,7 @@ static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 			p = msg_end;
 			if (p + sizeof(s->v4) > buffer+buflen) {
 				IP_VS_ERR_RL("BACKUP, Dropping buffer, to small\n");
-				return;
+				goto out;
 			}
 			s = (union ip_vs_sync_conn *)p;
 			size = ntohs(s->v4.ver_size) & SVER_MASK;
@@ -1128,18 +1133,18 @@ static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 			/* Basic sanity checks */
 			if (msg_end  > buffer+buflen) {
 				IP_VS_ERR_RL("BACKUP, Dropping buffer, msg > buffer\n");
-				return;
+				goto out;
 			}
 			if (ntohs(s->v4.ver_size) >> SVER_SHIFT) {
 				IP_VS_ERR_RL("BACKUP, Dropping buffer, Unknown version %d\n",
 					      ntohs(s->v4.ver_size) >> SVER_SHIFT);
-				return;
+				goto out;
 			}
 			/* Process a single sync_conn */
 			if ((retc=ip_vs_proc_sync_conn(p, msg_end)) < 0) {
 				IP_VS_ERR_RL("BACKUP, Dropping buffer, Err: %d in decoding\n",
 					     retc);
-				return;
+				goto out;
 			}
 			/* Make sure we have 32 bit alignment */
 			msg_end = p + ((size + 3) & ~3);
@@ -1147,8 +1152,10 @@ static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 	} else {
 		/* Old type of message */
 		ip_vs_process_message_v0(buffer, buflen);
-		return;
 	}
+
+out:
+	local_bh_enable();
 }
 
 
@@ -1497,11 +1504,7 @@ static int sync_thread_backup(void *data)
 				break;
 			}
 
-			/* disable bottom half, because it accesses the data
-			   shared by softirq while getting/creating conns */
-			local_bh_disable();
 			ip_vs_process_message(tinfo->buf, len);
-			local_bh_enable();
 		}
 	}
 
-- 
1.7.2.3

