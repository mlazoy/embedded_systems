#import "./template.typ":report
#import "@preview/codelst:2.0.2": sourcecode, sourcefile, codelst
#import "@preview/showybox:2.0.3": showybox

#show: report.with(
  title: "Σχεδιασμός Ενσωματωμένων Συστημάτων",
  subtitle: "6η Εργαστηριακή Άσκηση",
  authors: ("Λάζου Μαρία-Αργυρώ (el20129)",
            ),
team: "35",
  semester: "9ο Εξάμηνο, 2024-2025",
)

#let my_sourcefile(file, lang: auto, ..args) = {
  showybox(
    frame: (
      body-color: rgb(245, 245, 245), // Light background (like VSCode light theme)
      border-color: rgb(200, 200, 200), // Light gray border
      title-color: rgb(200, 200, 200), // Darker gray title for contrast
      radius: 5pt, // Rounded corners
      thickness: 1pt, // Thin border for a clean look
    ),
    breakable: true,
    width: 100%, // Fill the available width
    align: center,
    color: rgb(80, 80, 80), // Dark gray text (like VSCode)
    title: grid(
      columns: (1fr, 1fr), // Two equal-width columns for title and language
      gutter: 1em, // Space between columns
      text(
        font: "DejaVu Sans Mono", // Monospaced font for code
        size: 0.75em,
        fill: rgb(80, 80, 80), // Dark gray title text
        weight: 600,
        file.split("/").at(-1)
      )
    ),
  )[
    #set text(size: 0.85em, font: "DejaVu Sans Mono", fill: rgb(10, 10, 10)) // Black text for the code
    #sourcefile(read(file), file: file, lang: lang, ..args, frame: none)
  ]
}

#let bash_box(file, lang: auto, ..args) = {
  show table.cell.where(y: 0): set text(weight: "regular")

  showybox(
    frame: (
      body-color: rgb("#2C001E"), // Ubuntu terminal background color
      thickness: 0.6pt,
    ),
    breakable: false,
    width: 100%,
    align: center,
  )[
    #set text(
      font: "Ubuntu Mono", 
      size: 0.8em,
      fill: rgb("#00FF00"), 
    )
    #sourcefile(
      read(file),
      file: file,
      // lang: "bash",
      ..args,
      frame: none,
      numbering: none,
    )
  ]
}



#let bordered_text(file) = {
  // Read the file content
  let file_content = read(file)
  
  // Display the file content inside the box
  showybox(
    frame: (
      border-color: black,         
      border-thickness: 1pt,       
      radius: 4pt,                 
      thickness: 1pt,             
    ),
    breakable: true,
    width: 100%,                  
    align: center,
 
    text(size: 12pt, fill: black)[#file_content]  
    )
}

#pagebreak() 

== Eγκατάσταση custom cross-compiler building toolchain crosstool-ng
\
Ακολουθήθηκαν τα βήματα που περιγράφονται στην εκφώνηση μέσα σε vm που τρέχει Ubuntu 22.04.5 LTS και τα προβλήματα που ανέκυψαν ήταν ελάχιστα και αφορούσαν στην εγκατάσταση κάποιων missing dependencies (makinfo, help2man, libtool) κατά το configuration step. Για την επίλυσή τους απλώς τα εγακτέστησα μέσω του apt package. Συγκεκριμένα: 

#bash_box("../src/errors/makeinfo.txt")
#bash_box("../src/errors/help2man.txt")
#bash_box("../src/errors/libtool.txt")

'Επειτα η εντολή #emph[./configure --prefix=\${HOME}/crosstool] επιτυγχάνει, οπότε μπροώ να προσχωρήσω στο building step του cross-compiler για την αρχιτεκτινική *arm-cortexa9_neon-linux-gnueabihf*.
\
Κατά την διάρκεια των επόμενων βημάτων δεν παρουσιάστηκαν προβλήματα.

