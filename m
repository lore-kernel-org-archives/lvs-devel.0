From: "Jason A. Donenfeld via dev" <ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Subject: Re: [f2fs-dev] [PATCH v1 3/5] treewide: use
 get_random_u32() when possible
Date: Thu, 6 Oct 2022 06:33:15 -0600
Message-ID: <Yz7LCyIAHC6l5mG9@zx2c4.com>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-4-Jason@zx2c4.com>
 <20221006084331.4bdktc2zlvbaszym@quack3>
Reply-To: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 18BE86104C
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 210BB60F3D
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 1C547402BC
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 6C968402A7
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105; 
 t=1665059607;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=PDyor0OPorRMVekuFSJiAglRmrxBh1riIl1rICqIsks=;
 b=boaVkmFeWj/P/2mwQH9q1gX7LNlMIfDuuF/jF0E1iusdkGap18NZ9sMOKKXCenUfGu1kBs
 OsFuQiM99GfLC9GZQ0iQjPl+iTbCo2UXzxz3nN8lhLRAzO97rrmctM7VRTQNz+DRBcdhZZ
 cSGHfymmDp55cC4uDg3E8k04jFUD4XI=
Content-Disposition: inline
In-Reply-To: <20221006084331.4bdktc2zlvbaszym@quack3>
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
To: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, "Darrick J . Wong" <djwong-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marcelo Ricardo Leitner <marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Andrii Nakryiko <andrii-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Md . Haris Iqbal" <haris.iqbal-vEVw2sk9H7kAvxtiuMwx3w@public.gmane.org>, Miquel Raynal <miquel.raynal-LDxbnhwyfcJBDgjK7y7TUQ@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, Sergey Matyukevich <geomatsi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rohit Maheshwari <rohitm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, Christophe Leroy <christophe.leroy-2tlSp11Fh4xulxpn9UvDqw@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Nilesh Javali <njavali-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Jean-Paul Roubelat <jpr-3OwtVqItl4LYtjvyW6yDsg@public.gmane.org>, Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Dick Kennedy <dick.kennedy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Jay Vosburgh <j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Potnuri Bharat Teja <bharat-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

On Thu, Oct 06, 2022 at 10:43:31AM +0200, Jan Kara wrote:
> The code here is effectively doing the
> 
> 	parent_group = prandom_u32_max(ngroups);
> 
> Similarly here we can use prandom_u32_max(ngroups) like:
> 
> 		if (qstr) {
> 			...
> 			parent_group = hinfo.hash % ngroups;
> 		} else
> 			parent_group = prandom_u32_max(ngroups);

Nice catch. I'll move these to patch #1.


> > diff --git a/fs/ext4/mmp.c b/fs/ext4/mmp.c
> > index 9af68a7ecdcf..588cb09c5291 100644
> > --- a/fs/ext4/mmp.c
> > +++ b/fs/ext4/mmp.c
> > @@ -265,7 +265,7 @@ static unsigned int mmp_new_seq(void)
> >  	u32 new_seq;
> >  
> >  	do {
> > -		new_seq = prandom_u32();
> > +		new_seq = get_random_u32();
> >  	} while (new_seq > EXT4_MMP_SEQ_MAX);
> 
> OK, here we again effectively implement prandom_u32_max(EXT4_MMP_SEQ_MAX + 1).
> Just presumably we didn't want to use modulo here because EXT4_MMP_SEQ_MAX
> is rather big and so the resulting 'new_seq' would be seriously
> non-uniform.

I'm not handling this during this patch set, but if in the course of
review we find enough places that want actually uniformly bounded
integers, I'll implement efficient rejection sampling to clean up these
cases, with something faster and general, and add a new function for it.
So far this is the first case to come up, but we'll probably eventually
find others. So I'll make note of this.

Jason
