Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C67804457BB;
	Fri,  2 Oct 2026 23:05:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790982320; cv=none; b=LredPuasNGR+2d2rc2UUgnX9nMHuvpH69YcYAPKgSXoSllrHkFa+9cjtQbjb4ozVCmhxQioj8zcPqb48hcRWVRgLq77N76WVrrMGAsHWpG90eX+NTwH/IgVPPL81ErW4cOaMomnfR2NipKNC9O+VQVzh7lj4whma/VWOAKb98ng=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790982320; c=relaxed/simple;
	bh=i5oaNHGAdkb0zqCN6vN8AE/+biKxEA0YIbi3B89FKZI=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=h/LpAfnhxC5yhJHrIuDgLJEQikEpuKSIXfm2GKaKXznxo0KJDciiI5itGo10g4IFQSJFODeaf382/SQt3LcMK036KIhAoBSOzPAuvEclaxlsbm+gsOfJ+eU/pNvz18ypfp1T/Xci9B+Y4gvcQS0HmZxJXxFNh8MgOnBo0+YMns4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Cxr4xlH9; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Cxr4xlH9"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 4903922277;
	Sat, 03 Oct 2026 02:05:05 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=0M1881/c6mUJyC89j1F2p8RwIeN5doM9DJaf/EAF91o=; b=Cxr4xlH9glGc
	7AtghnLdMSJAUxvhED7oIuGpxbjmHizc8esUgqXtWdxXzCE44/ag8zTNBXW9Q4jD
	XtHCYDbQjA+JE3Xg8j9B28DscyBSD/LLdqkptZYVkON8bvffc/WvWSY3Awrf8NKz
	ZanXMH16aWN5U68da/ylCugs7BjkowtJvP/Pwd27y7n4F+oNc9n/rDaNkKn9l9fF
	uhUa/7VRTdIwMpgRO89RSDDbUFgcdVNp8k0f47e4JOEiK9l457twwKA8B0AJXEC+
	RBocqm08ynO/HCRe78IKNy8nKvtZwE7lFv1/R59iAlQdgXGn1Jb89DRYgzt0cIQv
	Zqzx5fI2rGdJOTa7yUxpRAxAKN+QAeX3FyuJxLKfJ0RJ08gP5PgbkzaUM8IXn41B
	ZWnE3RwIdDy6KHCg45ZINMafhIilzMB5Y/4gC8H0PQNhaJgjs9BxVIBY5WmRqfmF
	10glUhQGm7bX9Viw9fOpyStU8GQsRD2uixPGn8EfsaeiI4m38/bzCpPtgcBW/h05
	9xsR4sSynTmI3uRtnPo+oqhFL7P6HwQWRL1AxgBwJwM26j/4UileVm/FSAw7Kole
	Vo0ZR/unPw2zDCHU8gZBZh+hYhuWzx2p4Ch1qouMu3pXF3AShLiVhPv6qd685yh0
	py0jE8dV3jIhvS4EAAf04HibO32G+2c=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 03 Oct 2026 02:05:05 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id BFD8F60B9C;
	Sat,  3 Oct 2026 02:05:05 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 692N4pow088259;
	Sat, 3 Oct 2026 02:04:52 +0300
Date: Sat, 3 Oct 2026 02:04:51 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Willy Tarreau <w@1wt.eu>, Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: keep templates and cport 0 conns away from
 packet lookups
In-Reply-To: <CALb1hrnMJGj5ePZSB89ZW0Uv_oNpepeqgAmGcZxRsLyv64HOYA@mail.gmail.com>
Message-ID: <f87eab0c-253a-2d5d-d2e6-f4fb691c9813@ssi.bg>
References: <20260925141115.16126-1-axel.mierczuk@1password.com> <002e2c69-ae17-4321-ba3d-74cca0e57123@ssi.bg> <CALb1hrnMJGj5ePZSB89ZW0Uv_oNpepeqgAmGcZxRsLyv64HOYA@mail.gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-247436806-1790982298=:44495"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-247436806-1790982298=:44495
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hi Axel,

On Wed, 30 Sep 2026, Axel Mierczuk wrote:

