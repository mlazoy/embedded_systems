#import "/report-template/template.typ": *

// #import "@preview/codelst:2.0.2": sourcecode, sourcefile, codelst
// #import "@preview/showybox:2.0.3": showybox

#show: project.with(
  title: "1η Εργαστηριακή Άσκηση",
  authors: (
    "Αβραμίδης Σταύρος A.M. 17811",
    "Λάζου Μαρία-Αργυρώ A.M. 20192",
  ),
  date: datetime.today(),
)

/****************************
* Document body, start here.*
*****************************/


= Μέρος 1ο


== Εισαγωγή
\

Στο 1ο μέρος της άσκησης ζητήθηκε η βελτιστοποίηση ενός αλγορίθμου Parallel Hierarchical One Dimensional Search (PHODS).
Ο αλγόριθμος PHODS είναι ένας αλγόριθμος εκτίμησης κίνησης (Motion Estimation),
ο οποίος έχει στόχο να ανιχνεύσειτη κίνηση των αντικειμένων μεταξύ δύο διαδοχικών εικόνων (frame) του
βίντεο. Ο αλγόριθμος βελτιστοποιήθηκε για το S7G2, έναν μικροελεγκτή της Renesas.

\
\

== Ζητούμενα
\

Μέσω του Datasheet και SpecSheet του dev-board εξάγουμε τις παρακάτω πληροφορίες: #footnote["https://www.renesas.com/en/products/microcontrollers-microprocessors/renesas-synergy-platform-mcus/s7g2-240-mhz-arm-cortex-m4-cpu#documents"]

#align(
  block(inset: (left: 3em, top: 0.5em))[
    - 640KB SRAM
    - 4MB Flash
    - 240MHz CPU clock frequency
    - Cortex-M4 CPU
    - Flash Cache
      - Flash cache 1 - Instruction cache: 256 bytes
      - Flash cache 2 - CPU operands: 16 bytes
      - Prefetch Buffer: 32 bytes
  ],
)

\

Από την σελίδα 1763 του _"Groups User manual"_ για τον εν λόγω μικροελεγκτή, μπορούμε να δούμε ότι η FCACHE είναι απενεργοποιημένη. Πάραυτα, το BSP ενεργοποιεί την cache, όταν καλείται η ρουτίνα του Reset Handle, κατά την αρχικοποίηση των ρολογιών (bps_clocks.c).

\ \

== Υλοποίηση
\

Για τον σκοπό της άσκησης, η σημαία βελτιστοποιήσεων του μεταγλωττιστή τέθηκε σε _"-Ο0"_. Για τον λόγο αυτό, πέρα των loop transformation, που είναι ο κύριος σκοπός της άσκησης, έγιναν και μερικές περαιτέρω βελτιστοποιήσεις, πού ανώτερα επίπεδα βελτιστοποίησης θα μπορούσαν να εξαλείψουν. Την ίδια στιγμή, όμως, αποφεύχθηκαν βελτιστοποιήσεις, που θα άλλαζαν την βασική δομή του αλγορίθμου (λ.χ. μετατροπή int σε uint8_t), θεωρώντας τες εκτός του πλαισίου της άσκησης.

\

Αναλυτικότερα στον δοσμένο κώδικα, έγιναν οι εξής βελτιστοποιήσεις:
#align(
  block(inset: (left: 3em, top: 0.5em))[
    1. Loop Merging (x3) στις των loop i, k, l. (Ακόλουθο αυτού, sub-expression elimination του p1)
    2. Loop Merging των 2 εξωτερικών loop (i,j) και (x,y) του κύριου αλγορίθμου και τις αρχικοποίησης των vectors_x και vectors_y.
    3. Απαλοιφή των πολλαπλών memory accesses των vectors_x[x][y] και vectors_y\[x\]\[y\].
    4. Loop Unrolling του loop i από -S εώς S+1. *\**
      - Αυτό έχει ως αποτέλεσμα την απλοποίηση της περίπτωσης για i=0, αφού οι συνθήκες των if/else είναι κοινές και κατα συνέπεια p2 = q2 και κατ'επέκταση p1-q2 = p1-p2.
    5. SubExpression Elimination για όλες τις πράξεις που γίνονται πάνω από μια φορά εντός των εσωτερικών των loop \(i, k, l\).
    6. Υλοποίηση των πολλαπλασιασμών στα x,y loop, ως running sum, αντί για πολλαπλασιασμό κάθε φορά.
    7. Τέλος, παρατηρούμε ότι η εντολές των if/else που προσαυξάνουν τα distx και disty, πραγματοποιούν πρακτικά μια πράξη abs. Για τον λόγο αυτό, η πράξη της αφαίρεσης και αφαίρεσης του προσήμου υλοποιήθηκε με βέλτιστο τρόπο σε assembly. \(Συνοπτική επεξήγηση, ακολουθεί παρακάτω\).

    \

    #text(size: 0.8em)[*\** Δεν εξετάστηκε, αν αντί για unroll, ήταν ευνοϊκότερη αντ' αυτού η χρήση if-else για την περίπτωση του i=0, με την προϋπόθεση ότι το loop body θα χωράει στην instructions cache.]
  ],
)
\

