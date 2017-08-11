From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: catch the original errno from netlink answer
Date: Fri, 11 Aug 2017 15:50:47 +0200
Message-ID: <20170811155047.46cb6b67@redhat.com>
References: <20170805113828.9951-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20170805113828.9951-1-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Emanuele Rocca <ema@wikimedia.org>, brouer@redhat.com

On Sat,  5 Aug 2017 14:38:28 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> nl_recvmsgs_default() returns NLE_* error codes and not
> errno values. As result, attempt to delete virtual service
> returns NLE_OBJ_NOTFOUND (12) which matches the ENOMEM value.
> 
> Problem as reported by Emanuele Rocca:
> 
> ipvsadm -D -t example.org:80
> Memory allocation problem
> 
> Fix it by providing generic error handler to catch the errno
> value as returned in netlink answer. By this way all netlink
> commands will get proper error string. The problem is present
> only when ipvsadm is compiled with libnl.
> 
> ipvsadm -D -t example.org:80
> No such service
> 
> Reported-by: Emanuele Rocca <ema@wikimedia.org>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I've gone through the full call path from the kernel via netlink, and I
was going to claim that we also needed to handle errno "-EEXIST" in the
ipvsadm translation function ipvs_strerror().  Note, this fix uses the
errno "-ESRCH".

As kernel function ip_vs_del_service() return -EEXIST (if svc==NULL)
 http://elixir.free-electrons.com/linux/v4.12.5/source/net/netfilter/ipvs/ip_vs_ctl.c#L1480

BUT a closer look shows that -EEXIST will never get returned by
ip_vs_del_service() as all callers of this function does a svc==NULL
check and return "-ESRCH" instead.

Thus, this patch is correct, but the kernel code is confusing ;-)

Applied:
 https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=f8cff0808a24b

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
