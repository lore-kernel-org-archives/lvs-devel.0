From: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Runtime interception method switch
Date: Wed, 16 Jan 2008 12:28:21 +0100
Message-ID: <DEEA1E66-8621-43E7-A985-9FD05BE967DE@endian.com>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com> <Pine.LNX.4.64.0801130758580.32303@wm7d.net> <47C3AD3C-1A21-43AC-B109-EE32E8B4B66A@endian.com> <Pine.LNX.4.64.0801140137470.32097@wm7d.net> <20080115082551.GB8826@verge.net.au> <Pine.LNX.4.64.0801150501120.22826@wm7d.net> <20080116075044.GA19249@verge.net.au> <478DE783.5070203@tis.icnet.pl>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Type: multipart/mixed; boundary=Apple-Mail-7-984885792
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <478DE783.5070203@tis.icnet.pl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: LVS Devel <lvs-devel@vger.kernel.org>


--Apple-Mail-7-984885792
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

I've added the documentation for the input_hook switch, and attached  
both patches for net-2.6.25 (i hope the mailer doesn't mess up things  
this time :).

Bye,
Raphael


--Apple-Mail-7-984885792
Content-Disposition: attachment;
	filename=0001-IPVS-Add-choice-for-connection-interception-method.patch
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="0001-IPVS-Add-choice-for-connection-interception-method.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=2031be5b549c946579e322b20d2c388fae0c221bb9=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Raphael=20Vallazza=20<raphael@endian.com>=0A=
Date:=20Sun,=2013=20Jan=202008=2009:29:53=20+0100=0ASubject:=20[PATCH]=20=
[IPVS]=20Add=20choice=20for=20connection=20interception=20method=0A=0A=
This=20patch=20adds=20an=20option=20to=20set=20the=20position=20at=20=
which=20IPVS=20intercepts=0Aincoming=20connections=20from=20Netfilter.=0A=
=0AThe=20options=20are:=0A=0A1.=20INPUT=20(default)=0AIntercept=20=
incoming=20connections=20after=20they=20have=20traveled=20through=0Athe=20=
INPUT=20table,=20only=20connections=20that=20have=20the=20director=20as=0A=
destination=20address=20will=20be=20processed.=0A=0A2.=20FORWARD=0A=
Intercept=20incoming=20connections=20after=20they=20have=20traveled=20=
through=0Athe=20INPUT=20or=20the=20FORWARD=20table.=20It=20has=20the=20=
same=20functionlity=20of=0Athe=20"INPUT=20method",=20but=20also=20=
processes=20connections=20that=20are=0Arouted=20through=20the=20=
director,=20supporting=20VIP-less=20setups.=0A=0A3.=20PREROUTING=0A=
Intercept=20incoming=20connections=20before=20DNAT=20and=20input=20=
filtering=0Ahas=20been=20applied,=20this=20enables=20transparent=20=
proxying=20on=20realnodes=0Aand=20localnode.=0A=0ASigned-off-by:=20=
Raphael=20Vallazza=20<raphael@endian.com>=0A---=0A=20=
net/ipv4/ipvs/Kconfig=20=20=20=20=20=20|=20=20=2044=20=
++++++++++++++++++++++++++++++++++++++++++++=0A=20=
net/ipv4/ipvs/ip_vs_core.c=20|=20=20=2030=20=
+++++++++++++++++++++++++++++-=0A=202=20files=20changed,=2073=20=
insertions(+),=201=20deletions(-)=0A=0Adiff=20--git=20=
a/net/ipv4/ipvs/Kconfig=20b/net/ipv4/ipvs/Kconfig=0Aindex=20=
09d0c3f..319f3e8=20100644=0A---=20a/net/ipv4/ipvs/Kconfig=0A+++=20=
b/net/ipv4/ipvs/Kconfig=0A@@=20-24,6=20+24,50=20@@=20menuconfig=20IP_VS=0A=
=20=0A=20if=20IP_VS=0A=20=0A+choice=0A+=09prompt=20"IPVS=20connection=20=
interception=20method"=0A+=09default=20IP_VS_INPUT_LOCAL_IN=0A+=09help=0A=
+=09=20=20This=20option=20sets=20the=20position=20at=20which=20IPVS=20=
intercepts=20incoming=0A+=09=20=20connections=20from=20Netfilter.=20If=20=
in=20doubt=20select=20'LOCAL_IN'.=0A+=0A+config=20IP_VS_INPUT_LOCAL_IN=0A=
+=09bool=20"INPUT"=0A+=09---help---=0A+=09=20=20Intercept=20incoming=20=
connections=20after=20they=20have=20traveled=20through=0A+=09=20=20the=20=
INPUT=20table,=20only=20connections=20that=20have=20the=20director=20as=0A=
+=09=20=20destination=20address=20will=20be=20processed.=0A+=0A+=09=20=20=
This=20method=20allows=20to=20apply=20packet=20filtering=20in=20the=20=
INPUT=20table=0A+=09=20=20before=20the=20connection=20is=20intercepted=20=
by=20IPVS.=0A+=0A+config=20IP_VS_INPUT_FORWARD=0A+=09bool=20"FORWARD"=0A=
+=09---help---=0A+=09=20=20Intercept=20incoming=20connections=20after=20=
they=20have=20traveled=20through=0A+=09=20=20the=20INPUT=20or=20the=20=
FORWARD=20table.=20It=20has=20the=20same=20functionlity=20of=0A+=09=20=20=
the=20"INPUT=20method",=20but=20also=20processes=20connections=20that=20=
are=0A+=09=20=20routed=20through=20the=20director,=20supporting=20=
VIP-less=20setups.=0A+=0A+=09=20=20This=20method=20allows=20to=20apply=20=
packet=20filtering=20in=20the=20INPUT=20or=0A+=09=20=20FORWARD=20table,=20=
before=20the=20connection=20is=20intercepted=20by=20IPVS.=0A+=0A+config=20=
IP_VS_INPUT_PRE_ROUTING=0A+=09bool=20"PREROUTING"=0A+=09---help---=0A+=09=
=20=20Intercept=20incoming=20connections=20before=20DNAT=20and=20input=20=
filtering=0A+=09=20=20has=20been=20applied,=20this=20allows=20=
transparent=20proxying=20on=20realnodes=0A+=09=20=20and=20localnode.=20=
Incoming=20connections=20are=20intercepted=20right=20after=0A+=09=20=20=
the=20mangle=20PREROUTING=20table=20and=20before=20the=20nat=20=
PREROUTING=20table,=0A+=09=20=20supporting=20VIP-less=20setups.=0A+=0A+=09=
=20=20WARNING:=20This=20method=20doesn't=20apply=20any=20packet=20=
filtering=20before=0A+=09=20=20packets=20are=20intercepted=20by=20IPVS.=20=
To=20filter=20the=20connections=20that=0A+=09=20=20should=20be=20=
intercepted,=20you=20have=20to=20mark=20the=20traffic=20in=20the=0A+=09=20=
=20mangle=20PREROUTING=20table.=0A+=0A+endchoice=0A+=0A=20config=09=
IP_VS_DEBUG=0A=20=09bool=20"IP=20virtual=20server=20debugging"=0A=20=09=
---help---=0Adiff=20--git=20a/net/ipv4/ipvs/ip_vs_core.c=20=
b/net/ipv4/ipvs/ip_vs_core.c=0Aindex=20963981a..0da4ef6=20100644=0A---=20=
a/net/ipv4/ipvs/ip_vs_core.c=0A+++=20b/net/ipv4/ipvs/ip_vs_core.c=0A@@=20=
-1026,6=20+1026,7=20@@=20ip_vs_forward_icmp(unsigned=20int=20hooknum,=20=
struct=20sk_buff=20*skb,=0A=20=0A=20=0A=20static=20struct=20nf_hook_ops=20=
ip_vs_ops[]=20__read_mostly=20=3D=20{=0A+#if=20=
defined(CONFIG_IP_VS_INPUT_LOCAL_IN)=20||=20=
defined(CONFIG_IP_VS_INPUT_FORWARD)=0A=20=09/*=20After=20packet=20=
filtering,=20forward=20packet=20through=20VS/DR,=20VS/TUN,=0A=20=09=20*=20=
or=20VS/NAT(change=20destination),=20so=20that=20filtering=20rules=20can=20=
be=0A=20=09=20*=20applied=20to=20IPVS.=20*/=0A@@=20-1036,6=20+1037,33=20=
@@=20static=20struct=20nf_hook_ops=20ip_vs_ops[]=20__read_mostly=20=3D=20=
{=0A=20=09=09.hooknum=20=20=20=20=20=20=20=20=3D=20NF_INET_LOCAL_IN,=0A=20=
=09=09.priority=20=20=20=20=20=20=20=3D=20100,=0A=20=09},=0A+#endif=0A=
+#ifdef=20CONFIG_IP_VS_INPUT_FORWARD=0A+=09/*=20Intercept=20incoming=20=
connections=20after=20they=20have=20traveled=20through=0A+=09=20*=20the=20=
INPUT=20or=20the=20FORWARD=20table.=20It=20has=20the=20same=20=
functionlity=20of=0A+=09=20*=20the=20"INPUT=20method",=20but=20also=20=
processes=20connections=20that=20are=0A+=09=20*=20routed=20through=20the=20=
director,=20supporting=20VIP-less=20setups.=20*/=0A+=09{=0A+=09=09.hook=09=
=09=3D=20ip_vs_in,=0A+=09=09.owner=09=09=3D=20THIS_MODULE,=0A+=09=09.pf=09=
=09=3D=20PF_INET,=0A+=09=09.hooknum=20=20=20=20=20=20=20=20=3D=20=
NF_INET_FORWARD,=0A+=09=09.priority=20=20=20=20=20=20=20=3D=2098,=0A+=09=
},=0A+#endif=0A+#ifdef=20CONFIG_IP_VS_INPUT_PRE_ROUTING=0A+=09/*=20=
Intercept=20incoming=20connections=20before=20DNAT=20and=20input=20=
filtering=0A+=09=20*=20has=20been=20applied,=20this=20enables=20=
ransparent=20proxying=20on=20realnodes=0A+=09=20*=20and=20localnode.=20=
Hook=20right=20after=20MANGLE=20and=20before=20NAT_DST.=0A+=09=20*/=0A+=09=
{=0A+=09=09.hook=20=20=20=20=20=20=20=20=20=20=20=3D=20ip_vs_in,=0A+=09=09=
.owner=20=20=20=20=20=20=20=20=20=20=3D=20THIS_MODULE,=0A+=09=09.pf=20=20=
=20=20=20=20=20=20=20=20=20=20=20=3D=20PF_INET,=0A+=09=09.hooknum=20=20=20=
=20=20=20=20=20=3D=20NF_INET_PRE_ROUTING,=0A+=09=09.priority=20=20=20=20=20=
=20=20=3D=20NF_IP_PRI_NAT_DST=20-=201,=0A+=09},=0A+#endif=0A=20=09/*=20=
After=20packet=20filtering,=20change=20source=20only=20for=20VS/NAT=20*/=0A=
=20=09{=0A=20=09=09.hook=09=09=3D=20ip_vs_out,=0A@@=20-1059,7=20+1087,7=20=
@@=20static=20struct=20nf_hook_ops=20ip_vs_ops[]=20__read_mostly=20=3D=20=
{=0A=20=09=09.owner=09=09=3D=20THIS_MODULE,=0A=20=09=09.pf=09=09=3D=20=
PF_INET,=0A=20=09=09.hooknum=20=20=20=20=20=20=20=20=3D=20=
NF_INET_POST_ROUTING,=0A-=09=09.priority=20=20=20=20=20=20=20=3D=20=
NF_IP_PRI_NAT_SRC-1,=0A+=09=09.priority=20=20=20=20=20=20=20=3D=20=
NF_IP_PRI_NAT_SRC=20-=201,=0A=20=09},=0A=20};=0A=20=0A--=20=0A1.5.3.7=0A=0A=

--Apple-Mail-7-984885792
Content-Disposition: attachment;
	filename=0002-IPVS-Runtime-interception-method-switch.patch
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="0002-IPVS-Runtime-interception-method-switch.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=20918801f6b9233ed26ffe8cd0a4ea1ebdb4fc588b=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Raphael=20Vallazza=20<raphael@endian.com>=0A=
Date:=20Wed,=2016=20Jan=202008=2012:23:59=20+0100=0ASubject:=20[PATCH]=20=
[IPVS]:=20Runtime=20interception=20method=20switch=0A=0A=20=20=20=20This=20=
patch=20allows=20to=20switch=20interception=20method=20at=20runtime=20by=20=
changing=0A=20=20=20=20the=20value=20of=20=
/proc/sys/net/ipv4/vs/input_hook=20with=20one=20of=20the=20following=0A=20=
=20=20=20values:=0A=20=20=20=200=20=09-=20INPUT=20(default)=0A=20=20=20=20=
1=09-=20FORWARD=0A=20=20=20=202=09-=20PREROUTING=0A=0ASigned-off-by:=20=
Raphael=20Vallazza=20<raphael@endian.com>=0A---=0A=20=
Documentation/networking/ipvs-sysctl.txt=20|=20=20=2027=20++++++=0A=20=
include/net/ip_vs.h=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20|=20=20=2015=20+++=0A=20net/ipv4/ipvs/Kconfig=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20|=20=20=2010=20++-=0A=20=
net/ipv4/ipvs/ip_vs_core.c=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20|=20=
=20141=20+++++++++++++++++++++++++-----=0A=20net/ipv4/ipvs/ip_vs_ctl.c=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20|=20=20=2043=20+++++++++=0A=20=
5=20files=20changed,=20213=20insertions(+),=2023=20deletions(-)=0A=0A=
diff=20--git=20a/Documentation/networking/ipvs-sysctl.txt=20=
b/Documentation/networking/ipvs-sysctl.txt=0Aindex=204ccdbca..3f15b8f=20=
100644=0A---=20a/Documentation/networking/ipvs-sysctl.txt=0A+++=20=
b/Documentation/networking/ipvs-sysctl.txt=0A@@=20-112,6=20+112,33=20@@=20=
expire_quiescent_template=20-=20BOOLEAN=0A=20=09persistence=20template=20=
if=20it=20is=20to=20be=20used=20to=20schedule=20a=20new=0A=20=09=
connection=20and=20the=20destination=20server=20is=20quiescent.=0A=20=0A=
+input_hook=20-=20INTEGER=0A+=090=20=09-=20INPUT=20(default)=0A+=091=09-=20=
FORWARD=0A+=092=09-=20PREROUTING=0A+=09=0A+=09This=20switch=20sets=20the=20=
interception=20method=20used=20by=20IPVS=20for=0A+=09intercepting=20=
incoming=20connections.=0A+=0A+=09INPUT=20-=20Intercept=20incoming=20=
connections=20after=20they=20have=20traveled=0A+=09through=20the=20INPUT=20=
table,=20only=20connections=20that=20have=20the=20director=20as=0A+=09=
destination=20address=20will=20be=20processed.=0A+=0A+=09FORWARD=20-=20=
Intercept=20incoming=20connections=20after=20they=20have=20traveled=0A+=09=
through=20the=20INPUT=20or=20the=20FORWARD=20table.=20It=20has=20the=20=
same=20functionlity=0A+=09of=20the=20"INPUT=20method",=20but=20also=20=
processes=20connections=20that=20are=0A+=09routed=20through=20the=20=
director,=20supporting=20VIP-less=20setups.=0A+=0A+=09PREROUTING=20-=20=
Intercept=20incoming=20connections=20before=20DNAT=20and=20input=0A+=09=
filtering=20has=20been=20applied,=20this=20allows=20transparent=20=
proxying=20on=0A+=09realnodes=20and=20localnode.=20Incoming=20=
connections=20are=20intercepted=20right=0A+=09after=20the=20mangle=20=
PREROUTING=20table=20and=20before=20the=20nat=20PREROUTING=0A+=09table,=20=
supporting=20VIP-less=20setups.=0A+=09WARNING:=20This=20method=20doesn't=20=
apply=20any=20packet=20filtering=20before=0A+=09packets=20are=20=
intercepted=20by=20IPVS.=20To=20filter=20the=20connections=20that=0A+=09=
should=20be=20intercepted,=20you=20have=20to=20mark=20the=20traffic=20in=20=
the=0A+=09mangle=20PREROUTING=20table.=0A+=0A=20nat_icmp_send=20-=20=
BOOLEAN=0A=20=20=20=20=20=20=20=20=200=20-=20disabled=20(default)=0A=20=20=
=20=20=20=20=20=20=20not=200=20-=20enabled=0Adiff=20--git=20=
a/include/net/ip_vs.h=20b/include/net/ip_vs.h=0Aindex=2056f3c94..6b71e31=20=
100644=0A---=20a/include/net/ip_vs.h=0A+++=20b/include/net/ip_vs.h=0A@@=20=
-681,6=20+681,21=20@@=20extern=20void=20ip_vs_init_hash_table(struct=20=
list_head=20*table,=20int=20rows);=0A=20#define=20IP_VS_APP_TYPE_FTP=091=0A=
=20=0A=20/*=0A+=20*=09IPVS=20input=20hook=20functions=0A+=20*/=0A+enum=20=
{=0A+=09IP_VS_INPUT_HOOK_FIRST=20=3D=20-1,=0A+=09=
IP_VS_INPUT_HOOK_LOCAL_IN,=0A+=09IP_VS_INPUT_HOOK_FORWARD,=0A+=09=
IP_VS_INPUT_HOOK_PRE_ROUTING,=0A+=09IP_VS_INPUT_HOOK_LAST,=0A+};=0A+=0A=
+extern=20int=20ip_vs_get_input_hook(void);=0A+extern=20int=20=
ip_vs_register_hooks(int=20input_hook);=0A+extern=20int=20=
ip_vs_unregister_hooks(int=20input_hook);=0A+=0A+/*=0A=20=20*=20=20=20=20=
=20ip_vs_conn=20handling=20functions=0A=20=20*=20=20=20=20=20(from=20=
ip_vs_conn.c)=0A=20=20*/=0Adiff=20--git=20a/net/ipv4/ipvs/Kconfig=20=
b/net/ipv4/ipvs/Kconfig=0Aindex=20319f3e8..19217d7=20100644=0A---=20=
a/net/ipv4/ipvs/Kconfig=0A+++=20b/net/ipv4/ipvs/Kconfig=0A@@=20-28,8=20=
+28,14=20@@=20choice=0A=20=09prompt=20"IPVS=20connection=20interception=20=
method"=0A=20=09default=20IP_VS_INPUT_LOCAL_IN=0A=20=09help=0A-=09=20=20=
This=20option=20sets=20the=20position=20at=20which=20IPVS=20intercepts=20=
incoming=0A-=09=20=20connections=20from=20Netfilter.=20If=20in=20doubt=20=
select=20'LOCAL_IN'.=0A+=09=20=20This=20option=20selects=20the=20default=20=
position=20at=20which=20IPVS=20intercepts=0A+=09=20=20incoming=20=
connections=20from=20Netfilter.=20If=20in=20doubt=20select=20'INPUT'.=0A=
+=09=0A+=09=20=20The=20interception=20method=20can=20be=20switched=20at=20=
runtime=20in=20=0A+=09=20=20/proc/sys/net/ipv4/vs/input_hook=20with=20=
the=20following=20values:=0A+=09=20=20=20=200=20=3D=20INPUT=0A+=09=20=20=20=
=201=20=3D=20FORWARD=0A+=09=20=20=20=202=20=3D=20PREROUTING=09=20=20=0A=20=
=0A=20config=20IP_VS_INPUT_LOCAL_IN=0A=20=09bool=20"INPUT"=0Adiff=20=
--git=20a/net/ipv4/ipvs/ip_vs_core.c=20b/net/ipv4/ipvs/ip_vs_core.c=0A=
index=200da4ef6..6acfbbd=20100644=0A---=20a/net/ipv4/ipvs/ip_vs_core.c=0A=
+++=20b/net/ipv4/ipvs/ip_vs_core.c=0A@@=20-1024,12=20+1024,111=20@@=20=
ip_vs_forward_icmp(unsigned=20int=20hooknum,=20struct=20sk_buff=20*skb,=0A=
=20=09return=20ip_vs_in_icmp(skb,=20&r,=20hooknum);=0A=20}=0A=20=0A+/*=0A=
+=20*=20Register=20netfilter=20hook=20based=20on=20input_hook=20type=0A+=20=
*/=0A+=0A+int=20ip_vs_register_hooks(int=20input_hook)=0A+{=0A+=09int=20=
ret;=0A+=09char=20*hookstr;=0A+=09struct=20nf_hook_ops=20*in_hooks;=0A+=09=
int=20count;=0A+=0A+=09IP_VS_DBG(5,=20"Registering=20input=20hooks:=20=
%i\n",=20input_hook);=0A+=0A+=09switch=20(input_hook)=20{=0A+=09case=20=
IP_VS_INPUT_HOOK_LOCAL_IN:=0A+=09=09hookstr=20=3D=20"INPUT";=0A+=09=09=
in_hooks=20=3D=20ip_vs_ops_local_in;=0A+=09=09count=20=3D=20=
ARRAY_SIZE(ip_vs_ops_local_in);=0A+=09=09break;=0A+=09case=20=
IP_VS_INPUT_HOOK_FORWARD:=0A+=09=09hookstr=20=3D=20"FORWARD";=0A+=09=09=
in_hooks=20=3D=20ip_vs_ops_forward;=0A+=09=09count=20=3D=20=
ARRAY_SIZE(ip_vs_ops_forward);=0A+=09=09break;=0A+=09case=20=
IP_VS_INPUT_HOOK_PRE_ROUTING:=0A+=09=09hookstr=20=3D=20"PREROUTING";=0A+=09=
=09in_hooks=20=3D=20ip_vs_ops_pre_routing;=0A+=09=09count=20=3D=20=
ARRAY_SIZE(ip_vs_ops_pre_routing);=0A+=09=09break;=0A+=09default:=0A+=09=09=
return=20-1;=0A+=09}=0A+=0A+=09ret=20=3D=20nf_register_hooks(in_hooks,=20=
count);=0A+=09if=20(ret=20<=200)=20{=0A+=09=09IP_VS_ERR("Can't=20=
register=20%s=20hooks.\n",=20hookstr);=0A+=09=09return=20-1;=0A+=09}=0A+=0A=
+=09ret=20=3D=20nf_register_hooks(ip_vs_ops_generic,=0A+=09=09=09=09=
ARRAY_SIZE(ip_vs_ops_generic));=0A+=09if=20(ret=20<=200)=20{=0A+=09=09=
nf_unregister_hooks(in_hooks,=20count);=0A+=09=09IP_VS_ERR("Can't=20=
register=20generic=20hooks.\n");=0A+=09=09return=20-1;=0A+=09}=0A+=0A+=09=
IP_VS_INFO("Registered=20interception=20method:=20%s\n",=20hookstr);=0A+=09=
return=200;=0A+}=0A+=0A+/*=0A+=20*=20Unregister=20netfilter=20hook=20=
based=20on=20input_hook=20type=0A+=20*/=0A=20=0A-static=20struct=20=
nf_hook_ops=20ip_vs_ops[]=20__read_mostly=20=3D=20{=0A-#if=20=
defined(CONFIG_IP_VS_INPUT_LOCAL_IN)=20||=20=
defined(CONFIG_IP_VS_INPUT_FORWARD)=0A-=09/*=20After=20packet=20=
filtering,=20forward=20packet=20through=20VS/DR,=20VS/TUN,=0A-=09=20*=20=
or=20VS/NAT(change=20destination),=20so=20that=20filtering=20rules=20can=20=
be=0A-=09=20*=20applied=20to=20IPVS.=20*/=0A+int=20=
ip_vs_unregister_hooks(int=20input_hook)=0A+{=0A+=09struct=20nf_hook_ops=20=
*in_hooks;=0A+=09int=20count;=0A+=0A+=09IP_VS_DBG(5,=20"Unregistering=20=
input=20hooks:=20%i\n",=20input_hook);=0A+=0A+=09switch=20(input_hook)=20=
{=0A+=09case=20IP_VS_INPUT_HOOK_LOCAL_IN:=0A+=09=09in_hooks=20=3D=20=
ip_vs_ops_local_in;=0A+=09=09count=20=3D=20=
ARRAY_SIZE(ip_vs_ops_local_in);=0A+=09=09break;=0A+=09case=20=
IP_VS_INPUT_HOOK_FORWARD:=0A+=09=09in_hooks=20=3D=20ip_vs_ops_forward;=0A=
+=09=09count=20=3D=20ARRAY_SIZE(ip_vs_ops_forward);=0A+=09=09break;=0A+=09=
case=20IP_VS_INPUT_HOOK_PRE_ROUTING:=0A+=09=09in_hooks=20=3D=20=
ip_vs_ops_pre_routing;=0A+=09=09count=20=3D=20=
ARRAY_SIZE(ip_vs_ops_pre_routing);=0A+=09=09break;=0A+=09default:=0A+=09=09=
return=20-1;=0A+=09}=0A+=0A+=09nf_unregister_hooks(in_hooks,=20count);=0A=
+=09nf_unregister_hooks(ip_vs_ops_generic,=20=
ARRAY_SIZE(ip_vs_ops_generic));=0A+=0A+=09IP_VS_DBG(5,=20"Unregistered=20=
input=20hooks.\n");=0A+=09return=200;=0A+}=0A+=0A+=0A+/*=20After=20=
packet=20filtering,=20forward=20packet=20through=20VS/DR,=20VS/TUN,=0A+=20=
*=20or=20VS/NAT(change=20destination),=20so=20that=20filtering=20rules=20=
can=20be=0A+=20*=20applied=20to=20IPVS.=20*/=0A+static=20struct=20=
nf_hook_ops=20ip_vs_ops_local_in[]=20__read_mostly=20=3D=20{=0A+=09{=0A+=09=
=09.hook=09=09=3D=20ip_vs_in,=0A+=09=09.owner=09=09=3D=20THIS_MODULE,=0A=
+=09=09.pf=09=09=3D=20PF_INET,=0A+=09=09.hooknum=20=20=20=20=20=20=20=20=
=3D=20NF_INET_LOCAL_IN,=0A+=09=09.priority=20=20=20=20=20=20=20=3D=20=
100,=0A+=09},=0A+};=0A+=0A+/*=20Intercept=20incoming=20connections=20=
after=20they=20have=20traveled=20through=0A+=20*=20the=20INPUT=20or=20=
the=20FORWARD=20table.=20It=20has=20the=20same=20functionlity=20of=0A+=20=
*=20the=20"INPUT=20method",=20but=20also=20processes=20connections=20=
that=20are=0A+=20*=20routed=20through=20the=20director,=20supporting=20=
VIP-less=20setups.=20*/=0A+static=20struct=20nf_hook_ops=20=
ip_vs_ops_forward[]=20__read_mostly=20=3D=20{=0A=20=09{=0A=20=09=09.hook=09=
=09=3D=20ip_vs_in,=0A=20=09=09.owner=09=09=3D=20THIS_MODULE,=0A@@=20=
-1037,12=20+1136,6=20@@=20static=20struct=20nf_hook_ops=20ip_vs_ops[]=20=
__read_mostly=20=3D=20{=0A=20=09=09.hooknum=20=20=20=20=20=20=20=20=3D=20=
NF_INET_LOCAL_IN,=0A=20=09=09.priority=20=20=20=20=20=20=20=3D=20100,=0A=20=
=09},=0A-#endif=0A-#ifdef=20CONFIG_IP_VS_INPUT_FORWARD=0A-=09/*=20=
Intercept=20incoming=20connections=20after=20they=20have=20traveled=20=
through=0A-=09=20*=20the=20INPUT=20or=20the=20FORWARD=20table.=20It=20=
has=20the=20same=20functionlity=20of=0A-=09=20*=20the=20"INPUT=20=
method",=20but=20also=20processes=20connections=20that=20are=0A-=09=20*=20=
routed=20through=20the=20director,=20supporting=20VIP-less=20setups.=20=
*/=0A=20=09{=0A=20=09=09.hook=09=09=3D=20ip_vs_in,=0A=20=09=09.owner=09=09=
=3D=20THIS_MODULE,=0A@@=20-1050,12=20+1143,13=20@@=20static=20struct=20=
nf_hook_ops=20ip_vs_ops[]=20__read_mostly=20=3D=20{=0A=20=09=09.hooknum=20=
=20=20=20=20=20=20=20=3D=20NF_INET_FORWARD,=0A=20=09=09.priority=20=20=20=
=20=20=20=20=3D=2098,=0A=20=09},=0A-#endif=0A-#ifdef=20=
CONFIG_IP_VS_INPUT_PRE_ROUTING=0A-=09/*=20Intercept=20incoming=20=
connections=20before=20DNAT=20and=20input=20filtering=0A-=09=20*=20has=20=
been=20applied,=20this=20enables=20ransparent=20proxying=20on=20=
realnodes=0A-=09=20*=20and=20localnode.=20Hook=20right=20after=20MANGLE=20=
and=20before=20NAT_DST.=0A-=09=20*/=0A+};=0A+=0A+/*=20Intercept=20=
incoming=20connections=20before=20DNAT=20and=20input=20filtering=0A+=20*=20=
has=20been=20applied,=20this=20enables=20ransparent=20proxying=20on=20=
realnodes=0A+=20*=20and=20localnode.=20Hook=20right=20after=20MANGLE=20=
and=20before=20NAT_DST.=0A+=20*/=0A+static=20struct=20nf_hook_ops=20=
ip_vs_ops_pre_routing[]=20__read_mostly=20=3D=20{=0A=20=09{=0A=20=09=09=
.hook=20=20=20=20=20=20=20=20=20=20=20=3D=20ip_vs_in,=0A=20=09=09.owner=20=
=20=20=20=20=20=20=20=20=20=3D=20THIS_MODULE,=0A@@=20-1063,7=20+1157,13=20=
@@=20static=20struct=20nf_hook_ops=20ip_vs_ops[]=20__read_mostly=20=3D=20=
{=0A=20=09=09.hooknum=20=20=20=20=20=20=20=20=3D=20NF_INET_PRE_ROUTING,=0A=
=20=09=09.priority=20=20=20=20=20=20=20=3D=20NF_IP_PRI_NAT_DST=20-=201,=0A=
=20=09},=0A-#endif=0A+};=0A+=0A+/*=0A+=20*=20Generic=20Netfilter=20hooks=20=
required=20for=20all=20the=20input=20methods=0A+=20*/=0A+=0A+static=20=
struct=20nf_hook_ops=20ip_vs_ops_generic[]=20__read_mostly=20=3D=20{=0A=20=
=09/*=20After=20packet=20filtering,=20change=20source=20only=20for=20=
VS/NAT=20*/=0A=20=09{=0A=20=09=09.hook=09=09=3D=20ip_vs_out,=0A@@=20=
-1119,9=20+1219,8=20@@=20static=20int=20__init=20ip_vs_init(void)=0A=20=09=
=09goto=20cleanup_app;=0A=20=09}=0A=20=0A-=09ret=20=3D=20=
nf_register_hooks(ip_vs_ops,=20ARRAY_SIZE(ip_vs_ops));=0A+=09ret=20=3D=20=
ip_vs_register_hooks(ip_vs_get_input_hook());=0A=20=09if=20(ret=20<=200)=20=
{=0A-=09=09IP_VS_ERR("can't=20register=20hooks.\n");=0A=20=09=09goto=20=
cleanup_conn;=0A=20=09}=0A=20=0A@@=20-1141,7=20+1240,7=20@@=20static=20=
int=20__init=20ip_vs_init(void)=0A=20=0A=20static=20void=20__exit=20=
ip_vs_cleanup(void)=0A=20{=0A-=09nf_unregister_hooks(ip_vs_ops,=20=
ARRAY_SIZE(ip_vs_ops));=0A+=09=
ip_vs_unregister_hooks(ip_vs_get_input_hook());=0A=20=09=
ip_vs_conn_cleanup();=0A=20=09ip_vs_app_cleanup();=0A=20=09=
ip_vs_protocol_cleanup();=0Adiff=20--git=20a/net/ipv4/ipvs/ip_vs_ctl.c=20=
b/net/ipv4/ipvs/ip_vs_ctl.c=0Aindex=2094c5767..1e05c54=20100644=0A---=20=
a/net/ipv4/ipvs/ip_vs_ctl.c=0A+++=20b/net/ipv4/ipvs/ip_vs_ctl.c=0A@@=20=
-82,6=20+82,15=20@@=20int=20sysctl_ip_vs_expire_quiescent_template=20=3D=20=
0;=0A=20int=20sysctl_ip_vs_sync_threshold[2]=20=3D=20{=203,=2050=20};=0A=20=
int=20sysctl_ip_vs_nat_icmp_send=20=3D=200;=0A=20=0A+#ifdef=20=
CONFIG_IP_VS_INPUT_LOCAL_IN=0A+static=20int=20sysctl_ip_vs_input_hook=20=
=3D=20IP_VS_INPUT_HOOK_LOCAL_IN;=0A+#endif=0A+#ifdef=20=
CONFIG_IP_VS_INPUT_FORWARD=0A+static=20int=20sysctl_ip_vs_input_hook=20=3D=
=20IP_VS_INPUT_HOOK_FORWARD;=0A+#endif=0A+#ifdef=20=
CONFIG_IP_VS_INPUT_PRE_ROUTING=0A+static=20int=20sysctl_ip_vs_input_hook=20=
=3D=20IP_VS_INPUT_HOOK_PRE_ROUTING;=0A+#endif=0A=20=0A=20#ifdef=20=
CONFIG_IP_VS_DEBUG=0A=20static=20int=20sysctl_ip_vs_debug_level=20=3D=20=
0;=0A@@=20-92,6=20+101,11=20@@=20int=20ip_vs_get_debug_level(void)=0A=20=
}=0A=20#endif=0A=20=0A+int=20ip_vs_get_input_hook(void)=0A+{=0A+=09=
return=20sysctl_ip_vs_input_hook;=0A+}=0A+=0A=20/*=0A=20=20*=09=
update_defense_level=20is=20called=20from=20keventd=20and=20from=20=
sysctl,=0A=20=20*=09so=20it=20needs=20to=20protect=20itself=20from=20=
softirqs=0A@@=20-1376,6=20+1390,28=20@@=20static=20int=20=
ip_vs_zero_all(void)=0A=20=09return=200;=0A=20}=0A=20=0A+static=20int=0A=
+proc_do_input_hook(struct=20ctl_table=20*table,=20int=20write,=20struct=20=
file=20*filp,=0A+=09=09=20=20=20void=20__user=20*buffer,=20size_t=20=
*lenp,=20loff_t=20*ppos)=0A+{=0A+=09char=20*valp=20=3D=20table->data;=0A=
+=09int=20oldval=20=3D=20*valp;=0A+=09int=20rc;=0A+=0A+=09rc=20=3D=20=
proc_dointvec(table,=20write,=20filp,=20buffer,=20lenp,=20ppos);=0A+=09=
if=20(write=20&&=20(*valp=20!=3D=20oldval))=20{=0A+=09=09if=20((*valp=20=
<=3D=20IP_VS_INPUT_HOOK_FIRST)=20||=0A+=09=09=20=20=20=20(*valp=20>=3D=20=
IP_VS_INPUT_HOOK_LAST))=20{=0A+=09=09=09IP_VS_ERR("Invalid=20input=20=
hook=20value:=20%i\n",=20*valp);=0A+=09=09=09*valp=20=3D=20oldval;=0A+=09=
=09}=20else=20{=0A+=09=09=09/*=20unregister=20old=20and=20register=20new=20=
input=20hooks=20*/=0A+=09=09=09ip_vs_unregister_hooks(oldval);=0A+=09=09=09=
ip_vs_register_hooks(*valp);=0A+=09=09}=0A+=09}=0A+=09return=20rc;=0A+}=0A=
=20=0A=20static=20int=0A=20proc_do_defense_mode(ctl_table=20*table,=20=
int=20write,=20struct=20file=20*=20filp,=0A@@=20-1430,6=20+1466,13=20@@=20=
static=20struct=20ctl_table=20vs_vars[]=20=3D=20{=0A=20=09=09.mode=09=09=
=3D=200644,=0A=20=09=09.proc_handler=09=3D=20&proc_dointvec,=0A=20=09},=0A=
+=09{=0A+=09=09.procname=09=3D=20"input_hook",=0A+=09=09.data=09=09=3D=20=
&sysctl_ip_vs_input_hook,=0A+=09=09.maxlen=09=09=3D=20sizeof(int),=0A+=09=
=09.mode=09=09=3D=200644,=0A+=09=09.proc_handler=09=3D=20=
&proc_do_input_hook,=0A+=09},=0A=20#ifdef=20CONFIG_IP_VS_DEBUG=0A=20=09{=0A=
=20=09=09.procname=09=3D=20"debug_level",=0A--=20=0A1.5.3.7=0A=0A=

--Apple-Mail-7-984885792
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit


Am 16.01.2008 um 12:16 schrieb Janusz Krzysztofik:

> Simon Horman wrote:
>> On Tue, Jan 15, 2008 at 05:13:14AM -0800, Joseph Mack NA3T wrote:
>>> What side effects might there be? Are they worse than not being  
>>> able to NAT packets emerging from a director?
>> I'm not sure, and thats what concerns me.
>> For starters could we clarify that the patch in question is the
>> following one by Janusz Krzysztofik?
>> Also can I clarify that the aim is to be able to SNAT LVS-DR
>> connections ...
>
> Hi,
>
> I can confirm what I have already said before: this patch works for  
> me (now for over two years) without any unexpected side effects. The  
> only side effect I can see is that all LVS-DR incoming packets go  
> through conntrack, even if you do not intend to SNAT them. That  
> could present excessive load on ancient hardware, but one can just  
> unload conntrack modules, or turn connection tracking off for  
> specific traffic with PREROUTING raw hook rules.
> However, I think this patch should be considered, if at all, as a  
> temporary solution.
>
> Thanks,
> Janusz
>
> PS. I am still busy with a different project, but subscribed to lvs- 
> devel.
> -
> To unsubscribe from this list: send the line "unsubscribe lvs-devel"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

:: e n d i a n
:: open source - open minds

:: raphael vallazza
:: phone +39 0471 631763  :: fax +39 0471 631764
:: http://www.endian.com  :: raphael (AT) endian.com


--Apple-Mail-7-984885792--
