From: Bassem Mettichi <mettichi@gmail.com>
Subject: Re: [PATCH v8 0/2] Allow tunneling with gue
	encapsulation
Date: Fri, 31 May 2019 09:40:14 +0100
Message-ID: <CADpsxzGL=_qRdaKVErfrzfyy_UD0HnW+t5SUPxgx4y6hWd5Knw@mail.gmail.com>
References: <20190530080057.8218-1-hengqing.hu@gmail.com>
	<alpine.LFD.2.21.1905302130360.4725@ja.home.ssi.bg>
	<20190531084955.7cd4af00@carbon>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="000000000000432dd9058a2af72f"
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
	h=mime-version:references:in-reply-to:from:date:message-id:subject:to
	:cc; bh=hO2rzJXjXlvF7ZvAIfphw9/1tEdoex5JOafVlWboRPA=;
	b=MGjG+BFCh08kVWu4tin5STsE7Q0cQzjcK2x9VhhkNLgUBdTt2XKjsswCydGZIhHs7o
	yfNusCq8h5zZ/5iZlCCrH48SMLco1GI5WPSMylTLwD5p7184ZppdZp/sOeSB8uhZi3Jk
	faCYkjPKNZUbnl6SYIX0V1XacyE9knPpJ76aAx5AZSeDTWtWL9n4tIPX6ou9HolUS+B3
	/FyVxT8OwfWq9Sq1qmrcxB3S8EHCDMMSCW2Rv11UEWO1XT7cShC1C2opfG5pKWfyxWrc
	F/axiXt4mMim0hxbopg7EJPEMKghA8Tw98zrcc6zZuQJsKDkLI42q+FN5JBfbgLytwFk
	qs7g==
In-Reply-To: <20190531084955.7cd4af00@carbon>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, horms@verge.net.au, jacky.hu@walmart.com, Jesper Dangaard Brouer <brouer@redhat.com>, Jacky Hu <hengqing.hu@gmail.com>, jason.niesz@walmart.com

--000000000000432dd9058a2af72f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

attached keepalived.conf

Le ven. 31 mai 2019 =C3=A0 07:53, Jesper Dangaard Brouer <brouer@redhat.com=
> a
=C3=A9crit :

>
> On Thu, 30 May 2019 21:37:34 +0300 (EEST) Julian Anastasov <ja@ssi.bg>
> wrote:
>
> > On Thu, 30 May 2019, Jacky Hu wrote:
> >
> > > This patchset allows tunneling with gue encapsulation.
> > >
> [...]
> >
> >       Both patches look ok to me, thanks!
> >
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> >
> >       Jesper, this patchset is based on the kernel patch
> > "[PATCH v4] ipvs: add checksum support for gue encapsulation"
> > which is to be applied to kernel trees. If needed, I can ping
> > you when the patch is accepted.
>
> Yes, that would be great!  I'll apply it as soon as the kernel patch is
> accepted.
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
>
> _______________________________________________
> Please read the documentation before posting - it's available at:
> http://www.linuxvirtualserver.org/
>
> LinuxVirtualServer.org mailing list - lvs-users@LinuxVirtualServer.org
> Send requests to lvs-users-request@LinuxVirtualServer.org
> or go to http://lists.graemef.net/mailman/listinfo/lvs-users
>

--000000000000432dd9058a2af72f
Content-Type: application/octet-stream; name="keepalived.conf"
Content-Disposition: attachment; filename="keepalived.conf"
Content-Transfer-Encoding: base64
Content-ID: <f_jwbu70rw0>
X-Attachment-Id: f_jwbu70rw0

