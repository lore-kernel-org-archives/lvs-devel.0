From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 12/25] IPVS: Extend functions for
	getting/creating connections
Date: Tue, 2 Sep 2008 16:47:55 +1000
Message-ID: <20080902064753.GF13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-13-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-13-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:56:09PM +0200, Julius Volz wrote:
> Extend functions for getting/creating connections and connection
> templates for IPv6 support and fix the callers.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>

./scripts/checkpatch.pl has flagged the following problems.
I realise that the last one is not new, but could you fix it anyway?

WARNING: line over 80 characters
#177: FILE: net/ipv4/ipvs/ip_vs_conn.c:236:
+		cp = __ip_vs_conn_in_get(af, protocol, s_addr, 0, d_addr, d_port);

WARNING: line over 80 characters
#549: FILE: net/ipv4/ipvs/ip_vs_ftp.c:175:
+			  NIPQUAD(from.ip), ntohs(port), NIPQUAD(cp->caddr.ip), 0);

ERROR: space required after that ',' (ctx:VxV)
#578: FILE: net/ipv4/ipvs/ip_vs_ftp.c:201:
+		sprintf(buf,"%d,%d,%d,%d,%d,%d", NIPQUAD(from.ip),
 		           ^

total: 1 errors, 2 warnings, 690 lines checked
