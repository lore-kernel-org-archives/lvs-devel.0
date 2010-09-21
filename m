From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] ipvs: Netfilter connection tracking changes
Date: Tue, 21 Sep 2010 16:58:43 +0200
Message-ID: <4C98C823.1010204@trash.net>
References: <Pine.LNX.4.58.1009162342590.6976@u.domain.uli> <4C935EE3.5070207@trash.net> <Pine.LNX.4.58.1009172232520.2923@u.domain.uli> <20100919120010.GB18134@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100919120010.GB18134@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Am 19.09.2010 14:00, schrieb Simon Horman:
> On Fri, Sep 17, 2010 at 10:38:14PM +0300, Julian Anastasov wrote:
>>
>> 	Hello,
>>
>> On Fri, 17 Sep 2010, Patrick McHardy wrote:
>>
>>> This one doesn't compile cleanly with CONFIG_IP_VS_NFCT=n:
>>>
>>>   CC [M]  net/netfilter/ipvs/ip_vs_ftp.o
>>> net/netfilter/ipvs/ip_vs_ftp.c: In function 'ip_vs_ftp_out':
>>> net/netfilter/ipvs/ip_vs_ftp.c:242: error: implicit declaration of
>>> function 'ip_vs_nfct_expect_related'
>>
>> 	I'm able to reproduce it only by commenting
>> CONFIG_IP_VS_FTP and CONFIG_IP_VS_NFCT and then this command fails:
>>
>> make net/netfilter/ipvs/ip_vs_ftp.o
>>
>> 	In all other cases if CONFIG_IP_VS_FTP is enabled
>> the 'select IP_VS_NFCT' does its job and enables
>> CONFIG_IP_VS_NFCT. Am I missing something?
>>
>>> Please fix this and resend.
> 
> I saw the same problem as Patrick when I ran
> 
> $ make oldconfig
> $ make M=net/netfilter/ipvs/
> 
> However, it went away once I ran
> 
> $ make

That might indeed have been the problem, I can't recall, but
sometimes I just build the affected subdirectories until I've
applied the last patch of a series.
