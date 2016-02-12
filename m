From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RESEND net-next 0/2] ipvs: drop packet during rescheduling
Date: Fri, 12 Feb 2016 19:29:47 +0100
Message-ID: <20160212182947.GA30534@verge.net.au>
References: <1454843252-6761-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1455301795; bh=0z7jgU9+090mqV7akUcKR8JmaqDDHB1nsaTaoV/E+OM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Q589JSPM4EBHNJ+dBR9yAIJGwYplP3Y7ljkWcrOFpy/EB9wp+zSiOw/sv2BT54uLJ
	 XGwvKb3zgidv3hlK2ZqVqEeKyp85x29xUcApSVS8sOb287pKyyztyhfRUTdT9dhT+z
	 DRzm1Ql68wi+Faz6VUXwvmTk3wDS21o+C5wXnmMc=
Content-Disposition: inline
In-Reply-To: <1454843252-6761-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Jiri Bohac <jbohac@suse.cz>

On Sun, Feb 07, 2016 at 01:07:30PM +0200, Julian Anastasov wrote:
> Jiri Bohac is reporting for a problem with the connection
> rescheduling mechanism added in 3.10 when new SYNs in
> connection to dead real server can be redirected to another
> real server. His solution is to drop SYNs until the IPVS
> connection and its conntrack are properly removed, so that
> a new connection can be established later from client's
> retransmissions. Alternative would be to redirect the
> conntrack (its reply direction) to the new real server but
> we do not see such solution.
> 
> The second patch addresses another scenario: client restarts
> TCP connection by reusing the same IPVS connection:
> 
> - IPVS conn is established, eg. FTP without persistence
> - restart client box
> - start new TCP connection from same port to reuse IPVS conn
> C: SYN with new SEQ
> S: ACK with ACK_SEQ=old SEQ
> C: RST SEQ=old SEQ, IPVS conn:EST->CLOSE
> retransmit pause
> C: SYN, still in CLOSE? => DROP, expire IPVS conn
> Expire IPVS connection
> retransmit pause
> C: SYN, create connection
> 
> In this case we should allow rescheduling in CLOSE state.
> In the worst case for this scenario with initial RTO=3 secs
> the client can be delayed for 9 seconds.

Thanks, applied.
