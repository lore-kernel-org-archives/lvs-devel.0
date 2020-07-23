From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 04/26] net: add a new sockptr_t type
Date: Thu, 23 Jul 2020 17:40:49 +0200 (CEST)
Message-ID: <nycvar.YFH.7.77.849.2007231725090.11202@n3.vanv.qr>
References: <20200723060908.50081-1-hch@lst.de> <20200723060908.50081-5-hch@lst.de>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20200723060908.50081-5-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-de


On Thursday 2020-07-23 08:08, Christoph Hellwig wrote:
>+typedef struct {
>+	union {
>+		void		*kernel;
>+		void __user	*user;
>+	};
>+	bool		is_kernel : 1;
>+} sockptr_t;
>+
>+static inline bool sockptr_is_null(sockptr_t sockptr)
>+{
>+	return !sockptr.user && !sockptr.kernel;
>+}

"""If the member used to access the contents of a union is not the same as the
member last used to store a value, the object representation of the value that
was stored is reinterpreted as an object representation of the new type (this
is known as type punning). If the size of the new type is larger than the size
of the last-written type, the contents of the excess bytes are unspecified (and
may be a trap representation)"""

As I am not too versed with the consequences of trap representations, I will
just point out that a future revision of the C standard may introduce (proposal
N2362) stronger C++-like requirements; as for union, that would imply a simple:

"""It's undefined behavior to read from the member of the union that wasn't
most recently written.""" [cppreference.com]


So, in the spirit of copy_from/to_sockptr, the is_null function should read

{
	return sockptr.is_kernel ? !sockptr.user : !sockptr.kernel;
}

