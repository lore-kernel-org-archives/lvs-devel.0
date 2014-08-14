From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH ipvs] ipvs: Add selftests for ipvs
Date: Thu, 14 Aug 2014 18:51:31 +0200
Message-ID: <20140814185131.5a3d6062@redhat.com>
References: <1407982349-9080-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1407982349-9080-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com

On Wed, 13 Aug 2014 19:12:29 -0700
Alex Gartrell <agartrell@fb.com> wrote:

> Here's a basic python framework for doing selftests on ipvs.

Generally, I would like to see some comments in the individual *.py
programs describing in general terms what is covered by this test or
what the module provide to others, but in general terms what the idea
is behind the module (I don't usually code/read python, but the
function names does make enough sense that I get what they do).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
