From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL v2 0/1] IPVS Fixes for v4.11
Date: Fri, 28 Apr 2017 12:11:53 +0200
Message-ID: <20170428101154.9750-1-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1493374320; bh=fFNdFwfMdOJKA1gnuacMf9ryD5DGRG2bJRGfIsZyovs=;
        h=From:To:Cc:Subject:Date:From;
        b=SQzQ8Y9Ze2uSxkVqLysjp2ETCFWFJ0dl0ISKgn/iwgAytvt8Ff06zzwVv4NuiERT7
         HeWTL3WD2B0Ff9e8ou9/uSslV+7DPf7CPWeHTaSP1ytcc3d3rmU8FfLyB3XIgXXLj6
         90k0WgyNy7DvbL93q0jRAvNhNxzf4ywyR6/eqAqY=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix to IPVS for v4.11.
Or if it is too late for v4.11 please consider it for v4.12.
I would also like it considered for stable.

* Explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled
  to avoid oops caused by IPVS accesing IPv6 routing code in such
  circumstances.

Change since v1 of pull request:
* Rebase on nf
* Correct URL; it should be ipvs not ipvs-next


The following changes since commit 9dd2ab609eef736d5639e0de1bcc2e71e714b28e:

  netfilter: Wrong icmp6 checksum for ICMPV6_TIME_EXCEED in reverse SNATv6 path (2017-04-25 11:10:38 +0200)

are available in the git repository at:

  http://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git ipvs-fixes-for-v4.11

for you to fetch changes up to 1442f6f7c1b77de1c508318164a527e240c24a4d:

  ipvs: explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled (2017-04-28 12:04:35 +0200)

----------------------------------------------------------------
Paolo Abeni (1):
      ipvs: explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled

 net/netfilter/ipvs/ip_vs_ctl.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)
