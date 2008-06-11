From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 21:53:39 +0200
Message-ID: <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <48500A0D.5020304@trash.net>
	 <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>
	 <48501C81.6010800@trash.net>
	 <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com>
	 <4850233E.7090501@trash.net>
	 <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com>
	 <48502826.9060502@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213214021; bh=ELwhLjW6oKDhn4/judGVD2i4oWQ=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=Ti2lSbaDMwRHQxAXpXeD+Bqwk7xA8rYv
	wQqk0vYjIDZ64/ZIQWS+QN1/lygHyepLHJafMcPbYhgy1exaXJomyw==
In-Reply-To: <48502826.9060502@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Vince Busam <vbusam@google.com>

On Wed, Jun 11, 2008 at 9:31 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>> It is clearly laid out to be able to be changed over time, hence the
>> ipvsadm version check...
>
> The usual way is to add new members at the end. The history shows no
> changes at all to these structs though.

Not in git history at least. No version number change there either
(maybe the LVS folks know more about the history).

Adding members at the end sounds interesting! The current structs have
the v4 address members in the middle of the struct, so you couldn't
use a union of v4 and v6 anymore, but since it's only in the userspace
interface, that shouldn't matter much. If this allows us to keep the
interface backwards compatible in an easy way, that would be great.

Julius

-- 
Google Switzerland GmbH
