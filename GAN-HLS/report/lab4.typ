#import "./template.typ":report
#import "@preview/codelst:2.0.2": sourcecode, sourcefile, codelst
#import "@preview/showybox:2.0.3": showybox

#show: report.with(
  title: "Σχεδιασμός Ενσωματωμένων Συστημάτων",
  subtitle: "4η Εργαστηριακή Άσκηση",
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
      fill: rgb("#FFFFFF"), // Green text color for terminal style
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

== ΑΣΚΗΣΗ 1. Performance & Resource Measurement

=== (Α) Estimation performance στο unoptimized design 
\ 

Μη έχοντας επιχειρήσει κάποια βελτιστοποίηση, οι εκτιμώμενοι κύκλοι εκτέλεσης της εφαρμογής καταγράφονται ίσοι με 683780 όπως φαίνεται στο στιγμιότυπο που ακολουθεί. Ακόμη παρατίθενται οι λεπτομέρειες από το HLS Report για τα Loops και βλέπουμε ότι ο compiler δεν έχει πραγματοποιήσει κανένα pipelined design αφού δεν δώσαμε άλλωστε κατάλληλα hints.

\

#align(center)[
#image("../screenshots/unopt.png", width:70%)
\
#image("../screenshots/unopt_report.png",width:70%)
]
\

=== (B) Hardware Evaluation στο unoptimized design 
\

Ακολουθώντας τα βήματα παραγωγής του bitstream και εκτέλεσης στο Zybo, κατγράφεται η έξοδος όπως τυπώθηκε στο screen terminal. Συγκεκριμένα, οι κύκλοι που αποιτούνται για την hardware version  του αλγορίθμου υπολογίστηκαν ίσοι με 682899 ενώ το speedup σε σχέση με την software version είναι 2.16059. Παρατηρώ ότι η προσομοίωση είναι αρκετά αντικειμενική στην εκτίμηση των κύκλων και μάλλον ελάχιστα πιο απαισιόδοξη το οποίο βολεύει για την ανάλυση μας έπειτα.
\

#bash_box("../outputs/unopt.txt")

=== (Γ) Design Space Exploration 
\

Τα optimisations που δοκιμάστηκαν εκμεταλλεύονται τις δυνατότητες για παραλληλισμό σε επίπεδο δεδομένων (data-level parallelism) και ταυτόχρονες προσβάσεις μνήμης. Παρατηρώ ότι όλα τα layers του νευρωνικού δικτύου δεν παρουσιάζουν εξαρτήσεις στο εσωτερικότερο loop οπότε τα iterations πάνω στην μεταβλητή j μπορούν να εκτελεστούν ταυτόχρονα. Με την τρέχουσα αναπαράσταση των διανυσμάτων βαρών W1, W2, W3 σε ένα εννοιαίο πίνακα για το καθένα, μπορούν να πραγματοποιηθούν το πολύ 2 προσβάσεις ανά κύκλο. Για τον λόγο αυτό, πραγματοποιείται διαμέριση σε υποπίνακες μεγέθους όσο το άνω όριο του εκάστοτε εσωτερικού loop ως προς τις στήλες για το W1 και ως προς τις γραμμές για τα W2, W3. Έτσι, σε 1 κύκλο επιτρέπουμε στην εφαρμοφή να διαβάσει όλα τα δεδομένα που απιτούνται. Παιρεταίρω κατάτμιση δεν έχει νόημα και θα αποτελούσε μονάχα σπατάληση πόρων. Για να επιτευχθεί το παραπάνω, ορίζεται ρητά unroll με παράγοντα ίσο με το εύρος των επαναλήψεων (ακριβώς ίδια αποτελέσματα λαμβάνονται και με την χρήση pipeline). Tέλος, ορίζω τις επιμέρους συναρτήσεις relu, tanh ως inline (αν και ο compiler τις έκανε έτσι και αλλιώς). Oι προσθήκες φαίνoνται στο απόσπασμα κώδικα που ακολουθεί: 

\

#my_sourcefile("../src/network.cpp",
highlighted: (7,16,36,37,38,40,41,43,52,60,63,73,81,84,97,100),
  highlight-color:  rgb(255, 255, 102).lighten(40%),) 

\
Οι συνολικοί κύκλοι που απαιτούνται με βάση την προσομοίωση για το optimized design είναι ίσοι με 12031 όπως καταγράφηκαν από το SDSoC: 

#align(center)[
#image("../screenshots/opt1.png", width:70%)
]


Ακολουθώντας ξανά τα βήματα για την εξαγωγή του bitstream για το optimized code και loading στην sd card του Zybo, οι actual κύκλοι υπολογίστηκαν ίσοι με 12207 ενώ το speedup ανέρχεται σε 120.773. Τα αποτελέσματα απεικονίζονται παρακάτω όπως τυπώθηκαν στο screen terminal :
\
#bash_box("../outputs/opt1.txt")

