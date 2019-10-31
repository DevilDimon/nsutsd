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

(defn conjunction [expr & rest]
  (if (empty? rest)
    expr
    (cons ::and (cons expr rest))))

(defn conjunction? [expr]
  (= ::and (first expr)))

(defn disjunction [expr & rest]
  (if (empty? rest)
    expr
    (cons ::or (cons expr rest))))

(defn disjunction? [expr]
  (= ::or (first expr)))

(defn args [expr]
  (rest expr))

(defn negation [expr]
  (list ::not expr))

(defn implication [expr1 expr2]
  (list ::implies expr1 expr2))
