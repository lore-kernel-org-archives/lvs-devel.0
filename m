From: Julius Volz <julius.volz@gmail.com>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG messages
Date: Thu, 2 Jul 2009 16:43:39 +0200
Message-ID: <43ca39800907020743v1ccc1979o5a934d5ead05edc9@mail.gmail.com>
References: <20090624132232.GA9633@egardia>
	 <20090628154302.GB21519@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=KaKYMf+i+TlVwvHGyEvxW523nqJrojsC7YSg4GMNAzk=;
        b=vlgoXp9WKhuhSwEA1lzk5Bp9IFgFeM7YiNr2cI/KuctR6vMFFZJDHQLyVbK3C7TS9b
         IAushZC8ToN4bJSVjkZyjldwLUqRNIabv9F+rePE/aBq2Rl1V7KXod+YVbOlAXmKCodY
         WUmoy9WTxd4lfMIL6S6WIxdVWVN1EPapDu8AE=
In-Reply-To: <20090628154302.GB21519@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, robert.gallagher@heanet.ie

Hi Simon,

On Sun, Jun 28, 2009 at 5:43 PM, Simon Horman<horms@verge.net.au> wrote=
:
> On Wed, Jun 24, 2009 at 03:22:32PM +0200, Julius Volz wrote:
>> Add handling of incoming ICMPv6 Packet Too Big messages. This messag=
e
>> is received when a realserver sends a packet >PMTU to the client. Th=
e
>> hop on this path with insufficient MTU will generate an ICMPv6 Packe=
t
>> Too Big message back to the VIP. The LVS server receives this messag=
e,
>> but the call to the function handling this has been missing. Thus, I=
PVS
>> fails to forward the message to the real server, which then does not
>> adjust the path MTU. This patch adds the missing call to
>> ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.
>>
>> Thanks to Rob Gallagher from HEAnet for reporting this issue and for
>> testing this patch in production (with direct routing mode).
>>
>> Signed-off-by: Julius Volz <julius.volz@gmail.com>
>> Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>
>
> Hi Julius, Hi Rob,
>
> this seems reasonable to me, although it seems that the following
> code is common. I wonder if its repetition could be removed.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (related)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 verdict;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_vs_fill_iphdr(af, s=
kb_network_header(skb), &iph);

I agree, though I see no "nice" way to remove this duplication
considering the ifs and #ifdefs around this. You could move the
related and verdict variables to the top of the function and then
recheck afterwards whether one of these ICMP-handling branches was
entered and put the common code in there. But this seems more
cumbersome to me than repeating the code. Maybe you see a nicer way?
Btw., exactly this structure already exists in ip_vs_out(), which is
why I adopted it like this for ip_vs_in().

Cheers,
Julius
