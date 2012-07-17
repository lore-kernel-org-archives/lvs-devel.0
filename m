From: Xiaotian Feng <xtfeng@gmail.com>
Subject: Re: [PATCH 2/3] ipvs: add missing lock in ip_vs_ftp_init_conn()
Date: Tue, 17 Jul 2012 10:34:43 +0800
Message-ID: <CAJn8CcHPOMRt6SjP5YvH3=4UtihFJKbCOJP4TBcfzguPRxEggQ@mail.gmail.com>
References: <1341965963-7275-1-git-send-email-horms@verge.net.au>
	<1341965963-7275-3-git-send-email-horms@verge.net.au>
	<20120716210757.GA18026@1984>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-type;
        bh=Hlp3RhLlupoMvavJM+QlVTL4n6pGDr81lVaTUELhlsQ=;
        b=YIfZOFD1lwldkB7ltrLNLOiub0pycRS29QLhHSvWCOb8N/+zRZji/iDp3Yoy7byv4y
         irDR4s7UpNoFwuHP8HZzMmYdPbkqRPwpJvOXHqYyCPPsm+bP/SU2pSPB0+FtJmjwsL2K
         C/3eopaUteO2l+wRYo4HDmoDOwj/0AaKbCzApGjd/+XpUINyj6hy3kZnrDAa+Hro8gAU
         xf7rbIHk2Dzk43DzjcLDsyoHzhWpbhhud2eWkrgogOb7f14hkyH1GIsenWe1/R/ynnU/
         FqD02X1udS9Xz7G8/+XsaLjjZRAYph3m9zx+Yt+/MRAi45w5gvIDq/Th838zvHqgrIUx
         IIOw==
In-Reply-To: <20120716210757.GA18026@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Xiaotian Feng <dannyfeng@tencent.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

On Tue, Jul 17, 2012 at 5:07 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> Hi Simon,
>
> On Wed, Jul 11, 2012 at 09:19:22AM +0900, Simon Horman wrote:
>> From: Xiaotian Feng <xtfeng@gmail.com>
>>
>> We met a kernel panic in 2.6.32.43 kernel:
> [...]
>>  net/netfilter/ipvs/ip_vs_ftp.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
>> index b20b29c..c2bc264 100644
>> --- a/net/netfilter/ipvs/ip_vs_ftp.c
>> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
>> @@ -65,8 +65,10 @@ static int ip_vs_ftp_pasv;
>>  static int
>>  ip_vs_ftp_init_conn(struct ip_vs_app *app, struct ip_vs_conn *cp)
>>  {
>> +     spin_lock(&cp->lock);
>>       /* We use connection tracking for the command connection */
>>       cp->flags |= IP_VS_CONN_F_NFCT;
>> +     spin_unlock(&cp->lock);
>>       return 0;
>
> The conntrack support for FTP IPVS helper seems to be there since
> 2.6.37.
>
> However, the patch description mentions 2.6.32.43.
>
> Something doesn't match here, could you clarify this?
>

Sorry for the misleading description in the patch. We found the panic
in 2.6.32.43 is caused by changing cp->flags without protection. In
2.6.32.43, ip_vs_process_message changes cp->flags without protection
while update active/inactive flags for the connection.

After code inspiration, we found in 3.x kernel, it is accidentally
fixed by commit  f73181c. But with ip_vs_app changes,
ip_vs_ftp_init_conn() will have chance to change cp->flags without
protection. So it is a potential bug in 3.x kernel.


> Thanks.
