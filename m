From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: IPVS network namespace aware ?
Date: Tue, 24 Aug 2010 12:02:53 +0200
Message-ID: <4C7398CD.7090905@free.fr>
References: <1281099450.2518.21.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>	 <4C72CA3C.4080708@free.fr> <1282640038.25529.38.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1282640038.25529.38.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On 08/24/2010 10:53 AM, Hans Schillstrom wrote:
> Hi Daniel
> The progress is good, so far I think everything is ported except for
> Simon Hormans latest patch-set.
>
> Right now I'm struggling with NULL pointers :-)
> i.e. seq_file doesn't carry any netns info.
>
> In the example below *net will be invalid because seq->private is NULL.
>
> static void *ip_vs_info_seq_next(struct seq_file *seq, ....) {
> struct net *net = seq_file_net(seq);
>
> single_open() seems to work, but seq_open() or seq_open_private().
>    

That sounds me familiar ... :)

> As you can see I'm not ready, so help will be nice.
> I'll remove some debugging stuff and send you a patch-set.
>    

Cool, thanks !

   -- Daniel

