From: "Julius Volz" <juliusv@google.com>
Subject: Adding SNAT support to LVS/NAT
Date: Sat, 13 Sep 2008 13:12:54 +0200
Message-ID: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221304375; bh=fGNHoDtydrJwzqtwSprg4VCGCpk=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition; b=QLgIKwIoQ8c53syA6KuA4jaN9/ilmgMOGQ4y8F3sFYP
	qB1a4BOh0BC1fFaZJGGDQT0t81FKdWt9CKoEDWDIfOA==
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: j.stubbs@linkthink.co.jp

Hi,

I'm wondering about how hard it would be to add SNAT support to IPVS
(that is, the director rewriting packets from the client to backends
to appear to be from the VIP and some randomly allocated port). This
would allow us to have remote real servers with LVS/NAT. I realize
that Jason Stubb's PRE/POSTROUTING patches would also make this
possible, but they seemed risky and we haven't heard of them in a long
time. Also, having this option directly integrated into the rest of
the IPVS NAT code might make it easier to use: just add another flag
on the ipvsadm command line when you want SNAT for an LVS/NAT backend.

Two problems I noticed immediately:

- Getting a free port:
We need to find an unused port for the SNAT for each connection. Is
there some subsystem function than can be used to easily find/allocate
a free TCP/UDP port (sockets and netfilter NAT would need this too)?
Also, this would only allow <64k connections to each backend. The only
way to possibly differentiate between more would be to look at
sequence numbers, but IPVS doesn't do that at all currently...

- Connection entry lookup:
Connection entries are currently hashed and looked up by [client IP,
client port]. In the new SNAT case, packets coming from the real
server to the director would have to be looked up by [VIP, xport],
where xport is a port that is allocated by IPVS for each connection. A
simple (hacky?) solution would be to just hash each connection entry
twice. Is there a better way?

Are there any other major problems with this? Is it the right way to
go in general? I'm mainly just doing some exploration into this now...

Thanks for any comments!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
