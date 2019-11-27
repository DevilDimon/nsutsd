(ns clojure4.core)

(defn constant [bool]
  {:pre [(boolean? bool)]}
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
  (rest expr))

(defn negation [expr]
  (list ::not expr))

(defn negation? [expr]
  (= ::not (first expr)))

(defn implication [expr1 expr2]
  (disjunction (negation expr1) expr2))

(declare dnf-rules)

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
    [(fn [expr] (or
                  (variable? expr)
                  (constant? expr)))
     (fn [expr] expr)]

    ; ¬true ==> false
    ; ¬false ==> true
    [(fn [expr] (and
                  (negation? expr)
                  (constant? (first (args expr)))))
     (fn [expr] (constant (not (constant-value (first (args expr))))))]

    ; ¬A ==> ¬A
    [(fn [expr] (and
                  (negation? expr)
                  (variable? (first (args expr)))))
     (fn [expr] expr)]

    ; ¬(¬A) ==> A
    [(fn [expr] (and
                  (negation? expr)
                  (negation? (first (args expr)))))
     (fn [expr] (dnf (first (args (first (args expr))))))]

    ; ¬(A∨B) ==> ¬A∧¬B
    [(fn [expr] (and
                  (negation? expr)
                  (disjunction? (first (args expr)))))
     (fn [expr] (dnf (conjunction
                       (dnf (negation (first (args (first (args expr))))))
                       (dnf (negation (second (args (first (args expr)))))))))]

    ; ¬(A∧B) ==> ¬A∨¬B
    [(fn [expr] (and
                  (negation? expr)
                  (conjunction? (first (args expr)))))
     (fn [expr] (dnf (disjunction
                       (dnf (negation (first (args (first (args expr))))))
                       (dnf (negation (second (args (first (args expr)))))))))]

    [(fn [expr] (negation? expr))
     (fn [expr] (negation (dnf (first (args expr)))))]

    ; (A∨B)∧C ==> (A∧C)∨(B∧C)
    [(fn [expr] (and (conjunction? expr)
                     (disjunction? (first (args expr)))
                     (not (disjunction? (second (args expr))))
                     (not (conjunction? (second (args expr))))))
     (fn [expr] (dnf (disjunction
                  (conjunction (first (args (first (args expr)))) (second (args expr)))
                  (conjunction (second (args (first (args expr)))) (second (args expr))))))]

    ; C∧(A∨B) ==> (A∧C)∨(B∧C)
    [(fn [expr] (and
                  (conjunction? expr)
                  (disjunction? (second (args expr)))
                  (not (disjunction? (first (args expr))))
                  (not (conjunction? (first (args expr))))))
     (fn [expr] (dnf (disjunction
                  (conjunction (first (args (second (args expr)))) (first (args expr)))
                  (conjunction (second (args (second (args expr)))) (first (args expr))))))]

    ; (C∨D)∧(A∧B) ==> (A∧(B∧C))∨(A∧(B∧D))
    [(fn [expr] (and
                  (conjunction? expr)
                  (disjunction? (first (args expr)))
                  (conjunction? (second (args expr)))))
     (fn [expr] (let [first-first-arg (first (args (first (args expr))))
                      second-first-arg (second (args (first (args expr))))
                      first-second-arg (first (args (second (args expr))))
                      second-second-arg (second (args (second (args expr))))]
                  (dnf (disjunction
                    (conjunction first-second-arg (conjunction second-second-arg first-first-arg))
                    (conjunction first-second-arg (conjunction second-second-arg second-first-arg))))))]

    ; (A∧B)∧(C∨D) ==> (A∧(B∧C))∨(A∧(B∧D))
    [(fn [expr] (and
                  (conjunction? expr)
                  (conjunction? (first (args expr)))
                  (disjunction? (second (args expr)))))
     (fn [expr] (let [first-first-arg (first (args (first (args expr))))
                      second-first-arg (second (args (first (args expr))))
                      first-second-arg (first (args (second (args expr))))
                      second-second-arg (second (args (second (args expr))))]
                  (dnf (disjunction
                    (conjunction first-first-arg (conjunction second-first-arg first-second-arg))
                    (conjunction first-first-arg (conjunction second-first-arg second-second-arg))))))]

    ; (A∨B)∧(C∨D) ==> ((A∧C)∨(A∧D))∨((B∧C)∨(B∧D))
    [(fn [expr] (and
                  (conjunction? expr)
                  (disjunction? (first (args expr)))
                  (disjunction? (second (args expr)))))
     (fn [expr] (let [first-first-arg (first (args (first (args expr))))
                      second-first-arg (second (args (first (args expr))))
                      first-second-arg (first (args (second (args expr))))
                      second-second-arg (second (args (second (args expr))))]
                  (dnf (disjunction
                    (disjunction
                      (conjunction first-first-arg first-second-arg)
                      (conjunction first-first-arg second-second-arg))
                    (disjunction
                      (conjunction second-first-arg first-second-arg)
                      (conjunction second-first-arg second-second-arg))))))]

    ; A∧A, A∨A ==> A
    [(fn [expr] (and
                  (or (conjunction? expr) (disjunction? expr))
                  (variable? (first (args expr)))
                  (variable? (second (args expr)))
                  (same-variables? (first (args expr)) (second (args expr)))))
     (fn [expr] (first (args expr)))]

    ; ¬A∧¬A, ¬A∨¬A ==> ¬A
    [(fn [expr] (and
                  (or (conjunction? expr) (disjunction? expr))
                  (negation? (first (args expr)))
                  (variable? (first (args (first (args expr)))))
                  (negation? (second (args expr)))
                  (variable? (first (args (second (args expr)))))
                  (same-variables? (first (args (first (args expr)))) (first (args (second (args expr)))))))
     (fn [expr] (first (args expr)))]

    ; A∧B ==> A∧B
    [(fn [expr] (conjunction? expr))
     (fn [expr] (conjunction (dnf (first (args expr))) (dnf (second (args expr)))))]

    ; A∨B ==> A∨B
    [(fn [expr] (disjunction? expr))
     (fn [expr] (disjunction (dnf (first (args expr))) (dnf (second (args expr)))))]
    ))

