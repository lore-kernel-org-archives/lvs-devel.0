From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 00/24] Add first IPv6 support to IPVS
Date: Tue,  2 Sep 2008 15:55:31 +0200
Message-ID: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363761; bh=wBf78BE5Rs5Plie0LYhIu3MlP+c=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer;
	b=uwKy7FS+u3x80GLTcGQY+BY4EcsjNhPAppvCXWkmfIB/bwSMnOXv+c3+C4eXppRnZ
	rspe3f4C+9Ggjs0xqm+jA==
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com

Hi Horms,

Here comes the whole batch again! I've fixed almost all style issues
reported by checkpatch.pl, except for some little things which look like
they could stay like they are for now (down to 3 warnings and 2 errors).
I also integrated your other comments and removed the patch that
adds the changelog information (not needed anymore, according to
Stephen).

These patches are based on lvs-2.6:

git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git

- Full kernel patch in one file:
  http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6_v3.patch

While not all IPv6 features are working or tested, existing IPv4 features
should still work as before. However, to use any of the new features, you
will need a new ipvsadm with support for genetlink and IPv6:

  http://sixpak.org/vince/google/ipvsadm/
  (by Vince Busam)

To enable IPv6 support in IPVS, set CONFIG_IP_VS_IPV6=y.

Short overview:

What works with IPv6:
- forwarding mechanisms: NAT, DR, maybe Tunnel (not fully tested yet)
- protocols: TCP, UDP, ESP, AH (last two not tested)
- manipulation and inspection of both IPv4 and IPv6 entries with ipvsadm
- 6 out of 10 schedulers

What is not supported with IPv6:
- handling fragmentation or other extension headers
- FTP application helper (can be loaded, but only operates on v4)
- sync daemon (can be started, but only operates on v4)
- probably some incorrect handling of ICMPv6 or other corner cases

Since fragmentation and extension headers should not occur very often,
things should "mostly" work. I tested HTTP and DNS over NAT and DR
with various supported schedulers without encountering any problems.
But we didn't test any exotic situations. Also, there are some TODOs
in the code for things that haven't been tested or implemented yet.

Thanks for any comments!

Julius