#underline[*Η ορθότητα του αλγορίθμου επαληθεύτηκε με την χρήση του randomized unit testing, στον προσωπικό μας υπολογιστή.*]

\ \
Ο τελικός κώδικας, μετά τις βελτιστοποιήσεις, είναι ο εξής:

#my_sourcefile(read("../part1/phods.h"), "phods.h")

\

#my_sourcefile(read("../part1/hal_entry.c"), "hal_entry.c")

\

Όσον αφορά την υλοποίηση της πράξης της αφαίρεσης με βέλτιστο τρόπο σε assembly, έγινε η ακόλουθη υλοποίηση:
#align(
  block(inset: (left: 4em))[
    ```nasm
    SUBS %0, %1, %2
    TI
    NEGMI %0, %0
    ```
  ],
)

#let f = footnote[
  #text("Το IT block (If-Then block) στους επεξεργαστές ARM είναι ένα χαρακτηριστικό του instruction set της αρχιτεκτονικής ARM Thumb-2, που επιτρέπει την εκτέλεση υπό συνθήκη μιας ομάδας εντολών")

  https://developer.arm.com/documentation/den0042/a/Unified-Assembly-Language-Instructions/Instruction-set-basics/Conditional-execution
]
Αρχικά, υλοποιούμε την αφαίρεση, η οποία ενημερώνει το αντίστοιχο flag, αν το αποτέλεσμα της είναι αρνητικό. Κατόπιν εισάγουμε ένα IT (If/Then) block#f, που θα εκτελεστεί μόνο αν η συνθήκη του Negative flag, έχει τεθεί. Έτσι, μπορούμε να κάνουμε τις πράξεις της αφαίρεσης και abs(), με μόνο 2 εντολές κι είναι και branchless, μη επιβαρύνοντας έτσι τον branch predictor.

\ \
== Χρόνοι εκτέλεσης
\

Ο αρχικός χρόνος εκτέλεσης του αλγορίθμου ήταν 442,530 κύκλοι ή #calc.round(442530 /240000, digits: 2)ms.
Μετά τις βελτιστοποιήσεις, ο χρόνος εκτέλεσης μειώθηκε στους 146,283 κύκλους ή #calc.round(146283 /240000, digits: 2)ms.


#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    table.header([Υλοποίηση], [Κύκλοι], [Χρόνος Εκτέλεσης (ms)]),
    [Naive], [442530], [#calc.round(442530 / 240000, digits: 2)],
    [Optimized], [146283], [#calc.round(146283 / 240000, digits: 2)],
  ),
  caption: "Χρονοι εκτέλεσης πριν και μετά τις βελτιστοποιήσεις",
)


#figure(
  image("./naive_vs_optimized_phods.svg", width: 60%),
  caption: "Σύγκριση χρόνων εκτέλεσης",
)

\

Καταλήγουμε λοιπόν να έχουν Speedup = 3.025.

\

Ενδιαφέρον επίσης παρουσιάζει η απενεργοποίηση της FCACHE, κι η σύγκριση του χρόνου του αλγορίθμου. Με την επίδοση να πέφτει στους 184285 κύκλους (26% Αύξηση!).

\ \

== Μεταβολή του Block Size
\

Στην συνέχεια ζητήθηκε, να συγκριθεί και να αναλυθεί η επίδραση του Block Size (B) στον χρόνο εκτέλεσης του αλγορίθμου.

\