\
=== Επιπλέον βελτιώσεις 

Για τα layers 2 και 3 δεν υπάρχουν εξαρτήσεις μεταξύ των i επαναλήψεων οπότε η εκτέλεση μοιράζεται σε 2 μέρη που μπορούν να υπολογιστούν ταυτόχρονα. Κανονικά απαιτείται και διπλασιασμός του partitioning ως προς την άλλη διάσταση όμως υπερβαίνει τους διαθέσιμους πόρους του Zybo, oπότε επωφελούμαι μόνο από τα overheads των branches στα loops. O ανανεωμένος κώδικας ακολουθεί:

\
#my_sourcefile("../src/network2.cpp",
highlighted: (79,80,81,85,86,87,88,90,91,99,100,104,105,106,107,109,110),
  highlight-color:  rgb(255, 255, 102).lighten(40%),)

Ο νέος εκτιμώμενος χρόνος σε κύκλους καταγράφηκε ίσος με 11875. 

#align(center)[
#image("../screenshots/opt2.png", width:70%)
]

\
Oι αντίστοιχοι κύκλοι που υπολογίστηκαν στο Zybo :
#bash_box("../outputs/opt2.txt")



=== (Δ) HLS Resource Profile 

Για την αρχική υλοποίηση τα loop latency details φαίνονται παρακάτω:

#align(center)[
#image("../screenshots/opt1_report.png", width:70%)
]
Έχει επιτευχθεί πλήρως pipelined design όμως στο layer 3, το οποίο είναι και το bottleneck, το Iteration latency είναι 10 και πιθανά οφείλεται στην πολυπλοκότητα της tanh συγκριτικά με την relu και στο πέρασμα του αποτελέσματος στο output y το οπόιο δεν μπορεί να παραληλοποιηθεί περαιτέρω αφού η μεταφορά γίνεται ως byte streams.

\
Για την δεύτερη υλοποίηση τα αντίστοιχα αποτελέσματα είναι : 
#align(center)[
#image("../screenshots/opt2_report.png", width:70%)
]

Παρατηρούμε ότι στο layer 3 δεν επιτεύχθηκε πλήρως pipeline, ωστόσο η επίδοση είναι συνολικά καλύτερη.

\

Tέλος, στο *Expression* section κατγράφονται όλοι οι καταχωρητές που χρησιμοποιούνται για πολλαπλασιασμούς, προσθέσεις και logical operations. Στην περίπτωση των πρώτων, δεν χρειάζονται καθόλου DSPs και εκτελούνται αποκλειστικά σε LUTs, ενώ στην περίπτωση των πολλαπλασιασμών χρειάζεται 1 DSP ανά πράξη.
Η εφαρμογή δίνει όλα τα DSPs (80 συνολικά) σε πολλαπλασιασμούς καθώς είναι η πιο computational intensive πράξη στον συγκεκριμένο αλγόριθμο και με τον τρόπο αυτό εκτελείται σε 1 κύκλο, αφήνοντας ελεύθερα LUTs και FFs για άλλα computations. Ενδεικτικά απεικονίζονται κάποιες διαφορετικές καταγραφές ανάθεσης πόρων : 
\

#align(center)[
#image("../screenshots/Expressions.png", width:80%)
]

#pagebreak()

== ΑΣΚΗΣΗ 2. Quality Measurement

\
(Α) Οι combined εικόνες για τα ζητούμενα indices (10,11,12) που παράχθηκαν από το software και το hardware αντίστοιχα απεικονίζονται στην συνέχεια : 

#columns(2)[
#figure(
  image("../img/sw_10.png",width:auto, height:16em),
  caption : "SW, idx = 10"),

#figure(
  image("../img/sw_11.png",width:auto, height:16em),
  caption : "SW, idx = 11"),

#figure(
  image("../img/sw_12.png",width:auto, height:16em),
  caption : "SW, idx = 12"),

#figure(
  image("../img/hw_10.png",width:auto, height:16em),
  caption : "HW, idx = 10"),

#figure(
  image("../img/hw_11.png",width:auto, height:16em),
  caption : "HW, idx = 11"),

#figure(
  image("../img/hw_12.png",width:auto, height:16em),
  caption : "HW, idx = 12")
]

#pagebreak()

\
(B) Για τον νέο υπλογισμό των τιμών της εφαπτομένης στο εύρος [-2,2] και για την ακρίβεια στα σημεία που προκύπτουν από την κβάντιση του άνω διαστήματος με βήμα ίσο με #emph[BITS_EXP], χρησιμοποιήθηκε το ακόλουθο python script που παράγει αυτόματα όλα τα header files: 
\
#my_sourcefile("../src/quantization/tanh.py") 