\
== Άσκηση 1
\
1. Η βασική διαφορά των 2 αρχιτεκτονικών *debian_wheezy_armel* και *debian_wheezy_armhf* έγκυται στον τρόπου υπολογισμού πράξεων κινητής υποδιαστολής. Η πρώτη διαχειρίζεται τα floating point operations μέσω software emulation τεχνικές, ενώ η δεύτερη τις εκτελεί απευθείας πάνω στο hardware και προορίζεται για επεξεργαστές που διαθέτουν κατάλληλα units (FPUs). Εξού και τα ακρωνύμια *el* (Embedded Linux) που εκφράζει την πλειοψηφία μηχανημάτων soft float που χρησιμοποιήθηκαν στο παρελθόν για ενσωματωμένες εφαρμογές και υιοθετήθηκε για ιστορικούς λόγους και *hf* (Hard Float) που αναφέρεται σε σύγχρονους επεξαργαστές με FPUs (π.χ ARM Cortex-A8 ή Cortex-A9). Η el είναι συμβατή με επεξεργαστές των οικογενειών ARMv5, ARMv5, ARMv6 ενώ η hf απαιτεί επεξεργαστή γενίας ARMv7. Η επίδοση των τελευταίων είναι σαφώς καλύτερη.
\
2. Χρησιμοποιούμε την αρχιτεκτονική *arm-cortexa9_neon-linux-gnueabihf* για λόγους compatibility με το qemu image που κατεβάσαμε. Συγκεκριμένα Debian Wheezy ARMHF είναι configured με τα ακόλουθα χαρακτηριστικά:
- ARMv7-A (που περιλαμβάνει τον Cortex A9 core)
- Neon intrinsics για υποστήριξη SIMD εντολών (ως περαιτέρω optimizations)
- VFPv3-D16 units για hard-float υπολογισμούς
Και τα 3 ταυτίζονται με επιλεγμένη αρχιτεκτονική ένα προς ένα όπως δηλώνουν και τα επιμέρους πεδία του ονόματός της.

Σε περίπτωση επιλογής διαφορετικής αρχιτεκτινικής δεν θα υπήρχε ταύτιση με το ISA (π.χ. διαφορετικό μήκος εντολών, μη υποστήριξη FLOPs) οπότε θα παίρναμε σφάλματα: #emph[Illegal insrtuction] ή #emph[Exec format error].

#pagebreak()

3. Δεν απαιτήθηκε κάποια χειροκίνητη αλλαγή στην βιβλιοθήκη που χρησιμοποιήσε στο configuration script o cross compiler αφού η gcc ήταν by default επιλεγμένη. Επιβεβαιώνω το παραπάνω μετά την εγκατάσταση με την ακόλουθη εντολή: 
#bash_box("../src/compile/ldd.txt")
Είναι η πιο safe επιλογή 
καθώς είναι συμβατή με Debian - μάλιστα προτείνεται από την ίδια για cross-compiling - και υποστηρίζει headers για ARMv7 αρχιτεκτονικές.

\
4. Τρέχω την ακόλουθη εντολή για την μεταγλώττιση του phods.c με τον cross compiler που χτίσαμε:
#bash_box("../src/compile/phods_cc.txt")
Παρατηρώ το είδος του εκτελέσιμου που παρήχθη με την ετνολή:
#bash_box("../src/compile/file.txt")
\ Από το readelf μπορούμε να δούμε περισσότερες λεπτομέρειες για την αρχιτεκτονική που προορίζεται, το endian, τα section headers (.text, .data, etc), τα program headers, το symbol table (globals, functions, etc), relocation entries και debugging πληροφορίες:
#bash_box("../src/compile/readelf.txt")
Πρόκειται, λοιπόν, για ένα 32-bit ELF file,little-endian με υποστήριξη στο ΕΑΒΙ. Επιπλέον διαθέτει THUMB-2 και NEONv1 εντολές και χρησιμοποιεί dynamic linking με την GLIBC 3.2.0.

\
5. Για να μεταγλωττίσω το ίδιο αρχείο phpds.c με τον linaro compiler εκτελώ την εντολή:
#bash_box("../src/compile/linaro.txt")
η οποία σκάει με το ακόλουθο error οπότε κατεβάζω την ζητούμενη shared library που λείπει:
#bash_box("../src/errors/linaro.txt")
και επαναλαμβάνω το compilation step που τώρα επιτυγχάνει. 

\
Συγκρίνοντας το μέγεθος των 2 παραγόμενων εκτέλεσιμων, παρατηρώ ότι το phods_linaro.out είναι περίπου το μισό (8878 bytes) σε σχέση με το phods_crosstool (15088 bytes).
#bash_box("../src/compile/sz.txt")
Από το αντίστοιχο readelf βλέπω:
#bash_box("../src/compile/readelf2.txt")
Παρατηρώ ότι τα περισσότερα χαρακτηριστικά είναι ίδια, όμως το linaro ΔΕΝ χρησιμοποιεί NEONv1 που εξηγεί την διαφορά στο μέγεθος των 2 ELFs αφού εισάγει έξτρα ελέγχους για πραγματοποιήση SIMD εντολών.

