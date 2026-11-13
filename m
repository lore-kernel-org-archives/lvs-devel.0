Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590101;
	b=y4mNCcG1Fode0OyxTpRpKIU6HT3qaOiHTsmEJ3WOWoZqfxS28M71o5+C4WrPiecBUJ8w
	 9CvwkdK2BJHEAgfG9zoE4DQ2W3CIFb2VWpIaVnJQ06dRJLp2724zxmpWcFjxr5F+V7b7v
	 rwBIceyVD5xmi6HbymsdnbPFEXsl79SA+mfg5Kp1REVWlsKmNcb5KB+BmcIt0J8VnAS7r
	 Uwsst5gy0IpXaa6709GzGg4gU4+lAEZuEgyjXQvEgHk+DMrprQJ6XUWzXmiS6cYqqq2Ap
	 qu96SZo849dCuDhSvBcHJ7fjmLeUQkvvf+vG7RmWy3svO+CSnpBPY0BWNn6ZUThJIFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590101;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To;
	bh=ucmNkO3Zr7utezXqbUCs39iAC3mVF4QkvwQZf15/8+s=;
	b=OuppHcN3ceFfllpDEbpOzTz+V/atI6/6nv/ijxftwisqw6w7itHqt5iaFMp7rlacNxts
	 qR098WMkb5bye1f2M9Vp+sGIGMaTA/07zsX1mahr5//6Xwxk5LtAWkdedRhq2pFgZlfNK
	 PQbyYVTbZSAGwS7QXNC8KCA6qKcKrei6MLh20cWzAPVbV3axQxBlDftkajhZt53WYaSPM
	 bX576rAh4gFP9DYqPwNxVh+AanEBcrTgWxSdF4IGKu/DpZ0E4HxillBPlzaNKhte2DRL0
	 eefH55ooKU05PoIlCRSey2ezwSwOEgRIAwNrsxv0wUr32vfWXLSj9ccLVYOggS+95Bw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DNCjJlgK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1838D606C0B9;
	Fri, 13 Nov 2026 17:15:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DNCjJlgK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 956A21F000C6;
	Fri, 13 Nov 2026 17:14:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590100;
	bh=ucmNkO3Zr7utezXqbUCs39iAC3mVF4QkvwQZf15/8+s=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=DNCjJlgKNh9c0r1PaRCLnwwE5n+C3S60bfvZJaf+nJ7KWcDiKLGcXX6FNu0XJfyD/
	 3bdoAG8tAkG68vEzKjQrrrI6ug0vHNAS4EQnciubWoQZopxMl1p87qVdVEKod+gpcE
	 Pvu/lZkOOMowPYg6epJuxo6POYBDZFCQxK3yaRXNIGwVmonlohl4naWlGk1awOAh1c
	 DW2t9XPiE2rc5KayQxzdVOlL/hb/7rd0j7g2bP27Iux4g7YZcChNqLiPK4pQfYUFke
	 VJvH0sWOL7F4hCT6XaVTVzVaCcr5fh5Sh91Kvz8uv24HKHW7vVhvyLvHirPIJzdRKr
	 RVwMU/4vX3u5Q==
Date: Fri, 13 Nov 2026 17:14:52 +0000
From: Simon Horman <horms@kernel.org>
To: netdev-bot+sashiko@kernel.org
Cc: jiayuan.chen@linux.dev, netdev@vger.kernel.org, dsahern@kernel.org,
	idosch@nvidia.com, davem@davemloft.net, edumazet@kernel.org,
	kuba@kernel.org, pabeni@redhat.com, pablo@netfilter.org,
	fw@strlen.de, phil@nwl.cc, razor@blackwall.org, paul@paul-moore.com,
	matttbe@kernel.org, martineau@kernel.org, geliang@kernel.org,
	ja@ssi.bg, achender@kernel.org, marcelo.leitner@gmail.com,
	lucien.xin@gmail.com, alibuda@linux.alibaba.com,
	dust.li@linux.alibaba.com, sidraya@linux.ibm.com,
	mjambigi@linux.ibm.com, tonylu@linux.alibaba.com,
	guwen@linux.alibaba.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux.dev, linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev, lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH net-next 06/14] sctp: annotate data-races around sctp
 sysctls
Message-ID: <20261113171452.GQ18859@horms.kernel.org>
References: <20261109025425.328445-7-jiayuan.chen@linux.dev>
 <179429000207.994134.10637780638316929795@kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <179429000207.994134.10637780638316929795@kernel.org>

