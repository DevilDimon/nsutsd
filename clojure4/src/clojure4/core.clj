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
  (rest expr))

(defn negation [expr]
  (list ::not expr))

(defn negation? [expr]
  (= ::not (first expr)))

(defn implication [expr1 expr2]
  (list ::implies expr1 expr2))

(defn implication? [expr]
  (= ::implies (first expr)))

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
    ; A->B ==> ¬A∨B
    [(fn [expr] (implication? expr))
     (fn [expr] (disjunction (dnf (negation (first (args expr)))) (dnf (second (args expr)))))]
    ))

(defn -main [& args]
  (println (dnf (implication (variable :a) (variable :b)))))