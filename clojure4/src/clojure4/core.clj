(ns clojure4.core)

(defn constant [bool]
  (list ::const bool))

(defn constant? [expr]
  (= (first expr) ::const))

(defn constant-value [const]
  (second const))

(defn variable [name]
  {:pre [(keyword? name)]}
  (list ::var name))

(defn variable? [expr]
  (= (first expr) ::var))

(defn variable-name [v]
  (second v))

(defn same-variables? [v1 v2]
  (and
    (variable? v1)
    (variable? v2)
    (= (variable-name v1)
       (variable-name v2))))

(defn conjunction [expr1 expr2]
  (list ::and expr1 expr2))

(defn conjunction? [expr]
  (= ::and (first expr)))

(defn disjunction [expr1 expr2]
  (list ::or expr1 expr2))

(defn disjunction? [expr]
  (= ::or (first expr)))

(defn args [expr]
  (cond
    (= 2 (count expr)) (rest expr)
    (= 3 (count expr)) (list (second expr) (nth expr 2))))

(defn negation [expr]
  (list ::not expr))

(defn negation? [expr]
  (= ::not (first expr)))

(defn implication [expr1 expr2]
  (list ::implies expr1 expr2))

(defn implication? [expr]
  (= ::implies (first expr)))

(declare dnf-preprocessing-rules)

(defn dnf-preprocess [expr]
  ((some (fn [rule]
           (if ((first rule) expr)
             (second rule)
             false))
         dnf-preprocessing-rules)
   expr))

(def dnf-preprocessing-rules
  (list
    [(fn [expr] (variable? expr))
     (fn [expr] expr)]

    [(fn [expr] (constant? expr))
     (fn [expr] expr)]

    ; A->B ==> ¬A∨B
    [(fn [expr] (implication? expr))
     (fn [expr] (disjunction
                  (dnf-preprocess (negation (first (args expr))))
                  (dnf-preprocess (second (args expr)))))]


    [(fn [expr] (= (count (args expr)) 1))
     (fn [expr] (list (first expr) (dnf-preprocess (first (args expr)))))]

    [(fn [expr] (= (count (args expr)) 2))
     (fn [expr] (list (first expr) (dnf-preprocess (first (args expr))) (dnf-preprocess (second (args expr)))))]
    ))

(declare dnf-rules)

(defn dnf-with-preprocessing [expr]
  (let [preprocessed-expr (dnf-preprocess expr)]
    ;(println preprocessed-expr)
    ((some (fn [rule]
             (if ((first rule) preprocessed-expr)
               (second rule)
               false))
           dnf-rules)
     preprocessed-expr)))

(defn dnf [expr]
    ((some (fn [rule]
             (if ((first rule) expr)
               (second rule)
               false))
           dnf-rules)
     expr))

