From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: Add boundary check on ioctl arguments
Date: Tue, 29 Dec 2009 12:58:22 +1100
Message-ID: <20091229015822.GF10172@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Arjan van de Ven <arjan@linux.intel.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>

From: Arjan van de Ven <arjan@linux.intel.com>

ipvs: Add boundary check on ioctl arguments

The ipvs code has a nifty system for doing the size of ioctl command
copies; it defines an array with values into which it indexes the cmd
to find the right length.

Unfortunately, the ipvs code forgot to check if the cmd was in the
range that the array provides, allowing for an index outside of the
array, which then gives a "garbage" result into the length, which
then gets used for copying into a stack buffer.

Fix this by adding sanity checks on these as well as the copy size.

[ horms@verge.net.au: adjusted limit to IP_VS_SO_GET_MAX ]
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

 net/netfilter/ipvs/ip_vs_ctl.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

Hi Arjen,

this is the 4th response to your patch. I am guessing the previous
ones didn't reach you for some reason. And I guess this one wont
for the same reason.

I agree with Julian's assessment that your patch shouldn't be
necessary, but on the other hand I think that the checks are
reasonable. Your original patch made checks of the form of
"cmd > IP_VS_SO_GET_MAX + 1". I have updated this to
"cmd > IP_VS_SO_GET_MAX", as suggested by Julian, as the optmax
elements of struct nf_sockopt_ops set a non-inclusive range.

http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/00852.html

Index: net-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- net-next-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2009-12-29 12:39:40.000000000 +1100
+++ net-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2009-12-29 12:46:47.000000000 +1100
@@ -2077,6 +2077,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cm
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
+		return -EINVAL;
+	if (len < 0 || len >  MAX_ARG_LEN)
+		return -EINVAL;
 	if (len != set_arglen[SET_CMDID(cmd)]) {
 		pr_err("set_ctl: len %u != %u\n",
 		       len, set_arglen[SET_CMDID(cmd)]);
@@ -2352,17 +2356,25 @@ do_ip_vs_get_ctl(struct sock *sk, int cm
 {
 	unsigned char arg[128];
 	int ret = 0;
+	unsigned int copylen;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX)
+		return -EINVAL;
+
 	if (*len < get_arglen[GET_CMDID(cmd)]) {
 		pr_err("get_ctl: len %u < %u\n",
 		       *len, get_arglen[GET_CMDID(cmd)]);
 		return -EINVAL;
 	}
 
-	if (copy_from_user(arg, user, get_arglen[GET_CMDID(cmd)]) != 0)
+	copylen = get_arglen[GET_CMDID(cmd)];
+	if (copylen > 128)
+		return -EINVAL;
+
+	if (copy_from_user(arg, user, copylen) != 0)
 		return -EFAULT;
 
 	if (mutex_lock_interruptible(&__ip_vs_mutex))
