From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 17:10:22 +0800
Message-ID: <AANLkTimneLE2xKg6fie5u3Cvjzcrq4VnK6wMT3pno0JK@mail.gmail.com>
References: <27901279770680@web67.yandex.ru> <1279781811.2405.15.camel@edumazet-laptop>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:mime-version:received:in-reply-to
         :references:from:date:message-id:subject:to:cc:content-type;
        bh=1t3MARAXxs80bKxFkkq3eOoSIspP8NVKguOil4eWO0s=;
        b=JeqyM3fI5CKNCN6J5aOrLAeNvE554lGC32WSdiqKqc7TI3dgCQX3hX8EXHre31vwYz
         qsjzcOsFMFKeBgPT5rn69sBVtvk11O1n6GbK+wwDgU/DKit4VmWGcmvLgom1dPScApHt
         5q2x0LZfNE1drJy772JC2wr01WP9ZEFMowRMk=
In-Reply-To: <1279781811.2405.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Franchoze Eric <franchoze@yandex.ru>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Jul 22, 2010 at 2:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> lvs seems not very SMP friendly and a bit complex.
>
> I would use an iptables setup and a slighly modified REDIRECT target
> (and/or a nf_nat_setup_info() change)
>
> Say you have 8 daemons listening on different ports (1000 to 1007)
>
> iptables -t nat -A PREROUTING -p tcp --dport 1234 -j REDIRECT --rxhash-dist --to-port 1000-1007
>
> rxhash would be provided by RPS on recent kernels or locally computed if
> not already provided by core network (or old kernel)
>
> This rule would be triggered only at connection establishment.
> conntracking take care of following packets and is SMP friendly.
>
>

I think maybe REDIRECT is enough. If the public port is one of the
real ports, you need to append "random" option to iptables target
REDIRECT. If not, "REDIRECT --to-ports 1000-1007" is good enough, and
the destination port will be selected in the round-robin manner.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
