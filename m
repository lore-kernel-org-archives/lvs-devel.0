From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 1/2] netfilter: ipvs: Verify that IP_VS protocol has
 been registered
Date: Sat, 14 Apr 2012 15:23:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204141518270.9966@ja.ssi.bg>
References: <1334409722-26315-1-git-send-email-levinsasha928@gmail.com> <alpine.LFD.2.00.1204141439440.1680@ja.ssi.bg> <CA+1xoqe0q=XH7mO6=qZKPxqZK8LU2Kk5BjmfLeQ9LUD1Ku65YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-151450638-1334406212=:9966"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CA+1xoqe0q=XH7mO6=qZKPxqZK8LU2Kk5BjmfLeQ9LUD1Ku65YA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-151450638-1334406212=:9966
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Sat, 14 Apr 2012, Sasha Levin wrote:

> On Sat, Apr 14, 2012 at 1:53 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >        Ops. It seems now we expose old problem when
> > no protocol is configured. As this change probably will
> > go to stable kernels, lets make it correct. Can you
> > remove the defines around register_ip_vs_proto_netns, so
> > that it is always compiled. One that wants to save
> > memory will not disable all protocols. See commit
> > 091bb34c143674d37a59b2d4857534f7106c5d7d for reference.
> 
> Oh, so it wasn't getting built right now at all if we didn't select
> any protocols.
> 
> How about moving those defines down to our loop as well? this way
> everything will behave exactly like it did before.

	Better to remove the defines. It is a misconfiguration
to enable IPVS without protocols. The referenced commit
just tried to remove warnings, not save memory by commenting
unused function. Adding more define makes the things more ugly.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-151450638-1334406212=:9966--
