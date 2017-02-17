From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 3/4] ipvs: Document sysctl sync_ports
Date: Fri, 17 Feb 2017 14:34:00 +0800
Message-ID: <1487313241-11361-4-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=QIonc14KXVoY416l8ZU7gYdhf/NolRSFNxlLcJ9h+HE=;
        b=Q3jSOkRuge4G1czPa/d35G429ooi2NqS1SngL32jp9aqqhyWj+aCGDWF9cIn7yVFEe
         2DzeGNzGvxZ7ct6JVqHZs3nJoTuF6WeN4gJSS+ZE+gYhwF0iA1CwAix9bzqNCuAsIqPD
         /QdVOtqIDG8MVcLN1+KNX1qxncHSUyVoirYIyC7RWqo+tGBt/J5sjLo/laY+LkZFoF2/
         Dvm9AZi1ZHpmZJhGkHqGjRIbtbC92PIDSwHPFZqmvQ+KaW+Kt0dqQDERb3mzyL+lX4j/
         wXaMCLpsx0s/Wzz/jGD7IrNj2/fzs9/cxscihNm5sGCqkolfhMQ8brqbrzEocz+9JHIw
         2K3Q==
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Hangbin Liu <liuhangbin@gmail.com>

Document sysctl sync_ports based on commit f73181c8288f ("ipvs: add support
for sync threads").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ipvs-sysctl.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7622ba5..e4d9235 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -230,6 +230,14 @@ sync_sock_size - INTEGER
 	Configuration of SNDBUF (master) or RCVBUF (slave) socket limit.
 	Default value is 0 (preserve system defaults).
 
+sync_ports - INTEGER
+	default 1
+
+	The number of threads that master and backup servers can use for
+	sync traffic. Every thread will use single UDP port, thread 0 will
+	use the default port 8848 while last thread will use port
+	8848+sync_ports-1.
+
 snat_reroute - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
-- 
2.5.5

