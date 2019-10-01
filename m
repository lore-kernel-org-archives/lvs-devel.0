From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v3 3/3] selftests: netfilter: add ipvs tunnel test case
Date: Tue,  1 Oct 2019 22:19:59 +0800
Message-ID: <1569939599-1872-4-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1569939599-1872-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1569939599-1872-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shuah Khan <shuah@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Test virtual server via ipip tunnel.

Tested:
# selftests: netfilter: ipvs.sh
# Testing DR mode...
# Testing NAT mode...
# Testing Tunnel mode...
# ipvs.sh: PASS
ok 6 selftests: netfilter: ipvs.sh

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
v2: optimize test script
---
 tools/testing/selftests/netfilter/ipvs.sh | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/tools/testing/selftests/netfilter/ipvs.sh b/tools/testing/selftests/netfilter/ipvs.sh
index 270b5da..a8f6e70 100755
--- a/tools/testing/selftests/netfilter/ipvs.sh
+++ b/tools/testing/selftests/netfilter/ipvs.sh
@@ -174,6 +174,30 @@ test_nat() {
     test_service
 }
 
+test_tun() {
+    ip netns exec ns0 ip route add ${vip_v4} via ${gip_v4} dev br0
+
+    ip netns exec ns1 modprobe ipip
+    ip netns exec ns1 ip link set tunl0 up
+    ip netns exec ns1 sysctl -qw net.ipv4.ip_forward=0
+    ip netns exec ns1 sysctl -qw net.ipv4.conf.all.send_redirects=0
+    ip netns exec ns1 sysctl -qw net.ipv4.conf.default.send_redirects=0
+    ip netns exec ns1 ipvsadm -A -t ${vip_v4}:${port} -s rr
+    ip netns exec ns1 ipvsadm -a -i -t ${vip_v4}:${port} -r ${rip_v4}:${port}
+    ip netns exec ns1 ip addr add ${vip_v4}/32 dev lo:1
+
+    ip netns exec ns2 modprobe ipip
+    ip netns exec ns2 ip link set tunl0 up
+    ip netns exec ns2 sysctl -qw net.ipv4.conf.all.arp_ignore=1
+    ip netns exec ns2 sysctl -qw net.ipv4.conf.all.arp_announce=2
+    ip netns exec ns2 sysctl -qw net.ipv4.conf.all.rp_filter=0
+    ip netns exec ns2 sysctl -qw net.ipv4.conf.tunl0.rp_filter=0
+    ip netns exec ns2 sysctl -qw net.ipv4.conf.veth21.rp_filter=0
+    ip netns exec ns2 ip addr add ${vip_v4}/32 dev lo:1
+
+    test_service
+}
+
 run_tests() {
 	local errors=
 
@@ -189,6 +213,12 @@ run_tests() {
 	test_nat
 	errors=$(( $errors + $? ))
 
+	echo "Testing Tunnel mode..."
+	cleanup
+	setup
+	test_tun
+	errors=$(( $errors + $? ))
+
 	return $errors
 }
 
-- 
1.8.3.1



