From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 09/25] IPVS: Add 'af' args to protocol handler
	functions
Date: Tue, 2 Sep 2008 16:26:11 +1000
Message-ID: <20080902062610.GE13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-10-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-10-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:56:06PM +0200, Julius Volz wrote:
> Add 'af' arguments to conn_schedule(), conn_in_get(), conn_out_get() and
> csum_check() function pointers in struct ip_vs_protocol. Extend the
> respective functions for TCP, UDP, AH and ESP and adjust the callers.
> 
> The changes in the callers need to be somewhat extensive, since they now
> need to pass a filled out struct ip_vs_iphdr * to the modified functions
> instead of a struct iphdr *.

Hi Julius,

./scripts/checkpatch.pl has flagged the following problems.
Could you take a look into the whitespace ones? I'm not
so concerned about the assignment one as it is
an existing problem - though if you want to fix it here and elsewhere,
thats fine too :-)

ERROR: code indent should use tabs where possible
#307: FILE: net/ipv4/ipvs/ip_vs_proto_ah_esp.c:43:
+^I           const struct ip_vs_iphdr *iph, unsigned int proto_off,$

ERROR: code indent should use tabs where possible
#308: FILE: net/ipv4/ipvs/ip_vs_proto_ah_esp.c:44:
+^I           int inverse)$

ERROR: code indent should use tabs where possible
#357: FILE: net/ipv4/ipvs/ip_vs_proto_ah_esp.c:82:
+^I            const struct ip_vs_iphdr *iph,$

ERROR: code indent should use tabs where possible
#359: FILE: net/ipv4/ipvs/ip_vs_proto_ah_esp.c:84:
+^I            int inverse)$

ERROR: do not use assignment in if condition
#654: FILE: net/ipv4/ipvs/ip_vs_proto_udp.c:94:
+	if ((svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,

total: 5 errors, 0 warnings, 624 lines checked
