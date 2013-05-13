From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Mon, 13 May 2013 15:38:52 +0200
Message-ID: <20130513153852.6d2d2840@redhat.com>
References: <alpine.LFD.2.00.1305081012310.1912@ja.ssi.bg>
	<1368264745-15242-1-git-send-email-grzegorz.lyczba@gmail.com>
	<alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Grzegorz =?UTF-8?B?xYF5Y3piYQ==?= <grzegorz.lyczba@gmail.com>, lvs-devel@vger.kernel.org

On Sat, 11 May 2013 16:23:33 +0300 (EEST) Julian Anastasov <ja@ssi.bg>
wrote:
 
> 	The change looks correct but you have to fix some
> coding style issues. Otherwise, patch will be rejected.
> You can also check Documentation/CodingStyle

Also remember to add a "version" tag to the subject, when you resubmit.

Subject like:
 [PATCH v3] ipvs: Fix reuse connection if real server is dead


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
