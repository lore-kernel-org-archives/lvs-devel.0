From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv3 0/2] IPVS: Add Generic Netlink configuration interface
Date: Thu, 14 Aug 2008 14:12:42 +1000
Message-ID: <20080814041240.GA778@verge.net.au>
References: <1218120219-1117-1-git-send-email-juliusv@google.com> <20080808022607.GB6094@verge.net.au> <20080808120642.GB32458@google.com> <20080809142331.GA3497@verge.net.au> <f4845fc0808130900o550511dn2ec425bb2c911738@mail.gmail.com> <20080813230927.GB10749@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080813230927.GB10749@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: julius.volz@gmail.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Thu, Aug 14, 2008 at 09:09:29AM +1000, Simon Horman wrote:
> On Wed, Aug 13, 2008 at 06:00:41PM +0200, Julius Volz wrote:
> > On Sat, Aug 9, 2008 at 4:23 PM, Simon Horman <horms@verge.net.au> wrote:
> > > Hi Julius,
> > >
> > > your latest patch does resolve the problem that I was seeing
> > > with ipvsadm-1.25-nl-2. ipvsadm-1.25-nl-3 also works :-)
> > >
> > > I'd like to try and stress it out a bit more.
> > > I will try and get to that tomorrow or on Monday.
> > 
> > Hi, you were probably occupied by the other IPVS patches. Is there any
> > news on this?
> 
> Sorry Julius, I got side-tracked. I'll get onto this today, one way or another.

Hi Julius,

I tried to stress this code a bit more and nothing fell off.
I'm pretty happy with them, though Sven's comment about error checking
needs attention.
