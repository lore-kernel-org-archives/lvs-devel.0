From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for
 IPPROTO_TCP
Date: Wed, 6 Jun 2018 01:35:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1806060126480.3574@ja.home.ssi.bg>
References: <20180419212324.1542504-1-kafai@fb.com> <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg> <20180502171041.s3euld6i7hm6bw5c@kafai-mbp> <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg> <20180503070114.bcuusvzga45klccs@kafai-mbp>
 <alpine.LFD.2.20.1805051515450.1895@ja.home.ssi.bg> <20180605213128.tlskvjhuk6vx3m6r@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180605213128.tlskvjhuk6vx3m6r@kafai-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin KaFai Lau <kafai@fb.com>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org


	Hello,

On Tue, 5 Jun 2018, Martin KaFai Lau wrote:

> On Sat, May 05, 2018 at 03:58:25PM +0300, Julian Anastasov wrote:
> > 	So, except the RTF_LOCAL check in __ip6_rt_update_pmtu
> > we should have no other issues. 
> Hi Julian,
> 
> Do you have a chance to work on the IPv6 side?

	I was chasing other IPVS issues while preparing
to finalize these changes. I plan to do tests this weekend
and to submit my patch but without gso_size modifications.
Can post patch for this check in __ip6_rt_update_pmtu too,
separately after making sure all is fine.

Regards
