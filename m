From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 14:15:49 +0200
Message-ID: <4875FD75.1090107@trash.net>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>	 <1215616317-11386-3-git-send-email-juliusv@google.com>	 <4874EABC.4000301@trash.net> <f4845fc0807091116s58b0b492p9f28281fcdca4e17@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f4845fc0807091116s58b0b492p9f28281fcdca4e17@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

Julius Volz wrote:
> On Wed, Jul 9, 2008, Patrick McHardy wrote:
>>> +static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info
>>> *info)
>>> +{
>>> +       struct ip_vs_service *svc;
>>> +       struct ip_vs_service_user usvc;
>>> +       struct ip_vs_dest_user udest;
>>> +       int ret = 0, cmd, flags;
>>> +       int need_full_svc = 0, need_full_dest = 0;
>>> +
>>> +       cmd = info->genlhdr->cmd;
>>> +       flags = info->nlhdr->nlmsg_flags;
>>> +
>>> +       /* increase the module use count */
>>> +       ip_vs_use_count_inc();
>> This looks fishy - the reference probably must be taken by
>> genetlink before calling the command handler.
> 
> That would seem better, but is that possible? I took this from the
> sockopt interface. What would you generally want to do in this
> situation?

There probably should be a struct module *owner in the
ops registered with genetlink. This is necessary at
least to make sure that modules don't disappear during
dumps.



