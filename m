From: juliusv@google.com (Julius Volz)
Subject: Re: [PATCHv3 0/2] IPVS: Add Generic Netlink configuration interface
Date: Fri, 8 Aug 2008 14:06:43 +0200
Message-ID: <20080808120642.GB32458@google.com>
References: <1218120219-1117-1-git-send-email-juliusv@google.com> <20080808022607.GB6094@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1218197208; bh=UwbHh8Frn5XxWL8goJ49fHp/uvs=;
	h=DomainKey-Signature:Date:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 User-Agent:From; b=fnKZwq8CbsjdcpUDUi2oL+0eI0sGNZ6+k97WL3xFG+daS9H
	yXboSeJg0S18BuiqUVfWbPu255rLSRC6RK9IboQ==
Content-Disposition: inline
In-Reply-To: <20080808022607.GB6094@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: julius.volz@gmail.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Fri, Aug 08, 2008 at 12:26:09PM +1000, Simon Horman wrote:
> these patches seem fine to me, however I am still seeing an oops
> when using the new ipvsadm. Are we sure that this bug is in generic
> code?
> 
> # ipvsadm -A -t 10.4.0.132:80
> # ipvsadm -C
> BUG: unable to handle kernel NULL pointer dereference at 00000028
> IP: [<c021f034>] ip_vs_genl_set_cmd+0x254/0x494
> *pde = 00000000 
> Oops: 0000 [#1] 

Ah, that made me find a bug where svc wasn't initialized to NULL at the
beginning of ip_vs_genl_set_cmd(). I'm not sure though if that was the
problem or if it still is some general genl issue. I just posted a newer
version version in response to my earlier post, could you give it a try?

Best with this updated ipvsadm:
http://www-user.tu-chemnitz.de/~volz/ipvsadm-1.25-nl-3.tar.gz
(later also at http://sixpak.org/vince/google/ipvsadm/)

Thanks,
Julius
