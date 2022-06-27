From: Dan Williams <dan.j.williams@intel.com>
Subject: RE: [PATCH][next] treewide: uapi: Replace zero-length arrays with
 flexible-array members
Date: Mon, 27 Jun 2022 15:31:42 -0700
Message-ID: <62ba2fced98ed_103a0e29448@dwillia2-xfh.notmuch>
References: <20220627180432.GA136081@embeddedor>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <virtualization-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 377EE60B83
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org A9B6B60A93
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 2D4E84155B
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 9DFB3414CD
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
 d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
 t=1656369111; x=1687905111;
 h=date:from:to:cc:subject:message-id:references:
 content-transfer-encoding:in-reply-to:mime-version;
 bh=cFfs79so5bDyszYGeV34Sx13DSMu8p5hKhG+YTrPg6I=;
 b=Yk8zj0+vGB1i1/ILrclww1zKfN/d4zMHVBJCTpZuSUqdNWoD4ed7CPwO
 4Jd1OazCezbrPVQ98AEA7fjlzd5NSbkFd0K3BeGQQpN3jrRtBQqmJfDmK
 iDXJ49nwe60/yFAQJqjNSdvlx4VkPUglmsqyQJBiCeX+RJakErDcJtsdn
 vrOh4DsmJeALn9i6Z9gj8038FJhVe8cdGvmgoq/WPxu9ivynTC/rpNKdO
 LXqRN8PzoMhZNwRaxgSDAttC4LIXIpUTcJppr2OzlDWfBocxbLiRbE4VJ
 YzEDbpucFxp+8BfSXz1pyP+DBrX0LQSENJwdBv/hmisxZHqyIjjBAPb4i Q==;
Content-Disposition: inline
In-Reply-To: <20220627180432.GA136081@embeddedor>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>, 
 <mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>, 
 <mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: virtualization-bounces@lists.linux-foundation.org
Sender: "Virtualization" <virtualization-bounces@lists.linux-foundation.org>
To: "Gustavo A. R. Silva" <gustavoars@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: nvdimm@lists.linux.dev, alsa-devel@alsa-project.org, "Gustavo A. R. Silva" <gustavoars@kernel.org>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, target-devel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-hardening@vger.kernel.org, linux1394-devel@lists.sourceforge.net, linux-stm32@st-md-mailman.stormreply.com, linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, kasan-dev@googlegroups.com, lvs-devel@vger.kernel.org, coreteam@netfilter.org, v9fs-developer@lists.sourceforge.net, intel-gfx@lists.freedesktop.org, linux-can@vger.kernel.org, linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org, io-uring@vger.kernel.org, linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mmc@vger.kernel.org, linux-mip

