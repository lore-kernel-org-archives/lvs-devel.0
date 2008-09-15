From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Adding SNAT support to LVS/NAT
Date: Tue, 16 Sep 2008 01:56:31 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0809160103160.3009@u.domain.uli>
References: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com> 
 <Pine.LNX.4.64.0809131100320.20936@wm7d.net> 
 <f4845fc0809131731g7f953b21t57aa226ebdc9641e@mail.gmail.com> 
 <Pine.LNX.4.64.0809131835001.12375@wm7d.net> 
 <f4845fc0809140339p1d3be327j98ddcb02c4efc786@mail.gmail.com>
 <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0809140747u63f6ad63m43877bbbf09c4778@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Joseph Mack NA3T <jmack@wm7d.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, j.stubbs@linkthink.co.jp


	Hello,

On Sun, 14 Sep 2008, Julius Volz wrote:

> > Thanks for the info! Right, I even said myself in the previous reply
> > that ip_vs_postrouting() stops further processing in the POSTROUTING
> > chain, so it never reaches netfilter NAT code.
> 
> Actually, what if we modify or remove that function to allow further
> processing in POSTROUTING? Could SNAT work with IPVS then?
> 
> The comment above it says that the function specifically wants to
> avoid further NAT by netfilter. But is this always a problem?

	This check (now flag ipvs_property) was implemented to avoid
netfilter to modify packet which was already changed by IPVS.
What happened was that FTP commands (TCP header and payload) were
modified first by ip_vs_ftp and then by netfilter. The result:
packet with wrong SEQ number. Later, after some Netfilter 
changes (2.6.11), TCP payload was modified always in POST_ROUTING
while address can be  modified in PRE_ROUTING. Not sure what happens
now, Netfilter code was reorganized and new code review and tests
are needed, may be such double manipulation (if ipvs_property is
not set) still can cause problems.

Regards

--
Julian Anastasov <ja@ssi.bg>
