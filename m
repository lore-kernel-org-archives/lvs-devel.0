From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Wed, 9 Jul 2008 20:16:43 +0200
Message-ID: <f4845fc0807091116s58b0b492p9f28281fcdca4e17@mail.gmail.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	 <1215616317-11386-3-git-send-email-juliusv@google.com>
	 <4874EABC.4000301@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1215627404; bh=B2bS2PWlS30oEzseCyqiNUsk/BI=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=W+r1Ie31pPcYtw+utbl+PlA8g0uaCusl
	NJVjCEzpM5RcX9qamSH3xIx+LwxrBL8U9McyUuT8giCuey32hhtyiw==
In-Reply-To: <4874EABC.4000301@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

On Wed, Jul 9, 2008, Patrick McHardy wrote:
> Just a few quick comments, will try to do a full review later:

Thanks!

>> + * Policy used for commands that operate on service, destination
>> + * or daemon entries
>> + */
>> +static struct nla_policy ip_vs_entries_policy[IPVS_ENTRY_ATTR_MAX + 1]
>> +__read_mostly = {
>
> These can all be const (and have the __read_mostly annotation removed).

Ok!

>> +static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
>> +                                struct ip_vs_stats *stats)
>> +{
>> +       struct nlattr *nl_stats = nla_nest_start(skb, container_type);
>> +       if (!nl_stats)
>> +               goto nla_put_failure;
>
> Unbalanced locking.

Whoa, right! Will correct that.

>> +static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info
>> *info)
>> +{
>> +       struct ip_vs_service *svc;
>> +       struct ip_vs_service_user usvc;
>> +       struct ip_vs_dest_user udest;
>> +       int ret = 0, cmd, flags;
>> +       int need_full_svc = 0, need_full_dest = 0;
>> +
>> +       cmd = info->genlhdr->cmd;
>> +       flags = info->nlhdr->nlmsg_flags;
>> +
>> +       /* increase the module use count */
>> +       ip_vs_use_count_inc();
>
> This looks fishy - the reference probably must be taken by
> genetlink before calling the command handler.

That would seem better, but is that possible? I took this from the
sockopt interface. What would you generally want to do in this
situation?

>> +void ip_vs_genl_unregister(void)
>> +{
>> +       genl_unregister_family(&ip_vs_genl_family);
>
> Doesn't it also has to unregister the ops?

No, that happens automatically when you unregister the family.

Julius

-- 
Google Switzerland GmbH
