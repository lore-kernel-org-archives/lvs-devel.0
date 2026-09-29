Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 202883D7D94;
	Tue, 29 Sep 2026 15:40:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790696443; cv=none; b=WbrQgONNdJXCzZOktDKWBSSIMoQtffjclqlWst+ECixKmpw3aC/0U04Azb2yIzZ6IpObNAHYqgpWDSV9hfGuYl0EFUMSTAF0HWdtswQGcy4lYrhl8iVGf+Db79ZW6m/K4eADaTEiDLc/Ayt6+jiuWs2Db3/UqK20Mi0H2ttRwHQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790696443; c=relaxed/simple;
	bh=1moNuHHBncGFFeKoSa0BHTqRQx0iefcOhw6cFUq/Xp4=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=DJLvW+8lNyJGPiLXw+ayQF7g82zHDqc3YgYOkhV9tbyhkhggpVMqkDWXmRqlGsNopebp010O9/rmfa1Kw4elc0xzSY8xvxDj/vT3mDZi22cYUrooleRKPOVdPYkqyf6eZeKc22cu4MuQ0v7rL5A0wxxLYoXnAcB4Erp/oqRhSlE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FhW5IXIk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FhW5IXIk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 421081F00893;
	Tue, 29 Sep 2026 15:40:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790696442;
	bh=0LsyaRjfKEK1HofltBB4yYzmttCl6fGaAL8ADqKmkIE=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=FhW5IXIkWBIQ+mGyO5V3ysLN1HHik1nAgFg0Pi3CsnCf4mt9kbaCCJF0hpXoUKfuf
	 Esd13hgCJrSmpz8viwdBAQWppaCY2AXBTY5BYm2siuOfjUn3ov+RTIIeAnlibJ7nbp
	 W0TJfc1ZihXFLqFF1q3VUYyHd4k+GEOMgPB2Rrv4pyrW6Vm49MTXibDg90F6MQQDax
	 8dLIGMtDScRRNBW1+F3uSFoUeyJsdsaA65xs9cQgV9GSO8AxxNB0ZoIKHxLhvyYray
	 5wF7lhiLvDQAFDjh1nUlnJbgtsIryRhxDmQFM4bmJ2cNE5Udvq54400MW2GllZznyl
	 6PnyeOCuhnJCQ==
Subject:
 Re: [PATCH nf 2/2] ipvs: skip cport 0 connections in ip_vs_conn_out_get()
From: netdev-bot+sashiko@kernel.org
To: axel.mierczuk@1password.com
Cc: ja@ssi.bg, horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 coreteam@netfilter.org, netdev@vger.kernel.org, w@1wt.eu,
 keith.hoodlet@1password.com, stable@vger.kernel.org, kuba@kernel.org
Date: Tue, 29 Sep 2026 15:40:40 +0000
Message-ID: <179069644081.434549.12041373468323144203@kernel.org>
In-Reply-To: <20260925141115.16126-3-axel.mierczuk@1password.com>
References: <20260925141115.16126-3-axel.mierczuk@1password.com>
X-sashiko-severity: Medium
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 5 potential
issue(s) to consider.

Critical: 0 · High: 0 · Medium: 4 · Low: 1

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [Medium] The new `cp->cport` requirement turns the "update or create"
  lookup in ip_vs_ftp_out() (net/netfilter/ipvs/ip_vs_ftp.c) into dead…
- [Medium] ip_vs_new_conn_out() (net/netfilter/ipvs/ip_vs_core.c) rejects
  only `!vport || !dport`.
- [Medium] The commit message assumes only templates and NO_CPORT entries
  have cport 0, but ordinary connections can too.
- [Medium] The commit rests on the claim "Templates keep cport 0
  throughout their lifetime", which does not hold for synced templates…
- [Low] The patch adds a second, separate plain read of cp->cport in
  ip_vs_conn_out_get().

--

ipvs: skip cport 0 connections in ip_vs_conn_out_get()

