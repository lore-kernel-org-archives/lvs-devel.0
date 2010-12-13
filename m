From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 1/3] ipvs: use SYNC_MESG_HEADER_LEN instead of explicit
 header length
Date: Mon, 13 Dec 2010 09:16:58 +0100
Message-ID: <1292228218.4983.8.camel@seasc0214>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
	 <20101212214623.GE7914@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101212214623.GE7914@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Tinggong Wang <wangtinggong@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Hans Schillstrom <hans@schillstrom.com>

On Sun, 2010-12-12 at 22:46 +0100, Simon Horman wrote:
> [ CCed Hans Schillstrom ]
> 
> On Sun, Dec 12, 2010 at 07:41:45PM +0800, Tinggong Wang wrote:
> > Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_sync.c |   10 +++++-----
> >  1 files changed, 5 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > index ab85aed..7632a17 100644
> > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > @@ -102,7 +102,6 @@ struct ip_vs_sync_thread_data {
> >        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> >  */
> >  
> > -#define SYNC_MESG_HEADER_LEN	4
> >  #define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
> >  
> >  struct ip_vs_sync_mesg {
> > @@ -112,6 +111,7 @@ struct ip_vs_sync_mesg {
> >  
> >  	/* ip_vs_sync_conn entries start here */
> >  };
> > +#define SYNC_MESG_HEADER_LEN	(sizeof(struct ip_vs_sync_mesg))
> >  
> >  /* the maximum length of sync (sending/receiving) message */
> >  static int sync_send_mesg_maxlen;
> > @@ -188,8 +188,8 @@ static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(void)
> >  	}
> >  	sb->mesg->nr_conns = 0;
> >  	sb->mesg->syncid = ip_vs_master_syncid;
> > -	sb->mesg->size = 4;
> > -	sb->head = (unsigned char *)sb->mesg + 4;
> > +	sb->mesg->size = SYNC_MESG_HEADER_LEN;
> > +	sb->head = (unsigned char *)sb->mesg + SYNC_MESG_HEADER_LEN;
> >  	sb->end = (unsigned char *)sb->mesg + sync_send_mesg_maxlen;
> >  	sb->firstuse = jiffies;
> >  	return sb;
> > @@ -315,7 +315,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> >  	char *p;
> >  	int i;
> >  
> > -	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
> > +	if (buflen < SYNC_MESG_HEADER_LEN) {
> >  		IP_VS_ERR_RL("sync message header too short\n");
> >  		return;
> >  	}
> > @@ -335,7 +335,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> >  		return;
> >  	}
> >  
> > -	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg);
> > +	p = (char *)buffer + SYNC_MESG_HEADER_LEN;
> >  	for (i=0; i<m->nr_conns; i++) {
> >  		unsigned flags, state;
> >  
> > -- 
> > 1.7.2.3
> > 
> 
> This looks good to me, Hans can I get an Ack from you?

This patch is outdated, it doesn't look like this after IPv6 & PE
additions. 

(BTW I will post the network name space patch today, and the 4 is
already replaced there.)

Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>


