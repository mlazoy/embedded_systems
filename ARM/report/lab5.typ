#import "./template.typ":report
#import "@preview/codelst:2.0.2": sourcecode, sourcefile, codelst
#import "@preview/showybox:2.0.3": showybox

#show: report.with(
  title: "Σχεδιασμός Ενσωματωμένων Συστημάτων",
  subtitle: "5η Εργαστηριακή Άσκηση",
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
      body-color: rgb("#1E1E1E"), // Mac terminal dark background color
      thickness: 0.6pt,
    ),
    breakable: false,
    width: 100%,
    align: center,
  )[
    #set text(
      font: "Menlo", 
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

== Ερώτημα 1ο
\
Το παρακάτω πρόγραμμα σε Assembly πραγματοποιεί την ζητούμενη λειτουργία με βάση τις ακόλουθες παρατηρήσεις:

\
- Για την μετατροπή από πεζά σε κεφαλαία και το αντίστροφο απαιτείται απλώς η πρόσθεση (ή αφαίρεση αντίστοιχα) της σταθεράς 32 από τον ASCII κώδικό του συγκεκριμένου χαρακτήρα που αντιστοιχεί σε 1 εντολή arm assembly (addge/ subge). H επιλογή χρήσης των ιδιωματικών εντολών arm θα φανεί στην συνέχεια.
\
- Για την μετατροπή των αριθμών απαιτείται ο υπολογισμός του (x + 5) mod 10, όπου x ε [1,...,9]. Προς αποφυγή διαίρεσης κάνω το εξής τρικ: προσθέτω 5, ελέγχω εαν προκύπτει τιμή > 9 και αφαιρώ 10 σε αυτήν περίπτωση, αντιτοιχεί λοιπόν σε 3 εντολές arm assembly (add, cmp, subgt).
\
- Για την διάκριση των modes λειτουργίας (arithmetic shift, lowercase -> uppercase, uppercase -> lowercase) συγκρίνω το στοιχείο της συμβολοσειράς εισόδου με τους κωδικούς ASCII των οριακών τιμών '0', '9', 'Ζ', 'z' σε hex μορφή και κατά αύξουσα σειρά, που αντιστοιχόυν σε μια εντολή assembly (cmp). Τα άνω modes λειτουργίας αντιστοιχούν στα ενδιάμεσα διαστήματα που σχηματίζουν οι οριακές αυτές τιμές (#emph[\_is_upper], #emph[\_is_lower]). Στην περίπτωση των γραμμάτων ελέγχω έπειτα και τον χαρακτήρα 'Α' ή 'α' για επιβεβαίωση ότι βρίσκεται πράγματι στο σωστό εύρος). Εαν δεν ικανοποιηθεί κανένας έλεγχος ο χαρακτήρας μένει αμετάβλητος.
\
- Η σύγκριση με 'q' ή 'Q' πραγματοποιείται πρωτού εισέλθουμε στην συνάρτηση #emph[\_transform] για έγκαιρο τερματισμό.
\
- Για την αγνόηση του input > 32 bytes καλούμε συνεχώς στο loop #emph[\_discard] το read system call μέχρι να διαβάσουμε τιμή != 32.
\
- Η ανάγνωση της συμβολοσειράς γίνεται καλώντας απευθείας το read systemcall (offset 3) και η εκτύπωση με jump στην external printf. (Θα μπορούσε να χρησιμοποιηθεί και επευθείας το write systemcall (offset 4)).

#my_sourcefile("../ex1/ex1.s", 
highlighted: (25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62),
highlight-color:  rgb("#42b27e").lighten(40%),)

#pagebreak()

Kάποια παραδείγματα εκτέλεσης μέσα στο περιβάλλον QEMU φαίνονται παρακάτω:
#bash_box("../ex1/ex1_exec.txt")

\
\
== Eρώτημα 2ο
\

Για την επικοινωνία μεταξύ host & guest χρησιμοποιήθηκε η 2η μέθοδος (χρήση flag #emph[-serial pty]) και η εικονική σειριακή θύρα που δημιουργήθηκε από το QEMU είναι η #emph[/dev/ttyAMA0] στην πλευρά του guest και #emph[/dev/ttys004] στην πλευρά του host. 
\
\

Δοκιμάστηκαν διαφορετικές τιμές baudrate και τελικά χρησιμοποίησα την 115200 ως default. Σημειώνεται ότι αυτή που οριζε το getty, το οποίο απενεργοποιήθηκε με comment out όπως αναφέρει η εκφώνηση, ήταν 9600. Οι υπόλοιπες τιμές του termios struct καθορίστηκαν και στα 2 μηχανήματα με τον ίδιο τρόπο θέτοντας απευθείας τα bits στην arm assembly και χρησιμοποιώντας τα αντίστοιχα macros στην C. Αξιοσημείωτα εδώ είναι μόνο τα flags #emph[c_cflag] που χρειάζεται να προσδιορίσουμε ότι η μεταφορά γίνεται ανά byte με το options #emph[CS8], καθώς και το #emph[c_lflag] το οποίο με option #emph[ICANON] διαβάζει το input ως ολόκληρη γραμμή μετά από Enter και μας επιτρέπει να ελέγχουμε το end of input string συγκρίνοντας με τν χαρακτήρα '\\n' στον assembly κώδικα. 
\
\
Και στις 2 περιπτώσεις το άνοιγμα τηε σειριακής θύρας γίνεται σε blocking mode με δικαίωματα ανγάγνωσης και εγγραφής αφού και τα 2 μηχανήματα στέλνουν και λαμβάνουν δεδομένα. O host κοιμάται για 1s αφού στείλει τα δεδομένα για να εξασφαλίσω ότι ο guest έχει προλάβει να γράψει το αποτέλεσμα στον buffer του serial port, όμως μπορεί να παραλειφθεί μιας και το read είναι blocking.
\
\
Aκολουθεί ο κώδικας σε C που τρέχει στο host μηχάνημα:
#my_sourcefile("../ex2/host.c")

#pagebreak()

Στην συνέχεια παρατίθεται ο κώδικας σε arm assembly που τρέχει στο QEMU vm:
#my_sourcefile("../ex2/guest.s")
\

Για την εύερεση του στοιχείο με υψηλότερη συχνότητα, διατηρείται στο .data section ένα αρχικοποιημένο σε 0 διάστημα #emph[\_freqs] και το κύριο μέρος του κώδικα φορτώνει πριν το σημείο #emph[\_count] έναν δείκτη στο base address αυτoύ. Σε κάθε επανάληψη, φορτώνει την τιμή του στο offset ίσο με τον ASCII κωδικό του χαρακτήρα εισόδου (η arm assembly το επιτρέπει σε μια εντολή #emph[ldrb [r\<num> ,\<offset>]]) και την αυξάνει κατά 1(το space ελέγχεται ξεχωριστά και δεν προσμετράται). Eπειδή τα στοιχεία είναι το πολύ 64 ένα byte αρκεί για την καταμέτρηση του κάθε χαρακτήρα. Για την εύρεση του μεγίστου διατρέχει μια φορά τα στοιχεία του #emph[\_freqs] με postindex τρόπο και ανανεώνει το offset του μέγιστου όταν χρειαστεί πάλι με τις ειδικές εντολές υπό συνθήκη που προσφέρει ο arm επεηεργαστής (#emph[movlt]).
\
Τέλος προτιμάται η εντολή #emph[svc] έναντι της #emph[swi] για την πρόκληση των interrupts από τα read / write system calls.

\
Aκολουθούν κάποια παραδείγματα εκτέλεσης:

#bash_box("../ex2/ex2_exec.txt")



#pagebreak() 

== Eρώτημα 3ο 
\
Δημιουργήθηκαν 4 ξεχωριστά αρχεία για την κάθε συνάρτηση γραμμένα σε arm assembly όπως φαίνονται παρακάτω. Σε κάθε ένα από αυτά δηλώνεται ως .global το όνομα της συνάρτησης και ακολουθεί ο προσδιορισμός του τύπου τους ως function. Το αποτέλεσμα αποθηκεύεται στον register r0. Για την επιστροφή στο σωστό σημείο όλα τερματίζουν με την εντολή #emph[bx lr] η οποία κάνει jump στο return address που βρίσκεται αποθηκευμένο στον lr. Ο ορισμός του .size στο τέλος βοηθάει τον linker να καθορίσει τα αρκιβή όρια του ορισμού της συνάρτησης στο symbol table. 

#my_sourcefile("../ex3/src/strlen.s")
\
#my_sourcefile("../ex3/src/strcmp.s")
\
#my_sourcefile("../ex3/src/strcpy.s")
\
#my_sourcefile("../ex3/src/strcat.s")
\
Για την μεταγλώττιση και σύνδεση των object files χρησιμοποιήθηκε το ακόλουθο Makefile που παράγει τα .o αρχεία μέσω pattern matching με τα κατάλληλα .s. Aκόμη για συντομία χρησιμοποιούνται τα \$^ \$< \$\@ arguement directives.

#my_sourcefile("../ex3/src/Makefile", lang:"make")
\
\
Tο αποτέλεσμα της make είναι το ακόλουθο: 

#bash_box("../ex3/linker.txt")
\
Για την επιβεβαίωση της ορθής λειτουργίας του τελικού εκτελέσιμου χρησιμοποιήθηκε το ακόλουθο script που συγκρίνει τα αρχεία εξόδου του #emph[string_manipulation.out] που παρήχθη από την παραπάνω διαδικασία με τις συναρτήσεις δηλωμένες ως extern, με εκείνα που δημιουργούνται από το ίδιο sourcefile #emph[string_manipulation.c] κάνοντας include την \<string.h> και χρησιμοποιώντας τις built-in συναρτήσεις με το ίδιο όνομα.

#bash_box("../ex3/outputs/cmp_results.sh")
\
Τρέχοντας το επιβεβαιώνω τα αποτελέσματα :
#bash_box("../ex3/outputs/cmp_out.txt")




