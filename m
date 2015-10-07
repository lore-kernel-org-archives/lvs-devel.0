From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 10/15] ipv4: Cache net in ip_build_and_send_pkt
 and ip_queue_xmit
Date: Tue, 06 Oct 2015 20:48:19 -0700
Message-ID: <1444189699.9555.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
	 <1444157595-28816-10-git-send-email-ebiederm@xmission.com>
	 <1444167637.9555.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87lhbf8ike.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :content-type:mime-version:content-transfer-encoding;
        bh=CPH9bAlMG04HQg5RxrXsBcazTzjM6xjckDOZ7lRyrGE=;
        b=ncRyy5SjUQjJNIEA+tSiCmRpmLvpiZIRloV+46v63kKJwjyj5kanFQrChITYaZ1ytM
         /MUcran3MC7pPT6Yjk33duT5s21Wf9EGyATjAf7KEu6co7o5DiKy6nE+0AEa7iW1/BRD
         uVZVZXRG4Ze5qyO+OZSU2Kqb9sDA9ZTwCt1t7kTUOkqK6ulF3Omw3jzCfpxcTAZMsXiB
         SsmcqglwuQaB0hXJwBDlqxW/DM/zW1f9Ko+sPHOnFJNLLdV8aTFeyxKl77fOMWawXEpZ
         sErFWRFsiA9jElja4DnQZiz2HzfCZ4J0KaqnY4qhEMq0N/oDZ81xDkHxPVvI3913tMc6
         06BQ==
In-Reply-To: <87lhbf8ike.fsf@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

On Tue, 2015-10-06 at 22:26 -0500, Eric W. Biederman wrote:

> So what I am really reading it for is ip_local_out which I change to
> take a struct net a few patches later in the series.  The patches that
> changes everything is noticably cleaner and easier to review with these
> couple of patches pulling struct net into it's own variable ahead of
> time, and ip_build_and_send_pkt does call ip_local_out unconditionally.
> 
> I am in the process of figuring out how to compute net once in the
> output path and just passing it through so I don't need to compute net
> from dst->dev.  As when the dust settles I hope to allow for a dst->dev
> in another network namespace.  So that routes with a destination device
> in another network namespace will allow for something simpler and faster
> than ipvlan that achieves a very similar effect.
> 
> In this case to achieve what you are looking for, for cache line
> friendliness I believe we would need to pass net in from
> tcp_v4_send_synack, and it's cousins in dccp.

Yes, something that can be done later.

> 
> skc_net does seem firmly in the first cache line of sockets so it does
> look like any of the the reads to inet_sock that we do perform would
> hit the same cache line.
> 
> To recap.  I store net in a variable because I start using it
> unconditionally a few patches later. The only way I can see to avoid
> hitting the cold cache line is to pass net into ip_build_and_send_pkt.
> 
> Do you think passing net into ip_build_and_send_pkt is the sensible way
> to address your performance concern?  Or do you have issues with my
> passing of net through the output path?

I have no issues, but was pointing out this particular path, that might
be optimized later, no worries.

Thanks.


