From: Vince Busam <vbusam@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 13:55:25 -0700
Message-ID: <48503BBD.6000307@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>	 <48500A0D.5020304@trash.net>	 <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>	 <48501C81.6010800@trash.net>	 <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com>	 <4850233E.7090501@trash.net>	 <f4845fc0806111229l6666161fu9d3bc5e432668485@mail.gmail.com>	 <48502826.9060502@trash.net>	 <f4845fc0806111253l4f1fea4fyef05cdc41ca45911@mail.gmail.com> <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213217662; bh=LQNlih8vhdfUR/Yi44FDvJoBmTg=;
	h=DomainKey-Signature:Message-ID:Date:From:User-Agent:MIME-Version:
	 To:CC:Subject:References:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding; b=XnngVBw56OSsyrYnCbxfVDlNlSg/rqNPf+Aqg
	6EWC43vnJjrk35a9EUtfp6+Q0fQxtaoEBKgJ3n82Sp9/tgLQA==
In-Reply-To: <f4845fc0806111314r41e7736ay54d22cf28efa2d27@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julius Volz <juliusv@google.com>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Julius Volz wrote:
> Ah, but the set/get-sockopt calls also pass a size argument, which is
> the size of the passed structs. If the kernel and userspace struct
> sizes don't match, it is treated as an error. Is this in case
> different compilers pad the structs differently, even if the IPVS
> version stays the same?

So we could disable the size checks of the passed structs, or key on it to 
determine if the older ABI was used, keeping a list of the structs that 
had different sizes around, but that sounds like a gross hack which would 
get worse if any other fields are added.  It would also mean new userspace 
binaries with the new fields wouldn't work with older kernels, is that a 
problem?  Is this better than the alternatives of breaking the ABI, or 
duplicating code into a separate ABI?

Vince
