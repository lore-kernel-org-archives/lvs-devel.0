From: Peilin Ye <yepeilin.cs@gmail.com>
Subject: Re: [Linux-kernel-mentees] [PATCH net] ipvs: Fix uninit-value in
 do_ip_vs_set_ctl()
Date: Tue, 11 Aug 2020 01:09:29 -0400
Message-ID: <20200811050929.GA821443@PWN>
References: <20200810220703.796718-1-yepeilin.cs@gmail.com>
 <CAM_iQpWsQubVJ-AYaLHujHwz68+nsHBcbgbf8XPMEPD=Vu+zaA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=bMSxjMPm7VjNJMk372pm84tQNgfCuUZD1VrmgkqYZCk=;
        b=eLBzjVCO5YbxLczQR30kyge47su0iVcJrFjbDeldqpgB2hjXU5IW3vXcQ8JtxRodoF
         qhbLl6bjXO7Jlw5cfCnfSLBt+UguSzjYM/bCiq6Xxpf+ZkzFhamxpFsXgZzbBx6bwrRb
         AnpIjg5QVPT1+z+Qpl+qqYHwXJoByhiyqO//u5t9q3f2ygLnkR8e72dL3xFxHLsAbyRH
         0oluLqNNUANwqEYLXSTn4UMI+9lJTfM97LFe+l/JXOJSCK689qf99iDm1Firfr0u/GSu
         UpgsbvWWHqyyqD/O1gvgX4uLDpJCVFTDiHOJmuk2+ojKOft0M7v7IHvKcYcncAIGKVzp
         EkZw==
Content-Disposition: inline
In-Reply-To: <CAM_iQpWsQubVJ-AYaLHujHwz68+nsHBcbgbf8XPMEPD=Vu+zaA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, linux-kernel-mentees@lists.linuxfoundation.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2020 at 08:57:19PM -0700, Cong Wang wrote:
> On Mon, Aug 10, 2020 at 3:10 PM Peilin Ye <yepeilin.cs@gmail.com> wrote:
> >
> > do_ip_vs_set_ctl() is referencing uninitialized stack value when `len` is
> > zero. Fix it.
> 
> Which exact 'cmd' is it here?
> 
> I _guess_ it is one of those uninitialized in set_arglen[], which is 0.

Yes, it was `IP_VS_SO_SET_NONE`, implicitly initialized to zero.

> But if that is the case, should it be initialized to
> sizeof(struct ip_vs_service_user) instead because ip_vs_copy_usvc_compat()
> is called anyway. Or, maybe we should just ban len==0 case.

I see. I think the latter would be easier, but we cannot ban all of
them, since the function does something with `IP_VS_SO_SET_FLUSH`, which
is a `len == 0` case.

Maybe we do something like this?

@@ -2432,6 +2432,8 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)

 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
 		return -EINVAL;
+	if (len == 0 && cmd != IP_VS_SO_SET_FLUSH)
+		return -EINVAL;
 	if (len != set_arglen[CMDID(cmd)]) {
 		IP_VS_DBG(1, "set_ctl: len %u != %u\n",
 			  len, set_arglen[CMDID(cmd)]);
@@ -2547,9 +2549,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		break;
 	case IP_VS_SO_SET_DELDEST:
 		ret = ip_vs_del_dest(svc, &udest);
-		break;
-	default:
-		ret = -EINVAL;
 	}

   out_unlock:

Thank you,
Peilin Ye

> In either case, it does not look like you fix it correctly.
> 
> Thanks.
