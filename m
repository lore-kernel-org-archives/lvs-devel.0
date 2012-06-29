From: Xiaotian Feng <xtfeng@gmail.com>
Subject: Re: [RFC PATCH net-next] ipvs: add missing lock in ip_vs_ftp_init_conn()
Date: Fri, 29 Jun 2012 09:50:59 +0800
Message-ID: <CAJn8CcFy=K+Aizpi0pvnpXCOYXhgyq12oBgVaPvMthW_fwn4Pg@mail.gmail.com>
References: <1340890587-8169-1-git-send-email-xtfeng@gmail.com>
	<alpine.LFD.2.00.1206290225490.1722@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type:content-transfer-encoding;
        bh=mnbSayJMT+Zx++3TW2IjQiatyTOaKA2F21usSfLCt1Y=;
        b=ZxrHDPXA0ogNgMx7fjUbnYhMHCkDq9eT94f60aNWre6XFgc6HzJyCtpuN/COuHod9Z
         vRCoQbiMulNqI9hFEh8fNKOE1Wn6GRPCSTOXtp21NZMuVGlFwjSAkBgZc0R556v3Gqyx
         J9r4CPovdCeNHyfxrju7MsDq5a5Ti+hndzwXUAMFxWDbG1s0nCuysnFFbJBQhtQoPhWC
         ntWXDusYtNtFaS+PhYIPlawD7N8b+rRlzlobwcAJdluOriWvRhgMbkzlD1co+s7JMcEz
         WKpxlzjO6JkCWRDmyVf7ggcWg3bCpIeLGCAN/oP3LQXeQfD9A+vgjDF320TeatUXXW/B
         J+MQ==
In-Reply-To: <alpine.LFD.2.00.1206290225490.1722@ja.ssi.bg>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, Xiaotian Feng <dannyfeng@tencent.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

On Fri, Jun 29, 2012 at 8:17 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Hello,
>
> On Thu, 28 Jun 2012, Xiaotian Feng wrote:
>
>> We met a kernel panic in 2.6.32.43 kernel:
>>
>> [2680191.848044] IPVS: ip_vs_conn_hash(): request for already hashed=
, called from run_timer_softirq+0x175/0x1d0
>> <snip>
>> [2680311.849009] general protection fault: 0000 [#1] SMP
>> [2680311.853001] RIP: 0010:[<ffffffff815f155c>] =C2=A0[<ffffffff815f=
155c>] ip_vs_conn_expire+0xdc/0x2f0
>> [2680311.853001] RSP: 0018:ffff880028303e70 =C2=A0EFLAGS: 00010202
>> [2680311.853001] RAX: dead000000200200 RBX: ffff8801aad00b80 RCX: 00=
00000000001d90
>> [2680311.853001] RDX: dead000000100100 RSI: 000000004fd59800 RDI: ff=
ff8801aad00c08
>> <snip>
>> [2680311.853001] Call Trace:
>> [2680311.853001] =C2=A0<IRQ>
>> [2680311.853001] =C2=A0[<ffffffff815f1480>] ? ip_vs_conn_expire+0x0/=
0x2f0
>> [2680311.853001] =C2=A0[<ffffffff8104e2a5>] run_timer_softirq+0x175/=
0x1d0
>> [2680311.853001] =C2=A0[<ffffffff81021a48>] ? lapic_next_event+0x18/=
0x20
>> [2680311.853001] =C2=A0[<ffffffff81049a13>] __do_softirq+0xb3/0x150
>> [2680311.853001] =C2=A0[<ffffffff8100cc5c>] call_softirq+0x1c/0x30
>> [2680311.853001] =C2=A0[<ffffffff8100ea9a>] do_softirq+0x4a/0x80
>> [2680311.853001] =C2=A0[<ffffffff81049957>] irq_exit+0x77/0x80
>> [2680311.853001] =C2=A0[<ffffffff81021f2c>] smp_apic_timer_interrupt=
+0x6c/0xa0
>> [2680311.853001] =C2=A0[<ffffffff8100c633>] apic_timer_interrupt+0x1=
3/0x20
>> [2680311.853001] =C2=A0<EOI>
>> [2680311.853001] =C2=A0[<ffffffff81013b52>] ? mwait_idle+0x52/0x70
>> [2680311.853001] =C2=A0[<ffffffff8100a7b0>] ? enter_idle+0x20/0x30
>> [2680311.853001] =C2=A0[<ffffffff8100ac62>] ? cpu_idle+0x52/0x80
>> [2680311.853001] =C2=A0[<ffffffff816d504d>] ? start_secondary+0x19d/=
0x280
>>
>> rax and rdx is LIST_POISON1 and LIST_POISON2, so kernel is list_del(=
) on an already deleted
>> connection and result the general protect fault.
>>
>> The "request for already hashed" warning, told us someone might chan=
ge the connection flags
>> incorrectly, like described in commit aea9d711, it changes the conne=
ction flags, but doesn't
>> put the connection back to the list. So ip_vs_conn_hash() throw a wa=
rning and return.
>> Later, when ip_vs_conn_expire fire again, ip_vs_conn_unhash() will f=
ind the HASHED connection
>> and list_del() it, then kernel panic happened.
>>
>> After code review, the only chance that kernel change connection fla=
g without protection is
>> in ip_vs_ftp_init_conn().
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Hm, ip_vs_ftp_init_conn is called before 1=
st hashing,
> from ip_vs_bind_app() in ip_vs_conn_new() before
> ip_vs_conn_hash(). It should be another problem with
> the flags. How different is IPVS in 2.6.32.43 compared to
> recent kernels? If commit aea9d711 is present, I'm not
> aware of other similar problems.

ip_vs_bind_app() is also called by ip_vs_try_bind_dest(), which can be
traced to ip_vs_proc_conn().
I've checked the changes in upstream, but nothing helps since aea9d711
has been taken into 2.6.32.28 kernel.

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0May be you can post some details for your =
setup on
> lvs-devel@vger.kernel.org. I assume FTP is used,
> what about master-backup sync? Can you confirm that
> this fix solves the problem or it happens in rare cases?

Yes, ftp and WRR scheduler is used. Unfortunately, the oops
is unreproducible :(

>
>> Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>
>> Cc: Wensong Zhang <wensong@linux-vs.org>
>> Cc: Simon Horman <horms@verge.net.au>
>> Cc: Julian Anastasov <ja@ssi.bg>
>> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> ---
>> =C2=A0net/netfilter/ipvs/ip_vs_ftp.c | =C2=A0 =C2=A02 ++
>> =C2=A01 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_=
vs_ftp.c
>> index b20b29c..c2bc264 100644
>> --- a/net/netfilter/ipvs/ip_vs_ftp.c
>> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
>> @@ -65,8 +65,10 @@ static int ip_vs_ftp_pasv;
>> =C2=A0static int
>> =C2=A0ip_vs_ftp_init_conn(struct ip_vs_app *app, struct ip_vs_conn *=
cp)
>> =C2=A0{
>> + =C2=A0 =C2=A0 spin_lock(&cp->lock);
>> =C2=A0 =C2=A0 =C2=A0 /* We use connection tracking for the command c=
onnection */
>> =C2=A0 =C2=A0 =C2=A0 cp->flags |=3D IP_VS_CONN_F_NFCT;
>> + =C2=A0 =C2=A0 spin_unlock(&cp->lock);
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>>
>> --
>> 1.7.1
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