(declare var-substitution-rules)

(defn substitute-vars [expr varmap]
  ((some (fn [rule]
           (if ((first rule) expr varmap)
             (second rule)
             false))
         var-substitution-rules)
   expr varmap))

(def var-substitution-rules
  (list
    ; Substitute a variable with its value
    [(fn [expr varmap] (and
                         (variable? expr)
                         (not (nil? (varmap (variable-name expr))))))
     (fn [expr varmap] (constant (varmap (variable-name expr))))]

    ; Leave unmentioned variables & constants intact
    [(fn [expr _] (or (variable? expr) (constant? expr)))
     (fn [expr _] expr)]

    ; Evaluate recursively. Should be rewritten if proper multiple args are implemented
    [(fn [expr _] (= (count (args expr)) 1))
     (fn [expr varmap] (list (first expr) (substitute-vars (first (args expr)) varmap)))]

    [(fn [expr _] (= (count (args expr)) 2))
     (fn [expr varmap] (list
                         (first expr)
                         (substitute-vars (first (args expr)) varmap)
                         (substitute-vars (second (args expr)) varmap)))]
    ))

(defn- in?
  "true if coll contains elm"
  [coll elm]
  (some #(= elm %) coll))

(defn- collapse-conj [exprs]
  (let [consts (filter constant? exprs)
        vars (filter (fn [expr] (or (variable? expr) (negation? expr))) exprs)
        combined-const (reduce (fn [acc entry] (and acc (constant-value entry))) true consts)
        combined-vars (reverse (reduce (fn [acc entry]
                                (if (not (in? acc entry))
                                  (cons entry acc)
                                  acc))
                              () vars))]
    (cond
      (= combined-const true)
        (if (empty? combined-vars)
          (list (constant true))
          combined-vars)
      :default
        (cons (constant combined-const) combined-vars))
    ))

(defn- collapse-disj [exprs]
  (let [consts (filter constant? exprs)
        vars (filter (fn [expr] (or (variable? expr) (negation? expr))) exprs)
        combined-const (reduce (fn [acc entry] (or acc (constant-value entry))) false consts)
        combined-vars (reverse (reduce (fn [acc entry]
                                         (if (not (in? acc entry))
                                           (cons entry acc)
                                           acc))
                                       () vars))
        other-exprs (remove (fn [expr] (or (constant? expr) (variable? expr) (negation? expr))) exprs)]
    (cond
      (= combined-const false)
        (if (and (empty? combined-vars) (empty? other-exprs))
          (list (constant false))
          (concat combined-vars other-exprs))
      :default
        (cons (constant combined-const) (concat combined-vars other-exprs)))
    ))

(defn conjunction-mult [expr & rest]
  (let [normalized-exprs
        (collapse-conj (cons expr rest))]
    (if (= 1 (count normalized-exprs))
      (first normalized-exprs)
      (cons ::and-mult normalized-exprs))))

(defn disjunction-mult [expr & rest]
  (let [normalized-exprs
        (collapse-disj (cons expr rest))]
    (if (= 1 (count normalized-exprs))
      (first normalized-exprs)
      (cons ::or-mult normalized-exprs))))

(defn disjunction-mult? [expr]
  (= (first expr) ::or-mult))

(declare mult-rules)

(defn transform-to-mult [expr]
  ((some (fn [rule]
           (if ((first rule) expr)
             (second rule)
             false))
         mult-rules)
   expr))

(def mult-rules
  (list
    [(fn [expr] (disjunction? expr))
     (fn [expr] (letfn [(transform-disj-to-mult [cur result]
                        (cond
                          (disjunction? cur) (transform-disj-to-mult
                                               (first (args cur))
                                               (transform-disj-to-mult (second (args cur)) result))
                          :default (cons cur result)))]
                  (transform-to-mult (cons ::or-mult (transform-disj-to-mult expr ())))))]

    [(fn [expr] (disjunction-mult? expr))
     (fn [expr] (apply disjunction-mult
                       (map transform-to-mult (args expr))))]

    [(fn [expr] (conjunction? expr))
     (fn [expr] (letfn [(transform-conj-to-mult [cur result]
                            (cond
                              (conjunction? cur) (transform-conj-to-mult
                                                   (first (args cur))
                                                   (transform-conj-to-mult (second (args cur)) result))
                              :default (cons cur result)))]
                  (transform-to-mult (apply conjunction-mult
                                            (transform-conj-to-mult expr ())))))]

    [(fn [_] true)
     (fn [expr] expr)]
    ))

(defn final-dnf
  ([expr] (transform-to-mult (dnf expr)))
  ([expr varmap]
    (transform-to-mult (dnf (substitute-vars (dnf expr) varmap)))))

; TODO: Document APIs
(defn -main [& args]
  (println (= (variable :a) (variable :b))))