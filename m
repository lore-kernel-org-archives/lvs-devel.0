From: "Julius Volz" <juliusv@google.com>
Subject: Re: Making IPVS work with IPv6
Date: Mon, 31 Mar 2008 14:43:11 +0200
Message-ID: <f4845fc0803310543v1ce55f24x9c186786c7d33ba2@mail.gmail.com>
References: <f4845fc0803280845n6a4d8683gffe95c8d64572971@mail.gmail.com>
	 <Pine.LNX.4.64.0803280853110.28825@wm7d.net>
	 <f4845fc0803310348u37b128e4paa5260d243489352@mail.gmail.com>
	 <Pine.LNX.4.64.0803310435160.9996@wm7d.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1206967392; bh=Cmezu8PgCr5AQcMBvwibKhiG60I=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=xAr6SxbRVuRG6iEXuj0XswgjCFC7CoyS
	jNpwtdO4IOQftfXe+3DFji+xc+avjzO1U90uDb2MghjSCs0xNmJfDw==
In-Reply-To: <Pine.LNX.4.64.0803310435160.9996@wm7d.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Joseph Mack NA3T <jmack@wm7d.net>
Cc: lvs-devel@vger.kernel.org

Hi,

On Mon, Mar 31, 2008, Joseph Mack NA3T wrote:
> On Mon, 31 Mar 2008, Julius Volz wrote:
>  > Does this have any special implications in the IPv6 case?
>
>  possibly, possibly not. I was just warning you so that if
>  you came across it, you would recognize it.

Ok!

> > Again, interesting info. Is there a specific relation to
>  > IPv6 though?
>
>  I assume you'll be testing UDP, and if it behaves strangely,
>  you'll want to know which parts to blame us for :-)

I see, thanks! :)

>  > Aha, interesting. Could you explain a bit more for a
>  > newbie in what ways IPVS "bypasses" netfilter?
>
>  LVS controlled packets don't always follow the netfilter
>  path. They appear in the output without going through the
>  middle. So iptables rules don't always work.

Ah, a kind colleague just forwarded me this URL:

http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html#path_of_an_ip_vs_packet

So that fits to what I thought before. Basically, FORWARD is skipped
over and the "forwarding" is done manually in IPVS (by sending a new
packet, changed according to the specific load balancing mechanism? In
ip_vs_xmit.c, in one of the transmitter functions).

Julius

-- 
Google Switzerland GmbH
