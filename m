Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=95.215.58.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794193073;
	b=EX6NgTv8IO57RhfWs39ntc+l3i/eHh5XsPh7CpYaiCK+or5Rk88ebzosZ035vPv+tnCJ
	 +jG8+lhsdjcTFxATgn/W/aSripEIxVgCKqiG+0hUBqj3KZVTSUg2RU5SZsVBvgHQgqnJq
	 YOst+DA4+PMUMnwdq5modxla/pZielcZebjZHxCTIEbriu49Q+Lz41p+Bg1LPANvIPTLS
	 JZN8cUqfm/Eze6bAUaNXYVQHvGc3SuqDn/82OZXzR5ua5kFq76pbpIrbFTg5cWU3XE8Sr
	 zslBKB6/4NkFADYtR1PWYXE45Tn1e+6dSmDTe1BBErKvEwe+8emElAsi1N/zebshQEQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193073;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=lozlDLGMrT/gL+voaOHtm4eMaFENRCN+XrnADYX5CgI=;
	b=Et/hx15851FCZiHt0AjCvWWtMJygidWt/wLaMpHklm/LeYjlGw4o8bHmgB9A0LWREdUP
	 Wn3J4FrkvwjVM1WcMSgT7f/45TS5ebep5wW40P75xfoMw+KN56aSHlSOLB5PiM00+GcwP
	 DZIUzhtr4/7KAlaiznFU3bztPBXEE8ykgvOeV0zaSRHqP1yXPkDCvDLJGpmE4+16H3ZAg
	 kZ7LNVVFNnvkmRS7m+PXXoW3iAljUcntKbcUYMqVk2jr1KPTLfxd3J7A+MMwd542CocuY
	 a623ug36NzNykB/62UnwMlByDmv6PDvUVJozWNQOlqmOPedBhATucKdMsVwYJ2540jQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=X4tcFqyj;
	arc=none smtp.remote-ip=95.215.58.98
Received: from mta1.migadu.com (out-98.mta1.migadu.com [95.215.58.98])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F153A606A331
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:57:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F153A606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=X4tcFqyj
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=bQlLi3pjQjNg07B3XdBXzAfYAXHL8wvePGlXaSV5fbk=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794193069; v=1; x=1794797869;
 b=X4tcFqyjSZuCM9fVCaQdosqMp6bpuolZ48GAnjnH5SnWiZSuKdUoU004/VyS1MP7KN+zTKgM
 1bHRAIUgGinMkiyfsd+cxe+QMSWe1fFtzKtx7pkWK35dfvH9/yVV0HOj5wCDcfyjmdItAEnMQUp
 w+2Sd+UZlLWQz1IbOboWQYCc=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 86d7e8d117da196a;
	Mon, 09 Nov 2026 02:57:48 +0000
X-Mizu-Trace-ID: 86d7e8d117da196a
X-Migadu-Flow: FLOW_OUT
From: Jiayuan Chen <jiayuan.chen@linux.dev>
To: netdev@vger.kernel.org
Cc: Jiayuan Chen <jiayuan.chen@linux.dev>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	bridge@lists.linux.dev,
	linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev,
	lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org,
	linux-s390@vger.kernel.org
Subject: [PATCH net-next 06/14] sctp: annotate data-races around sctp sysctls
Date: Mon,  9 Nov 2026 10:52:05 +0800
Message-ID: <20261109025425.328445-7-jiayuan.chen@linux.dev>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261109025425.328445-1-jiayuan.chen@linux.dev>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