> Hi Julian,
> 
> Sounds good. I will take a look as well and get back to you.
> 
> On Tue, Sep 29, 2026 at 2:29 PM Julian Anastasov <ja@ssi.bg> wrote:
> 
>               Hello,
> 
>       On Fri, 25 Sep 2026, Axel Mierczuk wrote:
> 
>       > A template received over the unauthenticated sync protocol with a
>       > nonzero cport is matched by data packets in ip_vs_conn_in_get() and
>       > the protocol state machine runs on it. Patch 1 rejects sync records
>       > with inconsistent cport and IP_VS_CONN_F_NO_CPORT combinations on
>       > the backup.
>       >
>       > Patch 2 requires a nonzero cp->cport in ip_vs_conn_out_get() so that
>       > templates and connections still waiting for their cport cannot be
>       > matched through the out hook.
>       >
>       > The companion patch "ipvs: filter some flags received in the backup
>       > server" rejects template records carrying IP_VS_CONN_F_NO_CPORT.
>       >
>       > Axel Mierczuk (2):
>       >   ipvs: validate cport in received sync records
>       >   ipvs: skip cport 0 connections in ip_vs_conn_out_get()
>       >
>       >  net/netfilter/ipvs/ip_vs_conn.c |  3 ++-
>       >  net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
>       >  2 files changed, 21 insertions(+), 1 deletion(-)
> 
>               Axel, this Sashiko review is shattering:
> 
>       https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
> 
>               I'll be back with analyze how should we fix the
>       problems...

	Here is what we have for the Sashiko review:

https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com

Patch 1:

Q. Should the template branch also reject IP_VS_CONN_F_NO_CPORT?
A. Fixed by "ipvs: filter some flags received in the backup server"
which is already in the trees

Q. Can the master itself briefly send a record with a nonzero cport and
IP_VS_CONN_F_NO_CPORT still set?
A. Harmless

	So, nothing that needs to change the patch.

Patch 2:

Q1. Does this make the "update or create" lookup in ip_vs_ftp_out() in
net/netfilter/ipvs/ip_vs_ftp.c unreachable?
A. Looks like we need the same check in ip_vs_conn_out_get:

We should use:
	(!p->vport ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT)))

instead of the wrong cp->cport check.

	Using p->vport and not re-reading cp->cport above due to
tricks in ip_vs_conn_fill_cport(), see Q4 below.

Q2. Can this lead to a new connection being created for every packet of a
flow started by a real server towards client port 0?
A. I can provide patch to ignore packets with port 0.

Q3. The commit message assumes that only templates and NO_CPORT entries have
cport 0. Does that hold for ordinary MASQ connections scheduled for a
client that uses source port 0?
A. I can provide patch to ignore packets with port 0.

Q4. Can the two separate plain reads of cp->cport in ip_vs_conn_out_get()
see different values?
A. We can check p->vport, see Q1

Q5. TEMPLATE and NO_CPORT
A. Fixed by "ipvs: filter some flags received in the backup server"
which is already in the trees

	There is the option to create 3th patch "validate vport and dport 
in received sync records" in your patchset, so that such change can be 
propagated together:

	} else if (!param->vport) {
		...
	} else if (!dport &&
		   (flags & IP_VS_CONN_F_FWD_MASK) == IP_VS_CONN_F_MASQ) {
		...
	}

	Because it depends on your "ipvs: validate cport in received sync 
records" patch. Such change will prevent sync messages to create
connections with port 0 that can be later hit by packets with
port 0. But may be such change is not needed.

	I can provide a separate patch that will disallow connections
with 0 in cp->cport/vport created from packets. It will not conflict
with your changes.

	After correcting the check in ip_vs_conn_out_get() lookup misses
caused by client port 0 can lead to scheduling for every packet and 
creating duplicate connections. The main thing is to isolate cport 0
which for the backup server is already in your patch. The remaining part 
is to filter it in the scheduler. OTOH, the vport/dport checks are
just nice to have. The rule here is, if we do not match cport 0 when 
NO_CPORT is not set, we should also not create connections with cport 0.
As for the zero vport/dport, I'm not sure, they look harmless.
What do you think?

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-247436806-1790982298=:44495--

