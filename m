From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/3] ipvs: add missing lock in ip_vs_ftp_init_conn()
Date: Wed, 11 Jul 2012 09:19:22 +0900
Message-ID: <1341965963-7275-3-git-send-email-horms@verge.net.au>
References: <1341965963-7275-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1341965963-7275-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Xiaotian Feng <xtfeng@gmail.com>, Xiaotian Feng <dannyfeng@tencent.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>

From: Xiaotian Feng <xtfeng@gmail.com>

We met a kernel panic in 2.6.32.43 kernel:

[2680191.848044] IPVS: ip_vs_conn_hash(): request for already hashed, called from run_timer_softirq+0x175/0x1d0
<snip>
[2680311.849009] general protection fault: 0000 [#1] SMP
[2680311.853001] RIP: 0010:[<ffffffff815f155c>]  [<ffffffff815f155c>] ip_vs_conn_expire+0xdc/0x2f0
[2680311.853001] RSP: 0018:ffff880028303e70  EFLAGS: 00010202
[2680311.853001] RAX: dead000000200200 RBX: ffff8801aad00b80 RCX: 0000000000001d90
[2680311.853001] RDX: dead000000100100 RSI: 000000004fd59800 RDI: ffff8801aad00c08
<snip>
[2680311.853001] Call Trace:
[2680311.853001]  <IRQ>
[2680311.853001]  [<ffffffff815f1480>] ? ip_vs_conn_expire+0x0/0x2f0
[2680311.853001]  [<ffffffff8104e2a5>] run_timer_softirq+0x175/0x1d0
[2680311.853001]  [<ffffffff81021a48>] ? lapic_next_event+0x18/0x20
[2680311.853001]  [<ffffffff81049a13>] __do_softirq+0xb3/0x150
[2680311.853001]  [<ffffffff8100cc5c>] call_softirq+0x1c/0x30
[2680311.853001]  [<ffffffff8100ea9a>] do_softirq+0x4a/0x80
[2680311.853001]  [<ffffffff81049957>] irq_exit+0x77/0x80
[2680311.853001]  [<ffffffff81021f2c>] smp_apic_timer_interrupt+0x6c/0xa0
[2680311.853001]  [<ffffffff8100c633>] apic_timer_interrupt+0x13/0x20
[2680311.853001]  <EOI>
[2680311.853001]  [<ffffffff81013b52>] ? mwait_idle+0x52/0x70
[2680311.853001]  [<ffffffff8100a7b0>] ? enter_idle+0x20/0x30
[2680311.853001]  [<ffffffff8100ac62>] ? cpu_idle+0x52/0x80
[2680311.853001]  [<ffffffff816d504d>] ? start_secondary+0x19d/0x280

rax and rdx is LIST_POISON1 and LIST_POISON2, so kernel is list_del() on an already deleted
connection and result the general protect fault.

The "request for already hashed" warning, told us someone might change the connection flags
incorrectly, like described in commit aea9d711, it changes the connection flags, but doesn't
put the connection back to the list. So ip_vs_conn_hash() throw a warning and return.
Later, when ip_vs_conn_expire fire again, ip_vs_conn_unhash() will find the HASHED connection
and list_del() it, then kernel panic happened.

After code review, the only chance that kernel change connection flag without protection is
in ip_vs_ftp_init_conn().

Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index b20b29c..c2bc264 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -65,8 +65,10 @@ static int ip_vs_ftp_pasv;
 static int
 ip_vs_ftp_init_conn(struct ip_vs_app *app, struct ip_vs_conn *cp)
 {
+	spin_lock(&cp->lock);
 	/* We use connection tracking for the command connection */
 	cp->flags |= IP_VS_CONN_F_NFCT;
+	spin_unlock(&cp->lock);
 	return 0;
 }
 
-- 
1.7.10.2.484.gcd07cc5
