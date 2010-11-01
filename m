From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Mon, 1 Nov 2010 23:56:40 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011012354340.1621@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <20101030231601.GA5908@verge.net.au> <201011011630.57467.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011011630.57467.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Mon, 1 Nov 2010, Hans Schillstrom wrote:

>> 	At this stage there is no facility for updating PE data.
>> 	But I think replacing it should be fine, so long as
>> 	the appropriate locking is in place.
>
> Julian,
> I can't see where this could happen,
> but I might be out of sync :-)
>
> IF this an issue that we must take care of,
>  (Then I'm a little bit lost)
>  could you please explain it for me or pass a code example of how to do it.
> ENDIF

 	Hm, lets leave this update for now. We can think
for this problem when some PE needs to update its data.

Regards

--
Julian Anastasov <ja@ssi.bg>
