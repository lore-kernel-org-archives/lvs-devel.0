From: Ye Yin <hustcat@gmail.com>
Subject: ipvs problem with container
Date: Wed, 25 Oct 2017 18:06:47 +0800
Message-ID: <CAK-cHazJX03jwFkcfFz2Xtin82f3jhnvMVU_QdK+qeSXXVNWsw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=LxXvIAXcZiuBAkd+fD07ebkvLEwAmYR4kWPjszoe0f0=;
        b=bIhzvemLzT9nPfB0xygGLtYZ5rXH6mUvKnHmKaESLuayY8vgM1YhiwcPE7DPV9R1sP
         011sBFEouNo1tocddXzB/CTo0TY+klHjr7Xh4w+rxq1+ZDtm8byYjghgDOJJk44r5m+g
         U5kmiidZqdF0fUr1Cu4QtfLBP9XUcPuQQxqzv42f9oRTbRM+PwXygxYSGurOYR6fWqr8
         UfPfybpSxPB6ZmJ+IOef1QJsHpJqFicJT6nhRqalaMbMFBikzZBIlOpMmgvUDreiGevk
         qNYPSxX/ZQ+iuOXCzIpxo6BG1q1juPmnYKP8erEwxUQUzCaZBSRnkR8Ma3QgpCmCdNjB
         r+Iw==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Hi, all,

We run ipvs at host and container in the same host at the same time,
and ipvs at host will transport network traffic to ipvs in the
container. Then some problem happended to us, the detail is as
follows:


 ________________              _____________
|                       ___|___      |container1        |
| host bridge     |_vethA_|----|192.168.1.232  |
|192.168.1.193/26  |             |____________|
|                       ___|___        _____________
|                      |_vethB_|----|container2        |
|________________|            |192.168.1.233  |
                                            |_____________|

container1 and container2 connected each other by bridge on the host,
which is the gateway of the two containers. Run ipvs on the host with
VIP 172.17.169.208.

host:
$ ipvsadm -l -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.17.169.208:80 rr
  -> 192.168.1.233:80             Masq    1      0          0

container2:
$ ipvsadm -l -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.233:80 rr
  -> 14.17.xx.yyy:80              Masq    0      0          0

telnet from container1 to container2:

access by ipvs at host will failed:

$ telnet 172.17.169.208 80
Trying 172.17.169.208...
telnet: connect to address 172.17.169.208: Connection refused

direct access ipvs in container will success:
$ telnet 192.168.1.233 80
Trying 192.168.1.233...
Connected to 192.168.1.233.
Escape character is '^]'.
^]
telnet  quit
Connection closed.


I think it's  the ipvs_property flag make ipvs in container return
NF_ACCEPT for network traffic, which make traffic go up to tcp layer.
Please see ip_vs_in.

We should clear this flag when SKB's netns has changed, Any idea?

Thanks,
Ye
