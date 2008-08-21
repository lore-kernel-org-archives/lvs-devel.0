From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 08/24] IPVS: Make protocol handler functions support IPv6
Date: Thu, 21 Aug 2008 15:52:36 +0200
Message-ID: <f4845fc0808210652o3b586e7cjbeadc41533f9ac7d@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <1219248931-15064-9-git-send-email-juliusv@google.com>
	 <48AD6DBB.9030607@hp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219326759; bh=imVsT8hfJlUnyMdbiYp4hKTJoLk=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=lUkXjt1YehoNNJqyr7JOXPINQ61TadyD
	Y6tyGnxinCrwfX1kHCeoVmRiZTXPHdmSQlrixAjNMCGpork0WlBDlw==
In-Reply-To: <48AD6DBB.9030607@hp.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Brian Haley <brian.haley@hp.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au, kaber@trash.net, vbusam@google.com

Hi,

On Thu, Aug 21, 2008 at 3:29 PM, Brian Haley <brian.haley@hp.com> wrote:
> Julius Volz wrote:
>>
>> +void
>> +ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
>> +                         const struct sk_buff *skb,
>> +                         int offset,
>> +                         const char *msg)
>> +{
>> +#ifdef CONFIG_IP_VS_IPV6
>> +       if (skb->protocol == __constant_htons(ETH_P_IPV6))
>> +               ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
>> +       else
>> +#endif
>
> I don't think you need the __constant_htons() here, just htons() - that's
> what tcp_ipv6.c does.

Thanks!

I guessed from the name and other uses that __constant_htons() is just
a version of htons() optimized for values that are constant at compile
time. Is this right? But htons() is fine too in any case.

>> +static void
>> +ah_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
>> +               int offset, const char *msg)
>> +{
>> +#ifdef CONFIG_IP_VS_IPV6
>> +       if (skb->protocol == __constant_htons(ETH_P_IPV6))
>> +               ah_debug_packet_v6(pp, skb, offset, msg);
>> +       else
>> +#endif
>
> htons()
>
>> +static void
>> +esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
>> +                int offset, const char *msg)
>> +{
>> +#ifdef CONFIG_IP_VS_IPV6
>> +       if (skb->protocol == __constant_htons(ETH_P_IPV6))
>> +               esp_debug_packet_v6(pp, skb, offset, msg);
>> +       else
>> +#endif
>
> htons()
>
> I think there's more in one of the other patches too.
>
> So why can't you just create one ip_vs_debug_packet_v6() instead of these ah
> and esp ones which are identical?

If you look at the original files, the whole ip_vs_proto_ah.c and
ip_vs_proto_esp.c are 100% identical except for the protocol names /
constants :-/ So I stuck with this pattern for now. Maybe it would
make sense to join those two files in a change separate from the v6
functionality? There's already a lot of duplication in the existing
IPVS that could be removed...

Julius

-- 
Google Switzerland GmbH