#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    table.header([B], [Κύκλοι], [Χρόνος Εκτέλεσης (ms)]),
    [1], [273050], [#calc.round(273050 / 240000, digits: 2)],
    [2], [179422], [#calc.round(179422 / 240000, digits: 2)],
    [5], [146283], [#calc.round(146283 / 240000, digits: 2)],
    [10], [139770], [#calc.round(139770 / 240000, digits: 2)],
  ),
  caption: "Συγκριτικά αποτελέσματα ανά Block Size",
)

\

Παρατηρούμε ότι όσο μεγαλύτερο είναι το Block Size, τόσο μειώνεται ο χρόνος εκτέλεσης του αλγορίθμου. Αυτό είναι λογικό, αφού στον αλγόριθμο έχουμε 2 ομάδες loop, τα εξωτερικά(x,y) που είναι αντιστρόφως ανάλογα του Β και τα εσωτερικά (k,l), πού είναι ανάλογα του Β. Ο συνολικός αριθμός επαναλήψεων συνεπώς μένει ίδιος, όμως όσο το φόρτο των υπολογισμών μετατοπίζεται προς το εσωτερικό, τόσο τα memory accesses, αλλά και διάφοροι υπολογισμοί μειώνονται. Την ίδια στιγμή δίνεται η ευκαιρία να "χτυπήσουμε" περισσότερο την instruction cache, αφού ο αλγόριθμός περνάει μεγαλύτερο χρονικό διάστημα στον ίδιο κώδικα.

\ \

== Ορθογώνιο Παράθυρο
\

Στην συνέχεια, ζητήθηκε η υλοποίηση του αλγορίθμου με ορθογώνιο παράθυρο, διαστάσεων $B_x, B_y$.
Η υλοποίηση τροποποιείται όπως επισημαίνεται παρακάτω:

#my_sourcefile(
  read("../part1/phods_rect.h"),
  "phods_rect.h",
  highlighted: (10, 11, 26, 27, 28, 29, 72, 81, 133, 139, 183, 192, 243, 247),
  highlight-color: green.lighten(60%),
)

\ \

Οι χρόνοι εκτέλεσης του αλγορίθμου με ορθογώνιο παράθυρο, για διάφορες τιμές των \(B_x, B_y\), παρουσιάζονται στον παρακάτω πίνακα: \

#figure(

  table(
    columns: 5,
    align: center,
    stroke: (x, y) => (
      left: if x == 1 {
        1pt
      } else {
        0pt
      },
      right: 0pt,
      top: if y <= 1 {
        1pt
      } else {
        0pt
      },
      bottom: 1pt,
    ),
    [*Bx\\By*], [1], [2], [5], [10],
    [*1*], [266072], [200912], [161836], [148752],
    [*2*], [219302], [177508], [152318], [143931],
    [*5*], [191229], [163336], [ 146609], [146609 ],
    [*10*], [ 181803], [ 158613], [144706], [140079],
  ),
  caption: "Συγκεντρωτικά αποτελέσματα ανά \(B_x, B_y\)",
)
#figure(
  image("./bx_by_heatmap.svg", width: 60%),
  caption: "Χρόνοι εκτέλεσης ανά \(B_x, B_y\)",
)

\

Για τους ίδιους λόγους που αναφέρθηκαν και παραπάνω, καλύτερο χρόνο επιτυγχάνει η υλοποίηση για $B_x = 10, B_y = 10$.

\

=== *Ευριστικός Αλγόριθμος*

Μία ευριστική μέθοδος, για την ανίχνευση κινήσεων στα frames, θα ήταν η τυχαία αναζήτηση block, κι όχι η αναζήτηση όλων των block. Αν το block, εμφανίζει αλλαγές μπορούμε να κινηθούμε ανάλογα με αυτές. Πρακτικά, ο αριθμός ο αριθμός των τυχαίων block που επιλέγουμε σε κάθε βήμα, αποτελεί και το quality factor του αλγορίθμου. Τέλος, η δημιουργία sub-blocks, θα μπορούσε να βελτιώσει την ποιότητα της συμπίεσης (όπως λ.χ. το H.265/HEVC).



#pagebreak()

= Μέρος 2ο

#let bash_box(file, lang: auto, ..args) = {
  show table.cell.where(y: 0): set text(weight: "regular")

  showybox(
    frame: (
      body-color: rgb("#111"),
      thickness: 0.6pt,
    ),
    breakable: false,
    width: 100%,
    align: center,
  )[
    #set text(
      font: "DejaVu Sans Mono",
      size: 0.8em,
      fill: lime, // Green text color for terminal style
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

\

== 1.
\

Προσομοιώνουμε πρώτα στο gem5 την κάτωθι αρχιτεκτονική (CPU + main memory):

\

#figure(
  image("./arch1.png", width: 30%),
  caption: "Αρχιτεκτονική 1",
)

\

// !! Αυτό έχει και τα 2 αποτελέσματα ??
και καταγράφουμε τους κύκλους που απαιτήθηκαν:

