From: juliusv@google.com (Julius Volz)
Subject: Re: [PATCHv3 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 14 Aug 2008 14:08:44 +0200
Message-ID: <20080814120843.GC8046@google.com>
References: <1218120219-1117-1-git-send-email-juliusv@google.com> <1218120219-1117-3-git-send-email-juliusv@google.com> <20080808112937.GA32458@google.com> <alpine.LNX.1.10.0808132326310.12259@titan.stealer.net> <20080814093201.GA8046@google.com> <alpine.LNX.1.10.0808141144240.12259@titan.stealer.net> <20080814102719.GB8046@google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1218715735; bh=v9qDVyJ1HXMWoS5eC/hYTt0cvrw=;
	h=DomainKey-Signature:Date:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 User-Agent:From; b=VbwF4DuMc3Mqjyvo1VdyJnqcRdnIZlErljRvWuQTjZtbYde
	Oj+rxAAIQ8+IRcTUx2f5fPIXGYIXdggSICF+nsA==
Content-Disposition: inline
In-Reply-To: <20080814102719.GB8046@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Thu, Aug 14, 2008 at 12:27:19PM +0200, Julius Volz wrote:
> On Thu, Aug 14, 2008 at 12:04:50PM +0200, Sven Wegener wrote:
> > On Thu, 14 Aug 2008, Julius Volz wrote:
> > 
> > > On Wed, Aug 13, 2008 at 11:51:06PM +0200, Sven Wegener wrote:
> > > > On Fri, 8 Aug 2008, Julius Volz wrote:
> > > > > +static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> > > > > +{
> > > > > +	struct sk_buff *msg;
> > > > > +	void *reply;
> > > > > +	int ret, cmd, reply_cmd;
> > > > > +
> > > > > +	mutex_lock(&__ip_vs_mutex);
> > > > > +
> > > > > +	cmd = info->genlhdr->cmd;
> > > > > +
> > > > > +	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > > > > +	if (!msg) {
> > > > > +		ret = -ENOMEM;
> > > > > +		goto out_err;
> > > > 
> > > > Here you want out...
> > > > 
> > > > > +	}
> > > > > +
> > > > > +	if (cmd == IPVS_CMD_GET_SERVICE)
> > > > > +		reply_cmd = IPVS_CMD_NEW_SERVICE;
> > > > > +	else if (cmd == IPVS_CMD_GET_INFO)
> > > > > +		reply_cmd = IPVS_CMD_SET_INFO;
> > > > > +	else if (cmd == IPVS_CMD_GET_CONFIG)
> > > > > +		reply_cmd = IPVS_CMD_SET_CONFIG;
> > > > > +	else {
> > > > > +		IP_VS_ERR("unknown Generic Netlink command\n");
> > > > > +		ret = -EINVAL;
> > > > > +		goto out;
> > > > 
> > > > ..and here you want out_error, to not leak msg.
> > > 
> > > Ouch, thanks! Fixed this and locked the mutex later. I also removed the
> > > "if (msg)" from out_err, as it becomes unneeded now. Here's the updated
> > > patch:
> > 
> > You missed the static on the register and unregister functions down at the 
> > bottom. :) Also see my comments to your change regarding the above issue 
> > down here.
> 
> Hrm, yes!
> 
> > > +static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> > > +{
> > > +	struct sk_buff *msg;
> > > +	void *reply;
> > > +	int ret, cmd, reply_cmd;
> > > +
> > > +	cmd = info->genlhdr->cmd;
> > > +
> > > +	if (cmd == IPVS_CMD_GET_SERVICE)
> > > +		reply_cmd = IPVS_CMD_NEW_SERVICE;
> > > +	else if (cmd == IPVS_CMD_GET_INFO)
> > > +		reply_cmd = IPVS_CMD_SET_INFO;
> > > +	else if (cmd == IPVS_CMD_GET_CONFIG)
> > > +		reply_cmd = IPVS_CMD_SET_CONFIG;
> > > +	else {
> > > +		IP_VS_ERR("unknown Generic Netlink command\n");
> > > +		ret = -EINVAL;
> > > +		goto out;
> > > +	}
> > > +
> > > +	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > > +	if (!msg) {
> > > +		ret = -ENOMEM;
> > > +		goto out;
> > > +	}
> > > +
> > > +	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
> > > +	if (reply == NULL)
> > > +		goto nla_put_failure;
> > 
> > These gotos now unlock a not locked mutex down in the error path.
> 
> What did they put into my water supply :-/ Thanks!

Ok, fixed this up. The mutex is not completely moved down to make the
code look a bit nicer (nla_put_failure assumes locked mutex). There
should not be much concurrency anyways since this mutex only locks the
userspace interface, which is mainly used by ipvsadm.

Julius

--------
Add the implementation of the new Generic Netlink interface to IPVS and
keep the old set/getsockopt interface for userspace backwards
compatibility.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 875 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 6379705..d1dbd8b 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -37,6 +37,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/sock.h>
+#include <net/genetlink.h>
 
 #include <asm/uaccess.h>
 
@@ -2320,6 +2321,872 @@ static struct nf_sockopt_ops ip_vs_sockopts = {
 	.owner		= THIS_MODULE,
 };
 
+/*
+ * Generic Netlink interface
+ */
+
+/* IPVS genetlink family */
+static struct genl_family ip_vs_genl_family = {
+	.id		= GENL_ID_GENERATE,
+	.hdrsize	= 0,
+	.name		= IPVS_GENL_NAME,
+	.version	= IPVS_GENL_VERSION,
+	.maxattr	= IPVS_CMD_MAX,
+};
+
+/* Policy used for first-level command attributes */
+static const struct nla_policy ip_vs_cmd_policy[IPVS_CMD_ATTR_MAX + 1] = {
+	[IPVS_CMD_ATTR_SERVICE]		= { .type = NLA_NESTED },
+	[IPVS_CMD_ATTR_DEST]		= { .type = NLA_NESTED },
+	[IPVS_CMD_ATTR_DAEMON]		= { .type = NLA_NESTED },
+	[IPVS_CMD_ATTR_TIMEOUT_TCP]	= { .type = NLA_U32 },
+	[IPVS_CMD_ATTR_TIMEOUT_TCP_FIN]	= { .type = NLA_U32 },
+	[IPVS_CMD_ATTR_TIMEOUT_UDP]	= { .type = NLA_U32 },
+};
+
+/* Policy used for attributes in nested attribute IPVS_CMD_ATTR_DAEMON */
+static const struct nla_policy ip_vs_daemon_policy[IPVS_DAEMON_ATTR_MAX + 1] = {
+	[IPVS_DAEMON_ATTR_STATE]	= { .type = NLA_U32 },
+	[IPVS_DAEMON_ATTR_MCAST_IFN]	= { .type = NLA_NUL_STRING,
+					    .len = IP_VS_IFNAME_MAXLEN },
+	[IPVS_DAEMON_ATTR_SYNC_ID]	= { .type = NLA_U32 },
+};
+
+/* Policy used for attributes in nested attribute IPVS_CMD_ATTR_SERVICE */
+static const struct nla_policy ip_vs_svc_policy[IPVS_SVC_ATTR_MAX + 1] = {
+	[IPVS_SVC_ATTR_AF]		= { .type = NLA_U16 },
+	[IPVS_SVC_ATTR_PROTOCOL]	= { .type = NLA_U16 },
+	[IPVS_SVC_ATTR_ADDR]		= { .type = NLA_BINARY,
+					    .len = sizeof(union nf_inet_addr) },
+	[IPVS_SVC_ATTR_PORT]		= { .type = NLA_U16 },
+	[IPVS_SVC_ATTR_FWMARK]		= { .type = NLA_U32 },
+	[IPVS_SVC_ATTR_SCHED_NAME]	= { .type = NLA_NUL_STRING,
+					    .len = IP_VS_SCHEDNAME_MAXLEN },
+	[IPVS_SVC_ATTR_FLAGS]		= { .type = NLA_BINARY,
+					    .len = sizeof(struct ip_vs_flags) },
+	[IPVS_SVC_ATTR_TIMEOUT]		= { .type = NLA_U32 },
+	[IPVS_SVC_ATTR_NETMASK]		= { .type = NLA_U32 },
+	[IPVS_SVC_ATTR_STATS]		= { .type = NLA_NESTED },
+};
+
+/* Policy used for attributes in nested attribute IPVS_CMD_ATTR_DEST */
+static const struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
+	[IPVS_DEST_ATTR_ADDR]		= { .type = NLA_BINARY,
+					    .len = sizeof(union nf_inet_addr) },
+	[IPVS_DEST_ATTR_PORT]		= { .type = NLA_U16 },
+	[IPVS_DEST_ATTR_FWD_METHOD]	= { .type = NLA_U32 },
+	[IPVS_DEST_ATTR_WEIGHT]		= { .type = NLA_U32 },
+	[IPVS_DEST_ATTR_U_THRESH]	= { .type = NLA_U32 },
+	[IPVS_DEST_ATTR_L_THRESH]	= { .type = NLA_U32 },
+	[IPVS_DEST_ATTR_ACTIVE_CONNS]	= { .type = NLA_U32 },
+	[IPVS_DEST_ATTR_INACT_CONNS]	= { .type = NLA_U32 },
+	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
+	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
+};
+
+static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
+				 struct ip_vs_stats *stats)
+{
+	struct nlattr *nl_stats = nla_nest_start(skb, container_type);
+	if (!nl_stats)
+		return -EMSGSIZE;
+
+	spin_lock_bh(&stats->lock);
+
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CONNS, stats->conns);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPKTS, stats->inpkts);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPKTS, stats->outpkts);
+	NLA_PUT_U64(skb, IPVS_STATS_ATTR_INBYTES, stats->inbytes);
+	NLA_PUT_U64(skb, IPVS_STATS_ATTR_OUTBYTES, stats->outbytes);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_CPS, stats->cps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INPPS, stats->inpps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTPPS, stats->outpps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_INBPS, stats->inbps);
+	NLA_PUT_U32(skb, IPVS_STATS_ATTR_OUTBPS, stats->outbps);
+
+	spin_unlock_bh(&stats->lock);
+
+	nla_nest_end(skb, nl_stats);
+
+	return 0;
+
+nla_put_failure:
+	spin_unlock_bh(&stats->lock);
+	nla_nest_cancel(skb, nl_stats);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_fill_service(struct sk_buff *skb,
+				   struct ip_vs_service *svc)
+{
+	struct nlattr *nl_service;
+	struct ip_vs_flags flags = { .flags = svc->flags,
+				     .mask = ~0 };
+
+	nl_service = nla_nest_start(skb, IPVS_CMD_ATTR_SERVICE);
+	if (!nl_service)
+		return -EMSGSIZE;
+
+	NLA_PUT_U16(skb, IPVS_SVC_ATTR_AF, AF_INET);
+
+	if (svc->fwmark) {
+		NLA_PUT_U32(skb, IPVS_SVC_ATTR_FWMARK, svc->fwmark);
+	} else {
+		NLA_PUT_U16(skb, IPVS_SVC_ATTR_PROTOCOL, svc->protocol);
+		NLA_PUT(skb, IPVS_SVC_ATTR_ADDR, sizeof(svc->addr), &svc->addr);
+		NLA_PUT_U16(skb, IPVS_SVC_ATTR_PORT, svc->port);
+	}
+
+	NLA_PUT_STRING(skb, IPVS_SVC_ATTR_SCHED_NAME, svc->scheduler->name);
+	NLA_PUT(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
+	NLA_PUT_U32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ);
+	NLA_PUT_U32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask);
+
+	if (ip_vs_genl_fill_stats(skb, IPVS_SVC_ATTR_STATS, &svc->stats))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nl_service);
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nl_service);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_dump_service(struct sk_buff *skb,
+				   struct ip_vs_service *svc,
+				   struct netlink_callback *cb)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+			  &ip_vs_genl_family, NLM_F_MULTI,
+			  IPVS_CMD_NEW_SERVICE);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (ip_vs_genl_fill_service(skb, svc) < 0)
+		goto nla_put_failure;
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_dump_services(struct sk_buff *skb,
+				    struct netlink_callback *cb)
+{
+	int idx = 0, i;
+	int start = cb->args[0];
+	struct ip_vs_service *svc;
+
+	mutex_lock(&__ip_vs_mutex);
+	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
+		list_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
+			if (++idx <= start)
+				continue;
+			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
+				idx--;
+				goto nla_put_failure;
+			}
+		}
+	}
+
+	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
+		list_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
+			if (++idx <= start)
+				continue;
+			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
+				idx--;
+				goto nla_put_failure;
+			}
+		}
+	}
+
+nla_put_failure:
+	mutex_unlock(&__ip_vs_mutex);
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
+static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
+				    struct nlattr *nla, int full_entry)
+{
+	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
+	struct nlattr *nla_af, *nla_port, *nla_fwmark, *nla_protocol, *nla_addr;
+
+	/* Parse mandatory identifying service fields first */
+	if (nla == NULL ||
+	    nla_parse_nested(attrs, IPVS_SVC_ATTR_MAX, nla, ip_vs_svc_policy))
+		return -EINVAL;
+
+	nla_af		= attrs[IPVS_SVC_ATTR_AF];
+	nla_protocol	= attrs[IPVS_SVC_ATTR_PROTOCOL];
+	nla_addr	= attrs[IPVS_SVC_ATTR_ADDR];
+	nla_port	= attrs[IPVS_SVC_ATTR_PORT];
+	nla_fwmark	= attrs[IPVS_SVC_ATTR_FWMARK];
+
+	if (!(nla_af && (nla_fwmark || (nla_port && nla_protocol && nla_addr))))
+		return -EINVAL;
+
+	/* For now, only support IPv4 */
+	if (nla_get_u16(nla_af) != AF_INET)
+		return -EAFNOSUPPORT;
+
+	if (nla_fwmark) {
+		usvc->protocol = IPPROTO_TCP;
+		usvc->fwmark = nla_get_u32(nla_fwmark);
+	} else {
+		usvc->protocol = nla_get_u16(nla_protocol);
+		nla_memcpy(&usvc->addr, nla_addr, sizeof(usvc->addr));
+		usvc->port = nla_get_u16(nla_port);
+		usvc->fwmark = 0;
+	}
+
+	/* If a full entry was requested, check for the additional fields */
+	if (full_entry) {
+		struct nlattr *nla_sched, *nla_flags, *nla_timeout,
+			      *nla_netmask;
+		struct ip_vs_flags flags;
+		struct ip_vs_service *svc;
+
+		nla_sched = attrs[IPVS_SVC_ATTR_SCHED_NAME];
+		nla_flags = attrs[IPVS_SVC_ATTR_FLAGS];
+		nla_timeout = attrs[IPVS_SVC_ATTR_TIMEOUT];
+		nla_netmask = attrs[IPVS_SVC_ATTR_NETMASK];
+
+		if (!(nla_sched && nla_flags && nla_timeout && nla_netmask))
+			return -EINVAL;
+
+		nla_memcpy(&flags, nla_flags, sizeof(flags));
+
+		/* prefill flags from service if it already exists */
+		if (usvc->fwmark)
+			svc = __ip_vs_svc_fwm_get(usvc->fwmark);
+		else
+			svc = __ip_vs_service_get(usvc->protocol, usvc->addr,
+						  usvc->port);
+		if (svc) {
+			usvc->flags = svc->flags;
+			ip_vs_service_put(svc);
+		} else
+			usvc->flags = 0;
+
+		/* set new flags from userland */
+		usvc->flags = (usvc->flags & ~flags.mask) |
+			      (flags.flags & flags.mask);
+
+		strlcpy(usvc->sched_name, nla_data(nla_sched),
+			sizeof(usvc->sched_name));
+		usvc->timeout = nla_get_u32(nla_timeout);
+		usvc->netmask = nla_get_u32(nla_netmask);
+	}
+
+	return 0;
+}
+
+static struct ip_vs_service *ip_vs_genl_find_service(struct nlattr *nla)
+{
+	struct ip_vs_service_user usvc;
+	int ret;
+
+	ret = ip_vs_genl_parse_service(&usvc, nla, 0);
+	if (ret)
+		return ERR_PTR(ret);
+
+	if (usvc.fwmark)
+		return __ip_vs_svc_fwm_get(usvc.fwmark);
+	else
+		return __ip_vs_service_get(usvc.protocol, usvc.addr,
+					   usvc.port);
+}
+
+static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
+{
+	struct nlattr *nl_dest;
+
+	nl_dest = nla_nest_start(skb, IPVS_CMD_ATTR_DEST);
+	if (!nl_dest)
+		return -EMSGSIZE;
+
+	NLA_PUT(skb, IPVS_DEST_ATTR_ADDR, sizeof(dest->addr), &dest->addr);
+	NLA_PUT_U16(skb, IPVS_DEST_ATTR_PORT, dest->port);
+
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_FWD_METHOD,
+		    atomic_read(&dest->conn_flags) & IP_VS_CONN_F_FWD_MASK);
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_WEIGHT, atomic_read(&dest->weight));
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold);
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold);
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
+		    atomic_read(&dest->activeconns));
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_INACT_CONNS,
+		    atomic_read(&dest->inactconns));
+	NLA_PUT_U32(skb, IPVS_DEST_ATTR_PERSIST_CONNS,
+		    atomic_read(&dest->persistconns));
+
+	if (ip_vs_genl_fill_stats(skb, IPVS_DEST_ATTR_STATS, &dest->stats))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nl_dest);
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nl_dest);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_dump_dest(struct sk_buff *skb, struct ip_vs_dest *dest,
+				struct netlink_callback *cb)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+			  &ip_vs_genl_family, NLM_F_MULTI,
+			  IPVS_CMD_NEW_DEST);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (ip_vs_genl_fill_dest(skb, dest) < 0)
+		goto nla_put_failure;
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_dump_dests(struct sk_buff *skb,
+				 struct netlink_callback *cb)
+{
+	int idx = 0;
+	int start = cb->args[0];
+	struct ip_vs_service *svc;
+	struct ip_vs_dest *dest;
+	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
+
+	mutex_lock(&__ip_vs_mutex);
+
+	/* Try to find the service for which to dump destinations */
+	if (nlmsg_parse(cb->nlh, GENL_HDRLEN, attrs,
+			IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy))
+		goto out_err;
+
+	svc = ip_vs_genl_find_service(attrs[IPVS_CMD_ATTR_SERVICE]);
+	if (IS_ERR(svc) || svc == NULL)
+		goto out_err;
+
+	/* Dump the destinations */
+	list_for_each_entry(dest, &svc->destinations, n_list) {
+		if (++idx <= start)
+			continue;
+		if (ip_vs_genl_dump_dest(skb, dest, cb) < 0) {
+			idx--;
+			goto nla_put_failure;
+		}
+	}
+
+nla_put_failure:
+	cb->args[0] = idx;
+	ip_vs_service_put(svc);
+
+out_err:
+	mutex_unlock(&__ip_vs_mutex);
+
+	return skb->len;
+}
+
+static int ip_vs_genl_parse_dest(struct ip_vs_dest_user *udest,
+				 struct nlattr *nla, int full_entry)
+{
+	struct nlattr *attrs[IPVS_DEST_ATTR_MAX + 1];
+	struct nlattr *nla_addr, *nla_port;
+
+	/* Parse mandatory identifying destination fields first */
+	if (nla == NULL ||
+	    nla_parse_nested(attrs, IPVS_DEST_ATTR_MAX, nla, ip_vs_dest_policy))
+		return -EINVAL;
+
+	nla_addr	= attrs[IPVS_DEST_ATTR_ADDR];
+	nla_port	= attrs[IPVS_DEST_ATTR_PORT];
+
+	if (!(nla_addr && nla_port))
+		return -EINVAL;
+
+	nla_memcpy(&udest->addr, nla_addr, sizeof(udest->addr));
+	udest->port = nla_get_u16(nla_port);
+
+	/* If a full entry was requested, check for the additional fields */
+	if (full_entry) {
+		struct nlattr *nla_fwd, *nla_weight, *nla_u_thresh,
+			      *nla_l_thresh;
+
+		nla_fwd		= attrs[IPVS_DEST_ATTR_FWD_METHOD];
+		nla_weight	= attrs[IPVS_DEST_ATTR_WEIGHT];
+		nla_u_thresh	= attrs[IPVS_DEST_ATTR_U_THRESH];
+		nla_l_thresh	= attrs[IPVS_DEST_ATTR_L_THRESH];
+
+		if (!(nla_fwd && nla_weight && nla_u_thresh && nla_l_thresh))
+			return -EINVAL;
+
+		udest->conn_flags = nla_get_u32(nla_fwd)
+				    & IP_VS_CONN_F_FWD_MASK;
+		udest->weight = nla_get_u32(nla_weight);
+		udest->u_threshold = nla_get_u32(nla_u_thresh);
+		udest->l_threshold = nla_get_u32(nla_l_thresh);
+	}
+
+	return 0;
+}
+
+static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __be32 state,
+				  const char *mcast_ifn, __be32 syncid)
+{
+	struct nlattr *nl_daemon;
+
+	nl_daemon = nla_nest_start(skb, IPVS_CMD_ATTR_DAEMON);
+	if (!nl_daemon)
+		return -EMSGSIZE;
+
+	NLA_PUT_U32(skb, IPVS_DAEMON_ATTR_STATE, state);
+	NLA_PUT_STRING(skb, IPVS_DAEMON_ATTR_MCAST_IFN, mcast_ifn);
+	NLA_PUT_U32(skb, IPVS_DAEMON_ATTR_SYNC_ID, syncid);
+
+	nla_nest_end(skb, nl_daemon);
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nl_daemon);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __be32 state,
+				  const char *mcast_ifn, __be32 syncid,
+				  struct netlink_callback *cb)
+{
+	void *hdr;
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+			  &ip_vs_genl_family, NLM_F_MULTI,
+			  IPVS_CMD_NEW_DAEMON);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (ip_vs_genl_fill_daemon(skb, state, mcast_ifn, syncid))
+		goto nla_put_failure;
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int ip_vs_genl_dump_daemons(struct sk_buff *skb,
+				   struct netlink_callback *cb)
+{
+	mutex_lock(&__ip_vs_mutex);
+	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) && !cb->args[0]) {
+		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_MASTER,
+					   ip_vs_master_mcast_ifn,
+					   ip_vs_master_syncid, cb) < 0)
+			goto nla_put_failure;
+
+		cb->args[0] = 1;
+	}
+
+	if ((ip_vs_sync_state & IP_VS_STATE_BACKUP) && !cb->args[1]) {
+		if (ip_vs_genl_dump_daemon(skb, IP_VS_STATE_BACKUP,
+					   ip_vs_backup_mcast_ifn,
+					   ip_vs_backup_syncid, cb) < 0)
+			goto nla_put_failure;
+
+		cb->args[1] = 1;
+	}
+
+nla_put_failure:
+	mutex_unlock(&__ip_vs_mutex);
+
+	return skb->len;
+}
+
+static int ip_vs_genl_new_daemon(struct nlattr **attrs)
+{
+	if (!(attrs[IPVS_DAEMON_ATTR_STATE] &&
+	      attrs[IPVS_DAEMON_ATTR_MCAST_IFN] &&
+	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
+		return -EINVAL;
+
+	return start_sync_thread(nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
+				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
+				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_SYNC_ID]));
+}
+
+static int ip_vs_genl_del_daemon(struct nlattr **attrs)
+{
+	if (!attrs[IPVS_DAEMON_ATTR_STATE])
+		return -EINVAL;
+
+	return stop_sync_thread(nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]));
+}
+
+static int ip_vs_genl_set_config(struct nlattr **attrs)
+{
+	struct ip_vs_timeout_user t;
+
+	__ip_vs_get_timeouts(&t);
+
+	if (attrs[IPVS_CMD_ATTR_TIMEOUT_TCP])
+		t.tcp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_TCP]);
+
+	if (attrs[IPVS_CMD_ATTR_TIMEOUT_TCP_FIN])
+		t.tcp_fin_timeout =
+			nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_TCP_FIN]);
+
+	if (attrs[IPVS_CMD_ATTR_TIMEOUT_UDP])
+		t.udp_timeout = nla_get_u32(attrs[IPVS_CMD_ATTR_TIMEOUT_UDP]);
+
+	return ip_vs_set_timeout(&t);
+}
+
+static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
+{
+	struct ip_vs_service *svc = NULL;
+	struct ip_vs_service_user usvc;
+	struct ip_vs_dest_user udest;
+	int ret = 0, cmd;
+	int need_full_svc = 0, need_full_dest = 0;
+
+	cmd = info->genlhdr->cmd;
+
+	mutex_lock(&__ip_vs_mutex);
+
+	if (cmd == IPVS_CMD_FLUSH) {
+		ret = ip_vs_flush();
+		goto out;
+	} else if (cmd == IPVS_CMD_SET_CONFIG) {
+		ret = ip_vs_genl_set_config(info->attrs);
+		goto out;
+	} else if (cmd == IPVS_CMD_NEW_DAEMON ||
+		   cmd == IPVS_CMD_DEL_DAEMON) {
+
+		struct nlattr *daemon_attrs[IPVS_DAEMON_ATTR_MAX + 1];
+
+		if (!info->attrs[IPVS_CMD_ATTR_DAEMON] ||
+		    nla_parse_nested(daemon_attrs, IPVS_DAEMON_ATTR_MAX,
+				     info->attrs[IPVS_CMD_ATTR_DAEMON],
+				     ip_vs_daemon_policy)) {
+			ret = -EINVAL;
+			goto out;
+		}
+
+		if (cmd == IPVS_CMD_NEW_DAEMON)
+			ret = ip_vs_genl_new_daemon(daemon_attrs);
+		else
+			ret = ip_vs_genl_del_daemon(daemon_attrs);
+		goto out;
+	} else if (cmd == IPVS_CMD_ZERO &&
+		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
+		ret = ip_vs_zero_all();
+		goto out;
+	}
+
+	/* All following commands require a service argument, so check if we
+	 * received a valid one. We need a full service specification when
+	 * adding / editing a service. Only identifying members otherwise. */
+	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
+		need_full_svc = 1;
+
+	ret = ip_vs_genl_parse_service(&usvc,
+				       info->attrs[IPVS_CMD_ATTR_SERVICE],
+				       need_full_svc);
+	if (ret)
+		goto out;
+
+	/* Lookup the exact service by <protocol, addr, port> or fwmark */
+	if (usvc.fwmark == 0)
+		svc = __ip_vs_service_get(usvc.protocol, usvc.addr, usvc.port);
+	else
+		svc = __ip_vs_svc_fwm_get(usvc.fwmark);
+
+	/* Unless we're adding a new service, the service must already exist */
+	if ((cmd != IPVS_CMD_NEW_SERVICE) && (svc == NULL)) {
+		ret = -ESRCH;
+		goto out;
+	}
+
+	/* Destination commands require a valid destination argument. For
+	 * adding / editing a destination, we need a full destination
+	 * specification. */
+	if (cmd == IPVS_CMD_NEW_DEST || cmd == IPVS_CMD_SET_DEST ||
+	    cmd == IPVS_CMD_DEL_DEST) {
+		if (cmd != IPVS_CMD_DEL_DEST)
+			need_full_dest = 1;
+
+		ret = ip_vs_genl_parse_dest(&udest,
+					    info->attrs[IPVS_CMD_ATTR_DEST],
+					    need_full_dest);
+		if (ret)
+			goto out;
+	}
+
+	switch (cmd) {
+	case IPVS_CMD_NEW_SERVICE:
+		if (svc == NULL)
+			ret = ip_vs_add_service(&usvc, &svc);
+		else
+			ret = -EEXIST;
+		break;
+	case IPVS_CMD_SET_SERVICE:
+		ret = ip_vs_edit_service(svc, &usvc);
+		break;
+	case IPVS_CMD_DEL_SERVICE:
+		ret = ip_vs_del_service(svc);
+		break;
+	case IPVS_CMD_NEW_DEST:
+		ret = ip_vs_add_dest(svc, &udest);
+		break;
+	case IPVS_CMD_SET_DEST:
+		ret = ip_vs_edit_dest(svc, &udest);
+		break;
+	case IPVS_CMD_DEL_DEST:
+		ret = ip_vs_del_dest(svc, &udest);
+		break;
+	case IPVS_CMD_ZERO:
+		ret = ip_vs_zero_service(svc);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+
+out:
+	if (svc)
+		ip_vs_service_put(svc);
+	mutex_unlock(&__ip_vs_mutex);
+
+	return ret;
+}
+
+static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	void *reply;
+	int ret, cmd, reply_cmd;
+
+	cmd = info->genlhdr->cmd;
+
+	if (cmd == IPVS_CMD_GET_SERVICE)
+		reply_cmd = IPVS_CMD_NEW_SERVICE;
+	else if (cmd == IPVS_CMD_GET_INFO)
+		reply_cmd = IPVS_CMD_SET_INFO;
+	else if (cmd == IPVS_CMD_GET_CONFIG)
+		reply_cmd = IPVS_CMD_SET_CONFIG;
+	else {
+		IP_VS_ERR("unknown Generic Netlink command\n");
+		return -EINVAL;
+	}
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	mutex_lock(&__ip_vs_mutex);
+
+	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
+	if (reply == NULL)
+		goto nla_put_failure;
+
+	switch (cmd) {
+	case IPVS_CMD_GET_SERVICE:
+	{
+		struct ip_vs_service *svc;
+
+		svc = ip_vs_genl_find_service(info->attrs[IPVS_CMD_ATTR_SERVICE]);
+		if (IS_ERR(svc)) {
+			ret = PTR_ERR(svc);
+			goto out_err;
+		} else if (svc) {
+			ret = ip_vs_genl_fill_service(msg, svc);
+			ip_vs_service_put(svc);
+			if (ret)
+				goto nla_put_failure;
+		} else {
+			ret = -ESRCH;
+			goto out_err;
+		}
+
+		break;
+	}
+
+	case IPVS_CMD_GET_CONFIG:
+	{
+		struct ip_vs_timeout_user t;
+
+		__ip_vs_get_timeouts(&t);
+#ifdef CONFIG_IP_VS_PROTO_TCP
+		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP, t.tcp_timeout);
+		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_TCP_FIN,
+			    t.tcp_fin_timeout);
+#endif
+#ifdef CONFIG_IP_VS_PROTO_UDP
+		NLA_PUT_U32(msg, IPVS_CMD_ATTR_TIMEOUT_UDP, t.udp_timeout);
+#endif
+
+		break;
+	}
+
+	case IPVS_CMD_GET_INFO:
+		NLA_PUT_U32(msg, IPVS_INFO_ATTR_VERSION, IP_VS_VERSION_CODE);
+		NLA_PUT_U32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
+			    IP_VS_CONN_TAB_SIZE);
+		break;
+	}
+
+	genlmsg_end(msg, reply);
+	ret = genlmsg_unicast(msg, info->snd_pid);
+	goto out;
+
+nla_put_failure:
+	IP_VS_ERR("not enough space in Netlink message\n");
+	ret = -EMSGSIZE;
+
+out_err:
+	nlmsg_free(msg);
+out:
+	mutex_unlock(&__ip_vs_mutex);
+
+	return ret;
+}
+
+
+static struct genl_ops ip_vs_genl_ops[] __read_mostly = {
+	{
+		.cmd	= IPVS_CMD_NEW_SERVICE,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_SET_SERVICE,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_DEL_SERVICE,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_GET_SERVICE,
+		.flags	= GENL_ADMIN_PERM,
+		.doit	= ip_vs_genl_get_cmd,
+		.dumpit	= ip_vs_genl_dump_services,
+		.policy	= ip_vs_cmd_policy,
+	},
+	{
+		.cmd	= IPVS_CMD_NEW_DEST,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_SET_DEST,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_DEL_DEST,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_GET_DEST,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.dumpit	= ip_vs_genl_dump_dests,
+	},
+	{
+		.cmd	= IPVS_CMD_NEW_DAEMON,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_DEL_DAEMON,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_GET_DAEMON,
+		.flags	= GENL_ADMIN_PERM,
+		.dumpit	= ip_vs_genl_dump_daemons,
+	},
+	{
+		.cmd	= IPVS_CMD_SET_CONFIG,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_GET_CONFIG,
+		.flags	= GENL_ADMIN_PERM,
+		.doit	= ip_vs_genl_get_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_GET_INFO,
+		.flags	= GENL_ADMIN_PERM,
+		.doit	= ip_vs_genl_get_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_ZERO,
+		.flags	= GENL_ADMIN_PERM,
+		.policy	= ip_vs_cmd_policy,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+	{
+		.cmd	= IPVS_CMD_FLUSH,
+		.flags	= GENL_ADMIN_PERM,
+		.doit	= ip_vs_genl_set_cmd,
+	},
+};
+
+static int __init ip_vs_genl_register(void)
+{
+	int ret, i;
+
+	ret = genl_register_family(&ip_vs_genl_family);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < ARRAY_SIZE(ip_vs_genl_ops); i++) {
+		ret = genl_register_ops(&ip_vs_genl_family, &ip_vs_genl_ops[i]);
+		if (ret)
+			goto err_out;
+	}
+	return 0;
+
+err_out:
+	genl_unregister_family(&ip_vs_genl_family);
+	return ret;
+}
+
+static void ip_vs_genl_unregister(void)
+{
+	genl_unregister_family(&ip_vs_genl_family);
+}
+
+/* End of Generic Netlink interface definitions */
+
 
 int __init ip_vs_control_init(void)
 {
@@ -2334,6 +3201,13 @@ int __init ip_vs_control_init(void)
 		return ret;
 	}
 
+	ret = ip_vs_genl_register();
+	if (ret) {
+		IP_VS_ERR("cannot register Generic Netlink interface.\n");
+		nf_unregister_sockopt(&ip_vs_sockopts);
+		return ret;
+	}
+
 	proc_net_fops_create(&init_net, "ip_vs", 0, &ip_vs_info_fops);
 	proc_net_fops_create(&init_net, "ip_vs_stats",0, &ip_vs_stats_fops);
 
@@ -2368,6 +3242,7 @@ void ip_vs_control_cleanup(void)
 	unregister_sysctl_table(sysctl_header);
 	proc_net_remove(&init_net, "ip_vs_stats");
 	proc_net_remove(&init_net, "ip_vs");
+	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
 	LeaveFunction(2);
 }
-- 
1.5.4.5

