From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 00/20] Support v6 real servers in v4 pools and
 vice versa
Date: Wed, 10 Sep 2014 09:01:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409100853260.6338@ja.home.ssi.bg>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: netdev@vger.kernel.org, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com


	Hello,

On Tue, 9 Sep 2014, Alex Gartrell wrote:

> The following patch set has been iterated upon in the lvs-devel mailing
> list.  I am submitting it here per Julian's advice for inclusion in the
> net-next tree.

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, please apply the patchset to ipvs-next.
I guess ipvs-next and nf-next need to be updated
before that due to dependency on net-next commit ea1d5d7755a3e556
("ipvs: properly declare tunnel encapsulation").

Regards

--
Julian Anastasov <ja@ssi.bg>
