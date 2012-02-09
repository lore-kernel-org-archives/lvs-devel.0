From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH] ipvsadm: fix list_daemon to handle master/backup status
 in either position
Date: Thu, 09 Feb 2012 18:42:07 +0100
Message-ID: <4F34056F.3010509@ahsoftware.de>
References: <4F33EB48.8010708@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4F33EB48.8010708@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Ryan O'Hara <rohara@redhat.com>
Cc: lvs-devel@vger.kernel.org

Am 09.02.2012 16:50, schrieb Ryan O'Hara:
> Attached is a patch that fixes the list_daemon function such that it
> does not assume that the master sync daemon status is always in the
> first position and master sync daemon status is always in the second
> position.
>
> If libipvs uses the netlink interface to retrieve sync daemon status,
> the results are not guaranteed to follow this ordering. As explained in
> a previous email, if libipvs uses the netlink interface to retrieve sync
> daemon status while only a backup sync daemon is running, the backup
> sync daemon status will but in the first position (index 0). This
> differs from the getsockopt interface, which would always put master
> sync daemon status in first position and backup sync daemon status in
> the second position, even when only backup sync daemon exists. Solution
> is to make ipvsadm check both elements of the array for master and backup.
>
> Ryan

I've fixed that through letting the netlink-api reporting the same as 
without netlink.

Don't know what solutions should be prefered.

Regards,

Alexander

---
  keepalived/libipvs-2.6/libipvs.c |   11 ++++++-----
  1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/keepalived/libipvs-2.6/libipvs.c 
b/keepalived/libipvs-2.6/libipvs.c
index ea5e851..6bee837 100644
--- a/keepalived/libipvs-2.6/libipvs.c
+++ b/keepalived/libipvs-2.6/libipvs.c
@@ -1003,12 +1003,9 @@ static int ipvs_daemon_parse_cb(struct nl_msg 
*msg, void *arg)
  	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
  	struct nlattr *daemon_attrs[IPVS_DAEMON_ATTR_MAX + 1];
  	ipvs_daemon_t *u = (ipvs_daemon_t *)arg;
+	__u32 state;
  	int i = 0;

-	/* We may get two daemons.  If we've already got one, this is the 
second */
-	if (u[0].state)
-		i = 1;
