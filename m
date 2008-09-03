From: =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>
Subject: A one-liner ipvs patch
Date: Wed, 03 Sep 2008 11:24:03 +0300
Message-ID: <48BE49A3.9030201@p6drad-teel.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030103060604020800060309"
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>

This is a multi-part message in MIME format.
--------------030103060604020800060309
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi!

I have a few very high connection rate services behind LVS and when
keepalived removes them because of problems, the LVS would be rebooted
with tens of thousands of this message in the logs (rebooted by hardware
watchdogs).

I have had it running on production systems for maybe 3 months or so and
this problem hasn't occured any more, which does not prove that the
patch isn't just curing a symptom, but I think it is concievable, that a
lot of printks could hang a system.

Siim


--------------030103060604020800060309
Content-Type: text/x-patch;
 name="ip_vs_wrr-ratelimit-printk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip_vs_wrr-ratelimit-printk.patch"

ipvs: ratelimit flooding message in wrr scheduler

When all backends are removed from wrr scheduler by a monitoring agent, this
message can flood so fast that a 10s watchdog would reset the system.

Signed-off-by: Siim Po~der <siim@p6drad-teel.net>
--- linux-2.6.24/net/ipv4/ipvs/ip_vs_wrr.c	2008-01-24 22:58:37.000000000 +0000
+++ linux-2.6.24-ipvs_patches/net/ipv4/ipvs/ip_vs_wrr.c	2008-05-06 16:17:17.790662800 +0000
@@ -169,7 +169,7 @@
 				 */
 				if (mark->cw == 0) {
 					mark->cl = &svc->destinations;
-					IP_VS_INFO("ip_vs_wrr_schedule(): "
+					IP_VS_DBG_RL("ip_vs_wrr_schedule(): "
 						   "no available servers\n");
 					dest = NULL;
 					goto out;


--------------030103060604020800060309--