\
Στον αρχικό κώδικα προστίθενται τα κατάλληλα definitions : 

#my_sourcefile("../src/network_bits.cpp", 
highlighted: (5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21),
  highlight-color:  rgb(255, 255, 102).lighten(40%),) 

\

Tέλος, για την συγρκιτική ανάλυση των τιμών μόνο του παραγόμενου αρχείου εξόδου και εφόσον ο ακριβής προσδιορισμός των κύκλων έχει μετρηθεί στην άσκηση 1 πάνω στο Zybo, χρησιμοποιήθηκε το ακόλουθο script για την μεταγλώττιση του πηγαίου κώδικα της αφρμογής και προσομοίωση του hardware υπολογισμού στον τοπικό μου υπολογιστή:

#bash_box("../src/emulations.sh")

\
Οι εικόνες που προκύπτουν από την επεξεργασία των αρχείων εξόδου στο jupyter notebook που μας δόθηκε απεικονίζονται παρακάτω: 

\

#figure(
  table(
    columns: 3,
    align: center,
    stroke: none,
    [], [], [],
    [], [#emph[*BITS = 3*]], [],
    [#figure(
    image("../img_results/HW_bits3_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits3_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits3_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],

    [], [], [],
    [], [#emph[*BITS = 4*]], [],
    [#figure(
    image("../img_results/HW_bits4_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits4_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits4_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],

    [], [], [],
    [], [#emph[*BITS = 5*]], [],
    [#figure(
    image("../img_results/HW_bits5_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits5_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits5_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],
  )
)

#pagebreak() 

#figure(
  table(
    columns: 3,
    align: center,
    stroke: none,
    
    [], [], [],
    [], [#emph[*BITS = 6*]], [],
    [#figure(
    image("../img_results/HW_bits6_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits6_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits6_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],

    [], [], [],
    [], [#emph[*BITS = 7*]], [],
    [#figure(
    image("../img_results/HW_bits7_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits7_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits7_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],

    [], [], [],
    [], [#emph[*BITS = 8*]], [],
    [#figure(
    image("../img_results/HW_bits8_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits8_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits8_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],
  )
)

#pagebreak() 

#figure(
  table(
    columns: 3,
    align: center,
    stroke: none,
    [], [#emph[*BITS = 9*]], [],
    [#figure(
    image("../img_results/HW_bits9_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits9_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits9_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],
    [], [], [],

    [], [#emph[*BITS = 10*]], [],
    [#figure(
    image("../img_results/HW_bits10_idx10.png",width:auto, height:16em),
    caption : "HW, idx = 10")], 
    [#figure(
    image("../img_results/HW_bits10_idx11.png",width:auto, height:16em),
    caption : "HW, idx = 11")], 
    [#figure(
    image("../img_results/HW_bits10_idx12.png",width:auto, height:16em),
    caption : "HW, idx = 12")],

  )
)

\
Οι εικόνες που παράγονται από το software είναι πανομοιότυπες όπως είναι αναμενόμενο, εφόσον η ακρίβεια των floating point αριθμών της αρχιτεκτονικής του μηχανήματος είναι fixed και ο κώδικας δεν μεταβάλλεται. 
Γι' αυτό, άλλωστε, χρησιμοποιούνται έπειτα ως σημείο αναφοράς των σφαλμάτων στο επόμενο ερώτημα. 
\
Παρατηρώ ότι καθώς αυξάνoνται τα BITS, η εικόνες έχουν καλύτερη ποιότητα για όλα τα indices με ένα άνω φράγμα στα 7.
Συγκεκριμένα, για τις περιπτώσεις BITS = 4, ο θόρυβος είναι μεγάλος και τα περιθώρια των αριθμών δεν είναι καθόλου σαφή, 
ενώ για BITS = 10 τα νούμερα διακρίνονται πλήρως από το background και έχουν σαφή περιθώρια. 
\
Αυτό οφείλεται στον διαφορετικό παράγοντα κβάντισης σε κάθε περίπτωση. Μικρότερο step (δηλ. μεγαλύτερο quantization) οδηγεί σε πιο λεπτομερή απεικόνιση των τιμών εισόδων και επηρεάζει την ευαισθησία της συνάρτησης ενεργοποίησης στο layer 3 που είναι μάλιστα και το εξωτερικό επίπεδο του νευρωνικού. Οδηγεί, λοιπόν, σε πιο ακριβείς προβλέψεις.

#pagebreak()


(Γ) Oι μετρικές που χρησιμοποιήθηκαν για την ανάλυση της ποιότητας ανακατσκευής των εικόνων είναι η Maximum Pixel Error που δίνεται από τον τύπο:
$
"Max Error" = max(| I_"sw"(i,j) - I_"hw"(i,j)|)
$

και η Peak Signal-to-Noise Ratio που δίνεται από τον τύπο :
$
  "PSNR" = 10 log_{10} ("MAX"_I^2 / "MSE")
$ , όπου 
$ 
  "MSE" = 1 / "MN" sum_(i=1)^M sum_(j=1)^N (I_"sw"(i,j) - I_"hw"(i,j))^2 
$


Οι γραφικές παραστάσεις και ο πίνακας που ακολουθούν, συνοψίζουν τις τιμές τους όπως εκτιμήθηκαν από τον επιμέρους κώδικα του jupyter notebook που μας δόθηκε, για όλους τους πιθανούς συνδυασμούς #emph[(BITS, idx)].

\
#image("../img_results/quality_plots.png")

\
#figure(
  table(
    columns: 4,
    align: center,
    stroke: none,
    table.header([*BITS*], [*index*], [*Maximum Pixel Error*], [*Peak Signal-to-Noise Ratio*]),
    [3], [10], [255], [13.598006427897612],
    [3], [11], [255], [10.951273518816551],
    [3], [12], [255], [14.412458999930394],
    [4], [10], [255], [14.051663945384881],
    [4], [11], [249], [14.634988266184102],
    [4], [12], [255], [13.525831164368576],
    [5], [10], [200], [20.32370043626041],
    [5], [11], [155], [22.354010215775265],
    [5], [12], [229], [19.407263480245117],
    [6], [10], [91], [28.159872103979914],
    [6], [11], [98], [27.496646597732962],
    [6], [12], [93], [29.23557136050292],
    [7], [10], [53], [32.77870229255662],
    [7], [11], [39], [37.09878984137624],
    [7], [12], [84], [32.654500509492976],
    [8], [10], [16], [42.6822168370888],
    [8], [11], [17], [42.56993337396983],
    [8], [12], [13], [47.065287020211215],
    [9], [10], [8], [50.76968548527325],
    [9], [11], [7], [49.98975523417636],
    [9], [12], [6], [51.955130625734746],
    [10], [10], [5], [54.08543347142643],
    [10], [11], [5], [52.556099880280584],
    [10], [12], [4], [53.76982650203158]
  ),
  caption: "Aναλυτικός πίνακας μετρικών αξιολόγησης"
)
\
\
Το Max Pixel Error δείχνει την χειρότερη απόκλιση ενός μεμονωμένου σημείου, άρα παρέχει κάποια πληροφορία σχετικά με το μέγεθος της διαστρεύλωσης που μπορεί να έχει η εικόνα σε ακραίες περιπτώσεις. 
Το PSNR υπολογίζεται με βάση τον μέσο όρο σφαλμάτων των pixels, είναι λογαριθμικό επομένως εκφράζει μια πιο σφαιρική εκτίμηση του θορύβου πάνω στην εικόνα. 
Παρ'όλα αυτά δεν λαμβάνει υπ'οψιν τον βιολογικό παράγοντα του ανθρώπινου ματιού, γι'αυτό ενώ οι καμπύλες προκύποτυν γνησίως αύξουσες, δεν μπορούμε να διακρίνουμε ανάλογη βελτίωση στις εικόνες από τα 6 BITS και πάνω. 
Αντιθέτως, οι καμπύλες του Max Error φτάνουν ικανοποιητικό σημείο σύγκλισης στα 8 BITS και είναι πιο σταθερές από εκεί και πάνω. 
Με βάση τα οπτικά αποτελέσματα αποτελέσματα, η πρώτη μετρική είναι πιο αντιπροσωπευτική. Προσωπικά, δεν διακρίνω διαφορά ούτε με τα 7 BITS.

\
Δεδομένου ότι η αναπαράσταση των pixels με περισσότερα bits κοστίζει σε απαιτήσεις μνήμης και η βέλτιστη ποιότητα της εικόνας στα πλάισια που συλλαμβάνει το ανθρώπινο μάτι πετυχαίνεται με την χρήση 7 bits κατά την γνώμη μου, θα το θεωρούσα ιδανική επιλογή. Το νευρωνικό δίκτυο δεν επωφελείται από περισσότερη ακρίβεια και έχει ήδη εκαπιδευτεί να διαχωρίζει τα patterns.

==== Παράρτημα 

O κώδικας για την εξαγωγή των γραφικών παραστάσεων μέσα στο τροποποιημένο  #emph[plot_outputs.ipynb] δίνεται παρακάτω: 

#my_sourcefile("../src/quantization/plots.py")

