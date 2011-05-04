From: Jianzhang Peng <pengjianzhang@gmail.com>
Subject: problem about change MAC address
Date: Wed, 4 May 2011 17:35:09 +0800
Message-ID: <BANLkTimsuHNMU1f7ZsB6cvEwUyuW76GNRQ@mail.gmail.com>
References: <BANLkTimTAn17vBsA2iMqUpEnFFsa0rhoUw@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:in-reply-to:references:date
         :message-id:subject:from:to:content-type:content-transfer-encoding;
        bh=d44HvlAQ8snhoO8KZ+SrD+C1OMx6WyEmqgNDdNyoHYg=;
        b=Ek8Bb470Y8wKW4jSZwRgn2X/03ZM9XSJuzuT/xe9GF6hS+8WsX47vd/SHjUri9B9kG
         e3t3bYXuC0FOYXgGIv3pM9UtY6C78cXl7LiQ1UAE2qJFHuKw+04vRwvyV12/dXnf0GGS
         y5xG+bpzpMb3AOvuaiK+ED1FRD3LTRzOJMV2M=
In-Reply-To: <BANLkTimTAn17vBsA2iMqUpEnFFsa0rhoUw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel@vger.kernel.org

hi=A3=AC
i have three PC
A  ip =3D 192.168.2.249  vip =3D 192.168.2.99
B ip =3D 192.168.2.245   vip =3D 192.168.2.99  no arp
C ip =3D 192.168.2.19

A send package to 192.168.2.99 , then A get IP package from C and
change it's MAC  and  send  to B. I find A  can  get C's IP package,
but it can't send out. I get the idea from ipvs's dr mode. I guess my
problem in function my_xmit, but i don't know why. Thanks.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#include <linux/init.h>
#include <linux/module.h>
#include <linux/netfilter.h>
#include <linux/socket.h>/*PF_INET*/
#include <linux/netfilter_ipv4.h>/*NF_IP_PRE_FIRST*/
#include <linux/skbuff.h>
#include <linux/netdevice.h>
#include <linux/inet.h> /*in_aton()*/
#include <net/ip.h>
#include <net/tcp.h>
#include <linux/version.h>
#include <linux/module.h>


#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
#define MAC_ARG(x)
((u8*)(x))[0],((u8*)(x))[1],((u8*)(x))[2],((u8*)(x))[3],((u8*)(x))[4],(=
(u8*)(x))[5]

MODULE_LICENSE("GPL");
MODULE_AUTHOR("bbo");
struct nf_hook_ops nfho;
struct nf_hook_ops nfout;

static char * vip=3D"192.168.2.99";
static char server_mac[ETH_ALEN] =3D {0x90,0xFB,0xA6,0x03,0x06,0x61};


static char * client_ip =3D "192.168.2.16";

static char *  rs_ip =3D "192.168.2.245";



#define MY_XMIT(pf, skb, rt)                            \
do {                                                    \
      skb_forward_csum(skb);                          \
      NF_HOOK(pf, NF_INET_LOCAL_OUT , (skb), NULL,    \
              (rt)->u.dst.dev, dst_output);           \
} while (0)

void print_mac_buf(char * buf)
{

      printk("DEST:" MAC_FMT "\n", MAC_ARG(buf));
      printk("SOURCE:" MAC_FMT "\n", MAC_ARG(buf+6));

}


void print_mac(struct ethhdr* eth)
{
      if(eth=3D=3DNULL)   return;

      if(eth->h_source!=3DNULL) printk("SOURCE:" MAC_FMT "\n",
MAC_ARG(eth->h_source));

      if(eth->h_dest!=3DNULL) printk("DEST:" MAC_FMT "\n", MAC_ARG(eth-=
>h_dest));
}


static struct rtable * my_route(int daddr_ip,int  rtos)
{
      struct rtable *rt =3D NULL;/* Route to the other host */
      struct flowi fl =3D {
              .oif =3D 0,
              .nl_u =3D {
                      .ip4_u =3D {
                              .daddr =3D daddr_ip,
                              .saddr =3D 0,
                              .tos =3D rtos, }
              },
      };

