From: Hannes Eder <heder@google.com>
Subject: Re: [PATCH v2 0/4] IPVS full NAT support + netfilter 'ipvs' match 
	support
Date: Tue, 29 Sep 2009 17:07:24 +0200
Message-ID: <b5ddba180909290807j4d1d1d2dl48af9453542612ff@mail.gmail.com>
References: <20090929123501.13798.84004.stgit@jazzy.zrh.corp.google.com>
	 <20090929145156.GB19797@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1254236849; bh=UrhM6b90yQ/WJAABKMUuYB4MiKw=;
	h=DomainKey-Signature:MIME-Version:In-Reply-To:References:Date:
	 Message-ID:Subject:From:To:Content-Type:Content-Transfer-Encoding:
	 X-System-Of-Record; b=mz/vrxSd8wGmjoUBdGCdp8JaSYT6RaOuF+kqaKvJcqle
	tP88+jaLP0Za5wPWR37trfpAMrZm0nvOLy8whtcBrw==
In-Reply-To: <20090929145156.GB19797@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Hannes Eder <heder@google.com>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, lvs-users@linuxvirtualserver.org, Laurent

On Tue, Sep 29, 2009 at 16:51, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 29, 2009 at 02:35:15PM +0200, Hannes Eder wrote:
>> The following series implements full NAT support for IPVS. =A0The
>> approach is via a minimal change to IPVS (make friends with
>> nf_conntrack) and adding a netfilter matcher, kernel- and user-space
>> part, i.e. xt_ipvs and libxt_ipvs.
>
> Its a bit late in the day for me to review the code, but I have a few
> quick comments.
>
>>
>> Example usage:
>>
>> % ipvsadm -A -t 192.168.100.30:80 -s rr
>> % ipvsadm -a -t 192.168.100.30:80 -r 192.168.10.20:80 -m
>> # ...
>>
>> # Source NAT for VIP 192.168.100.30:80
>> % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
>> > --vport 80 -j SNAT --to-source 192.168.10.10
>>
>> or SNAT-ing only a specific real server:
>>
>> % iptables -t nat -A POSTROUTING --dst 192.168.11.20 \
>> > -m ipvs --vaddr 192.168.100.30/32 -j SNAT --to-source 192.168.10.1=
0
>
> If the iptables rule is not in place does LVS just use
> its old NAT behaviour?

Yes, without iptables rules LVS NAT does DNAT.

>> First of all, thanks for all the feedback. =A0This is the changelog =
for v2:
>>
>> - Make ip_vs_ftp work again. =A0Setup nf_conntrack expectations for
>> =A0 related data connections (based on Julian's patch see
>> =A0 http://www.ssi.bg/~ja/nfct/) and let nf_conntrack/nf_nat do the
>> =A0 packet mangling and the TCP sequence adjusting.
>>
>> =A0 This change rises the question how to deal with ip_vs_sync? =A0D=
oes it
>> =A0 work together with conntrackd? =A0Wild idea: what about getting =
rid of
>> =A0 ip_vs_sync and piggy packing all on nf_conntrack and use conntra=
ckd?
>>
>> =A0 Any comments on this?
>
> =A0 =A0That sounds like a reasonable suggestion.
>
> =A0 =A0I think that ip_vs_sync came along before conntrackd
> =A0 =A0and no one has given much thought to merging the functionality=
=2E

Okay, I'll dig further in this direction.

Cheers,
-Hannes