\
6. Η εκτέλεση του binary από τον cross-compiler αποτυγχάνει με το ακόλουθο error: 
#bash_box("../src/errors/exec_cross.txt")

Aντίθετα η εκτέλεση του binary από το linaro toolchain είναι επιτυχής.
#bash_box("../src/compile/exec_linaro.txt")

\
7. Μεταγλώττίζοντας ξανά το phods.c με τα 2 εργαλεία και το έξτρα flag -static παρατηρώ τα μεγέθη των νέων παραγόμενων αρχείων συγκριτικά με τα προηγούμενα:
#bash_box("../src/compile/sz2.txt")
Η διαφορά είναι αισθητή όπως αναμενόταν διότι το -static option εξαναγκάζει τον compiler να παράγει κώδικα για ολόκληρη την βιβλιοθήκη μέσα στο εκτέλισμο και δεν γίνεται δυναμικό linking με την υπάρχουσα shared μορφή της.
\
Εαν δοκιμάσω να τρέξω το νέο εκτελέσιμο από τον crosstool στο target δεν εμφανίζει κανένα πλέον σφάλμα για εύρεση της GLIBC:
#bash_box("../src/compile/exec_static.txt")

\
8. Στο υποθετικό σενάριο δημιουργίας μιας δικής μας custom συνάρτησης στην libc (θεώρησα ότι η αλλαγή κάποιου headerfile της glibc καθώς και το Makefile ώστε να συμπεριλάβει την mlab_foo() μάλλον δεν είναι τόσο καλή ιδέα...) αναμένω τα ακόλουθα μετά το compilation του με τον cross compiler του βήματος 3 και flags -Wall -O0 -o my_foo.out :
\
Α. Σε κάθε περίπτωση το ./my_foo.out στον host αποτυγχάνει αφού δεν ταιριάζει στην αρχιτεκτονική που έχω. 

\
Β. Στο target μηχάνημα θα αποτύχει διότι έχει παραχθεί με δυναμικό linking της glibc και η shared εκδοχή που εντοπίζει on runtime στο target δεν περιλαμβάνει την mlab_foo() σε κανένα headerfile.

\
C. Στην περίπτωση του στατικού linking επειδή γίνεται παραγωγή κώδικα για ολόκληρη την glibc μαζί με το .c αρχείο στο ίδιο εκτελέσιμο, το ./my_foo.out θα επιτύχει γιατί δεν έχει εξαρτήσεις από κανένα shard library και η mlab_foo() έχει γίνει inline.

\
== Άσκηση 2

Αρχικά αντιγράφω ολόκληρο το ./boot directory στο host ώστε να μπορώ μετά το τέλος της εγκατάστασης του νέου πυρήνα να συγκρίνω τα περιεχόμενά τους.
#bash_box("../src/kernel/boot.txt")
Aντιγράφω τον νέο πηρύνα στο host για να γίνει locally το extraction:
#bash_box("../src/kernel/source.txt")

Κατά την εισγαωγή του config δημιουργήθηκε το σφάλμα που περιγράφει η εκφώνηση με τον lexer οπότε δηλώνω τη αντίστοιχη μεταβλητή ως extern και επαναλαμβάνω:
#bash_box("../src/kernel/extern.txt")
Ακολούθησαν διάφορα σφάλματα που σχετίζονται με την δήλωση των .section flags. Χρειάστηκε να αντικατασταθούν οι ακόλουθες γραμμές #emph[.section .start,\#alloc,\#execute] με #emph[.section,"ax"] στα αρχεία: 
+ #emph[arch/arm/boot/compressed/head.S] 
+ #emph[arch/arm/boot/compressed/big-endian.S] 
+ #emph[arch/arm/boot/bootp/init.S] 
+ #emph[arch/arm/mm/proc-v7.S]  
και την #emph[.section .start,\#alloc] με #emph[.section .start,"a"] στα αρχεία :
+ #emph[arch/arm/boot/compressed/piggy.lzma.S]
+ #emph[arch/arm/boot/compressed/piggy.gzip.S]
\
Τελικά τα 3 αρχεία παράχθηκαν με επιτυχία και παρακάτω βλέπουμε κάποιες πληροφορίες για το καθένα:
#bash_box("../src/kernel/info1.txt")
#bash_box("../src/kernel/info2.txt")
#bash_box("../src/kernel/info3.txt")
\
Δυστυχώς το compression αυτών δεν υποστηρίζεται όταν τα ανεβάζουμε στο qemu και παίνρουμε αυτό το σφάλμα:
#bash_box("../src/errors/compression.txt")
Oι επιλογές είναι 2, είτε να αναβαθμίσω το dpkg package στον armhf που είναι πολύ παλιό και δεν θα παίξει οπότε πρέπει κάνω χρήση των ακόλουθων πακέτων: #emph[aptitude, ztsd, bzip2] 
είτε να επαναλάβω το compilation του kernel αλλάζοντας το compression των παραγόμενων αρχείων από το αρχείο #emph[scripts/package/builddeb] μετατρέποντας την γραμμή #emph[dpkg --build] σε #emph[dpkg-deb -Zgzip --build].  
Ακολυθώ την 2η καθώς έχει λιγότερο manual compression-decompression ανάμεσα σε διαφορετικά formats.
Tελικά αποσυμπιέζω τα αρχεία του kernel:
#bash_box("../src/kernel/extract.txt")
Για να εκκινήσει το μηχάνημα με τον νέο πηρύνα χρειάζεται να τα περάσουμε ως ορίσματα στο script που σηκώνει το qemu ως ακολούθως:
#bash_box("../src/kernel/qemu_script.txt")

