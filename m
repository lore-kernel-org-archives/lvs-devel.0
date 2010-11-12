From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v3 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Sat, 13 Nov 2010 01:31:21 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011130123360.2125@ja.ssi.bg>
References: <201011121342.41418.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011121342.41418.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horms <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, Daniel Lezcano <daniel.lezcano@free.fr>


 	Hello,

On Fri, 12 Nov 2010, Hans Schillstrom wrote:

> This patch series adds/(updates) the following functionality
> in the synchronization between master and backup daemons.
>
> - IPv6
> - Persistence Engine
> - Firewall marks transferred
> - Time-outs transferred.
> - Flag field increased to 32 bits.
>
> Note:
> This patches depends on Patch 1-9 in staging branch:
> "IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon."
> to ...
> "IPVS: skb defrag in L7 helpers"
>
> A new message format is also introduced, not understood by old backup daemons.
> For compatibility reasons receiving the old version (version 0) is still possible.
> Old (version 0) backups will just drop new (Version 1) messages.
> It's also possible to send sync msg in version 0 format, by sysctl
> #sysclt -w net.ipv4.vs.sync_version=0

v3 PATCH 1/3
 	- ntoh_seq can use directly get_unaligned_be32, it is BE to CPU,
 		no need for ntohl

 	- In ip_vs_conn_fill_param_sync:

 		- should we ignore the conn entry when pe_name_len
 		is 0 and pe_data_len != 0 (return 1)? May be such checks:

 		/* Handle pe data */
 		if ((pe_data_len != 0) != (pe_name_len != 0)) {
 			IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
 			return 1;
 		}
 		if (!pe_name_len)
 			return 0;
 		...

 		- make sure p->pe is _put when p->pe_data
 			allocation fails (-ENOMEM)

 	- ip_vs_proc_str: use 'unsigned int', not just 'unsigned'

 	- ip_vs_proc_sync_conn:
 		- pe_data_len, pe_name_len, pe_data, pe_name are
 		not initialized

 		- 'retc 10;' must be 'retc = 10;' ?

 		- inconsistent spaces:
 			'} else if (! s->v4.type) {'
 			'while (p< msg_end && *p && !retc ) {'

 		- please convert char *p, char *msg_end to '__u8 *' or
 		'unsigned char *' because this is risky for char * when
 		value is above 127:
 			int ptype = *(p++);
 			int plen =  *(p++);

 		- add some sanity checks because 'p< msg_end' guarantees
 		that only ptype is present, for example:

 			while (p < msg_end) {
 				int ptype;
 				int plen;

 				if (p + 2 > msg_end)
 					return -30;

 				ptype = *(p++);
 				plen = *(p++);

 		- for IPVS_OPT_PE_NAME ip_vs_proc_str must be called
 		with IPVS_OPT_F_PE_NAME

 	- ip_vs_process_message:
 		- before 'size = ntohs(s->v4.ver_size) & SVER_MASK;'
 		there must be a check for present v4 structure:

 		if (msg_end + sizeof(s->v4) > buffer+buflen) {
 			IP_VS_ERR_RL("BACKUP, Dropping buffer, msg > buffer\n");
 			return;
 		}
 		size = ntohs(s->v4.ver_size) & SVER_MASK;

 		- we must account padding later after
 		ip_vs_proc_sync_conn is called, it should not be
 		included in size because the parameter
 		parsing will fail while walking the padding:

 			size += 3;
 			size &= ~3;
 			msg_end = p + size;

 		there is no need to check if new msg_end
 		exceeds buflen because if there are more
 		conn entries the above code will check for
 		present v4 structure.

 		Another option is the parameter parsing
 		to consider ptype=0 as 1 byte padding but
 		then there should be no plen octet for this
 		case. Then ver_size can include the padding.
 		For example:

 		while (p < msg_end) {
 			int ptype = *(p++);
 			int plen;

 			/* Padding ? */
 			if (!ptype)
 				continue;
 			if (p + 1 > msg_end)
 				return -30;
 			plen = *(p++);

v3 PATCH 2/3
 	- hton_seq can use put_unaligned_be32
 	- ip_vs_sync_conn:
 		- move init of pe_name_len after sloop

 		- The 'Sanity checks' code must be after sloop

 		- we can use cp->pe instead of cp->dest->svc->pe

 		- before 'len = (len+3) & 0xffc;' may be
 		we have to calculate pad = (4 - len) & 3
 		so that we can use it later, len should not
 		include the padding, for example:

 		pad = (4 - len) & 3;
 		/* check if there is a space for this one */
 		if (curr_sb && (curr_sb->head+len+pad > curr_sb->end)) {
 		...

 		- then after all parameters:

 		curr_sb->head += len;
 		if (pad) {
 			memset(curr_sb->head, 0, pad);
 			curr_sb->head += pad;
 		}

 		or

 		curr_sb->head += len;
 		while (pad --)
 			*curr_sb->head ++ = 0;

 		then this code is not needed:

 		+	if (p < curr_sb->head)
 		+		*p = 0; 	/* Dont leave random bytes at end */

 		- use cp->pe for IPVS_OPT_PE_NAME

v3 PATCH 3/3
 	OK

Regards

--
Julian Anastasov <ja@ssi.bg>
