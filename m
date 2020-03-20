From: Alexander Petrovsky <askjuise@gmail.com>
Subject: Re: Micro ipvsadm patch
Date: Fri, 20 Mar 2020 21:16:47 +0300
Message-ID: <CAH57y_R=xUY-MPkFfeoOpH_f3eCLWDKuwW+wtNOKD9JJMjRkTw@mail.gmail.com>
References: <CAH57y_TcVNdCe7ciAXX85HzWXPhWgUWvXn2f7r8yWjM2TUNecQ@mail.gmail.com>
	<20200320133137.3cc59704@carbon>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane-mx.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
	h=mime-version:references:in-reply-to:from:date:message-id:subject:to
	:cc; bh=tEzsIB8JIzJYGpYvY04rUZCZdLI1Xbz2DMUq1X8q4os=;
	b=vHKKMmwgkvfS1FFMqHe5wOIHz21x27QCDXtWze3wPhwB1rMEJWQW6MBU/DdGPzQA0u
	ylVG9GFXp1ZRMkwjGYYEjIt2Bt+xZwYRT6V9Zsr2pPfZoqNf3ij6Yds61oi1Mb3VeaN9
	NHLvdL3aGndnoIwLLv9jjlDoY9GfSf9GQfKUmbdbiZigfIyLSgoHljbFXxaMKopjtc4Y
	g4xF85//J8i6rCuGwmmT7RKSSY9tEEEVxl6Uy+kp2LL7d+p0M+n8mu0A76GdoBU5UbHY
	oL91eQPUISa5yHOxRMzI7i8OCYgXn8svfpsNbUrkva2pEGDcurC5IwjRSinQE4rED+Ib
	iUKg==
In-Reply-To: <20200320133137.3cc59704@carbon>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane-mx.org@linuxvirtualserver.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

T2gsIHRoYW5rcy4KCldoZXJlIEkgY2FuIGZpbmQgb3V0IHRoZSBmdWxsIHByb2NlZHVyZT8KCtC/
0YIsIDIwINC80LDRgNGC0LAgMjAyMCDQsy4g0LIgMTU6MzIsIEplc3BlciBEYW5nYWFyZCBCcm91
ZXIgPGJyb3VlckByZWRoYXQuY29tPjoKCj4gT24gV2VkLCAxMSBNYXIgMjAyMCAxNTowNTo1OCAr
MDMwMAo+IEFsZXhhbmRlciBQZXRyb3Zza3kgPGFza2p1aXNlQGdtYWlsLmNvbT4gd3JvdGU6Cj4K
PiA+IEhlbGxvIQo+ID4KPiA+IFRoaXMgbWljcm8gaXB2c2FkbSBwYXRjaCBmaXhlcyB3cm9uZyAo
bmVnYXRpdmUpIEZXTUFSSyB2YWx1ZXMKPiA+IHJlcHJlc2VudGF0aW9uOgo+ID4KPiA+ICMgaXB2
c2FkbSAtTCAtZiAyODgyNDMwODQ5Cj4gPiBQcm90IExvY2FsQWRkcmVzczpQb3J0IFNjaGVkdWxl
ciBGbGFncwo+ID4gICAtPiBSZW1vdGVBZGRyZXNzOlBvcnQgICAgICAgICAgIEZvcndhcmQgV2Vp
Z2h0IEFjdGl2ZUNvbm4gSW5BY3RDb25uCj4gPiBGV00gIC0xNDEyNTM2NDQ3IHdsYwo+ID4gICAt
PiBhYmMubXkuaG9zdC5uZXQuIFR1bm5lbCAgMSAgICAgIDAgICAgICAgICAgMAo+ID4KPgo+IEhp
IEFsZXhhbmRlciwKPgo+IFlvdXIgcGF0Y2ggc3VibWlzc2lvbiBkb2VzIG5vdCBmb2xsb3cgYWxs
IHRoZSBwcm9jZWR1cmVzLCBidXQgZ2l2ZW4KPiB0aGlzIGlzIGZhaXJseSB0cml2aWFsLCBhbmQg
SnVsaWFuIGRpZG4ndCBvYmplY3QsIEkgd2VudCBhaGVhZCBhbmQKPiBhcHBsaWVkIHRoZSBwYXRj
aCB3aXRoICh5b3VyIFNvQiBhbmQgY3JlZGl0IHRvIHlvdSksIGhlcmU6Cj4KPgo+IGh0dHBzOi8v
Z2l0Lmtlcm5lbC5vcmcvcHViL3NjbS91dGlscy9rZXJuZWwvaXB2c2FkbS9pcHZzYWRtLmdpdC9j
b21taXQvP2lkPWU2MWM4Y2RkMWRjYWQKPgo+IC0tCj4gQmVzdCByZWdhcmRzLAo+ICAgSmVzcGVy
IERhbmdhYXJkIEJyb3Vlcgo+ICAgTVNjLkNTLCBQcmluY2lwYWwgS2VybmVsIEVuZ2luZWVyIGF0
IFJlZCBIYXQKPiAgIExpbmtlZEluOiBodHRwOi8vd3d3LmxpbmtlZGluLmNvbS9pbi9icm91ZXIK
Pgo+IC0tCkFsZXhhbmRlciBQZXRyb3Zza3kKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KUGxlYXNlIHJlYWQgdGhlIGRvY3VtZW50YXRpb24gYmVmb3JlIHBv
c3RpbmcgLSBpdCdzIGF2YWlsYWJsZSBhdDoKaHR0cDovL3d3dy5saW51eHZpcnR1YWxzZXJ2ZXIu
b3JnLwoKTGludXhWaXJ0dWFsU2VydmVyLm9yZyBtYWlsaW5nIGxpc3QgLSBsdnMtdXNlcnNATGlu
dXhWaXJ0dWFsU2VydmVyLm9yZwpTZW5kIHJlcXVlc3RzIHRvIGx2cy11c2Vycy1yZXF1ZXN0QExp
bnV4VmlydHVhbFNlcnZlci5vcmcKb3IgZ28gdG8gaHR0cDovL2xpc3RzLmdyYWVtZWYubmV0L21h
aWxtYW4vbGlzdGluZm8vbHZzLXVzZXJz
