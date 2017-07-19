From: Julian Anastasov <ja@ssi.bg>
Subject: Re: LVS TCP package fragment
Date: Wed, 19 Jul 2017 10:25:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1707191016360.2130@ja.home.ssi.bg>
References: <CAGpjB9LEJrVUmdhe-mV+y7VaXwinyHCN0w9Y36gQEYy34mpWpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="-1463811672-1162392699-1500449117=:2130"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAGpjB9LEJrVUmdhe-mV+y7VaXwinyHCN0w9Y36gQEYy34mpWpg@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: =?UTF-8?B?5p2O5pil?= <pickup112@gmail.com>
Cc: lvs-devel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1162392699-1500449117=:2130
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Mon, 17 Jul 2017, 李春 wrote:

> I have meet a very strange problem in my LVS environment.
> 
> 
> when I connect to mysqld real server, mysql client is ok.
> when I connect to LVS to access to the real server, mysql client report error.
> 
> 
> I config the LVS as DR mode like this:
> ```
> ipvsadm -A -t 158.222.165.185:3306 -s wrr
> ipvsadm -a -t 158.222.165.185:3306 -r 158.222.165.125:3306 -g -w 100
> ```
> 
> 
> 
> And I have tcpdump the package on the LVS and real server.
> Sync/Sync+ack/ack of Three-way Handshake is ok，and four-way handshake is ok.
> But when mysql client send the login request (user/password) package,
> the package fragment.
> 
> 
> As show as follows,The LVS received the package and send it the real
> server correct(length 252).
> But real server get a fragment of the package (length 248) and a error
> chksum. It have missed the 4 bytes fragment of the package.
> 
> 
> Here is the package I have ```tcpdump -lnnneeevvv``` on the LVS.
> * 9c:dc:71:4d:49:d0 = 158.222.165.126 is the client
> * 24:8a:07:64:7f:21 = 158.222.165.185 is the VIP and the director
> * 24:8a:07:64:56:41 = 158.222.165.185 is the real server
> 
> 
> LVS package:
> ```
> 19:12:22.229356 9c:dc:71:4d:49:d0 > 24:8a:07:64:7f:21, ethertype IPv4
> (0x0800), length 252: (tos 0x8, ttl 64, id 56669, offset 0, flags
> [DF], proto TCP (6), l
>     158.222.165.126.37691 > 158.222.165.185.3306: Flags [P.], cksum
> 0x5d97 (correct), seq 0:198, ack 83, win 115, length 198
> 19:12:22.229367 24:8a:07:64:7f:21 > 24:8a:07:64:56:41, ethertype IPv4
> (0x0800), length 252: (tos 0x8, ttl 64, id 56669, offset 0, flags
> [DF], proto TCP (6), l
>     158.222.165.126.37691 > 158.222.165.185.3306: Flags [P.], cksum
> 0x5d97 (correct), seq 0:198, ack 83, win 115, length 198
> ```
> 
> 
> real server packages:
> ```
> 19:12:21.803118 24:8a:07:64:7f:21 > 24:8a:07:64:56:41, ethertype IPv4
> (0x0800), length 248: (tos 0x8, ttl 64, id 56668, offset 0, flags
> [DF], proto TCP (6), l
>     158.222.165.126.37691 > 158.222.165.185.3306: Flags [.], cksum
> 0x5d97 (incorrect -> 0x4883), seq 1:195, ack 83, win 115, length 194
> 19:12:21.803126 24:8a:07:64:7f:21 > 24:8a:07:64:56:41, ethertype IPv4
> (0x0800), length 60: (tos 0x8, ttl 64, id 56669, offset 0, flags [DF],
> proto TCP (6), le
>     158.222.165.126.37691 > 158.222.165.185.3306: Flags [P.], cksum
> 0x7973 (incorrect -> 0x5fb3), seq 199, ack 83, win 115, length 0
> ```
> 
> 
> 
> * we run the test on rhel6.7 with ipvsadm v1.26 2008/5/15 (compiled
> with popt and IPVS v1.2.1)
> * our network engineer have mirror the port of LVS and report that the
> package is fragmented from LVS director.
> * we have replace the broadcom network card to mellanox netword card,
> but it still the same problem
> 
> 
> And I have not config net.ipv4.ip_forward = 1 accord to
> http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-DR.html
> But if I config "net.ipv4.ip_forward = 1 ", there are no package
> fragment. MySQL connect to mysqld (throught LVS) successfully.
> 
> 
> Have any one meet the problem, do you resolve it ? Or any one can help
> to fix it.

	There can be a problem with fragments but your
tcpdump output does not show such fragments, even in
previous emails. According to 'man tcpdump':

Fragmented Internet datagrams are printed as
	(frag id:size@offset+)
	(frag id:size@offset)

	What exactly is the kernel version (uname -a) ?
You can use such minimum options: tcpdump -s0 -lennn -vvv ...

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1162392699-1500449117=:2130--
