#import "bookmaster/bookmaster.typ": *

#show: book.with(
  title: "BREXX/370 for MVS 3.8j",
  subtitle: "Library and Samples",
  short-title: "BREXX/370 Library and Samples",
  number: "ML03-0003-0",
  date: "October 2026",
  authors: ("Peter Jacob", "Mike Großmann"),
  edition: [
    #text(font: head-font, weight: "bold", size: 11pt)[First Edition (October 2026)]

    This edition applies to Version 3 Release 0 of BREXX/370
    (BREXX/370 3.0.0), as built with cc370 1.5.0 and libc370 2.6, and to
    all subsequent releases and modifications until otherwise indicated in
    new editions.

    *Draft.* The chapters are being converted from the BREXX/370 User's
    Guide and checked against BREXX/370 3.0; chapters still to be converted
    say so.

    BREXX was written by Vasilis Vlachoudis. Jason Winter and Jürgen
    Winkelmann ported it to MVS 3.8j; the BREXX/370 releases are made by
    Peter Jacob and Mike Großmann. BREXX is licensed under the GNU General
    Public License v2.0.

    Comments on this book may be addressed to the issue tracker of the
    mvslovers/brexx370 repository on GitHub.

    © Copyright Peter Jacob and Mike Großmann 2026. This book is part of
    BREXX/370. It may be copied, changed and distributed under the same
    terms as BREXX/370: the GNU General Public License, version 2.
  ],
)

#part("index.html", title: [BREXX/370 Library and Samples])[
#titlepage()
#contents()
#figures()

#heading(numbering: none)[About This Book] <about>

This book describes the REXX library that comes with BREXX/370, RXLIB, and the programs and samples written with it.

== How This Book Is Organized

#deflist(width: 1.35in,
  [Chapter 1], [“The REXX Library”.],
  [Chapter 2], [“RXLIB Functions”.],
  [Chapter 3], [“TSO Commands Written in REXX”.],
  [Chapter 4], [“Formatted Screens: the FSS API, Menus and Dialogs”.],
  [Chapter 5], [“The Key/Value Database”.],
  [Chapter 6], [“Applications”.],
  [Chapter 7], [“The Sample Library”.],
)

== Related Publications

#deflist(width: 1.35in,
  [ML03-0001], [_BREXX/370 User's Guide_],
  [ML03-0002], [_BREXX/370 Reference_],
)

#mainmatter()
]
#set page(numbering: "1")

#part("lib-intro.html", include "lib/lib-intro.typ")
#part("lib-rxlib.html", include "lib/lib-rxlib.typ")
#part("lib-tsocmd.html", include "lib/lib-tsocmd.typ")
#part("lib-fssmenu.html", include "lib/lib-fssmenu.typ")
#part("lib-kv.html", include "lib/lib-kv.typ")
#part("lib-apps.html", include "lib/lib-apps.typ")
#part("lib-samples.html", include "lib/lib-samples.typ")

#part("index-terms.html", title: [Index])[
#heading(numbering: none)[Index]
#make-index()
]