#bash_box("../part2/m5out.txt")

\

== 2.
\

Ομοίως για την ακόλουθη αρχιτεκτονική:

\

#figure(
  image("./arch2.png", width: 30%),
  caption: "Αρχιτεκτονική 2",
)

\

#bash_box("../part2/m5out_cache.txt")

\

// TODO: Σχόλια

#figure(
  image("../part2/arch1_vs_arch2_plot.svg", width: 60%),
  caption: "Σύγκριση συνολικών κύκλων εκτέλεσης αρχιτεκτονικών",
)

\

Είναι προφανές, ότι με την προσθήκη κρυφής μνήμης μειώνεται σημαντικά το latency. Τα δεδομένα βρίσκονται πιο κοντά στον επεξεργαστή και δεν χρειάζεται να πληρώνουμε το overhead για την μεταφορά τους από την κύρια μνήμη σε κάθε single operation παρά μόνο όταν έχουμε misses. Επιπρόσθετα, ο επεξεργαστής που προσημειώνουμε (X86TimingSimpleCPU#footnote([https://www.gem5.org/documentation/general_docs/cpu_models/SimpleCPU#timingsimplecpu])), δεν έχει pipeline και χρειάζεται να περιμένει την ολοκλήρωση των προηγούμενων εντολών πριν εκτελέσει τις επόμενες. Συνεπώς, η προσθήκη κρυφής μνήμης και κατ'επέκταση μείωση του χρόνου αναμονής των δεδομένων, μειώνει το stall time και τον συνολικό αριθμό κύκλων εκτέλεσης. Τέλος, η προσθήκη της Instruction L1 cache, είναι σίγουρα οφέλη, αφού το πρόγραμμα υπό εξέταση, απαρτίζεται κατα κύριο λόγο δύο for-loop, οπότε εκτελούνται συνεχώς τα ίδια κομμάτια κώδικα.

\

== 3.
\
Με το ακόλουθο script τρέχουμε τις προσομοιώσεις με τις διαφορετικές τιμές unrolling factor (2, 4, 8, 16, 32) και απεικονίζουμε τα αποτελέσματα:

#my_sourcefile(read("../part2/unrolling.sh"), "unrolling.sh")

\

#figure(
  image("../part2/unrolling.svg", width: 60%),
  caption: "Συγκριτικό διάγραμμα για το Unrolling Factor",
)

\

O αριθμός των κύκλων μειώνεται σημαντικά όσο το unrolling factor αυξάνεται. Δεδομένου ότι, έχουμε single threaded εκτέλεση σε επεξεργαστή #underline("χωρίς") pipelining, η βελτίωση οφείλεται αποκλειστικά στην μείωση του overhead των μηχανισμών των loops (κόστος αύξησης loop counter, σύγκριση κλπ.)

\

== 4.
\

Με το ακόλουθο script τρέχουμε τις προσομοιώσεις με τα διαφορετικά μεγέθη L1 Data Cache (2kB, 4kB, 8kB, 16kB, 32kB, 64kB) και απεικονίζουμε τα αποτελέσματα:

#my_sourcefile(read("../part2/cache.sh"), "cache.sh")

\

#figure(
  image("../part2/cache.svg", width: 60%),
  caption: "Συγκριτικό διάγραμμα για το L1 Data Cache Size",
)

\

Αυξάνοντας το μέγεθος της L1 Data Cache παρατηρούμε μικρή βελτίωση από τα 2ΚΒ έως 8ΚΒ και ραγδαία επιτάχυνση από τα 8ΚΒ στα 16ΚΒ, ενώ μετά δεν υπάρχει κλιμάκωση. Ανατρέχοντας στην υλοποίηση της εν λόγω L1 cache#footnote([https://github.com/gem5/gem5/blob/stable/configs/learning_gem5/part1/caches.py]), βρίσκουμε ότι πρόκειται για μία 2-way associative cache. Εικάζουμε, λοιπόν, πώς η αύξηση του μεγέθους της cache, επιτρέπει την αποθήκευση περισσότερων δεδομένων και την μείωση των conflict misses. Στα 16ΚΒ ολόκληρο το Data Set κατάφερε τελικά να χωρέσει στην κρυφή μνήμη πληρώνοντας πλέον μόνο τα compulsory misses, οπότε περαιτέρω αύξηση της L1 Data Cache επιφέρει μικρή βελτίωση.

\ \

=== Εξαντλητική Αναζήτηση

