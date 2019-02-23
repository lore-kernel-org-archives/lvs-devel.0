From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 14/65] ipvs: Fix signed integer overflow when setsockopt timeout
Date: Sat, 23 Feb 2019 16:05:49 -0500
Message-ID: <20190223210640.200911-14-sashal@kernel.org>
References: <20190223210640.200911-1-sashal@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550956021;
        bh=k85cwR9dsXmfNIsJVA1Lp6Y5FOovwXmuS/9qk2+l2A4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=onJZVw91UJ6QP/5m+5DPl4Xy4ffRzijwKklaeFYF5a04IVld/j8GdzkTT2wllBWA2
         2Vt6a1MEGX9FL1vO9eyJKbcNBC5yYmif/XCfz4d4REzUFd4+BxGUI+s1Mp+rI4eY3n
         EP1vgdpsuLqpJuc0wbU1st073rXcPAu746nP/OTE=
In-Reply-To: <20190223210640.200911-1-sashal@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: ZhangXiaoxu <zhangxiaoxu5@huawei.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sashal@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

From: ZhangXiaoxu <zhangxiaoxu5@huawei.com>

[ Upstream commit 53ab60baa1ac4f20b080a22c13b77b6373922fd7 ]

There is a UBSAN bug report as below:
UBSAN: Undefined behaviour in net/netfilter/ipvs/ip_vs_ctl.c:2227:21
signed integer overflow:
-2147483647 * 1000 cannot be represented in type 'int'

Reproduce program:
	#include <stdio.h>
	#include <sys/types.h>
	#include <sys/socket.h>

	#define IPPROTO_IP 0
	#define IPPROTO_RAW 255

	#define IP_VS_BASE_CTL		(64+1024+64)
	#define IP_VS_SO_SET_TIMEOUT	(IP_VS_BASE_CTL+10)

	/* The argument to IP_VS_SO_GET_TIMEOUT */
	struct ipvs_timeout_t {
		int tcp_timeout;
		int tcp_fin_timeout;
		int udp_timeout;
	};

	int main() {
		int ret = -1;
		int sockfd = -1;
		struct ipvs_timeout_t to;

		sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
		if (sockfd == -1) {
			printf("socket init error\n");
			return -1;
		}

		to.tcp_timeout = -2147483647;
		to.tcp_fin_timeout = -2147483647;
		to.udp_timeout = -2147483647;

		ret = setsockopt(sockfd,
				 IPPROTO_IP,
				 IP_VS_SO_SET_TIMEOUT,
				 (char *)(&to),
				 sizeof(to));

		printf("setsockopt return %d\n", ret);
		return ret;
	}

Return -EINVAL if the timeout value is negative or max than 'INT_MAX / HZ'.

Signed-off-by: ZhangXiaoxu <zhangxiaoxu5@huawei.com>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 518364f4abccd..55a77314340a5 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2220,6 +2220,18 @@ static int ip_vs_set_timeout(struct netns_ipvs *ipvs, struct ip_vs_timeout_user
 		  u->tcp_fin_timeout,
 		  u->udp_timeout);
 
+#ifdef CONFIG_IP_VS_PROTO_TCP
+	if (u->tcp_timeout < 0 || u->tcp_timeout > (INT_MAX / HZ) ||
+	    u->tcp_fin_timeout < 0 || u->tcp_fin_timeout > (INT_MAX / HZ)) {
+		return -EINVAL;
+	}
+#endif
+
+#ifdef CONFIG_IP_VS_PROTO_UDP
+	if (u->udp_timeout < 0 || u->udp_timeout > (INT_MAX / HZ))
+		return -EINVAL;
+#endif
+
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	if (u->tcp_timeout) {
 		pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
-- 
2.19.1