rto_min, rto_max, rto_initial, hb_interval, sack_timeout,
valid_cookie_life, max_burst, max_retrans_path, max_retrans_association,
max_retrans_init, pf_retrans, ps_retrans, pf_expose, pf_enable, udp_port,
encap_port, probe_interval, addip_enable, addip_noauth, auth_enable,
default_auto_asconf, prsctp_enable, reconf_enable, ecn_enable,
intl_enable, cookie_auth_enable, cookie_preserve_enable, sndbuf_policy,
rcvbuf_policy, rwnd_upd_shift, scope_policy and max_autoclose can be
read concurrently with the sysctl handlers that update them, and the
rto_min, rto_max, udp_port, probe_interval, auth_enable and
cookie_hmac_alg handlers store them with plain writes. Add READ_ONCE() to
the readers and WRITE_ONCE() to those handlers.

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 net/sctp/associola.c     |  2 +-
 net/sctp/bind_addr.c     |  2 +-
 net/sctp/endpointola.c   | 14 ++++++------
 net/sctp/input.c         |  2 +-
 net/sctp/sm_make_chunk.c |  6 +++---
 net/sctp/sm_sideeffect.c |  2 +-
 net/sctp/sm_statefuns.c  |  6 +++---
 net/sctp/socket.c        | 46 +++++++++++++++++++++-------------------
 net/sctp/sysctl.c        | 16 +++++++-------
 net/sctp/transport.c     |  6 +++---
 10 files changed, 52 insertions(+), 50 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 4521be3bd85aa..0a814faaea601 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1454,7 +1454,7 @@ static inline bool sctp_peer_needs_update(struct sctp_association *asoc)
 	case SCTP_STATE_SHUTDOWN_SENT:
 		if ((asoc->rwnd > asoc->a_rwnd) &&
 		    ((asoc->rwnd - asoc->a_rwnd) >= max_t(__u32,
-			   (asoc->base.sk->sk_rcvbuf >> net->sctp.rwnd_upd_shift),
+			   (asoc->base.sk->sk_rcvbuf >> READ_ONCE(net->sctp.rwnd_upd_shift)),
 			   asoc->pathmtu)))
 			return true;
 		break;
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 31737f144c7f0..36cea9ae2ad18 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -530,7 +530,7 @@ int sctp_in_scope(struct net *net, const union sctp_addr *addr,
 	 * Address scoping can be selectively controlled via sysctl
 	 * option
 	 */
-	switch (net->sctp.scope_policy) {
+	switch (READ_ONCE(net->sctp.scope_policy)) {
 	case SCTP_SCOPE_POLICY_DISABLE:
 		return 1;
 	case SCTP_SCOPE_POLICY_ENABLE:
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index a15b599b20b76..49d9c5c0babc1 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -54,8 +54,8 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	struct net *net = sock_net(sk);
 	struct sctp_shared_key *null_key;
 
-	ep->asconf_enable = net->sctp.addip_enable;
-	ep->auth_enable = net->sctp.auth_enable;
+	ep->asconf_enable = READ_ONCE(net->sctp.addip_enable);
+	ep->auth_enable = READ_ONCE(net->sctp.auth_enable);
 	if (ep->auth_enable) {
 		if (sctp_auth_init(ep, gfp))
 			goto nomem;
@@ -86,14 +86,14 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	INIT_LIST_HEAD(&ep->asocs);
 
 	/* Use SCTP specific send buffer space queues.  */
-	ep->sndbuf_policy = net->sctp.sndbuf_policy;
+	ep->sndbuf_policy = READ_ONCE(net->sctp.sndbuf_policy);
 
 	sk->sk_data_ready = sctp_data_ready;
 	sk->sk_write_space = sctp_write_space;
 	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
 	/* Get the receive buffer policy for this endpoint */
-	ep->rcvbuf_policy = net->sctp.rcvbuf_policy;
+	ep->rcvbuf_policy = READ_ONCE(net->sctp.rcvbuf_policy);
 
 	/* Generate the cookie authentication key. */
 	gen_cookie_auth_key(&ep->cookie_auth_key);
@@ -109,9 +109,9 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	/* Add the null key to the endpoint shared keys list and
 	 * set the hmcas and chunks pointers.
 	 */
-	ep->prsctp_enable = net->sctp.prsctp_enable;
-	ep->reconf_enable = net->sctp.reconf_enable;
-	ep->ecn_enable = net->sctp.ecn_enable;
+	ep->prsctp_enable = READ_ONCE(net->sctp.prsctp_enable);
+	ep->reconf_enable = READ_ONCE(net->sctp.reconf_enable);
+	ep->ecn_enable = READ_ONCE(net->sctp.ecn_enable);
 
 	/* Remember who we are attached to.  */
 	ep->base.sk = sk;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 9494cfa51106c..ecff82c0d5539 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1276,7 +1276,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 			break;
 
 		case SCTP_CID_ASCONF:
-			if (have_auth || net->sctp.addip_noauth)
+			if (have_auth || READ_ONCE(net->sctp.addip_noauth))
 				asoc = __sctp_rcv_asconf_lookup(
 						net, ch, laddr,
 						sctp_hdr(skb)->source,
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 90de272842512..43a757d4a69e7 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2038,7 +2038,7 @@ static int sctp_verify_ext_param(struct net *net,
 	 * only if ADD-IP is turned on and we are not backward-compatible
 	 * mode.
 	 */
-	if (net->sctp.addip_noauth)
+	if (READ_ONCE(net->sctp.addip_noauth))
 		return 1;
 
 	if (ep->asconf_enable && !have_auth && have_asconf)
@@ -2425,7 +2425,7 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	 * also give us an option to silently ignore the packet, which
 	 * is what we'll do here.
 	 */
-	if (!asoc->base.net->sctp.addip_noauth &&
+	if (!READ_ONCE(asoc->base.net->sctp.addip_noauth) &&
 	    (asoc->peer.asconf_capable && !asoc->peer.auth_capable)) {
 		asoc->peer.addip_disabled_mask |= (SCTP_PARAM_ADD_IP |
 						  SCTP_PARAM_DEL_IP |
@@ -2583,7 +2583,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 		break;
 
 	case SCTP_PARAM_COOKIE_PRESERVATIVE:
-		if (!net->sctp.cookie_preserve_enable)
+		if (!READ_ONCE(net->sctp.cookie_preserve_enable))
 			break;
 
 		stale = ntohl(param.life->lifespan_increment);
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 35f540fb15fc1..01ee6c3dd441a 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -591,7 +591,7 @@ static void sctp_do_8_2_transport_strike(struct sctp_cmd_seq *commands,
 	 * is SCTP_ACTIVE, then mark this transport as Partially Failed,
 	 * see SCTP Quick Failover Draft, section 5.1
 	 */
-	if (asoc->base.net->sctp.pf_enable &&
+	if (READ_ONCE(asoc->base.net->sctp.pf_enable) &&
 	    transport->state == SCTP_ACTIVE &&
 	    transport->error_count < transport->pathmaxrxt &&
 	    transport->error_count > transport->pf_retrans) {
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b2f609f177fb9..b6b95972eea9a 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -653,7 +653,7 @@ static bool sctp_auth_chunk_verify(struct net *net, struct sctp_chunk *chunk,
 	 */
 
 	/* Make sure that we and the peer are AUTH capable */
-	if (!net->sctp.auth_enable || !asoc->peer.auth_capable)
+	if (!READ_ONCE(net->sctp.auth_enable) || !asoc->peer.auth_capable)
 		return false;
 
 	/* set-up our fake chunk so that we can process it */
@@ -3944,7 +3944,7 @@ enum sctp_disposition sctp_sf_do_asconf(struct net *net,
 	 * described in [I-D.ietf-tsvwg-sctp-auth].
 	 */
 	if (!asoc->peer.asconf_capable ||
-	    (!net->sctp.addip_noauth && !chunk->auth))
+	    (!READ_ONCE(net->sctp.addip_noauth) && !chunk->auth))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	hdr = (struct sctp_addiphdr *)chunk->skb->data;
@@ -4087,7 +4087,7 @@ enum sctp_disposition sctp_sf_do_asconf_ack(struct net *net,
 	 * described in [I-D.ietf-tsvwg-sctp-auth].
 	 */
 	if (!asoc->peer.asconf_capable ||
-	    (!net->sctp.addip_noauth && !asconf_ack->auth))
+	    (!READ_ONCE(net->sctp.addip_noauth) && !asconf_ack->auth))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	addip_hdr = (struct sctp_addiphdr *)asconf_ack->skb->data;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b5a57f61ee6d1..715ecc25b2866 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -403,7 +403,7 @@ static void sctp_auto_asconf_init(struct sctp_sock *sp)
 {
 	struct net *net = sock_net(&sp->inet.sk);
 
-	if (net->sctp.default_auto_asconf) {
+	if (READ_ONCE(net->sctp.default_auto_asconf)) {
 		spin_lock_bh(&net->sctp.addr_wq_lock);
 		list_add_tail(&sp->auto_asconf_list, &net->sctp.auto_asconf_splist);
 		spin_unlock_bh(&net->sctp.addr_wq_lock);
@@ -2326,6 +2326,7 @@ static int sctp_setsockopt_autoclose(struct sock *sk, u32 *optval,
 {
 	struct sctp_sock *sp = sctp_sk(sk);
 	struct net *net = sock_net(sk);
+	unsigned long max_autoclose;
 
 	/* Applicable to UDP-style socket only */
 	if (sctp_style(sk, TCP))
@@ -2333,9 +2334,10 @@ static int sctp_setsockopt_autoclose(struct sock *sk, u32 *optval,
 	if (optlen != sizeof(int))
 		return -EINVAL;
 
+	max_autoclose = READ_ONCE(net->sctp.max_autoclose);
 	sp->autoclose = *optval;
-	if (sp->autoclose > net->sctp.max_autoclose)
-		sp->autoclose = net->sctp.max_autoclose;
+	if (sp->autoclose > max_autoclose)
+		sp->autoclose = max_autoclose;
 
 	return 0;
 }
@@ -4296,7 +4298,7 @@ static int sctp_setsockopt_interleaving_supported(struct sock *sk,
 	if (!asoc && p->assoc_id != SCTP_FUTURE_ASSOC && sctp_style(sk, UDP))
 		return -EINVAL;
 
-	if (!sock_net(sk)->sctp.intl_enable || !sp->frag_interleave) {
+	if (!READ_ONCE(sock_net(sk)->sctp.intl_enable) || !sp->frag_interleave) {
 		return -EPERM;
 	}
 
@@ -5098,9 +5100,9 @@ static int sctp_init_sock(struct sock *sk)
 	sp->default_timetolive = 0;
 
 	sp->default_rcv_context = 0;
-	sp->max_burst = net->sctp.max_burst;
+	sp->max_burst = READ_ONCE(net->sctp.max_burst);
 
-	sp->cookie_auth_enable = net->sctp.cookie_auth_enable;
+	sp->cookie_auth_enable = READ_ONCE(net->sctp.cookie_auth_enable);
 
 	/* Initialize default setup parameters. These parameters
 	 * can be modified with the SCTP_INITMSG socket option or
@@ -5108,24 +5110,24 @@ static int sctp_init_sock(struct sock *sk)
 	 */
 	sp->initmsg.sinit_num_ostreams   = sctp_max_outstreams;
 	sp->initmsg.sinit_max_instreams  = sctp_max_instreams;
-	sp->initmsg.sinit_max_attempts   = net->sctp.max_retrans_init;
-	sp->initmsg.sinit_max_init_timeo = net->sctp.rto_max;
+	sp->initmsg.sinit_max_attempts   = READ_ONCE(net->sctp.max_retrans_init);
+	sp->initmsg.sinit_max_init_timeo = READ_ONCE(net->sctp.rto_max);
 
 	/* Initialize default RTO related parameters.  These parameters can
 	 * be modified for with the SCTP_RTOINFO socket option.
 	 */
-	sp->rtoinfo.srto_initial = net->sctp.rto_initial;
-	sp->rtoinfo.srto_max     = net->sctp.rto_max;
-	sp->rtoinfo.srto_min     = net->sctp.rto_min;
+	sp->rtoinfo.srto_initial = READ_ONCE(net->sctp.rto_initial);
+	sp->rtoinfo.srto_max     = READ_ONCE(net->sctp.rto_max);
+	sp->rtoinfo.srto_min     = READ_ONCE(net->sctp.rto_min);
 
 	/* Initialize default association related parameters. These parameters
 	 * can be modified with the SCTP_ASSOCINFO socket option.
 	 */
-	sp->assocparams.sasoc_asocmaxrxt = net->sctp.max_retrans_association;
+	sp->assocparams.sasoc_asocmaxrxt = READ_ONCE(net->sctp.max_retrans_association);
 	sp->assocparams.sasoc_number_peer_destinations = 0;
 	sp->assocparams.sasoc_peer_rwnd = 0;
 	sp->assocparams.sasoc_local_rwnd = 0;
-	sp->assocparams.sasoc_cookie_life = net->sctp.valid_cookie_life;
+	sp->assocparams.sasoc_cookie_life = READ_ONCE(net->sctp.valid_cookie_life);
 
 	/* Initialize default event subscriptions. By default, all the
 	 * options are off.
@@ -5135,15 +5137,15 @@ static int sctp_init_sock(struct sock *sk)
 	/* Default Peer Address Parameters.  These defaults can
 	 * be modified via SCTP_PEER_ADDR_PARAMS
 	 */
-	sp->hbinterval  = net->sctp.hb_interval;
-	sp->udp_port    = htons(net->sctp.udp_port);
-	sp->encap_port  = htons(net->sctp.encap_port);
-	sp->pathmaxrxt  = net->sctp.max_retrans_path;
-	sp->pf_retrans  = net->sctp.pf_retrans;
-	sp->ps_retrans  = net->sctp.ps_retrans;
-	sp->pf_expose   = net->sctp.pf_expose;
+	sp->hbinterval  = READ_ONCE(net->sctp.hb_interval);
+	sp->udp_port    = htons(READ_ONCE(net->sctp.udp_port));
+	sp->encap_port  = htons(READ_ONCE(net->sctp.encap_port));
+	sp->pathmaxrxt  = READ_ONCE(net->sctp.max_retrans_path);
+	sp->pf_retrans  = READ_ONCE(net->sctp.pf_retrans);
+	sp->ps_retrans  = READ_ONCE(net->sctp.ps_retrans);
+	sp->pf_expose   = READ_ONCE(net->sctp.pf_expose);
 	sp->pathmtu     = 0; /* allow default discovery */
-	sp->sackdelay   = net->sctp.sack_timeout;
+	sp->sackdelay   = READ_ONCE(net->sctp.sack_timeout);
 	sp->sackfreq	= 2;
 	sp->param_flags = SPP_HB_ENABLE |
 			  SPP_PMTUD_ENABLE |
@@ -5182,7 +5184,7 @@ static int sctp_init_sock(struct sock *sk)
 	atomic_set(&sp->pd_mode, 0);
 	skb_queue_head_init(&sp->pd_lobby);
 	sp->frag_interleave = 0;
-	sp->probe_interval = net->sctp.probe_interval;
+	sp->probe_interval = READ_ONCE(net->sctp.probe_interval);
 
 	/* Create a per socket endpoint structure.  Even if we
 	 * change the data structure relationships, this may still
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 2b94c211427de..8a84ae3272d24 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -402,11 +402,11 @@ static int proc_sctp_do_hmac_alg(const struct ctl_table *ctl, int write,
 		if (ret)
 			return ret;
 		if (!strcmp(tmp, "sha256")) {
-			net->sctp.cookie_auth_enable = 1;
+			WRITE_ONCE(net->sctp.cookie_auth_enable, 1);
 			return 0;
 		}
 		if (!strcmp(tmp, "none")) {
-			net->sctp.cookie_auth_enable = 0;
+			WRITE_ONCE(net->sctp.cookie_auth_enable, 0);
 			return 0;
 		}
 		return -EINVAL;
@@ -441,7 +441,7 @@ static int proc_sctp_do_rto_min(const struct ctl_table *ctl, int write,
 		if (new_value > max || new_value < min)
 			return -EINVAL;
 
-		net->sctp.rto_min = new_value;
+		WRITE_ONCE(net->sctp.rto_min, new_value);
 	}
 
 	return ret;
@@ -469,7 +469,7 @@ static int proc_sctp_do_rto_max(const struct ctl_table *ctl, int write,
 		if (new_value > max || new_value < min)
 			return -EINVAL;
 
-		net->sctp.rto_max = new_value;
+		WRITE_ONCE(net->sctp.rto_max, new_value);
 	}
 
 	return ret;
@@ -504,7 +504,7 @@ static int proc_sctp_do_auth(const struct ctl_table *ctl, int write,
 	if (write && ret == 0) {
 		struct sock *sk = net->sctp.ctl_sock;
 
-		net->sctp.auth_enable = new_value;
+		WRITE_ONCE(net->sctp.auth_enable, new_value);
 		/* Update the value in the control socket */
 		lock_sock(sk);
 		sctp_sk(sk)->ep->auth_enable = new_value;
@@ -541,12 +541,12 @@ static int proc_sctp_do_udp_port(const struct ctl_table *ctl, int write,
 			return -EINVAL;
 
 		mutex_lock(&sctp_sysctl_mutex);
-		net->sctp.udp_port = new_value;
+		WRITE_ONCE(net->sctp.udp_port, new_value);
 		sctp_udp_sock_stop(net);
 		if (new_value) {
 			ret = sctp_udp_sock_start(net);
 			if (ret)
-				net->sctp.udp_port = 0;
+				WRITE_ONCE(net->sctp.udp_port, 0);
 		}
 
 		/* Update the value in the control socket */
@@ -580,7 +580,7 @@ static int proc_sctp_do_probe_interval(const struct ctl_table *ctl, int write,
 		if (new_value && new_value < SCTP_PROBE_TIMER_MIN)
 			return -EINVAL;
 
-		net->sctp.probe_interval = new_value;
+		WRITE_ONCE(net->sctp.probe_interval, new_value);
 	}
 
 	return ret;
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 6ea55b9fbde45..78b87e1b7e64b 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -55,7 +55,7 @@ static void sctp_transport_init(struct net *net,
 	 * given destination transport address, set RTO to the protocol
 	 * parameter 'RTO.Initial'.
 	 */
-	peer->rto = msecs_to_jiffies(net->sctp.rto_initial);
+	peer->rto = msecs_to_jiffies(READ_ONCE(net->sctp.rto_initial));
 
 	peer->last_time_heard = 0;
 	peer->last_time_ecne_reduced = jiffies;
@@ -65,8 +65,8 @@ static void sctp_transport_init(struct net *net,
 			    SPP_SACKDELAY_ENABLE;
 
 	/* Initialize the default path max_retrans.  */
-	peer->pathmaxrxt  = net->sctp.max_retrans_path;
-	peer->pf_retrans  = net->sctp.pf_retrans;
+	peer->pathmaxrxt  = READ_ONCE(net->sctp.max_retrans_path);
+	peer->pf_retrans  = READ_ONCE(net->sctp.pf_retrans);
 
 	INIT_LIST_HEAD(&peer->transmitted);
 	INIT_LIST_HEAD(&peer->send_ready);
-- 
2.43.0

