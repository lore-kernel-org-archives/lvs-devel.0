From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 4/6] ipvs: fix sparse warnings for sync msg size
Date: Fri, 19 Apr 2013 10:49:55 +0900
Message-ID: <20130419014952.GA25718@verge.net.au>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg>
 <1366231850-22188-5-git-send-email-ja@ssi.bg>
 <20130418114325.GA11486@verge.net.au>
 <alpine.LFD.2.00.1304182215060.1842@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304182215060.1842@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Thu, Apr 18, 2013 at 10:24:58PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 18 Apr 2013, Simon Horman wrote:
> 
> > On Wed, Apr 17, 2013 at 11:50:48PM +0300, Julian Anastasov wrote:
> > > 	Fix sparse warnings while changing the
> > > size between host and network order:
> > > 
> > > net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> > > net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> > > net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> > > net/netfilter/ipvs/ip_vs_sync.c:1179:20: warning: cast to restricted __be16
> > > net/netfilter/ipvs/ip_vs_sync.c:1550:19: warning: incorrect type in
> > > 	assignment (different base types)
> > > net/netfilter/ipvs/ip_vs_sync.c:1550:19:    expected unsigned short
> > > 	[unsigned] [usertype] size
> > > net/netfilter/ipvs/ip_vs_sync.c:1550:19:    got restricted __be16
> > > 	[usertype] <noident>
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > 
> > I'm not very excited by the use of __force.
> > Can't we change the type of the size element
> > of struct ip_vs_sync_mesg and use the sparse annotations
> > to our advantage?
> 
> 	AFAIK, __force is the only way to suppress sparse
> warning. Not sure what is your idea, may be you can try it.

Sure, sorry for not explaining myself more clearly.
My idea is as follows:

From: Simon Horman <horms@verge.net.au>

ipvs: Use network byte order for sync message size

struct ip_vs_sync_mesg is both sent across the wire and
used internally to store IPVS synchronisation messages.

Up until now the scheme used has been to convert the size field
to network byte order before sending a message on the wire and
convert it to host byte order when sending a message.

This patch changes that scheme to always treat the field
as being network byte order. This seems appropriate as
the structure is sent across the wire. And by consistently
treating the field has network byte order it is now possible
to take advantage of sparse to flag any future miss-use.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 8e57077..c73778a 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -255,7 +255,7 @@ struct ip_vs_sync_mesg_v0 {
 struct ip_vs_sync_mesg {
 	__u8			reserved;	/* must be zero */
 	__u8			syncid;
-	__u16			size;
+	__be16			size;
 	__u8			nr_conns;
 	__s8			version;	/* SYNC_PROTO_VER  */
 	__u16			spare;
@@ -335,7 +335,7 @@ ip_vs_sync_buff_create(struct netns_ipvs *ipvs)
 	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zero now */
 	sb->mesg->version = SYNC_PROTO_VER;
 	sb->mesg->syncid = ipvs->master_syncid;
-	sb->mesg->size = sizeof(struct ip_vs_sync_mesg);
+	sb->mesg->size = htons(sizeof(struct ip_vs_sync_mesg));
 	sb->mesg->nr_conns = 0;
 	sb->mesg->spare = 0;
 	sb->head = (unsigned char *)sb->mesg + sizeof(struct ip_vs_sync_mesg);
@@ -693,7 +693,7 @@ sloop:
 
 	p = buff->head;
 	buff->head += pad + len;
-	m->size += pad + len;
+	m->size = htons(ntohs(m->size) + pad + len);
 	/* Add ev. padding from prev. sync_conn */
 	while (pad--)
 		*(p++) = 0;
@@ -1175,10 +1175,8 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
 		IP_VS_DBG(2, "BACKUP, message header too short\n");
 		return;
 	}
-	/* Convert size back to host byte order */
-	m2->size = ntohs(m2->size);
 
-	if (buflen != m2->size) {
+	if (buflen != ntohs(m2->size)) {
 		IP_VS_DBG(2, "BACKUP, bogus message size\n");
 		return;
 	}
@@ -1544,10 +1542,7 @@ ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
 	int msize;
 	int ret;
 
-	msize = msg->size;
