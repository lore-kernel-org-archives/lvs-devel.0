From: Peilin Ye <yepeilin.cs@gmail.com>
Subject: Re: [Linux-kernel-mentees] [PATCH net] ipvs: Fix uninit-value in
 do_ip_vs_set_ctl()
Date: Tue, 11 Aug 2020 03:19:14 -0400
Message-ID: <20200811071914.GA832118@PWN>
References: <20200810220703.796718-1-yepeilin.cs@gmail.com>
 <CAM_iQpWsQubVJ-AYaLHujHwz68+nsHBcbgbf8XPMEPD=Vu+zaA@mail.gmail.com>
 <20200811050929.GA821443@PWN>
 <alpine.LFD.2.23.451.2008110936570.3707@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=QUV+RKelrGDMMeJLFdVFPbO5APkLi9wyQFp+5QMDpqo=;
        b=G8B0k6+gHQyZJGZkIl+xEMk6z/IlDGgzjGX5y4LxNPYyppL8U7UKPd3gn+3fIKXHCo
         l9kweqnqTiecZV2ppBXXk7umYr3ephBhbV8F21O/89WgTHoAW0RxLr7uNmAFB/jp7JAS
         QkKwvX2oUHmDCy2WrQQG3Q7sOLr62fSGghzehtSVFW5dSIffIgKzCwEkKerIv2qsnz2j
         6HXMeKJr7toegZllvqQbAmUtlY3qUIGrTZG3Sg/2nNGBCdCC+ot2LSIpg6JI8qB4/rcf
         heYYSfK9onwXOq7o4LBJlO95mn//YsfsVAlK5QbjYbgU6M3+ZGw+qvxYy25G/3shbRUP
         PgzA==
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.23.451.2008110936570.3707@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, linux-kernel-mentees@lists.linuxfoundation.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 11, 2020 at 09:58:46AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 11 Aug 2020, Peilin Ye wrote:
> 
> > On Mon, Aug 10, 2020 at 08:57:19PM -0700, Cong Wang wrote:
> > > On Mon, Aug 10, 2020 at 3:10 PM Peilin Ye <yepeilin.cs@gmail.com> wrote:
> > > >
> > > > do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
> > > > zero. Fix it.
> > > 
> > > Which exact 'cmd' is it here?
> > > 
> > > I _guess_ it is one of those uninitialized in set_arglen[], which is 0.
> > 
> > Yes, it was `IP_VS_SO_SET_NONE`, implicitly initialized to zero.
> > 
> > > But if that is the case, should it be initialized to
> > > sizeof(struct ip_vs_service_user) instead because ip_vs_copy_usvc_compat()
> > > is called anyway. Or, maybe we should just ban len==0 case.
> > 
> > I see. I think the latter would be easier, but we cannot ban all of
> > them, since the function does something with `IP_VS_SO_SET_FLUSH`, which
> > is a `len == 0` case.
> > 
> > Maybe we do something like this?
> 
> 	Yes, only IP_VS_SO_SET_FLUSH uses len 0. We can go with
> this change but you do not need to target net tree, as the
> problem is not fatal net-next works too. What happens is
> that we may lookup services with random search keys which
> is harmless.

I see, I'll target net-next instead.

> 	Another option is to add new block after this one:
> 
>         } else if (cmd == IP_VS_SO_SET_TIMEOUT) {
>                 /* Set timeout values for (tcp tcpfin udp) */
>                 ret = ip_vs_set_timeout(ipvs, (struct ip_vs_timeout_user *)arg);
>                 goto out_unlock;
>         }
> 
> 	such as:
> 
> 	} else if (!len) {
> 		/* No more commands with len=0 below */
> 		ret = -EINVAL;
> 		goto out_unlock;
> 	}
> 
> 	It give more chance for future commands to use len=0
> but the drawback is that the check happens under mutex. So, I'm
> fine with both versions, it is up to you to decide :)

Ah, this seems much cleaner. I'll send v2 soon, thank you!

Peilin Ye

> > @@ -2432,6 +2432,8 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
> > 
> >  	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
> >  		return -EINVAL;
> > +	if (len == 0 && cmd != IP_VS_SO_SET_FLUSH)
> > +		return -EINVAL;
> >  	if (len != set_arglen[CMDID(cmd)]) {
> >  		IP_VS_DBG(1, "set_ctl: len %u != %u\n",
> >  			  len, set_arglen[CMDID(cmd)]);
> > @@ -2547,9 +2549,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
> >  		break;
> >  	case IP_VS_SO_SET_DELDEST:
> >  		ret = ip_vs_del_dest(svc, &udest);
> > -		break;
> > -	default:
> > -		ret = -EINVAL;
> >  	}
> > 
> >    out_unlock:
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