      if(ip_route_output_key(&init_net, &rt, &fl))
              return NULL;

      if(rt)
      {
              char * buf;
              struct hh_cache * hh =3D rt->u.dst.hh;
              if(hh)
              {
                      buf =3D hh->hh_data;
                      print_mac_buf(buf+2);
              }
      }

      return rt;
}



int my_xmit(struct sk_buff *skb, int daddr_ip)
{
      struct rtable *rt;                      /* Route to the other hos=
t */
      struct iphdr  *iph =3D ip_hdr(skb);
      int    mtu;


      rt =3D my_route(daddr_ip, RT_TOS(iph->tos));

      if(rt =3D=3D NULL)  return 0;


         /*
       * Call ip_send_check because we are not sure it is called
       * after ip_defrag. Is copy-on-write needed?
       */
      if (unlikely((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NU=
LL)) {
              ip_rt_put(rt);
              return 1;
      }
      ip_send_check(ip_hdr(skb));

      /* drop old route */
      skb_dst_drop(skb);
      skb_dst_set(skb, &rt->u.dst);

      /* Another hack: avoid icmp_send in ip_fragment */
      skb->local_df =3D 1;

      MY_XMIT(NFPROTO_IPV4, skb, rt);

      return 1;
}


unsigned int checksum(unsigned int hooknum,
                      struct sk_buff *__skb,
                      const struct net_device *in,
                      const struct net_device *out,
                      int (*okfn)(struct sk_buff *))
{
      struct sk_buff *skb;
      struct net_device *dev;
      struct iphdr *iph;
      struct tcphdr *tcph;
      int tot_len;
      int iph_len;
      int tcph_len;
      int ret;

      skb =3D __skb;
      if(skb =3D=3D NULL) return NF_ACCEPT;

      iph =3D ip_hdr(skb);
      if(iph =3D=3D NULL)  return NF_ACCEPT;

      if((iph->daddr =3D=3D in_aton(vip)) && (iph->saddr =3D=3D in_aton=
(client_ip)))
      {

              if(my_xmit(skb,in_aton(rs_ip)))
              {
                      printk ("route OK\n");
                      return NF_STOLEN;
              }
              else
              {
                      printk ("route false\n");
              }
      }

      return NF_ACCEPT;
}



unsigned int output(unsigned int hooknum,
                      struct sk_buff *__skb,
                      const struct net_device *in,
                      const struct net_device *out,
                      int (*okfn)(struct sk_buff *))
{
      struct sk_buff *skb;
      struct net_device *dev;
      struct iphdr *iph;
      struct tcphdr *tcph;
      int tot_len;
      int iph_len;
      int tcph_len;
      int ret;

      skb =3D __skb;
      if(skb =3D=3D NULL) return NF_ACCEPT;

      iph =3D ip_hdr(skb);
      if(iph =3D=3D NULL)  return NF_ACCEPT;

      if((iph->daddr =3D=3D in_aton(vip)) && (iph->saddr =3D=3D in_aton=
(client_ip)))
      {
              printk ("In output\n");
      }

      return NF_ACCEPT;
}

static int __init filter_init(void)
{
      int ret;
      nfho.hook =3D checksum;
      nfho.pf =3D AF_INET;
//      nfho.hooknum =3D NF_INET_PRE_ROUTING;
      nfho.hooknum =3D NF_INET_LOCAL_IN;
//      nfho.hooknum =3D NF_IP_PRE_ROUTING;
      nfho.priority =3D NF_IP_PRI_FIRST;


      nfout.hook =3D output;
      nfout.pf =3D AF_INET;
      nfout.hooknum =3D NF_INET_POST_ROUTING;
      nfho.priority =3D NF_IP_PRI_FIRST;

      printk ("Hello,init forward~~~~~~~.\n");

      ret =3D nf_register_hook(&nfho);

      if(ret < 0)
      {
          printk("%s\n", "can't modify skb hook!");
          return ret;
      }

      return 0;
}

static void filter_fini(void)
{
      printk ("Hello,remove forward~~~~~~~.\n");
      nf_unregister_hook(&nfho);
}

module_init(filter_init);
module_exit(filter_fini);


--
Jianzhang Peng
