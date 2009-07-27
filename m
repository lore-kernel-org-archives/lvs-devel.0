From: Julius Volz <julius.volz@gmail.com>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG messages
Date: Mon, 27 Jul 2009 12:19:03 +0200
Message-ID: <43ca39800907270319r4fd42236v21ade59dc56b02da@mail.gmail.com>
References: <20090624132232.GA9633@egardia>
	 <20090724024711.GA13280@verge.net.au> <4A6937B5.3040707@gmail.com>
	 <20090726.191905.158195470.davem@davemloft.net>
	 <20090727023754.GC723@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=FE2HWUBILZRTHT2QV4QSsTNZOSUowCjkFOrJPR8yxIk=;
        b=XemNpz/axph7FIgLhdenX7tuqp4Vthxk/ki0tjpHEzoGbLCF0FhoSQBLj+czEuPnW8
         wh4ecNOtVwFdBhAZrX1IY/XVuUAS3aMNAA8QUcUB+XlWjIrk5H7MAla9W1LUeebvnOrT
         kH6B8gX6mbRqp5kupi03DyLkq57DBKEZGVkDA=
In-Reply-To: <20090727023754.GC723@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, robert.gallagher@heanet.ie

On Mon, Jul 27, 2009 at 4:37 AM, Simon Horman<horms@verge.net.au> wrote=
:
> On Sun, Jul 26, 2009 at 07:19:05PM -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 24 Jul 2009 06:25:25 +0200
>>
>> > I see no reference to ICMPV6_PKT_TOOBIG in this patch, so ChangeLo=
g
>> > might be misleading or uncomplete, since other ICMPV6 message type=
s
>> > (ICMPV6_DEST_UNREACH/ICMPV6_TIME_EXCEED) will also be forwarded/ha=
ndled
>> > ?
>>
>> Agreed, this commit message could use a tidy. =A0What the patch actu=
ally is
>> doing is adding the handling of ipv6 icmp messages at all.
>>
>> Simon could you clarify the commit message a bit and resubmit?
>
> Will do.

Oops, yes. For some weird reason, only the specific problem that
caused the patch was in my head when writing that commit message. Feel
free to edit it to include ICMPv6 handling for in-out packets in
general.

Julius
