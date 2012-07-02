From: Xiaotian Feng <xtfeng@gmail.com>
Subject: Re: [RFC PATCH net-next] ipvs: add missing lock in ip_vs_ftp_init_conn()
Date: Mon, 2 Jul 2012 18:30:08 +0800
Message-ID: <CAJn8CcHBQCT3r1xc7VW4c5DxyFefzxSdQB3EvGhmaAkbRyaing@mail.gmail.com>
References: <1340890587-8169-1-git-send-email-xtfeng@gmail.com>
	<alpine.LFD.2.00.1206290225490.1722@ja.ssi.bg>
	<CAJn8CcFy=K+Aizpi0pvnpXCOYXhgyq12oBgVaPvMthW_fwn4Pg@mail.gmail.com>
	<alpine.LFD.2.00.1206291125270.1690@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=7jvJUOqj3c6Q0Mkis7n97ExxToItJzInd/hnGxOuTNk=;
        b=fT1wKn+10LU5TKkJmkY+bxLdNNk9/zWsRr/g5oMYExrvPScAdL3rfF8Rz/V7Yt1zWj
         GnydFAkrOnL/eS6gvga3Cz0nJVrf2Fv6zENvTqzcE9QrhfYM7Z+qw6iCdQjD7273BwWn
         ZJjn2GmTYEIJSgGnq6iJvR3ocZIMzvQGW84vchdEs87W369638UMcHev+vRpKRhX3Vby
         DuXrFrZAnEeGF0RnGsNyoDJcgwV66XVAMLa5Y6w4vGDyb37o/Fy5Lf1nFc9SnXLiZNqh
         x0SczTrvKSGpeXGqxrWIWnYPPFZb4vOnFRH8Yd2m9nHrypIY9viN82SP4Ik3BG7ZJ5VW
         /hmQ==
In-Reply-To: <alpine.LFD.2.00.1206291125270.1690@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, Xiaotian Feng <dannyfeng@tencent.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

On Fri, Jun 29, 2012 at 5:04 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Fri, 29 Jun 2012, Xiaotian Feng wrote:
>
>> > On Thu, 28 Jun 2012, Xiaotian Feng wrote:
>> >
>> >> We met a kernel panic in 2.6.32.43 kernel:
>> >>
>> >> [2680191.848044] IPVS: ip_vs_conn_hash(): request for already hashed, called from run_timer_softirq+0x175/0x1d0
>> >> <snip>
>> >> [2680311.849009] general protection fault: 0000 [#1] SMP
>
>         What we see here is 120 seconds between 2680191 and
> 2680311. It can mean 2 things:
>
> - some state timeout, it depends on your forwarding method.
> What is it? NAT? DR?
>
> - 60 seconds for ip_vs_conn_expire retries
>
>> >> After code review, the only chance that kernel change connection flag without protection is
>> >> in ip_vs_ftp_init_conn().
>> >
>> >        Hm, ip_vs_ftp_init_conn is called before 1st hashing,
>> > from ip_vs_bind_app() in ip_vs_conn_new() before
>> > ip_vs_conn_hash(). It should be another problem with
>> > the flags. How different is IPVS in 2.6.32.43 compared to
>> > recent kernels? If commit aea9d711 is present, I'm not
>> > aware of other similar problems.
>>
>> ip_vs_bind_app() is also called by ip_vs_try_bind_dest(), which can be
>> traced to ip_vs_proc_conn().
>> I've checked the changes in upstream, but nothing helps since aea9d711
>> has been taken into 2.6.32.28 kernel.
>
>         OK, this fix should make it safe for master-backup
> sync and it should be applied but I suspect you are not
> using sync, right? And then this fix will not solve the oops.
>

We're using sync.

>         There are no many places that rehash conn:
>
> ip_vs_conn_fill_cport
>         - used for FTP
>
> ip_vs_check_template:
>         - do you have persistence configured?

No.

>
>         After you provide details for the used forwarding
> method, persistence and sync we should think how such races
> with rehashing can lead to double hlist_del. May be
> you can modify the debug message in ip_vs_conn_hash, so
> that we can see cp->flags and ntohs of cp->cport, cp->dport
> and cp->vport when oops happens again.

I just found 2.6.32.34 kernel differ from upstream kernel,  2.6.32
kernel doesn't have ip_vs_try_bind_dest(), but ip_vs_process_message()
kernel might change conn flags without lock protection. This is fixed in
commit f73181c, following changes:

@@ -834,6 +843,7 @@ static void ip_vs_proc_conn(struct net *net,
struct ip_vs_conn_param *param,
                kfree(param->pe_data);

                dest = cp->dest;
+               spin_lock(&cp->lock);
                if ((cp->flags ^ flags) & IP_VS_CONN_F_INACTIVE &&
                    !(flags & IP_VS_CONN_F_TEMPLATE) && dest) {
                        if (flags & IP_VS_CONN_F_INACTIVE) {
@@ -847,6 +857,7 @@ static void ip_vs_proc_conn(struct net *net,
struct ip_vs_conn_param *param,
                flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
                flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
                cp->flags = flags;
+               spin_unlock(&cp->lock);
                if (!dest) {
                        dest = ip_vs_try_bind_dest(cp);
                        if (dest)

So I took this part into 2.6.32 kernel. But I still think the patch I
posted is required for upstream kernel. Even though there are no many
places that rehash conn, this is potential race as cp->flags is not
protected.

Thanks.

>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
