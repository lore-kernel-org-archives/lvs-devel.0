From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [patch] ipvs: Keep track of backlog connections
Date: Sun, 26 Sep 2010 16:59:28 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1009261657570.609@titan.stealer.net>
References: <20100926133101.GA9004@verge.net.au> <alpine.LNX.2.00.1009261629240.609@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1009261629240.609@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Venkata Mohan Reddy Koppula <mohanreddykv@gmail.com>

On Sun, 26 Sep 2010, Sven Wegener wrote:

> On Sun, 26 Sep 2010, Simon Horman wrote:
> 
> > here is an updated though as yet untested version of your patch from Julian
> > to take into account recent changes. In particualr, the ip_vs_sync.c
> > portion is no longer needed as only the flags in the first 16 bits are
> > synced now. It applies against Patrick McHardy's nf-next-2.6 tree.
> > 
> > You mentioned in your original post that you would work on an ipvsadm
> > patch for this feature. Have you had time to do so?
> > 
> > Also, are you in a position to test this? If not I can do so.
> 
> I've tested your patch with the below addition to ipvsadm and it works 
> correctly. 

And here is a small patch for the manpage:

diff --git a/ipvsadm.8 b/ipvsadm.8
index 6874c0e..78d67ef 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -392,6 +392,15 @@ information of each server in service listing. The persistent
 connection is used to forward the actual connections from the same
 client/network to the same server.
 .TP
+.B --backlog-conn
+Output of backlog connection information. The \fIlist\fP command
+with this option will display the backlog connection counter
+information of each server in service listing. A backlog connection
+is a connection that is inactive, but is expected to move to active
+soon. Speaking in TCP language, a connection from which we have seen
+the initial SYN packet, but the three-way handshake has not finished
+yet.
+.TP
 .B --sort
 Sort the list of virtual services and real servers. The virtual
 service entries are sorted in ascending order by <protocol, address,