On Tue, Nov 10, 2026 at 05:53:22AM +0000, netdev-bot+sashiko@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found 1 potential
> issue(s) to consider.
> 
> Critical: 0 · High: 1 · Medium: 0 · Low: 0
> 
> If you believe none of the issues are legitimate, please reply to each
> issue of Medium severity or higher and explain why the AI is wrong.
> If any of them are legitimate and you plan to respin, please let patchwork
> know by including "pw-bot: cr" as a separate line at the end of your reply
> (one such reply per series is enough).
> 
> - [High] The fix is incomplete inside the same sysctl handlers it
>   changes.
> 
> --
> 
> sctp: annotate data-races around sctp sysctls
> 
> This commit adds READ_ONCE() to readers of many per-netns sctp sysctl
> fields. It also converts the plain stores in the rto_min, rto_max,
> udp_port, probe_interval, auth_enable and cookie_hmac_alg handlers to
> WRITE_ONCE().
> 
> > diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> > index 2b94c211427de..8a84ae3272d24 100644
> > --- a/net/sctp/sysctl.c
> > +++ b/net/sctp/sysctl.c
> > @@ -402,11 +402,11 @@ static int proc_sctp_do_hmac_alg(const struct ctl_table *ctl, int write,
> >  		if (ret)
> >  			return ret;
> >  		if (!strcmp(tmp, "sha256")) {
> > -			net->sctp.cookie_auth_enable = 1;
> > +			WRITE_ONCE(net->sctp.cookie_auth_enable, 1);
> >  			return 0;
> >  		}
> >  		if (!strcmp(tmp, "none")) {
> > -			net->sctp.cookie_auth_enable = 0;
> > +			WRITE_ONCE(net->sctp.cookie_auth_enable, 0);
> >  			return 0;
> >  		}
> >  		return -EINVAL;
> > @@ -441,7 +441,7 @@ static int proc_sctp_do_rto_min(const struct ctl_table *ctl, int write,
> >  		if (new_value > max || new_value < min)
> >  			return -EINVAL;
> >  
> > -		net->sctp.rto_min = new_value;
> > +		WRITE_ONCE(net->sctp.rto_min, new_value);
> >  	}
> >  
> >  	return ret;
> > @@ -469,7 +469,7 @@ static int proc_sctp_do_rto_max(const struct ctl_table *ctl, int write,
> >  		if (new_value > max || new_value < min)
> >  			return -EINVAL;
> >  
> > -		net->sctp.rto_max = new_value;
> > +		WRITE_ONCE(net->sctp.rto_max, new_value);
> >  	}
> >  
> >  	return ret;
> 
> [Severity: High]
> Do the handlers this patch edits still contain plain loads of these same
> fields?
> 
> proc_sctp_do_rto_min() reads rto_max through extra2 to bound the new
> value. proc_sctp_do_rto_max() reads rto_min through extra1 in the same
> way:
> 
> net/sctp/sysctl.c:proc_sctp_do_rto_min() {
> 	...
> 	unsigned int min = *(unsigned int *) ctl->extra1;
> 	unsigned int max = *(unsigned int *) ctl->extra2;
> 	...
> }
> 
> sctp_sysctl_net_register() points these at the live per-netns fields. The
> static sctp_net_table does the same for init_net:
> 
> 	table[SCTP_RTO_MIN_IDX].extra2 = &net->sctp.rto_max;
> 	table[SCTP_RTO_MAX_IDX].extra1 = &net->sctp.rto_min;
> 
> So when writes to /proc/sys/net/sctp/rto_min and rto_max run at the same
> time, proc_sctp_do_rto_min() does a plain read of rto_max while
> proc_sctp_do_rto_max() does WRITE_ONCE(net->sctp.rto_max, ...). The same
> thing happens in the other direction for rto_min. Nothing serializes
> these two handlers against each other.
> 
> The read branch of proc_sctp_do_hmac_alg() also still loads
> cookie_auth_enable without READ_ONCE():
> 
> 	if (net->sctp.cookie_auth_enable)
> 		tbl.data = (char *)"sha256";
> 	else
> 		tbl.data = (char *)"none";
> 
> This can race with the WRITE_ONCE() stores above when cookie_hmac_alg is
> read and written at the same time.
> 
> The commit message lists rto_min, rto_max and the cookie_hmac_alg handler
> among the races being closed. The readers of these fields in
> sctp_init_sock() now use READ_ONCE().
> 
> Should these three loads in the handlers use READ_ONCE() too? Otherwise
> KCSAN can still report a marked write racing with a plain read on these
> fields.

This one also looks like it should be addressed.

-- 
pw-bot: changes-requested