Συνεπώς πρέπει να τα κατεβάσουμε από το /boot directory του guest στον host.

#pagebreak()

== Ερωτήματα 

\ *1.* Πριν την εκκίνηση με τον νέο πηρύνα εκτελώ:
#bash_box("../src/kernel/uname_old.txt")
Mετά την εκκίνηση η ίδια εντολή παράγει διαφορετικό αποτέλεσμα:
#bash_box("../src/kernel/uname_new.txt")
Παραητρώ ότι έχει λάβει το όνομα του νέου πυρήνα.

\ *2.* Για την προσθήκη ενός δικού μου custom system call ακολούθησα τα παρακάτω βήματα 
- Δημιούργησα εκ νέου ένα directory με όνομα *greet/ * μέσα στο #emph[linux-source-3.16.84] το οποίο αποτελείται από το #emph[greet.c] και το #emph[Makefile] που φαίνονται παρακάτω:
#my_sourcefile("../src/syscall/greet.c") 

#bash_box("../src/syscall/makegreet.txt")

- Προσθέτω στο #emph[*arch/arm/kernel/call.S*] την ακόλουθη γραμμή μετά το definition του τελευταίου system call: 
#bash_box("../src/syscall/callS.txt")
Tώρα το system call μου έχει εισαχθεί στο system call table του συστήματος.

- Προσθέτω στο αρχείο #emph[*arch/arm/include/uapi/asm/unistd.h*] στην τελευταία γραμμή τον αριθμό του custom system call (+ 386 από την βάση εφόσον ο υπάρχοντας τελευταίος ήταν 385 όπως φαίνεται στο παραπάνω στιγμιότυπο):
#bash_box("../src/syscall/unistd.txt")

- Προσθέτω στο αρχείο #emph[*include/linux/syscalls.h*] την επικεφαλίδα της συνάρτησης που καλεί το custom system call μου:
#bash_box("../src/syscall/include.txt")

- Tέλος προσθέτω το νέο directory #emph[greet/] στους κανόνες για το core-y στο Makefile στο root directory του linux-source:
#my_sourcefile("../src/syscall/makefile.txt") 
Με τον τρόπο αυτό ο compiler γνωρίζει που βρίσκεται το νεό system call και εξασφαλίζει ότι θα κάνει make το εν λόγω directory.

\ Mε την ολοκλήρωση των παραπάνω βημάτων, επαναλαμβλανω το compilation με τον ίδιο cross compiler και τα ίδια configurations με προηγουμένων και έπειτα αποσυμπιέζω τα νέα .deb αρχεία  στο guest. Για να λειτουργήσει το σύστημα με τις επιθυμητές αλλαγές απαιτείται *reboot*.

\ *3.* Για τον έλεγχο της επιθυμητής λειτουργίας του custom system call χρησιμοποιήθηκε ο ακόλουθος κώδικας:
#my_sourcefile("../src/syscall/test_greet.c")
ο οποίος παράγει το αποτέλεσμα :
#bash_box("../src/syscall/test_exec.txt")

\
\
\
\
\
\
\
\
#emph[Τα απαιτούμενα αρχεία για τους σκοπούς της άσκησης παρατίθενται σε ξεχωριστούς φακέλους μέσα στο zip.]




