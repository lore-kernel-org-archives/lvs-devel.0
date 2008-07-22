From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv2 0/2] IPVS: Add Generic Netlink configuration interface
Date: Tue, 22 Jul 2008 18:43:52 +0200
Message-ID: <f4845fc0807220943p77ed37d1l47484597842856a4@mail.gmail.com>
References: <1216645375-20410-1-git-send-email-juliusv@google.com>
	 <20080722003403.GC9041@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1216745035; bh=ZQ+GLmGZt82CzhRdaJitUzSuurs=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=IxlOiCK2SLiAAu5yrRx6UGoORGkfGkPc
	TACfwrdMFliO/18qlUv4ehTv4pue+u9b0flYbxeRbxHcE+Ox9DvuvA==
In-Reply-To: <20080722003403.GC9041@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Tue, Jul 22, 2008 at 2:34 AM, Simon Horman <horms@verge.net.au> wrote:
> I'm not an expert on netlink, but these patches are looking good to me.
> Is the user-space portion available somewhere?

It's not quite ready, but Vince can hopefully post a preview version
later today or tomorrow!

>> The ip_vs.h header change depends on this patch I sent previously:
>> "IPVS: Move userspace definitions to include/linux/ip_vs.h"
>> (this one looked good to Horms, can it go in?)
>
> Yes, it can. I'll repost it with an Ack.

Thanks!

Julius

-- 
Google Switzerland GmbH
