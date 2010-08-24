From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: IPVS network namespace aware ?
Date: Tue, 24 Aug 2010 10:53:58 +0200
Message-ID: <1282640038.25529.38.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
References: <1281099450.2518.21.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
	 <4C72CA3C.4080708@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C72CA3C.4080708@free.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: lvs-devel@vger.kernel.org, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

Hi Daniel
The progress is good, so far I think everything is ported except for
Simon Hormans latest patch-set. 

Right now I'm struggling with NULL pointers :-)
i.e. seq_file doesn't carry any netns info.

In the example below *net will be invalid because seq->private is NULL.

static void *ip_vs_info_seq_next(struct seq_file *seq, ....) {
struct net *net = seq_file_net(seq);

single_open() seems to work, but seq_open() or seq_open_private().

As you can see I'm not ready, so help will be nice.
I'll remove some debugging stuff and send you a patch-set.

/Hans


On Mon, 2010-08-23 at 21:21 +0200, Daniel Lezcano wrote:
> On 08/06/2010 02:57 PM, Hans Schillstrom wrote:
> > Hello
> > Is there any one that have made ipvs network namespace aware ?
> > There is an urgent need of it within Ericsson.
> > I could not find any trace of it in any of the normal lists.
> >
> > I will start patching ipvs next week or give a helping hand to any
> > existing work.
> 
> Hi Hans,
> 
> do you have a patchset ready (or just a prototype) ? I will be glad to 
> help you ;)
> 
> Thanks
>    -- Daniel