R3VzdGF2byBBLiBSLiBTaWx2YSB3cm90ZToKPiBUaGVyZSBpcyBhIHJlZ3VsYXIgbmVlZCBpbiB0
aGUga2VybmVsIHRvIHByb3ZpZGUgYSB3YXkgdG8gZGVjbGFyZQo+IGhhdmluZyBhIGR5bmFtaWNh
bGx5IHNpemVkIHNldCBvZiB0cmFpbGluZyBlbGVtZW50cyBpbiBhIHN0cnVjdHVyZS4KPiBLZXJu
ZWwgY29kZSBzaG91bGQgYWx3YXlzIHVzZSDigJxmbGV4aWJsZSBhcnJheSBtZW1iZXJz4oCdWzFd
IGZvciB0aGVzZQo+IGNhc2VzLiBUaGUgb2xkZXIgc3R5bGUgb2Ygb25lLWVsZW1lbnQgb3IgemVy
by1sZW5ndGggYXJyYXlzIHNob3VsZAo+IG5vIGxvbmdlciBiZSB1c2VkWzJdLgo+IAo+IFRoaXMg
Y29kZSB3YXMgdHJhbnNmb3JtZWQgd2l0aCB0aGUgaGVscCBvZiBDb2NjaW5lbGxlOgo+IChsaW51
eC01LjE5LXJjMiQgc3BhdGNoIC0tam9icyAkKGdldGNvbmYgX05QUk9DRVNTT1JTX09OTE4pIC0t
c3AtZmlsZSBzY3JpcHQuY29jY2kgLS1pbmNsdWRlLWhlYWRlcnMgLS1kaXIgLiA+IG91dHB1dC5w
YXRjaCkKPiAKPiBAQAo+IGlkZW50aWZpZXIgUywgbWVtYmVyLCBhcnJheTsKPiB0eXBlIFQxLCBU
MjsKPiBAQAo+IAo+IHN0cnVjdCBTIHsKPiAgIC4uLgo+ICAgVDEgbWVtYmVyOwo+ICAgVDIgYXJy
YXlbCj4gLSAwCj4gICBdOwo+IH07Cj4gCj4gLWZzdHJpY3QtZmxleC1hcnJheXM9MyBpcyBjb21p
bmcgYW5kIHdlIG5lZWQgdG8gbGFuZCB0aGVzZSBjaGFuZ2VzCj4gdG8gcHJldmVudCBpc3N1ZXMg
bGlrZSB0aGVzZSBpbiB0aGUgc2hvcnQgZnV0dXJlOgo+IAo+IC4uL2ZzL21pbml4L2Rpci5jOjMz
NzozOiB3YXJuaW5nOiAnc3RyY3B5JyB3aWxsIGFsd2F5cyBvdmVyZmxvdzsgZGVzdGluYXRpb24g
YnVmZmVyIGhhcyBzaXplIDAsCj4gYnV0IHRoZSBzb3VyY2Ugc3RyaW5nIGhhcyBsZW5ndGggMiAo
aW5jbHVkaW5nIE5VTCBieXRlKSBbLVdmb3J0aWZ5LXNvdXJjZV0KPiAJCXN0cmNweShkZTMtPm5h
bWUsICIuIik7Cj4gCQleCj4gCj4gU2luY2UgdGhlc2UgYXJlIGFsbCBbMF0gdG8gW10gY2hhbmdl
cywgdGhlIHJpc2sgdG8gVUFQSSBpcyBuZWFybHkgemVyby4gSWYKPiB0aGlzIGJyZWFrcyBhbnl0
aGluZywgd2UgY2FuIHVzZSBhIHVuaW9uIHdpdGggYSBuZXcgbWVtYmVyIG5hbWUuCj4gCj4gWzFd
IGh0dHBzOi8vZW4ud2lraXBlZGlhLm9yZy93aWtpL0ZsZXhpYmxlX2FycmF5X21lbWJlcgo+IFsy
XSBodHRwczovL3d3dy5rZXJuZWwub3JnL2RvYy9odG1sL3Y1LjE2L3Byb2Nlc3MvZGVwcmVjYXRl
ZC5odG1sI3plcm8tbGVuZ3RoLWFuZC1vbmUtZWxlbWVudC1hcnJheXMKPiAKPiBMaW5rOiBodHRw
czovL2dpdGh1Yi5jb20vS1NQUC9saW51eC9pc3N1ZXMvNzgKPiBCdWlsZC10ZXN0ZWQtYnk6IGh0
dHBzOi8vbG9yZS5rZXJuZWwub3JnL2xrbWwvNjJiNjc1ZWMud0tYNkFPWjZjYkU3MXZ0RiUyNWxr
cEBpbnRlbC5jb20vCj4gU2lnbmVkLW9mZi1ieTogR3VzdGF2byBBLiBSLiBTaWx2YSA8Z3VzdGF2
b2Fyc0BrZXJuZWwub3JnPgo+IC0tLQo+IEhpIGFsbCEKPiAKPiBKRllJOiBJJ20gYWRkaW5nIHRo
aXMgdG8gbXkgLW5leHQgdHJlZS4gOikKPiAKWy4uXQo+ICBpbmNsdWRlL3VhcGkvbGludXgvbmRj
dGwuaCAgICAgICAgICAgICAgICAgICAgfCAxMCArLS0KCkZvciBuZGN0bC5oCgpBY2tlZC1ieTog
RGFuIFdpbGxpYW1zIDxkYW4uai53aWxsaWFtc0BpbnRlbC5jb20+Cl9fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlz
dApWaXJ0dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3Rz
LmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
