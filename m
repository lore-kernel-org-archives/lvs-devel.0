From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH v2 1/2] netfilter: ipvs: Verify that IP_VS protocol has
 been registered
Date: Sat, 14 Apr 2012 14:06:22 +0200
Message-ID: <CA+1xoqe0q=XH7mO6=qZKPxqZK8LU2Kk5BjmfLeQ9LUD1Ku65YA@mail.gmail.com>
References: <1334409722-26315-1-git-send-email-levinsasha928@gmail.com> <alpine.LFD.2.00.1204141439440.1680@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type:content-transfer-encoding;
        bh=V3kw4IZYbIuHdfy8qoYzKPhjN+vIkZcq5QXgvdODUWo=;
        b=ODX1Nv/nDBE7+BXErsVq/cK7H4SOE4435YbYdS2s5s2FNtFYR0h1pyC3+YsrutLrXm
         aN+aJMMMuyZQZRrZGXIeFmEy949qfg1CzGpl9hRpaD3WRGb+cNjsPtBr1ss4+vpsvFjb
         Q+ddE4S/I1zaQ2C8ZzYeCiiZvyNk9uTeQAaiBzRBbvmVUYke77b+aJGU0cpoajl1CalD
         VptWwMrYh5io/+9IDArinKOPdHpNMdrW8m0nTjJ5RrDWQHDhRIM37MCALZ5ijJu2Ac/g
         pZMiHlQaK2kVaSjMqyy8Nnps6hmBo52IFlExqcZ8iWx6boZUik6l1vYFiFcPb5zXS4gx
         TwtA==
In-Reply-To: <alpine.LFD.2.00.1204141439440.1680@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Julian Anastasov <ja@ssi.bg>
Cc: wensong@linux-vs.org, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Apr 14, 2012 at 1:53 PM, Julian Anastasov <ja@ssi.bg> wrote:
> =A0 =A0 =A0 =A0Ops. It seems now we expose old problem when
> no protocol is configured. As this change probably will
> go to stable kernels, lets make it correct. Can you
> remove the defines around register_ip_vs_proto_netns, so
> that it is always compiled. One that wants to save
> memory will not disable all protocols. See commit
> 091bb34c143674d37a59b2d4857534f7106c5d7d for reference.

Oh, so it wasn't getting built right now at all if we didn't select
any protocols.

How about moving those defines down to our loop as well? this way
everything will behave exactly like it did before.
