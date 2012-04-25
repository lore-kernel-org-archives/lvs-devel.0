From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 0/2] ipvs: netns avoid crash at netns init
Date: Wed, 25 Apr 2012 09:43:39 +0200
Message-ID: <1335339821-29684-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Two simple patches that avoid crashes for no memory at netns init.

- Check return value of protocoll init.
- Null check of net-ipvs in shedulers.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
-- 
1.7.2.3