Z2xvYmFsX2RlZnMNCnsNCmVuYWJsZV9zY3JpcHRfc2VjdXJpdHkNCnNjcmlwdF91c2VyIHJvb3Qg
cm9vdA0KfQ0KDQoNCg0KdnJycF9zY3JpcHQgY2hrX215c2NyaXB0IHsNCiAgc2NyaXB0ICAgICAg
ICIvZXRjL2tlZXBhbGl2ZWQvdHJhY2suc2giDQogIGludGVydmFsIDUgICAjIGNoZWNrIGV2ZXJ5
IDIgc2Vjb25kcw0KICBmYWxsIDIgICAgICAgIyByZXF1aXJlIDIgZmFpbHVyZXMgZm9yIEtPDQog
IHJpc2UgMiAgICAgICAjIHJlcXVpcmUgMiBzdWNjZXNzZXMgZm9yIE9LDQp9IA0KDQoNCnZycnBf
aW5zdGFuY2UgVklfTEIxIHsNCiAgICBzdGF0ZSBCQUNLVVANCiAgICBpbnRlcmZhY2UgZXRoMQ0K
ICAgIHZpcnR1YWxfcm91dGVyX2lkIDE0NQ0KICAgIHByaW9yaXR5IDE1MA0KICAgIHVuaWNhc3Rf
c3JjX2lwIGlwX29mX21hc3Rlcl9rZWVwYWxpdmVkDQogICAgdW5pY2FzdF9wZWVyIHsNCiAgICAg
ICAgaXBfb2Zfc2xhdmVfa2VlcGFsaXZlZA0KICAgIH0NCiAgICB2aXJ0dWFsX2lwYWRkcmVzcyB7
DQoJVklQMSAgZGV2IGV0aDEgICMgDQogICAgCVZJUDIgIGRldiBldGgyICAjIA0KCVZJUDMgIGRl
diBldGgxICAjIA0KCVZJUDQgZGV2IGV0aDIgICMgR0FURVdBWQ0KICAgIH0NCg0KDQp0cmFja19z
Y3JpcHQgew0KICAgIGNoa19teXNjcmlwdA0KICB9DQoNCg0KICAgIHRyYWNrX2ludGVyZmFjZSB7
DQogICAgICAgIGV0aDIgICAgICAgICAgICMgRmF1bHQgaWYgZG93bi4gZXRoMiBpcyBhbHJlYWR5
IG1vbml0b3JlZCBieSBWUlJQLg0KICAgIH0NCiAgDQogbm9wcmVlbXB0ICAgICAgIyB0byBhdm9p
ZCBhdXRvbWF0aWMgc3dpdGNoICANCiBub3RpZnkgIi9ldGMva2VlcGFsaXZlZC9ub3RpZnlhcGFj
aGUuc2giDQogICANCg0KDQoNCn0NCg0KdmlydHVhbF9zZXJ2ZXJfZ3JvdXAgUE9SVDE4MTIgew0K
ICAgICAgICBWSVAyIDE4MTINCglWSVAyIDE4MTINCn0NCg0KdmlydHVhbF9zZXJ2ZXJfZ3JvdXAg
UE9SVDE4MTMgew0KICAgIFZJUDEgMTgxMw0KICAgIFZJUDEgMTgxMw0KfQ0KDQoNCg0KDQp2aXJ0
dWFsX3NlcnZlciBWSVAzIDgwIHsNCiAgICBkZWxheV9sb29wIDEwDQogICAgbGJfYWxnbyBycg0K
ICAgIGxiX2tpbmQgTkFUDQogICAjIG5hdF9tYXNrIDI1NS4yNTUuMjU1LjI0MA0KICAgICNwZXJz
aXN0ZW5jZV90aW1lb3V0IDMwMA0KICAgICNwZXJzaXN0ZW5jZV9ncmFudWxhcml0eSAyNTUuMjU1
LjI1NS4yNTUNCiAgICBwcm90b2NvbCBUQ1ANCg0KICAgIHJlYWxfc2VydmVyICBJUF9BUEFDSEVf
MSA4MDAwIHsNCiAgICAgICAgd2VpZ2h0IDENCiAgICAgICAgSFRUUF9HRVQgew0KICAgICAgICAg
IHVybCB7DQogICAgICAgICAgICAgICBwYXRoIC9hbHRlb24uaHRtbA0KICAgICAgICAgICAgICAg
DQogICAgICAgICAgICAgICAgZGlnZXN0IGE3Yjg2MDNmMWMxMGU5MjI5YmVhOWU5NGM5NjQ1YTUz
DQogICAgICAgICAgICAgIH0NCiAgICAgICAgICAgICAgY29ubmVjdF90aW1lb3V0IDMNCiAgICAg
ICAgICAgICAgbmJfZ2V0X3JldHJ5IDMNCiAgICAgICAgICAgICAgZGVsYXlfYmVmb3JlX3JldHJ5
IDMNCiAgICAgICAgfQ0KICAgIH0NCg0KDQogICAgcmVhbF9zZXJ2ZXIgSVBfQVBBQ0hFXzIgODAw
MCB7DQogICAgICAgIHdlaWdodCAxDQogICAgICAgIEhUVFBfR0VUIHsNCiAgICAgICAgICB1cmwg
ew0KICAgICAgICAgICAgICAgcGF0aCAvYWx0ZW9uLmh0bWwNCiAgICAgICAgICAgICAgIA0KICAg
ICAgICAgICAgICAgIGRpZ2VzdCBhN2I4NjAzZjFjMTBlOTIyOWJlYTllOTRjOTY0NWE1Mw0KICAg
ICAgICAgICAgICB9DQogICAgICAgICAgICAgIGNvbm5lY3RfdGltZW91dCAzDQogICAgICAgICAg
ICAgIG5iX2dldF9yZXRyeSAzDQogICAgICAgICAgICAgIGRlbGF5X2JlZm9yZV9yZXRyeSAzDQog
ICAgICAgIH0NCiAgICB9DQp9DQoNCg0KDQp2aXJ0dWFsX3NlcnZlciBncm91cCBQT1JUMTgxMiB7
DQogICAgZGVsYXlfbG9vcCAxMA0KICAgIGxiX2FsZ28gcnIgDQogICAgbGJfa2luZCBOQVQNCiAg
ICAjcGVyc2lzdGVuY2VfdGltZW91dCAxMDAgICAjIGRlLWFjdGl2YXRlIGZvciBBY3RpdmUvQWN0
aXZlDQogICAgcHJvdG9jb2wgVURQDQoNCiAgICByZWFsX3NlcnZlciBJUF9SQURJVVNfMSAxODEy
IHsNCiAgICAgICAgd2VpZ2h0IDENCiAgICAgICAgTUlTQ19DSEVDSyB7DQojICAgICAgICAgIG1p
c2NfcGF0aCAiL2V0Yy9rZWVwYWxpdmVkL2Jlc3Bva2VfaGVhbHRoY2hlY2suc2ggaGVhbHRoY2hl
Y2sxX3NydjEiDQoJICBtaXNjX3BhdGggIi9vcHQvYXBwbGljYXRpb24vcmFkY2hlY2suc2ggSVBf
UkFESVVTXzEgMTgxMiINCiAgICAgICAgICBtaXNjX3RpbWVvdXQgNQ0KICAgICAgICB9DQogICAg
fQ0KICAgIHJlYWxfc2VydmVyIElQX1JBRElVU18yIDE4MTIgew0KICAgICAgICB3ZWlnaHQgMQ0K
ICAgICAgICBNSVNDX0NIRUNLIHsNCiMgICAgICAgICAgbWlzY19wYXRoICIvZXRjL2tlZXBhbGl2
ZWQvYmVzcG9rZV9oZWFsdGhjaGVjay5zaCBoZWFsdGhjaGVjazFfc3J2MiINCgkgIG1pc2NfcGF0
aCAiL29wdC9hcHBsaWNhdGlvbi9yYWRjaGVjay5zaCBJUF9SQURJVVNfMiAxODEyIg0KICAgICAg
ICAgIG1pc2NfdGltZW91dCA1DQogICAgICAgIH0NCiAgICB9DQp9DQoNCnZpcnR1YWxfc2VydmVy
IGdyb3VwIFBPUlQxODEzIHsNCiAgICBkZWxheV9sb29wIDEwDQogICAgbGJfYWxnbyBycg0KICAg
IGxiX2tpbmQgTkFUDQogICAgI3BlcnNpc3RlbmNlX3RpbWVvdXQgMTAwICAgIyBkZS1hY3RpdmF0
ZSBmb3IgQWN0aXZlL0FjdGl2ZQ0KICAgIHByb3RvY29sIFVEUA0KDQogICAgcmVhbF9zZXJ2ZXIg
IElQX1JBRElVU18xICAxODEzIHsNCiAgICAgICAgd2VpZ2h0IDENCiAgICAgICAgSFRUUF9HRVQg
ew0KICAgICAgICAgIHVybCB7DQogICAgICAgICAgICAgICBwYXRoIC9oZWFsdGhjaGVjaw0KICAg
ICAgICAgICAgICAgc3RhdHVzX2NvZGUgMjAwDQogICAgICAgICAgICAgIH0NCiAgICAgICAgICAg
ICAgY29ubmVjdF9wb3J0IDgwDQogICAgICAgICAgICAgIGNvbm5lY3RfdGltZW91dCAzDQogICAg
ICAgICAgICAgIG5iX2dldF9yZXRyeSAzDQogICAgICAgICAgICAgIGRlbGF5X2JlZm9yZV9yZXRy
eSAzDQogICAgICAgIH0NCiAgICB9DQoNCiAgICByZWFsX3NlcnZlciBJUF9SQURJVVNfMiAxODEz
IHsNCiAgICAgICAgd2VpZ2h0IDENCiAgICAgICAgSFRUUF9HRVQgew0KICAgICAgICAgIHVybCB7
DQogICAgICAgICAgICAgICBwYXRoIC9oZWFsdGhjaGVjaw0KCSAgICAgICBzdGF0dXNfY29kZSAy
MDANCiAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgICBjb25uZWN0X3BvcnQgODANCiAgICAg
ICAgICAgICAgY29ubmVjdF90aW1lb3V0IDMNCiAgICAgICAgICAgICAgbmJfZ2V0X3JldHJ5IDMN
CiAgICAgICAgICAgICAgZGVsYXlfYmVmb3JlX3JldHJ5IDMNCiAgICAgICAgfQ0KICAgIH0NCn0N
Cg==
--000000000000432dd9058a2af72f
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--000000000000432dd9058a2af72f--