(def dnf-rules
  (list
    ; A ==> A
    [(fn [expr] (variable? expr))
     (fn [expr] expr)]

    ; ¬A ==> ¬A
    [(fn [expr] (and
                  (negation? expr)
                  (variable? (first (args expr)))))
     (fn [expr] expr)]

    ; ¬(¬A) ==> A
    [(fn [expr] (and
                  (negation? expr)
                  (negation? (first (args expr)))))
     (fn [expr] (dnf (first (args (args expr)))))]

    ; ¬(A∨B) ==> ¬A∧¬B
    [(fn [expr] (and
                  (negation? expr)
                  (disjunction? (first (args expr)))))
     (fn [expr] (dnf (conjunction
                       (negation (first (args (args expr))))
                       (negation (second (args (args expr)))))))]

    ; ¬(A∧B) ==> ¬A∨¬B
    [(fn [expr] (and
                  (negation? expr)
                  (conjunction? (first (args expr)))))
     (fn [expr] (disjunction
                  (dnf (negation (first (args (args expr)))))
                  (dnf (negation (second (args (args expr)))))))]

    [(fn [expr] (negation? expr))
     (fn [expr] (negation (dnf (first (args expr)))))]

    ; (A∨B)∧C ==> (A∧C)∨(B∧C)
    [(fn [expr] (and (conjunction? expr)
                     (disjunction? (first (args expr)))
                     (not (disjunction? (second (args expr))))
                     (not (conjunction? (second (args expr))))))
     (fn [expr] (disjunction
                  (conjunction (first (args (first (args expr)))) (second (args expr)))
                  (conjunction (second (args (first (args expr)))) (second (args expr)))))]

    ; C∧(A∨B) ==> (A∧C)∨(B∧C)
    [(fn [expr] (and
                  (conjunction? expr)
                  (disjunction? (second (args expr)))
                  (not (disjunction? (first (args expr))))
                  (not (conjunction? (first (args expr))))))
     (fn [expr] (disjunction
                  (conjunction (first (args (second (args expr)))) (first (args expr)))
                  (conjunction (second (args (second (args expr)))) (first (args expr)))))]

    ; (C∨D)∧(A∧B) ==> (A∧(B∧C))∨(A∧(B∧D))
    [(fn [expr] (and
                  (conjunction? expr)
                  (disjunction? (first (args expr)))
                  (conjunction? (second (args expr)))))
     (fn [expr] (let [first-first-arg (first (args (first (args expr))))
                      second-first-arg (second (args (first (args expr))))
                      first-second-arg (first (args (second (args expr))))
                      second-second-arg (second (args (second (args expr))))]
                  (disjunction
                    (conjunction first-second-arg (conjunction second-second-arg first-first-arg))
                    (conjunction first-second-arg (conjunction second-second-arg second-first-arg)))))]

    ; (A∧B)∧(C∨D) ==> (A∧(B∧C))∨(A∧(B∧D))
    [(fn [expr] (and
                  (conjunction? expr)
                  (conjunction? (first (args expr)))
                  (disjunction? (second (args expr)))))
     (fn [expr] (let [first-first-arg (first (args (first (args expr))))
                      second-first-arg (second (args (first (args expr))))
                      first-second-arg (first (args (second (args expr))))
                      second-second-arg (second (args (second (args expr))))]
                  (disjunction
                    (conjunction first-first-arg (conjunction second-first-arg first-second-arg))
                    (conjunction first-first-arg (conjunction second-first-arg second-second-arg)))))]

    ; (A∨B)∧(C∨D) ==> ((A∧C)∨(A∧D))∨((B∧C)∨(B∧D))
    [(fn [expr] (and
                  (conjunction? expr)
                  (disjunction? (first (args expr)))
                  (disjunction? (second (args (expr))))))
     (fn [expr] (let [first-first-arg (first (args (first (args expr))))
                      second-first-arg (second (args (first (args expr))))
                      first-second-arg (first (args (second (args expr))))
                      second-second-arg (second (args (second (args expr))))]
                  (disjunction
                    (disjunction
                      (conjunction first-first-arg first-second-arg)
                      (conjunction first-first-arg second-second-arg))
                    (disjunction
                      (conjunction second-first-arg first-second-arg)
                      (conjunction second-first-arg second-second-arg)))))]

    ; A∧B ==> A∧B
    [(fn [expr] (conjunction? expr))
     (fn [expr] (conjunction (dnf (first (args expr))) (dnf (second (args expr)))))]

    ; A∨B ==> A∨B
    [(fn [expr] (disjunction? expr))
     (fn [expr] (disjunction (dnf (first (args expr))) (dnf (second (args expr)))))]
    ))

; TODO: Use wikipedia examples to test all DNF transforms from there.
; TODO: Add support for constants
; TODO: Add support for variable substitutions
(defn -main [& args]
  (println (dnf-with-preprocessing (negation (disjunction (implication (variable :x) (variable :y))
                                       (negation (implication (variable :y) (variable :z))))))))