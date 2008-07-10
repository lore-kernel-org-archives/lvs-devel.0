From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 17:13:39 +0200
Message-ID: <f4845fc0807100813o65dee75bgfc53a395dccf74f6@mail.gmail.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	 <1215616317-11386-3-git-send-email-juliusv@google.com>
	 <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com>
	 <20080710113649.GS20815@postel.suug.ch>
	 <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com>
	 <20080710144131.GU20815@postel.suug.ch>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1215702829; bh=UaEOIwijFlob5/dGmpFs2xGunec=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=yYWbXJFTV3BdPiG7PdrhMJM7I0IMeHag
	L8yEH4A7+JTdc38s/JxxsTczHV8hYaGEdJFgavGgYG3cVG3fVzDSWw==
In-Reply-To: <20080710144131.GU20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Thomas Graf <tgraf@suug.ch>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

On Thu, Jul 10, 2008, Thomas Graf wrote:
> * Julius Volz <juliusv@google.com> 2008-07-10 14:33
>> Note that I use different first level attributes depending on the
>> command. Rather than calculating the largest needed size, it's
>> probably best to join all attributes that may ever occur in the first
>> level into one big enum, right?
>
> Yes, that's the easiest solution and it doesn't really cost you
> anything besides the slightly bigger allocation.

Yes.

>> > Typically, netlink code follows the following semantics WRT to
>> > commands/message types:
>> > -> GET_SERVICE (NLM_F_DUMP)
>> > <- NEW_SERVICE
>> > <- NEW_SERVICE
>> > <- NEW_SERVICE
>>
>> Ok, so I will set the answer message type to IPVS_CMD_NEW_SERVICE (and
>> accordingly in the other dump cases). For non-dump GET commands, is it
>> usual to have the response ID be the same as the request?
>
> It should follow the same semantics as with dumps. Netlink is typically
> used in an object context, where objects are requested, added or deleted.
> Basically, a dump is a request to fill the userspace listening part with
> all objects of the specified type. genetlink is a bit special as it
> moved away from the traditional 4 commands per family (get, new, set,
> delete) but in a case like IPVS where you are in fact managing objects
> it does make sense to stick to the known semantics.

So, just to be sure: when I'm not returning an object (like in
IPVS_CMD_GET_INFO), I still use IPVS_CMD_GET_INFO as the command ID in
the response? This is also how net/irda/irnetlink.c does it, but maybe
I'm copying bad examples again.

But whenever a response message is about objects, be it one or
multiple entries, I use the IPVS_CMD_NEW_* response IDs.

Julius

-- 
Google Switzerland GmbH
