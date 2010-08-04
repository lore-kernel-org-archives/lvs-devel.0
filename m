From: Simon Horman <horms@verge.net.au>
Subject: Re: ldirectord: a new format of ldirectord.conf for IPv6
Date: Wed, 4 Aug 2010 10:00:35 +0900
Message-ID: <20100804010034.GD4469@verge.net.au>
References: <20100802.183549.71091890.sohgo@sohgo.dyndns.org>
 <20100803010342.GE14499@verge.net.au>
 <20100804.001324.112617176.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100804.001324.112617176.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Cc: lvs-devel@vger.kernel.org

Hi Takeuchi-san,

On Wed, Aug 04, 2010 at 12:13:24AM +0900, Sohgo Takeuchi wrote:
> 
> Hi simon,
> 
> From: Simon Horman <horms@verge.net.au>
> |
> > On Mon, Aug 02, 2010 at 06:35:49PM +0900, Sohgo Takeuchi wrote:
> >> 
> >> Hi,
> >> 
> >>   I have been working on improving IPv6 support of ldirectord
> >> for a few weeks. I would like to hear your opinion or ideas
> >> about how to write ldirectord.conf.
> > 
> > A tricky topic, thanks for thinking it through.
> > 
> >> Q1. Should ldirectord support an IPv6 hostname in ldirectord.conf?
> >> 
> >>     A manual of ldirectord says that a hostname can be written
> >>     in "virtual", "real", "fallback" and so on. Current
> >>     implementation of ldirectord handles the hostname as only
> >>     IPv4. It partially supports IPv6, and can write only IPv6
> >>     addresses. But it does not have a way to write a hostname as
> >>     IPv6. Because there is no way to distinguish between IPv4
> >>     and IPv6. Should ldirectord support an IPv6 hostname in
> >>     ldirectord.conf?
> >> 
> >> Q2. If the answer of Q1 is yes, how do you want to write?
> >> 
> >>     [Candidate 1] Adding a new keyword like a "ipversion".
> >> 	A default value of "ipversion" is 4 (IPv4).
> >> 
> >> 	fallback=fallback.example.com
> >> 	fallback6=fallback.example.com
> >>         virtual=virtual.example.com:daytime
> >> 	    real=real1.example.com:daytime gate
> >> 	    real=10.10.10.10:daytime gate
> >>     	
> >> 	virtual=virtual.example.com:daytime
> >> 	    ipversion=6
> >> 	    real=real1.example.com:daytime gate
> >> 	    real=[2001:db8::10]:daytime gate
> >> 
> >>     This way cannot handle a global "fallback" variable. We must
> >>     have a way to distinguish between IPv4 and IPv6 when a
> >>     hostname is specified in the global "fallback" variable. To
> >>     achieve this, there is a way to add a new variable of
> >>     "fallback6". Any other good ideas?
> > 
> > This "fallback" problem seems to be the most difficult issue.
> > 
> >>     [Candidate 2] Adding new keywords of "virtual6" and
> >> 	"fallback6".
> >> 
> >>     "virtual6" is an IPv6 version of "virtual". If a hostname
> >>     and an IP address are specified in the "virtual6" line and
> >>     in its section, they are treated as an IPv6 address and the
> >>     hostname will be resolved into an IPv6 address.
> >> 
> >>     "fallback6" is just a global variable. It cannot be
> >>     specified in a virtual section. If no "fallback" in a
> >>     "virtual6" section is defined, the variable of "fallback6"
> >>     will be used.  If "fallback" in the "virtual6" section is
> >>     defined, it is treated as an IPv6 address.
> >>     
> >> 
> >> 	fallback=fallback.example.com
> >> 	fallback6=fallback.example.com
> >>         virtual=virtual.example.com:daytime
> >> 	    real=real1.example.com:daytime gate
> >> 	    real=10.10.10.10:daytime gate
> >>     	
> >> 	virtual6=virtual.example.com:daytime
> >> 	    real=real1.example.com:daytime gate
> >> 	    real=[2001:db8::10]:daytime gate
> >> 
> >>     This way breaks a backward compatibility. Current ldirectord
> >>     can write an IPv6 address in a "virtual" line. But this way
> >>     cannot.
> > 
> > I'm not particularly concerned about backwards compatibility here,
> > IPv6 for ldirectord is pretty green.
> 
> That's good.
> 
> >>     [Candidate 3] Completely separate IPv4 and IPv6 using
> >> 	"hoge6" keywords.
> >>     
> >>     Adding new keywords which denote IPv6. These keywords can
> >>     handle IPv6 only and have a name "hoge6".
> >> 
> >> 	fallback=fallback.example.com
> >> 	fallback6=fallback.example.com
> >>         virtual=virtual.example.com:daytime
> >> 	    real=real1.example.com:daytime gate
> >> 	    real=10.10.10.10:daytime gate
> >>     	
> >> 	virtual6=virtual.example.com:daytime
> >> 	    real6=real1.example.com:daytime gate
> >> 	    real6=[2001:db8::10]:daytime gate
> >> 	    fallback6=localhost:daytime
> >> 
> >>     This way is very similar to [Candidate 2]. But it is
> >>     consistent and easy to read. A demerit is a bit redundant?
> > 
> > I like candidate 3. Yes, it is redundant, but it is also very clear
> > and consistent.
> 
> Yes.
> 
> I have implemented [candidate 3]. Now it works good.

Great, once you've finished your testing please post the patch.

> > N.B: I think that all of the proposals would fwmark services without
> > any extra magic.
> 
> Oh, thank you. I have not considered fwmark. I think so too as
> you say.