This patch makes ip_vs_conn_out_get() match only connections with a
nonzero cp->cport. The goal is to stop out-direction packets sent to
client port 0 from matching persistence templates, or connections still
waiting for their client port (IP_VS_CONN_F_NO_CPORT), and then updating
their state and timeout.

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6fa3e1dc534c3..24dbe34a48275 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -579,7 +579,8 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  				    ip_vs_addr_equal(p->af, p->vaddr,
>  						     &cp->caddr) &&
>  				    ip_vs_addr_equal(p->af, p->caddr, saddr) &&
> -				    p->protocol == cp->protocol) {
> +				    p->protocol == cp->protocol &&
> +				    cp->cport) {

[Severity: Medium]
Does this make the "update or create" lookup in ip_vs_ftp_out() in
net/netfilter/ipvs/ip_vs_ftp.c unreachable?

ip_vs_ftp_out() looks up with vport 0 on purpose, to find an existing
IP_VS_CONN_F_NO_CPORT passive data connection:

net/netfilter/ipvs/ip_vs_ftp.c:ip_vs_ftp_out() {
    ...
	/* Now update or create a connection entry for it */
	{
		struct ip_vs_conn_param p;

		ip_vs_conn_fill_param(cp->ipvs, cp->af,
				      ipvsh->protocol, &from, port,
				      &cp->caddr, 0, &p);
		n_cp = ip_vs_conn_out_get(&p);
	}
	if (!n_cp) {
		...
		n_cp = ip_vs_conn_new(&p, cp->af, &from, port,
				      IP_VS_CONN_F_NO_CPORT |
				      IP_VS_CONN_F_NFCT,
				      cp->dest, skb->mark);
		if (!n_cp)
			return 0;
    ...
}

When p->vport is 0, the earlier check in ip_vs_conn_out_get():

	if (p->vport != cp->cport)
		continue;

only lets through entries with cp->cport == 0. The new cp->cport test
then rejects every one of them, so this lookup can never return a match.

Suppose a client sends PASV/EPSV again and the server answers with the
same passive port, for example because it has a fixed or narrow passive
range. Each such reply now creates a duplicate NO_CPORT entry with the
same hash key.

Each duplicate increments no_cport_conns[], takes another n_control
reference on the control connection and adds another conntrack
expectation. Only one of them ever gets its cport filled. The rest stay
until the listen timeout.

If conn_count has reached conn_max, ip_vs_conn_new() returns NULL and
ip_vs_ftp_out() returns 0. The control reply is dropped, where before
the existing entry would have been reused.

A retransmitted 227/229 segment does not seem to trigger this, because
cp->app_data is set to IP_VS_FTP_ACTIVE after the first pass. A repeated
PASV/EPSV command does trigger it.

The commit message says "FTP data connections learn their client port
from incoming traffic before replies are processed". Doesn't that only
cover replies on the data connection? This control-channel lookup runs
before the port is known.

[Severity: Medium]
Can this lead to a new connection being created for every packet of a
flow started by a real server towards client port 0?

ip_vs_new_conn_out() in net/netfilter/ipvs/ip_vs_core.c only rejects a
zero vport or dport:

	if (!vport || !dport)
		return NULL;

Take a SIP-PE service with conn_out_counter > 0, where a real server
sends a UDP packet to client port 0. This path:

ip_vs_out_hook()->__ip_vs_rs_conn_out()->ip_vs_sip_conn_out()->
    ip_vs_new_conn_out()->ip_vs_conn_new()

creates an ordinary hashed connection with cp->cport == 0 and neither
TEMPLATE nor NO_CPORT set.

Before this patch, the next packet of that flow matched this entry in
ip_vs_conn_out_get(). With the new cp->cport test it misses. So
ip_vs_out_hook() falls back to __ip_vs_rs_conn_out() again and creates
yet another connection.

Each extra connection lives until the UDP timeout. For persistent
services, each one also takes another n_control reference on the
template.

__ip_vs_conn_in_get() cannot match these entries either, because a
cport 0 lookup there requires NO_CPORT.

Linux UDP sockets refuse sendto() to port 0, so in practice this needs a
raw socket or a non-Linux real server.

Should ip_vs_new_conn_out() also reject a zero cport? Or should the out
lookup exclude only templates and NO_CPORT entries?

[Severity: Medium]
The commit message assumes that only templates and NO_CPORT entries have
cport 0. Does that hold for ordinary MASQ connections scheduled for a
client that uses source port 0?

ip_vs_schedule() in net/netfilter/ipvs/ip_vs_core.c takes the client
port directly from the packet:

	cport = pptr[0];
	...
	ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol,
			      caddr, cport, vaddr, vport, &p);
	cp = ip_vs_conn_new(&p, dest->af, &dest->addr,
			    dest->port ? dest->port : vport,
			    flags, dest, skb->mark);

Nothing in the scheduling path rejects source port 0. A remote client
sending a TCP SYN or UDP packet from port 0 to VIP:vport on a
non-persistent MASQ service gets an ordinary connection with
cp->cport == 0.

Before this patch, the real server's reply to client:0 matched this
connection in ip_vs_conn_out_get() and was SNATed back to VIP:vport. Now
the lookup rejects it.

With the default nat_icmp_send=0, ip_vs_out_hook() then returns
NF_ACCEPT. The reply, for example a SYN-ACK or RST, leaves the director
with the real server's private address and port as its source.

ICMP errors behave the same way. If the real server sends an error that
quotes client:0->RS:rport, ip_vs_out_icmp() does the reversed lookup
with vport 0:

	cp = INDIRECT_CALL_1(pp->conn_out_get, ip_vs_conn_out_get_proto,
			     ipvs, AF_INET, skb, &ciph);
	if (!cp)
		return NF_ACCEPT;

This now returns NULL, so neither the outer source nor the embedded
tuple is reverse-NATed.

__ip_vs_conn_in_get() already could not match such entries. The out
direction, though, was NATed before this patch.

Would excluding IP_VS_CONN_F_TEMPLATE (and NO_CPORT, if intended) by
flag avoid this?

[Severity: Low]
Can the two separate plain reads of cp->cport in ip_vs_conn_out_get()
see different values?

The lookup holds only rcu_read_lock(). Meanwhile, ip_vs_conn_fill_cport()
writes cp->cport under cp->lock and the bucket locks, before it updates
hn->hash_key and moves the node:

	if (!cp->cport) {
		cp->cport = cport;
		by_me = true;
	}

It can also reset cp->cport to 0 on the "Too many ht changes" path.

Suppose a MASQ NO_CPORT connection is getting its cport filled while an
out-direction packet to client port 0 is looked up. The reader can see
the old hash_key and read cp->cport == 0 in:

	if (p->vport != cp->cport)
		continue;

and then read the new nonzero port in the added cp->cport test. The
entry then matches, and handle_response() runs ip_vs_set_state() and the
timeout update. That is the NO_CPORT case the commit message says this
patch closes.

A successful match leaves the loop through goto out, so the seqcount
retry in ip_vs_rht_for_bucket_retry() is never checked.

Neither side uses READ_ONCE()/WRITE_ONCE(), so KCSAN could also report
this as a data race.

Would a single snapshot close this window?

	__be16 cport = READ_ONCE(cp->cport);

	if (!cport || p->vport != cport)
		continue;

[Severity: Medium]
The commit message says:

    Templates keep cport 0 throughout their lifetime.

Is that true for synced templates that also carry IP_VS_CONN_F_NO_CPORT?

IP_VS_CONN_F_BACKUP_MASK includes both TEMPLATE and NO_CPORT. The
template check in ip_vs_proc_conn() in net/netfilter/ipvs/ip_vs_sync.c
only rejects a nonzero cport:

	if (flags & IP_VS_CONN_F_TEMPLATE) {
		if (param->cport) {
			IP_VS_DBG(2, "BACKUP, template with cport dropped\n");
			kfree(param->pe_data);
			return;
		}
	}

So a forged TEMPLATE|NO_CPORT|MASQ record with cport 0 is accepted. It
is hashed through hn0, counted in no_cport_conns[] and bound to
ip_vs_nat_xmit().

An incoming packet C:X -> vaddr:vport then goes through:

ip_vs_in_hook()
  ip_vs_conn_in_get()     <- the cport 0 fallback matches; TEMPLATE
                             is not excluded
  ip_vs_nat_xmit()
    ip_vs_conn_fill_cport(cp, X)

ip_vs_conn_fill_cport() sets cp->cport = X and clears NO_CPORT, but
leaves TEMPLATE set. It also rehashes hn0 to hash(C, X, vaddr, vport).
All of this happens before the later "stopping DNAT to local address"
check in ip_vs_nat_xmit().

Now suppose the forged record also sets daddr == vaddr and
dport == vport. An out packet vaddr:vport -> C:X then passes the
hash_key check, the MASQ saddr/sport comparisons and the new cp->cport
test. handle_response() then runs ip_vs_set_state() and the timeout
update on the template.

One way to produce that out packet: vaddr is local to the backup and
the incoming packet has no conntrack entry. The packet is then delivered
locally, and the local reply or RST goes through ip_vs_out_hook() at
LOCAL_OUT.

The in-direction fallback already let such a forged template see
packets before this patch. The out-direction match on the template is
what reappears here.

Would it be more robust to exclude IP_VS_CONN_F_TEMPLATE explicitly in
ip_vs_conn_out_get(), and to reject TEMPLATE|NO_CPORT records in
ip_vs_proc_conn()?

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
