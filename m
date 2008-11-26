From: Joseph Mack NA3T <jmack@wm7d.net>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Wed, 26 Nov 2008 06:40:02 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0811260636100.26650@wm7d.net>
References: <1227706578-5449-1-git-send-email-catab@embedromix.ro>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1227706578-5449-1-git-send-email-catab@embedromix.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Wed, 26 Nov 2008, Catalin(ux) M. BOIE wrote:

> I was very frustrated about the fact that I have to recompile the kernel
> to change the hash size. So, I created this patch.

thanks for sending us the code.

Why do you need to change the hash size? We really don't 
recommend anyone do this under normal circumstances

Thanks Joe

> If IPVS is built-in you can append ip_vs.conn_tab_bits=?? to kernel
> command line, or, if you built IPVS as modules, you can add
> options ip_vs conn_tab_bits=??.
> To keep everything backward compatible, you still can select the size at
> compile time, and that will be used as default.
>
> Signed-off-by: Catalin(ux) M. BOIE <catab@embedromix.ro>
> ---
> include/net/ip_vs.h             |   16 ++++----------
> net/netfilter/ipvs/Kconfig      |    4 +++
> net/netfilter/ipvs/ip_vs_conn.c |   41 ++++++++++++++++++++++++++++----------
> net/netfilter/ipvs/ip_vs_ctl.c  |    8 +++---
> 4 files changed, 43 insertions(+), 26 deletions(-)
>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index fe9fcf7..5a788a4 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -26,6 +26,11 @@
> #include <linux/ipv6.h>			/* for struct ipv6hdr */
> #include <net/ipv6.h>			/* for ipv6_addr_copy */
>
> +
> +/* Connections' size value needed by ip_vs_ctl.c */
> +extern int ip_vs_conn_tab_size;
> +
> +
> struct ip_vs_iphdr {
> 	int len;
> 	__u8 protocol;
> @@ -599,17 +604,6 @@ extern void ip_vs_init_hash_table(struct list_head *table, int rows);
>  *     (from ip_vs_conn.c)
>  */
>
> -/*
> - *     IPVS connection entry hash table
> - */
> -#ifndef CONFIG_IP_VS_TAB_BITS
> -#define CONFIG_IP_VS_TAB_BITS   12
> -#endif
> -
> -#define IP_VS_CONN_TAB_BITS	CONFIG_IP_VS_TAB_BITS
> -#define IP_VS_CONN_TAB_SIZE     (1 << IP_VS_CONN_TAB_BITS)
> -#define IP_VS_CONN_TAB_MASK     (IP_VS_CONN_TAB_SIZE - 1)
> -
> enum {
> 	IP_VS_DIR_INPUT = 0,
> 	IP_VS_DIR_OUTPUT,
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index 79a6980..c71e543 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -68,6 +68,10 @@ config	IP_VS_TAB_BITS
> 	  each hash entry uses 8 bytes, so you can estimate how much memory is
> 	  needed for your box.
>
> +	  You can overwrite this number setting conn_tab_bits module parameter
> +	  or by appending ip_vs.conn_tab_bits=? to the kernel command line
> +	  if IP VS was compiled built-in.
> +
> comment "IPVS transport protocol load balancing support"
>
> config	IP_VS_PROTO_TCP
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 9a24332..b1462f1 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -37,6 +37,21 @@
> #include <net/ip_vs.h>
>
>
> +#ifndef CONFIG_IP_VS_TAB_BITS
> +#define CONFIG_IP_VS_TAB_BITS	12
> +#endif
> +
> +/*
> + * Connection hash size. Default is what was selected at compile time.
> +*/
> +int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
> +module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, 0444);
> +MODULE_PARM_DESC(conn_tab_bits, "Set connections' hash size");
> +
> +/* size and mask values */
> +int ip_vs_conn_tab_size;
> +int ip_vs_conn_tab_mask;
> +
> /*
>  *  Connection hash table: for input and output packets lookups of IPVS
>  */
> @@ -122,11 +137,11 @@ static unsigned int ip_vs_conn_hashkey(int af, unsigned proto,
> 	if (af == AF_INET6)
> 		return jhash_3words(jhash(addr, 16, ip_vs_conn_rnd),
> 				    (__force u32)port, proto, ip_vs_conn_rnd)
> -			& IP_VS_CONN_TAB_MASK;
> +			& ip_vs_conn_tab_mask;
> #endif
> 	return jhash_3words((__force u32)addr->ip, (__force u32)port, proto,
> 			    ip_vs_conn_rnd)
> -		& IP_VS_CONN_TAB_MASK;
> +		& ip_vs_conn_tab_mask;
> }
>
>
> @@ -752,7 +767,7 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
> 	int idx;
> 	struct ip_vs_conn *cp;
>
> -	for(idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
> +	for(idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> 		ct_read_lock_bh(idx);
> 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
> 			if (pos-- == 0) {
> @@ -789,7 +804,7 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> 	idx = l - ip_vs_conn_tab;
> 	ct_read_unlock_bh(idx);
>
> -	while (++idx < IP_VS_CONN_TAB_SIZE) {
> +	while (++idx < ip_vs_conn_tab_size) {
> 		ct_read_lock_bh(idx);
> 		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
> 			seq->private = &ip_vs_conn_tab[idx];
> @@ -972,8 +987,8 @@ void ip_vs_random_dropentry(void)
> 	/*
> 	 * Randomly scan 1/32 of the whole table every second
> 	 */
> -	for (idx = 0; idx < (IP_VS_CONN_TAB_SIZE>>5); idx++) {
> -		unsigned hash = net_random() & IP_VS_CONN_TAB_MASK;
> +	for (idx = 0; idx < (ip_vs_conn_tab_size>>5); idx++) {
> +		unsigned hash = net_random() & ip_vs_conn_tab_mask;
>
> 		/*
> 		 *  Lock is actually needed in this loop.
> @@ -1025,7 +1040,7 @@ static void ip_vs_conn_flush(void)
> 	struct ip_vs_conn *cp;
>
>   flush_again:
> -	for (idx=0; idx<IP_VS_CONN_TAB_SIZE; idx++) {
> +	for (idx=0; idx<ip_vs_conn_tab_size; idx++) {
> 		/*
> 		 *  Lock is actually needed in this loop.
> 		 */
> @@ -1056,10 +1071,14 @@ int __init ip_vs_conn_init(void)
> {
> 	int idx;
>
> +	/* Compute size and mask */
> +	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
> +	ip_vs_conn_tab_mask = ip_vs_conn_tab_size - 1;
> +
> 	/*
> 	 * Allocate the connection hash table and initialize its list heads
> 	 */
> -	ip_vs_conn_tab = vmalloc(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head));
> +	ip_vs_conn_tab = vmalloc(ip_vs_conn_tab_size * sizeof(struct list_head));
> 	if (!ip_vs_conn_tab)
> 		return -ENOMEM;
>
> @@ -1074,12 +1093,12 @@ int __init ip_vs_conn_init(void)
>
> 	IP_VS_INFO("Connection hash table configured "
> 		   "(size=%d, memory=%ldKbytes)\n",
> -		   IP_VS_CONN_TAB_SIZE,
> -		   (long)(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head))/1024);
> +		   ip_vs_conn_tab_size,
> +		   (long)(ip_vs_conn_tab_size*sizeof(struct list_head))/1024);
> 	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
> 		  sizeof(struct ip_vs_conn));
>
> -	for (idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
> +	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> 		INIT_LIST_HEAD(&ip_vs_conn_tab[idx]);
> 	}
>
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 0302cf3..6dcadc2 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1854,7 +1854,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
> 	if (v == SEQ_START_TOKEN) {
> 		seq_printf(seq,
> 			"IP Virtual Server version %d.%d.%d (size=%d)\n",
> -			NVERSION(IP_VS_VERSION_CODE), IP_VS_CONN_TAB_SIZE);
> +			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
> 		seq_puts(seq,
> 			 "Prot LocalAddress:Port Scheduler Flags\n");
> 		seq_puts(seq,
> @@ -2385,7 +2385,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
> 		char buf[64];
>
> 		sprintf(buf, "IP Virtual Server version %d.%d.%d (size=%d)",
> -			NVERSION(IP_VS_VERSION_CODE), IP_VS_CONN_TAB_SIZE);
> +			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
> 		if (copy_to_user(user, buf, strlen(buf)+1) != 0) {
> 			ret = -EFAULT;
> 			goto out;
> @@ -2398,7 +2398,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
> 	{
> 		struct ip_vs_getinfo info;
> 		info.version = IP_VS_VERSION_CODE;
> -		info.size = IP_VS_CONN_TAB_SIZE;
> +		info.size = ip_vs_conn_tab_size;
> 		info.num_services = ip_vs_num_services;
> 		if (copy_to_user(user, &info, sizeof(info)) != 0)
> 			ret = -EFAULT;
> @@ -3238,7 +3238,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
> 	case IPVS_CMD_GET_INFO:
> 		NLA_PUT_U32(msg, IPVS_INFO_ATTR_VERSION, IP_VS_VERSION_CODE);
> 		NLA_PUT_U32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
> -			    IP_VS_CONN_TAB_SIZE);
> +			    ip_vs_conn_tab_size);
> 		break;
> 	}
>
>

-- 
Joseph Mack NA3T EME(B,D), FM05lw North Carolina
jmack (at) wm7d (dot) net - azimuthal equidistant map
generator at http://www.wm7d.net/azproj.shtml
Homepage http://www.austintek.com/ It's GNU/Linux!
