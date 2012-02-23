From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] IPVS Bug IPv6 extension header handling faulty.
Date: Thu, 23 Feb 2012 11:03:52 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1202231012260.1481@ja.ssi.bg>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com> <201202220846.58599.hans@schillstrom.com> <alpine.LFD.2.00.1202222347030.1603@ja.ssi.bg> <201202230834.24254.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201202230834.24254.hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net, pablo@netfilter.org


	Hello,

On Thu, 23 Feb 2012, Hans Schillstrom wrote:

> > 	This is not going to work. You are trying to track
> > any locally delivered fragments. If cp is NULL it will crash.
> > There is no need to add check for !iph.fragoffs because
> > for iph.fragoffs != 0 we find cp with data from reasm,
> > I mean with ip_vs_skb_hdr_ptr.
> > 
> 	cp = pp->conn_in_get(af, skb, &iph, 0);
> 	if (unlikely(!cp) && !iph.fragoffs) {

	OK, then let's just keep the !cp check and
later if cp is NULL just to NF_ACCEPT packets with
iph.fragoffs != 0, the check should be before calling
conn_schedule.

	In the case after calling ip_vs_lookup_real_service
is it correct to reject non-first fragment with
ICMPV6_PORT_UNREACH, is that allowed? May be we should
avoid sending ICMP errors to non-first fragment, what
is the right thing to do?

> No it is working pretty well, because conn_in_get() is fragment aware.
> if cp is null it's a new connection and in that case only the first frag will do
> a schedule.
> For the following fragments reasm will be used by conn_in_get()
> so it should normaly return a valid "cp".

	I worry that cp can be expired by force at that
time, so lets add the above check before scheduling.

> > 	But IPVS is working in LOCAL_IN, even fragments will
> > come with dst because they will be delivered locally after
> > input routing. 
> 
> Well in the case when you have the VIP at the loopback that is true.
> If you have rules based on fw mark that force packets to IPVS,
> you will miss all fragments, i.e. the will go to the FORWARD chain
> 
> So that is why skb_dst_copy() is needed.

	You mean, only the first fragment has correct
mark, the following fragments can not be marked correctly
because we can not match the ports. And CONNMARK can not help
us because it depends on conntrack support?

> > So, there is no need to assign dst. In
> > PREROUTING there will be dst for loopback traffic. The
> > other traffic will get input route before reaching IPVS.
> > And it is dangerous to replace dst for the reason that
> > ip_vs_preroute_frag6 does not know if reasm was tracked
> > by IPVS, it can be just some netfilter packet. 
> 
> That's a side effect. 
> But I'm working on a solution for ip6tables to keep track on the fragments
> most people isn't aware of that you must take care of fragemnts your self 
> in your ip6tables rule-set....

	skb_dst_copy before PREROUTING is wrong even if
we do it for IPVS traffic, ip6_rcv_finish is going to
call dst_input. And all transmitters check the skb dst
to decide how to route the packet, so we have to leave
this job to transmitters, even for the fragments.

> > May be it is a good idea to set reasm->ipvs_property at
> > some place, so that we know the packets are tracked
> > by IPVS. Then we can restrict ip_vs_preroute_frag6 to
> > work only for IPVS traffic.
> 
> Good idea, thanks !!!
> I'll will do that

	Yes, it seems it will be needed to copy mark,
so that all IPVS fragments are forced to have same mark.

> > 	Hm, I have to check what happens if we decide to
> > mangle payload. Also, note that now ip_vs_nat_xmit_v6
> > should try to NAT ports only for first fragment, is that
> > handled? 
> Yes in xnat_handler(..)
> 
> #ifdef CONFIG_IP_VS_IPV6
> 	if (cp->af == AF_INET6 && iph->fragoffs)
> 		return 1;
> #endif

	Yes, there must be checks for fragoffs at some
places. May be it is a good idea to rename ip_vs_skb_hdr_ptr
to ip_vs_first_skb_hdr_ptr and to use it only at places
that need data from first fragment. Places that work
with current fragment will continue to use skb_header_pointer.
By this way we will know correctly which skb is accessed.
May be that is what you do but at least lets have a proper
func name.

> BTW, I have not test ESP & AH but on the other hand the are not subjects for fragmentation.
> The sending of ICMPV6_PKT_TOOBIG seems to be generic so...

	ok

Regards

--
Julian Anastasov <ja@ssi.bg>