Με την μέθοδο της εξαντλητικής αναζήτησης, τρέχουμε τις προσομοιώσεις για όλους τους πιθανούς συνδυασμούς των μνημών του συστήματος και του unrolling factor που προκύπτουν από τα σύνολα που δίνονται (συνολικά 6 x 6 x 4 x 5 = 720):

\


#figure(
  table(
    columns: 2,
    align: center,
    table.header([Parameters], [Values]),
    [L1D Cache Size], [2kB, 4kB, 8kB, 16kB, 32kB, 64kB],
    [L1I Cache Size], [2kB, 4kB, 8kB, 16kB, 32kB, 64kB],
    [L2 Cache Size], [128kB, 256kB, 512kB, 1024kB],
    [Unrolling Factor], [2, 4, 8, 16, 32],
  ),
  caption: "Συνδυασμοί παραμέτρων",
)

\

#my_sourcefile(read("../part2/exhaustive.py"), "exhaustive.py")


\

Για την εξαγωγή των pareto βέλτιστων σημείων του χώρου εξερεύνησης όσον αφορά στο συνολικό μέγεθος μνήμης (L1D + L1I + L2) και τον αριθμό κύκλων ταυτόχρονα εφαρμόζουμε την built-in μέθοδο paretoset με συνάρτηση ελαχιστοποίησης και στα 2 μεγέθη και καταγράφουμε τα αποτελέσματα:

#my_sourcefile(read("../part2/find_pareto.py"), "find_pareto.py")

\
#figure(
  table(
    columns: 6,
    align: center,
    table.header([L1D], [L1I], [L2], [Unrolling Factor], [Total Memory (KB)], [Latency(CC)]),
    [2], [2], [128], [8], [132], [59725456],
    [2], [4], [128], [16], [134], [59608257],
    [2], [8], [128], [32], [138], [59447087],
    [4], [4], [128], [16], [136], [59477547],
    [4], [8], [128], [32], [140], [59287222],
    [8], [8], [128], [32], [144], [59249179],
    [16], [2], [128], [8], [146], [42547387],
    [16], [4], [128], [16], [148], [42480342],
    [16], [8], [128], [32], [152], [42348777],
    [32], [2], [128], [8], [162], [42278590],
    [32], [4], [128], [16], [164], [42176201],
    [32], [8], [128], [32], [168], [41936302],
    [32], [16], [128], [32], [176], [41922370],
    [32], [16], [256], [32], [304], [41915840],
    [32], [32], [128], [32], [192], [41915945],
    [32], [32], [256], [32], [320], [41910851],
    [32], [64], [512], [32], [608], [41901786],
    [64], [32], [256], [32], [352], [41906326],
    [64], [64], [256], [32], [384], [41904339],
  ),
  caption: "Συγκεντρωτικός πίνακας των pareto-optimal σημείων",
)

\

#figure(
  image("../part2/pareto_optimal.svg", width: 60%),
  caption: "Σύγκριση pareto-optimal σημείων",
)

\

== 5.
\

H ευριστική εξερεύνηση του ίδιου χώρου αναζήτησης ολοκληρώθηκε σε εκθετικά μικρότερο χρόνο και για τον ακριβή αριθμό των evaluations που έγιναν προσθέσαμε μια εκτύπωση της μεταβλητής #emph("result.algorithm.evaluator.n_eval") στο genOptimizer.py η οπόια επέστρεψε αποτέλεσμα *30*.

H συνάρτηση επέστρεψε πολύ λιγότερα pareto-optimal που είναι όμως υποσύνολο της εξαντλητικής αναζήτησης όπως φαίνεται στην συνέχεια:

\

#figure(
  table(
    columns: 6,
    align: center,
    table.header([L1I], [L1D], [L2], [Unrolling Factor], [Total Memory(KB)], [Latency(CC)]),
    [4], [4], [128], [16], [136], [59477547],
    [16], [32], [128], [32], [176], [41922370],
    [4], [32], [128], [8], [164], [42227791],
    [2], [4], [128], [4], [134], [59780093],
  ),
  caption: "Συγκεντρωτικός πίνακας των ευριστικών σημείων",
)

\

Παρατηρούμε ότι δεν βρήκε το βέλτιστο Latency που είναι 41901786CC ούτε την ελάχιστη μνήμη 132kB. Άλλοι συνδυασμοί που δεν εντοπίστηκαν διαφέρουν κυρίως στα unrolling factors που είναι ανεξάρτητο της αρχιτεκτονικής και την συνολικής μνήμης που καλείται ο αλγόριθμος να ελαχιστοποιήσει.
