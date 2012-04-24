From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v3] ipvs: add support for sync threads
Date: Tue, 24 Apr 2012 09:36:00 +0900
Message-ID: <20120424003600.GD22556@verge.net.au>
References: <1335221927-3655-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335221927-3655-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi Julian,

it seems that patch 5 from the original series no longer applies due to 
4a17fd5229c1b6066aa478f6b690f8293ce811a1 ("sock: Introduce named constants
for sk_reuse") which is now present in ipvs-next. Would it be possible
for you to rebase your series on ipvs-next and repost the entire series?
