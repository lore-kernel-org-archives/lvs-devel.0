From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Wed, 9 Jul 2008 17:24:40 +0200
Message-ID: <f4845fc0807090824v7cbb9ca8h93be4c2f9511f993@mail.gmail.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	 <1215616317-11386-3-git-send-email-juliusv@google.com>
	 <20080710.001748.72390839.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1215617082; bh=7h+F8dDUDPyo9zhWNKmhlI8qy1Q=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=NUlBgjLJMK8YDnh+vwx+bqQnFAwrFDDi
	DWVcwXE32jLqJGsMZ5csTbpvmDAlrGDVR0u9dWQFszgYQDIo5YCHag==
In-Reply-To: <20080710.001748.72390839.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-2022-jp"
To: =?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?= <yoshfuji@linux-ipv6.org>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, kaber@trash.net, davem@davemloft.net

On Wed, Jul 9, 2008 at 5:17 PM, YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org> wrote:
> In article <1215616317-11386-3-git-send-email-juliusv@google.com> (at Wed,  9 Jul 2008 17:11:57 +0200), Julius Volz <juliusv@google.com> says:
>
> :
>> +static struct genl_ops ip_vs_genl_ops[] __read_mostly = {
>> +     /* SET commands */
>> +     {
>> +             .cmd    = IPVS_CMD_ADD_SERVICE,
>> +             .flags  = GENL_ADMIN_PERM,
>> +             .policy = ip_vs_entries_policy,
>> +             .doit   = ip_vs_genl_set_cmd
>
> please add ",".

Thanks, did that!

Julius
-- 
Google Switzerland GmbH
