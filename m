From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH net-next 00/12] IPVS optimizations
Date: Thu, 07 Mar 2013 11:09:26 +0100
Message-ID: <1362650966.18590.127.camel@localhost>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, 2013-03-06 at 10:42 +0200, Julian Anastasov wrote:
> 	This is a first patchset for IPVS optimizations.
> Another patchset will address the locking in schedulers
> and moving the global _bh disabling from LOCAL_OUT to all
> locks. It is in TODO list.

Do you have any performance measurements?

Or is this code primarily cleanup optimizations, and the next patchset
will address the performance part?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


