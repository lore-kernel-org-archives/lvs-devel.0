From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v4 2/3] selftests: netfilter: add ipvs nat test case
Date: Sat,  5 Oct 2019 22:37:44 +0800
Message-ID: <1570286265-15855-3-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1570286265-15855-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1570286265-15855-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shuah Khan <shuah@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Test virtual server via NAT.

Tested:
# selftests: netfilter: ipvs.sh
# Testing DR mode...
# Testing NAT mode...
# ipvs.sh: PASS

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 tools/testing/selftests/netfilter/ipvs.sh | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/netfilter/ipvs.sh b/tools/testing/selftests/netfilter/ipvs.sh
index f6da1bd..2601a7c 100755
--- a/tools/testing/selftests/netfilter/ipvs.sh
+++ b/tools/testing/selftests/netfilter/ipvs.sh
@@ -160,20 +160,40 @@ test_dr() {
     test_service
 }
 
+test_nat() {
+    ip netns exec ns0 ip route add ${vip_v4} via ${gip_v4} dev br0
+
+    ip netns exec ns1 sysctl -qw net.ipv4.ip_forward=1
+    ip netns exec ns1 ipvsadm -A -t ${vip_v4}:${port} -s rr
+    ip netns exec ns1 ipvsadm -a -m -t ${vip_v4}:${port} -r ${rip_v4}:${port}
+    ip netns exec ns1 ip addr add ${vip_v4}/32 dev lo:1
+
+    ip netns exec ns2 ip link del veth20
+    ip netns exec ns2 ip route add default via ${dip_v4} dev veth21
+
+    test_service
+}
+
 run_tests() {
 	local errors=
 
 	echo "Testing DR mode..."
+	cleanup
 	setup
 	test_dr
 	errors=$(( $errors + $? ))
 
+	echo "Testing NAT mode..."
+	cleanup
+	setup
+	test_nat
+	errors=$(( $errors + $? ))
+
 	return $errors
 }
 
 trap cleanup EXIT
 
-cleanup
 run_tests
 
 if [ $? -ne 0 ]; then
-- 
1.8.3.1



