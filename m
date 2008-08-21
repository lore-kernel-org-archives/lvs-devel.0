From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH RFC 08/24] IPVS: Make protocol handler functions support
 IPv6
Date: Thu, 21 Aug 2008 10:08:30 -0400
Message-ID: <48AD76DE.4030000@hp.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>	 <1219248931-15064-9-git-send-email-juliusv@google.com>	 <48AD6DBB.9030607@hp.com> <f4845fc0808210652o3b586e7cjbeadc41533f9ac7d@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <f4845fc0808210652o3b586e7cjbeadc41533f9ac7d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au, kaber@trash.net, vbusam@google.com

Julius Volz wrote:
> I guessed from the name and other uses that __constant_htons() is just
> a version of htons() optimized for values that are constant at compile
> time. Is this right? But htons() is fine too in any case.

I think the __constant one is for initializations.  All I know is that 
someone (Stephen Hemminger?) always points this out in other patchsets, 
so I beat him to it.

>> So why can't you just create one ip_vs_debug_packet_v6() instead of these ah
>> and esp ones which are identical?
> 
> If you look at the original files, the whole ip_vs_proto_ah.c and
> ip_vs_proto_esp.c are 100% identical except for the protocol names /
> constants :-/ So I stuck with this pattern for now. Maybe it would
> make sense to join those two files in a change separate from the v6
> functionality? There's already a lot of duplication in the existing
> IPVS that could be removed...

I didn't look too closely, there's a lot of patches! :)  Doing it in a 
separate patch is probably a good idea though.

-Brian
