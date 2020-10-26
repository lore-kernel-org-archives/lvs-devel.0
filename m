From: Julian Anastasov <ja@ssi.bg>
Subject: Re: a question about fullnat mode for ipvs
Date: Mon, 26 Oct 2020 22:23:42 +0200 (EET)
Message-ID: <615db10-72af-2a86-dde2-61af8e6bd80@ssi.bg>
References: <20201005201347.13644-1-ja@ssi.bg> <20201012000223.GA14420@salvia> <1989ac03.3737.175445ba5f9.Coremail.bigclouds@163.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-345138178-1603743827=:4529"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1989ac03.3737.175445ba5f9.Coremail.bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
To: "longguang.yue" <bigclouds@163.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yuelongguang@gmail.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-345138178-1603743827=:4529
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Tue, 20 Oct 2020, longguang.yue wrote:

> Hi,all:
>     fullnat mode refers to  incoming packet's src:port and dst:port pairs are both changed at the same
> time, vice  versa for outgoing packets.
>     fullnat has existed for many years since 2009, why which is not in kernel.

	Not sure. What I see now is that it adds some complexity
to the code. Open questions are about integration with netfilter
conntracks (when conntrack=1), in the sync protocol, etc.

>     introduction for fullnat    http://kb.linuxvirtualserver.org/wiki/IPVS_FULLNAT_and_SYNPROXY
> 
> could we port or re-implement it in upstream?

	May be I don't fully understand the goals but
is it worth it?

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-345138178-1603743827=:4529--

