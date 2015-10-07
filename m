From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 01/15] ipv4: Fix ip_local_out_sk by passing the
 sk into __ip_local_out_sk
Date: Wed, 7 Oct 2015 16:37:03 +0300
Message-ID: <56151FFF.90506@cogentembedded.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
 <1444157595-28816-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1444157595-28816-1-git-send-email-ebiederm@xmission.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Hello.

On 10/6/2015 9:53 PM, Eric W. Biederman wrote:

> In the rare case where sk != skb->sk ip_local_out_sk arranges
> to call dst->output differently if the skb is queued or not.
> This is a bug.
>
> Fix this bug by passing the sk parameter of ip_local_out_sk through
> from ip_local_out_sk to __ip_local_out_sk (skipping __ip_local_out).
>
> Fixes: 7026b1ddb6b8d4e6ee33dc2bd06c0ca8746fa7ab

    Please see Documentation/SubmittingPatches on how the Fixes tag should 
look like.

> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

MBR, Sergei

