From: "Julius Volz" <juliusv@google.com>
Subject: First IPv6 support for IPVS and ipvsadm
Date: Fri, 23 May 2008 15:59:15 +0200
Message-ID: <f4845fc0805230659o5464eb15i131790df8443349d@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1211551157; bh=M9l9HXvUP/Fojiw3q6VmYy3JEqU=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition; b=Urw9Gmv7opFiPN/6aXPXM1DMjUFC4e7h5ZJxezT2hM6
	abkaXWR7dcIcuCYD0ZJXo54zvKTGrqjYtbHbIlY2R5w==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: Vince Busam <vbusam@google.com>

Hi,

It's not ready for prime time, but we wanted to throw some of our IPv6
code for IPVS out there... We now actually have a lot of working IPv6
functionality in IPVS. While I have mainly been working on the kernel
part, Vince Busam has been converting ipvsadm to support the new
kernel features from userspace. You can find the whole, big patches
here (unfortunately, we haven't reworked them into sane pieces yet,
sorry):

- Kernel patch against davem's net-2.6:
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6.patch
- It depends on this patch that moves the "ipvs" directory to "net/netfilter":
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/move_ipvs_to_netfilter.patch

- ipvsadm patch and tar.gz:
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvsadm-1.25-ipv6-1.patch
http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvsadm-1.25-ipv6-1.tar.gz

Enable CONFIG_IP_VS_IPV6 for IPv6 support in IPVS.

Short overview:

What works with IPv6:
- forwarding mechanisms: NAT, DR, maybe Tunnel (not fully tested yet)
- protocols: TCP, UDP, ESP, AH (last two not tested)
- manipulation and inspection of both IPv4 and IPv6 entries with ipvsadm
- 6 out of 10 schedulers

What is not supported with IPv6:
- handling fragmentation or other extension headers
- FTP application helper (can be loaded, but only operates on v4)
- sync daemon (can be started, but only operates on v4)
- probably some incorrect handling of ICMPv6 or other corner cases

Since fragmentation and extension headers should not occur very often,
things should "mostly" work. I tested HTTP and DNS over NAT and DR
with various supported schedulers without encountering any problems.
But we didn't test any exotic situations. Also, there are some TODOs
in the code for things that haven't been tested or implemented yet.

I copied and changed many IPv4 methods into corresponding IPv6
versions, so the duplication is quite high. I chose to go that way in
order to not break too much of the existing IPv4 code. The upside of
that is that v4 should hopefully still work exactly as before. All
relevant data structures have an added 'af' fields for specifying the
address family - see my previous thread about that for details. That
means the kernel<->userspace interface changed and you absolutely need
to use the new ipvsadm with these kernel changes, even for IPv4-only
operation.

Feel free to comment, question, criticize, ridicule... but please
remember that this our first real shot at a kernel project!

Julius & Vince

-- 
Google Switzerland GmbH
