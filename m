From: "Jason A. Donenfeld via dev" <ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Subject: Re: [PATCH v1 0/5] treewide cleanup of random integer
	usage
Date: Thu, 6 Oct 2022 06:53:14 -0600
Message-ID: <Yz7PusEN5TG1PvJZ@zx2c4.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <202210052148.B11CBC60@keescook>
Reply-To: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org B8AED40C80
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org CBC0040223
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 1686F41936
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org AD9594192D
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105; 
 t=1665060806;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=+Hkd+03ZPFCZHL4SytFYjQxSlVLh/tCnsKNFxa5wK+g=;
 b=JFNs4Hazt/h3DVxpbrAbzMPE9whooDcKk8uIX5aTYNyaQ0ww6ONDZEpvj0pBCk5Bkl2DLt
 ktmEJcNw1Kn2Ot/YdbAehCwxq7qPZvj6WGsUyAnJyfFHg6BU5H6pbom+jt+FBFixHsfFyw
 FXN6BTv1V4qGzBVuWo2f1r2ZOkBYL5M=
Content-Disposition: inline
In-Reply-To: <202210052148.B11CBC60@keescook>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
 <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
 <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, "Darrick J . Wong" <djwong-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Andrii Nakryiko <andrii-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Md . Haris Iqbal" <haris.iqbal-vEVw2sk9H7kAvxtiuMwx3w@public.gmane.org>, Miquel Raynal <miquel.raynal-LDxbnhwyfcJBDgjK7y7TUQ@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, Sergey Matyukevich <geomatsi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rohit Maheshwari <rohitm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christophe Leroy <christophe.leroy-2tlSp11Fh4xulxpn9UvDqw@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Nilesh Javali <njavali-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Jean-Paul Roubelat <jpr-3OwtVqItl4LYtjvyW6yDsg@public.gmane.org>, Dick Kennedy <dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Jay Vosburgh <j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Potnuri Bharat Teja <bharat-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Vinay Kumar Yadav <vinay.yadav-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, linux-nfs@vg

On Wed, Oct 05, 2022 at 09:55:43PM -0700, Kees Cook wrote:
> It'd be nice to capture some (all?) of the above somewhere. Perhaps just
> a massive comment in the header?

I'll include (something like) this in some "how to use" documentation
I'm working on separately.

> > I've CC'd get_maintainers.pl, which is a pretty big list. Probably some
> > portion of those are going to bounce, too, and everytime you reply to
> > this thread, you'll have to deal with a bunch of bounces coming
> > immediately after. And a recipient list this big will probably dock my
> > email domain's spam reputation, at least temporarily. Sigh. I think
> > that's just how it goes with treewide cleanups though. Again, let me
> > know if I'm doing it wrong.
> 
> I usually stick to just mailing lists and subsystem maintainers.

Lord have mercy I really wish I had done that. I supremely butchered the
sending of this, and then tried to save it by resubmitting directly to
vger with the same message ID but truncated CC, which mostly worked, but
the whole thing is a mess. I'll trim this to subsystem maintainers and
resubmit a v2 right away, rather than having people wade through the
mess.

To any one who's reading this: no more replies to v1! It clogs the
tubes.

> If any of the subsystems ask you to break this up (I hope not), I've got

Oh god I surely hope not. Sounds like a massive waste of time and
paperwork.

Jason
