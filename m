From: Julian Anastasov <ja@ssi.bg>
Subject: Re:Re: [PATCH] ipvs: add a sysctl switch to control ipvs to bypass
 OUTPUT chain or not
Date: Thu, 25 Aug 2022 08:32:51 +0300 (EEST)
Message-ID: <e1adaaad-49f-de31-1dff-183eee242dc@ssi.bg>
References: <20220819100702.14889-1-bigclouds@163.com> <495ceee5-f8dc-06e-d1ef-258d1889c7b8@ssi.bg> <31196e83.2cbe.182d3693f03.Coremail.bigclouds@163.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-110765213-1661405572=:5176"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <31196e83.2cbe.182d3693f03.Coremail.bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
To: "longguang.yue" <bigclouds@163.com>
Cc: horms@verge.net.au, kadlec@netfilter.org, fw@strlen.de, pablo@netfilter.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-110765213-1661405572=:5176
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Thu, 25 Aug 2022, longguang.yue wrote:

> I see. 
> I hope we could find a maintainable and decoupled way to keep ipvs high performance.
> especially for kubernetes environment, there are from dozens up to one hundred rules in OUTPUT chain.

	May be some rules can help the bunch of rules to
be applied only for first packet, not for every packet in
connection, such as:

iptables -t filter -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A OUTPUT -m ipvs --ipvs -j ACCEPT

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-110765213-1661405572=:5176--

