From: Vince Busam <vbusam@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 15:26:06 -0700
Message-ID: <485050FE.6030209@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>	 <48500A0D.5020304@trash.net>	 <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>	 <48501C81.6010800@trash.net>	 <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com>	 <4850233E.7090501@trash.net>	 <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com>	 <48502826.9060502@trash.net>	 <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com> <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com> <48503BBD.6000307@google.com> <485043E6.5030105@candelatech.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213223104; bh=0XPyRqWPVUiXuyO9/d2vkbvdIpc=;
	h=DomainKey-Signature:Message-ID:Date:From:User-Agent:MIME-Version:
	 To:CC:Subject:References:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding; b=j6qi4VdLol5EjzBVSVPaykirC6D9sc1FKD2S0
	WgklVyQ5AzCKxKXH42uD5vpzI/MzmYaWr5S/+RCnVZ5S+jmBA==
In-Reply-To: <485043E6.5030105@candelatech.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Ben Greear <greearb@candelatech.com>
Cc: Julius Volz <juliusv@google.com>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Ben Greear wrote:
> You can have the kernel ignore any data it doesn't understand (ie, if 
> struct is 24 bytes,
> but the kernel expects 20 bytes, just ignore the last 4).  This way it 
> should
> work with newer binaries.

Currently, the IPVS code specifically checks that length, so all kernels 
up to now won't play well with any changes to the structs.

Vince
