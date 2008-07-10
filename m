From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 23:16:30 +0200
Message-ID: <20080710211630.GW20815@postel.suug.ch>
References: <1215616317-11386-1-git-send-email-juliusv@google.com> <1215616317-11386-3-git-send-email-juliusv@google.com> <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com> <20080710113649.GS20815@postel.suug.ch> <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com> <20080710144131.GU20815@postel.suug.ch> <f4845fc0807100813o65dee75bgfc53a395dccf74f6@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0807100813o65dee75bgfc53a395dccf74f6@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

* Julius Volz <juliusv@google.com> 2008-07-10 17:13
> So, just to be sure: when I'm not returning an object (like in
> IPVS_CMD_GET_INFO), I still use IPVS_CMD_GET_INFO as the command ID in
> the response? This is also how net/irda/irnetlink.c does it, but maybe
> I'm copying bad examples again.
> 
> But whenever a response message is about objects, be it one or
> multiple entries, I use the IPVS_CMD_NEW_* response IDs.

Personally I would never use a GET id to send any data at all. My main
focus is on trying to make message protocols self documenting. If a
certain message type has multiple meanings depending on the direction
it will make it harder to understand and harder to debug from a protocol
standpoint.

The common netlink semantics are

 CMD_OBJ_NEW - create or update objects as described in the message
               content.
 CMD_OBJ_SET - rarely used, update a static object which doesn't have
               to be created or added. asme as OBJ_NEW otherwise.
 CMD_OBJ_DEL - delete object described in the message
 CMD_OBJ_GET - search for a object as described in the message and
               send a CMD_OBJ_NEW as reply including the full object.

	       with NLM_F_DUMP: iterate over all objects and send a
	       CMD_OBJ_NEW for each object. This request often carries
	       no additional data.

It's pretty simple but covers almost every possible protocol for use
in configuration interfaces. In the case of IPVS_CMD_GET_INFO the
actual data being sent back can be regarded as a info object. Basically
netlink is mainly used as a very basic form of rpc.
